-- DESBRAV Authentication & User Management Module Migration
-- Migration: 20250713081000_desbrav_auth_module.sql

-- 1. Create custom types
CREATE TYPE public.user_role AS ENUM ('admin', 'moderator', 'rider');
CREATE TYPE public.motorcycle_brand AS ENUM (
    'honda', 'yamaha', 'kawasaki', 'suzuki', 'bmw', 'ducati', 
    'harley_davidson', 'triumph', 'ktm', 'aprilia', 'other'
);

-- 2. User profiles table (intermediary for auth relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    date_of_birth DATE,
    
    -- User settings
    role public.user_role DEFAULT 'rider'::public.user_role,
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Motorcycle information
    motorcycle_brand public.motorcycle_brand,
    motorcycle_model TEXT,
    motorcycle_year INTEGER CHECK (motorcycle_year >= 1980 AND motorcycle_year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    motorcycle_displacement INTEGER CHECK (motorcycle_displacement >= 50 AND motorcycle_displacement <= 3000),
    
    -- Location and preferences
    city TEXT,
    state TEXT,
    country TEXT DEFAULT 'Brasil',
    timezone TEXT DEFAULT 'America/Sao_Paulo',
    
    -- Privacy settings
    profile_visibility TEXT DEFAULT 'public' CHECK (profile_visibility IN ('public', 'friends', 'private')),
    show_location BOOLEAN DEFAULT true,
    allow_friend_requests BOOLEAN DEFAULT true,
    
    -- Gamification data
    level INTEGER DEFAULT 1 CHECK (level >= 1),
    total_xp INTEGER DEFAULT 0 CHECK (total_xp >= 0),
    total_distance DECIMAL(10,2) DEFAULT 0 CHECK (total_distance >= 0),
    total_rides INTEGER DEFAULT 0 CHECK (total_rides >= 0),
    total_cities_visited INTEGER DEFAULT 0 CHECK (total_cities_visited >= 0),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_active_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_phone CHECK (phone IS NULL OR phone ~* '^\+?[1-9]\d{1,14}$')
);

-- 3. Create indexes for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_full_name ON public.user_profiles(full_name);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_is_active ON public.user_profiles(is_active);
CREATE INDEX idx_user_profiles_level ON public.user_profiles(level);
CREATE INDEX idx_user_profiles_created_at ON public.user_profiles(created_at);
CREATE INDEX idx_user_profiles_last_active ON public.user_profiles(last_active_at);

-- 4. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- 5. Helper functions for RLS policies
CREATE OR REPLACE FUNCTION public.is_profile_owner(profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = profile_id AND up.id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin_user()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

CREATE OR REPLACE FUNCTION public.can_view_profile(profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = profile_id AND (
        up.profile_visibility = 'public' OR
        up.id = auth.uid() OR
        public.is_admin_user()
    )
)
$$;

-- 6. RLS policies
CREATE POLICY "users_can_view_public_profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (public.can_view_profile(id));

CREATE POLICY "users_can_manage_own_profile"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_profile_owner(id))
WITH CHECK (public.is_profile_owner(id));

CREATE POLICY "admins_can_manage_all_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

-- 7. Function to automatically create user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    user_full_name TEXT;
    user_role public.user_role;
BEGIN
    -- Extract full name and role from metadata
    user_full_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        split_part(NEW.email, '@', 1)
    );
    
    user_role := COALESCE(
        (NEW.raw_user_meta_data->>'role')::public.user_role,
        'rider'::public.user_role
    );

    -- Create user profile
    INSERT INTO public.user_profiles (
        id, 
        email, 
        full_name,
        first_name,
        last_name,
        role,
        avatar_url
    )
    VALUES (
        NEW.id,
        NEW.email,
        user_full_name,
        NEW.raw_user_meta_data->>'first_name',
        NEW.raw_user_meta_data->>'last_name',
        user_role,
        NEW.raw_user_meta_data->>'avatar_url'
    );

    RETURN NEW;
END;
$$;

-- 8. Trigger for automatic profile creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 9. Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 10. Trigger for updated_at
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 11. Function to calculate user level from XP
CREATE OR REPLACE FUNCTION public.calculate_user_level(total_xp INTEGER)
RETURNS INTEGER
LANGUAGE sql
STABLE
AS $$
SELECT GREATEST(1, (total_xp / 1000) + 1);
$$;

-- 12. Function to update user level automatically
CREATE OR REPLACE FUNCTION public.update_user_level()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.level = public.calculate_user_level(NEW.total_xp);
    RETURN NEW;
END;
$$;

-- 13. Trigger for automatic level calculation
CREATE TRIGGER update_user_level_trigger
    BEFORE UPDATE OF total_xp ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_user_level();

-- 14. Mock data for development
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    rider1_uuid UUID := gen_random_uuid();
    rider2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@desbrav.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Carlos Admin Santos", "first_name": "Carlos", "last_name": "Santos", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (rider1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'rider@desbrav.com', crypt('rider123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Maria Oliveira Silva", "first_name": "Maria", "last_name": "Silva"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (rider2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'joao@desbrav.com', crypt('joao123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "João Carlos Mendes", "first_name": "João", "last_name": "Mendes"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update user profiles with motorcycle and location data
    UPDATE public.user_profiles SET
        motorcycle_brand = 'honda'::public.motorcycle_brand,
        motorcycle_model = 'CB 600F Hornet',
        motorcycle_year = 2020,
        motorcycle_displacement = 600,
        city = 'São Paulo',
        state = 'SP',
        total_xp = 2450,
        total_distance = 15420.50,
        total_rides = 87,
        total_cities_visited = 12,
        is_verified = true
    WHERE id = admin_uuid;

    UPDATE public.user_profiles SET
        motorcycle_brand = 'yamaha'::public.motorcycle_brand,
        motorcycle_model = 'MT-07',
        motorcycle_year = 2019,
        motorcycle_displacement = 689,
        city = 'Rio de Janeiro',
        state = 'RJ',
        total_xp = 1800,
        total_distance = 8950.75,
        total_rides = 45,
        total_cities_visited = 8
    WHERE id = rider1_uuid;

    UPDATE public.user_profiles SET
        motorcycle_brand = 'kawasaki'::public.motorcycle_brand,
        motorcycle_model = 'Ninja 650',
        motorcycle_year = 2021,
        motorcycle_displacement = 649,
        city = 'Belo Horizonte',
        state = 'MG',
        total_xp = 3200,
        total_distance = 22100.00,
        total_rides = 102,
        total_cities_visited = 18
    WHERE id = rider2_uuid;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 15. Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_test_users()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    test_user_ids UUID[];
BEGIN
    -- Get test user IDs
    SELECT ARRAY_AGG(id) INTO test_user_ids
    FROM auth.users
    WHERE email LIKE '%@desbrav.com';

    -- Delete user profiles first (triggers will handle the rest)
    DELETE FROM public.user_profiles WHERE id = ANY(test_user_ids);

    -- Delete auth users last
    DELETE FROM auth.users WHERE id = ANY(test_user_ids);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;