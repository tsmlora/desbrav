-- Statistics and Community Module Migration
-- Migration: 20250713084000_statistics_and_community_module.sql
-- Module: User statistics tracking, daily/historical data, and community groups

-- 1. Create custom types for statistics and community
CREATE TYPE public.statistic_type AS ENUM (
    'daily_distance', 'daily_time', 'daily_avg_speed', 'daily_max_speed',
    'daily_rides', 'daily_xp', 'weekly_summary', 'monthly_summary'
);

CREATE TYPE public.group_category AS ENUM (
    'sport', 'touring', 'adventure', 'cruiser', 'scooter', 'vintage', 'general'
);

CREATE TYPE public.group_visibility AS ENUM (
    'public', 'private', 'invite_only'
);

CREATE TYPE public.member_role AS ENUM (
    'owner', 'admin', 'moderator', 'member'
);

-- 2. User daily statistics table
CREATE TABLE public.user_daily_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Distance metrics
    total_distance DECIMAL(10,2) DEFAULT 0 CHECK (total_distance >= 0),
    total_time_minutes INTEGER DEFAULT 0 CHECK (total_time_minutes >= 0),
    average_speed DECIMAL(5,2) DEFAULT 0 CHECK (average_speed >= 0),
    max_speed DECIMAL(5,2) DEFAULT 0 CHECK (max_speed >= 0),
    
    -- Ride metrics
    total_rides INTEGER DEFAULT 0 CHECK (total_rides >= 0),
    longest_ride_distance DECIMAL(10,2) DEFAULT 0,
    longest_ride_time_minutes INTEGER DEFAULT 0,
    
    -- XP and achievements
    xp_earned INTEGER DEFAULT 0 CHECK (xp_earned >= 0),
    achievements_unlocked INTEGER DEFAULT 0 CHECK (achievements_unlocked >= 0),
    
    -- Exploration metrics
    cities_visited INTEGER DEFAULT 0 CHECK (cities_visited >= 0),
    new_places_discovered INTEGER DEFAULT 0 CHECK (new_places_discovered >= 0),
    fuel_stops INTEGER DEFAULT 0 CHECK (fuel_stops >= 0),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(user_id, date)
);

-- 3. Community groups table
CREATE TABLE public.community_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    
    -- Group settings
    category public.group_category DEFAULT 'general'::public.group_category,
    visibility public.group_visibility DEFAULT 'public'::public.group_visibility,
    
    -- Location data
    city TEXT,
    state TEXT,
    country TEXT DEFAULT 'Brasil',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    radius_km INTEGER DEFAULT 50, -- Group's activity radius
    
    -- Group details
    cover_image_url TEXT,
    rules TEXT,
    meeting_location TEXT,
    meeting_schedule TEXT,
    
    -- Statistics
    member_count INTEGER DEFAULT 1 CHECK (member_count >= 0),
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    
    -- Motorcycle focus
    motorcycle_types TEXT[], -- Array of motorcycle types this group focuses on
    min_engine_size INTEGER, -- Minimum engine size requirement
    experience_level TEXT, -- beginner, intermediate, advanced, expert
    
    -- Management
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

-- 4. Group memberships table
CREATE TABLE public.group_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES public.community_groups(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Membership details
    role public.member_role DEFAULT 'member'::public.member_role,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    -- Notifications
    receive_notifications BOOLEAN DEFAULT true,
    
    -- Statistics
    messages_sent INTEGER DEFAULT 0 CHECK (messages_sent >= 0),
    events_attended INTEGER DEFAULT 0 CHECK (events_attended >= 0),
    
    -- Metadata
    invited_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(group_id, user_id)
);

-- 5. Group events table
CREATE TABLE public.group_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES public.community_groups(id) ON DELETE CASCADE,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Event details
    title TEXT NOT NULL,
    description TEXT,
    event_date TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER DEFAULT 240, -- Default 4 hours
    
    -- Location
    meeting_point TEXT NOT NULL,
    meeting_latitude DECIMAL(10, 8),
    meeting_longitude DECIMAL(11, 8),
    destination TEXT,
    route_description TEXT,
    estimated_distance DECIMAL(10,2),
    
    -- Participation
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT true,
    requires_rsvp BOOLEAN DEFAULT true,
    
    -- Status
    is_cancelled BOOLEAN DEFAULT false,
    cancellation_reason TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_event_date CHECK (event_date > CURRENT_TIMESTAMP),
    CONSTRAINT valid_participants CHECK (
        max_participants IS NULL OR 
        (max_participants > 0 AND current_participants <= max_participants)
    )
);

-- 6. User ride sessions table (for detailed tracking)
CREATE TABLE public.ride_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Session timing
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    
    -- Distance and speed
    total_distance DECIMAL(10,2) DEFAULT 0,
    average_speed DECIMAL(5,2) DEFAULT 0,
    max_speed DECIMAL(5,2) DEFAULT 0,
    
    -- Route data
    start_latitude DECIMAL(10, 8),
    start_longitude DECIMAL(11, 8),
    end_latitude DECIMAL(10, 8),
    end_longitude DECIMAL(11, 8),
    route_points JSONB, -- Array of GPS coordinates
    
    -- Cities and places visited
    cities_visited TEXT[],
    places_visited TEXT[],
    fuel_stops INTEGER DEFAULT 0,
    
    -- Session metadata
    weather_conditions TEXT,
    temperature_celsius INTEGER,
    motorcycle_used TEXT, -- Brand and model
    
    -- Gamification
    xp_earned INTEGER DEFAULT 0,
    achievements_unlocked TEXT[], -- Array of achievement IDs
    
    -- Status
    is_completed BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false, -- For preventing fake data
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Essential indexes for performance
CREATE INDEX idx_user_daily_statistics_user_date ON public.user_daily_statistics(user_id, date DESC);
CREATE INDEX idx_user_daily_statistics_date ON public.user_daily_statistics(date DESC);

CREATE INDEX idx_community_groups_location ON public.community_groups(city, state) WHERE city IS NOT NULL;
CREATE INDEX idx_community_groups_category ON public.community_groups(category);
CREATE INDEX idx_community_groups_visibility ON public.community_groups(visibility);
CREATE INDEX idx_community_groups_coords ON public.community_groups(latitude, longitude) WHERE latitude IS NOT NULL;
CREATE INDEX idx_community_groups_member_count ON public.community_groups(member_count DESC);

CREATE INDEX idx_group_memberships_user_id ON public.group_memberships(user_id);
CREATE INDEX idx_group_memberships_group_id ON public.group_memberships(group_id);
CREATE INDEX idx_group_memberships_active ON public.group_memberships(is_active) WHERE is_active = true;

CREATE INDEX idx_group_events_group_id ON public.group_events(group_id);
CREATE INDEX idx_group_events_date ON public.group_events(event_date);
CREATE INDEX idx_group_events_public ON public.group_events(is_public) WHERE is_public = true;

CREATE INDEX idx_ride_sessions_user_id ON public.ride_sessions(user_id);
CREATE INDEX idx_ride_sessions_started_at ON public.ride_sessions(started_at DESC);
CREATE INDEX idx_ride_sessions_completed ON public.ride_sessions(is_completed) WHERE is_completed = true;

-- 8. Enable RLS
ALTER TABLE public.user_daily_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ride_sessions ENABLE ROW LEVEL SECURITY;

-- 9. Helper functions for RLS policies
CREATE OR REPLACE FUNCTION public.can_view_user_statistics(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = target_user_id AND (
        up.id = auth.uid() OR
        up.profile_visibility = 'public' OR
        public.is_admin_user()
    )
)
$$;

CREATE OR REPLACE FUNCTION public.is_group_member(group_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.group_memberships gm
    WHERE gm.group_id = group_uuid 
    AND gm.user_id = auth.uid() 
    AND gm.is_active = true
)
$$;

CREATE OR REPLACE FUNCTION public.can_view_group(group_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.community_groups cg
    WHERE cg.id = group_uuid AND (
        cg.visibility = 'public' OR
        public.is_group_member(group_uuid) OR
        public.is_admin_user()
    )
)
$$;

CREATE OR REPLACE FUNCTION public.can_manage_group(group_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.group_memberships gm
    WHERE gm.group_id = group_uuid 
    AND gm.user_id = auth.uid() 
    AND gm.role IN ('owner', 'admin') 
    AND gm.is_active = true
) OR public.is_admin_user()
$$;

-- 10. RLS policies for user statistics
CREATE POLICY "users_can_view_accessible_statistics"
ON public.user_daily_statistics
FOR SELECT
TO authenticated
USING (public.can_view_user_statistics(user_id));

CREATE POLICY "users_can_manage_own_statistics"
ON public.user_daily_statistics
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 11. RLS policies for community groups
CREATE POLICY "anyone_can_view_public_groups"
ON public.community_groups
FOR SELECT
TO public
USING (visibility = 'public');

CREATE POLICY "members_can_view_accessible_groups"
ON public.community_groups
FOR SELECT
TO authenticated
USING (public.can_view_group(id));

CREATE POLICY "authenticated_users_can_create_groups"
ON public.community_groups
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "group_managers_can_edit_groups"
ON public.community_groups
FOR UPDATE
TO authenticated
USING (public.can_manage_group(id))
WITH CHECK (public.can_manage_group(id));

-- 12. RLS policies for group memberships
CREATE POLICY "members_can_view_group_memberships"
ON public.group_memberships
FOR SELECT
TO authenticated
USING (
    auth.uid() = user_id OR 
    public.is_group_member(group_id) OR 
    public.is_admin_user()
);

CREATE POLICY "users_can_join_groups"
ON public.group_memberships
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_manage_own_membership"
ON public.group_memberships
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id OR public.can_manage_group(group_id))
WITH CHECK (auth.uid() = user_id OR public.can_manage_group(group_id));

CREATE POLICY "users_can_leave_groups"
ON public.group_memberships
FOR DELETE
TO authenticated
USING (auth.uid() = user_id OR public.can_manage_group(group_id));

-- 13. RLS policies for ride sessions
CREATE POLICY "users_can_view_accessible_ride_sessions"
ON public.ride_sessions
FOR SELECT
TO authenticated
USING (public.can_view_user_statistics(user_id));

CREATE POLICY "users_can_manage_own_ride_sessions"
ON public.ride_sessions
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 14. Functions to update group member count
CREATE OR REPLACE FUNCTION public.update_group_member_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.is_active = true THEN
        UPDATE public.community_groups
        SET member_count = member_count + 1,
            last_activity_at = CURRENT_TIMESTAMP
        WHERE id = NEW.group_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.is_active = false AND NEW.is_active = true THEN
            -- Member rejoining
            UPDATE public.community_groups
            SET member_count = member_count + 1,
                last_activity_at = CURRENT_TIMESTAMP
            WHERE id = NEW.group_id;
        ELSIF OLD.is_active = true AND NEW.is_active = false THEN
            -- Member leaving
            UPDATE public.community_groups
            SET member_count = GREATEST(0, member_count - 1),
                last_activity_at = CURRENT_TIMESTAMP
            WHERE id = NEW.group_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.is_active = true THEN
        UPDATE public.community_groups
        SET member_count = GREATEST(0, member_count - 1),
            last_activity_at = CURRENT_TIMESTAMP
        WHERE id = OLD.group_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- 15. Function to aggregate daily statistics
CREATE OR REPLACE FUNCTION public.aggregate_daily_statistics()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_date DATE;
    session_user_id UUID;
BEGIN
    -- Get the session data
    session_user_id := COALESCE(NEW.user_id, OLD.user_id);
    target_date := COALESCE(NEW.started_at, OLD.started_at)::DATE;
    
    IF TG_OP IN ('INSERT', 'UPDATE') AND NEW.is_completed = true THEN
        -- Recalculate daily statistics for the user and date
        INSERT INTO public.user_daily_statistics (
            user_id, date, total_distance, total_time_minutes, 
            average_speed, max_speed, total_rides, xp_earned,
            longest_ride_distance, longest_ride_time_minutes
        )
        SELECT 
            session_user_id,
            target_date,
            SUM(total_distance),
            SUM(duration_minutes),
            AVG(average_speed),
            MAX(max_speed),
            COUNT(*),
            SUM(xp_earned),
            MAX(total_distance),
            MAX(duration_minutes)
        FROM public.ride_sessions
        WHERE user_id = session_user_id 
        AND started_at::DATE = target_date 
        AND is_completed = true
        ON CONFLICT (user_id, date) DO UPDATE SET
            total_distance = EXCLUDED.total_distance,
            total_time_minutes = EXCLUDED.total_time_minutes,
            average_speed = EXCLUDED.average_speed,
            max_speed = EXCLUDED.max_speed,
            total_rides = EXCLUDED.total_rides,
            xp_earned = EXCLUDED.xp_earned,
            longest_ride_distance = EXCLUDED.longest_ride_distance,
            longest_ride_time_minutes = EXCLUDED.longest_ride_time_minutes,
            updated_at = CURRENT_TIMESTAMP;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- 16. Triggers for automatic updates
CREATE TRIGGER update_group_member_count_on_insert
    AFTER INSERT ON public.group_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_group_member_count();

CREATE TRIGGER update_group_member_count_on_update
    AFTER UPDATE ON public.group_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_group_member_count();

CREATE TRIGGER update_group_member_count_on_delete
    AFTER DELETE ON public.group_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_group_member_count();

CREATE TRIGGER aggregate_daily_statistics_on_insert
    AFTER INSERT ON public.ride_sessions
    FOR EACH ROW EXECUTE FUNCTION public.aggregate_daily_statistics();

CREATE TRIGGER aggregate_daily_statistics_on_update
    AFTER UPDATE ON public.ride_sessions
    FOR EACH ROW EXECUTE FUNCTION public.aggregate_daily_statistics();

-- 17. Function to update updated_at timestamp
CREATE TRIGGER update_user_daily_statistics_updated_at
    BEFORE UPDATE ON public.user_daily_statistics
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_community_groups_updated_at
    BEFORE UPDATE ON public.community_groups
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_group_memberships_updated_at
    BEFORE UPDATE ON public.group_memberships
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_group_events_updated_at
    BEFORE UPDATE ON public.group_events
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_ride_sessions_updated_at
    BEFORE UPDATE ON public.ride_sessions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 18. Mock data for development and testing
DO $$
DECLARE
    admin_user_id UUID;
    rider_user_id UUID;
    joao_user_id UUID;
    group1_id UUID := gen_random_uuid();
    group2_id UUID := gen_random_uuid();
    group3_id UUID := gen_random_uuid();
    session1_id UUID := gen_random_uuid();
    session2_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user IDs
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE email = 'admin@desbrav.com' LIMIT 1;
    SELECT id INTO rider_user_id FROM public.user_profiles WHERE email = 'rider@desbrav.com' LIMIT 1;
    SELECT id INTO joao_user_id FROM public.user_profiles WHERE email = 'joao@desbrav.com' LIMIT 1;

    -- Insert community groups with location-based data
    INSERT INTO public.community_groups (
        id, name, description, category, visibility, city, state, country,
        latitude, longitude, radius_km, cover_image_url, member_count,
        motorcycle_types, experience_level, created_by, is_verified
    ) VALUES
        (group1_id, 'Motociclistas São Paulo', 
         'Grupo para motociclistas da região metropolitana de São Paulo',
         'general'::public.group_category, 'public'::public.group_visibility,
         'São Paulo', 'SP', 'Brasil', -23.5505, -46.6333, 50,
         'https://images.pexels.com/photos/163210/motorcycles-race-helmets-pilots-163210.jpeg',
         1, ARRAY['sport', 'touring', 'adventure'], 'intermediate', admin_user_id, true),
         
        (group2_id, 'Adventure Riders Rio', 
         'Aventureiros de moto explorando o Rio de Janeiro e arredores',
         'adventure'::public.group_category, 'public'::public.group_visibility,
         'Rio de Janeiro', 'RJ', 'Brasil', -22.9068, -43.1729, 75,
         'https://images.pexels.com/photos/1119796/pexels-photo-1119796.jpeg',
         1, ARRAY['adventure', 'touring'], 'beginner', rider_user_id, false),
         
        (group3_id, 'Trilheiros BH', 
         'Grupo focado em trilhas e aventuras em Belo Horizonte',
         'adventure'::public.group_category, 'public'::public.group_visibility,
         'Belo Horizonte', 'MG', 'Brasil', -19.9167, -43.9345, 60,
         'https://images.pexels.com/photos/2116475/pexels-photo-2116475.jpeg',
         1, ARRAY['adventure', 'sport'], 'advanced', joao_user_id, false);

    -- Insert group memberships
    INSERT INTO public.group_memberships (group_id, user_id, role)
    VALUES
        (group1_id, admin_user_id, 'owner'::public.member_role),
        (group2_id, rider_user_id, 'owner'::public.member_role),
        (group3_id, joao_user_id, 'owner'::public.member_role),
        (group1_id, rider_user_id, 'member'::public.member_role),
        (group1_id, joao_user_id, 'member'::public.member_role);

    -- Insert ride sessions for realistic statistics
    INSERT INTO public.ride_sessions (
        id, user_id, started_at, ended_at, duration_minutes, total_distance,
        average_speed, max_speed, start_latitude, start_longitude,
        end_latitude, end_longitude, cities_visited, fuel_stops,
        xp_earned, is_completed, is_verified
    ) VALUES
        (session1_id, admin_user_id,
         CURRENT_TIMESTAMP - INTERVAL '2 hours',
         CURRENT_TIMESTAMP - INTERVAL '30 minutes',
         90, 127.5, 46.3, 89.2,
         -23.5505, -46.6333, -23.5489, -46.6388,
         ARRAY['São Paulo'], 1, 85, true, true),
         
        (session2_id, rider_user_id,
         CURRENT_TIMESTAMP - INTERVAL '1 day',
         CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '3 hours',
         180, 245.8, 52.1, 95.4,
         -22.9068, -43.1729, -22.8568, -43.2096,
         ARRAY['Rio de Janeiro', 'Niterói'], 2, 140, true, true);

    -- Insert daily statistics (will be auto-calculated by triggers)
    INSERT INTO public.user_daily_statistics (
        user_id, date, total_distance, total_time_minutes, average_speed,
        max_speed, total_rides, xp_earned, cities_visited, fuel_stops
    ) VALUES
        (admin_user_id, CURRENT_DATE, 127.5, 90, 46.3, 89.2, 1, 85, 1, 1),
        (rider_user_id, CURRENT_DATE - INTERVAL '1 day', 245.8, 180, 52.1, 95.4, 1, 140, 2, 2),
        (admin_user_id, CURRENT_DATE - INTERVAL '1 day', 89.2, 60, 38.5, 75.3, 1, 45, 1, 1),
        (joao_user_id, CURRENT_DATE - INTERVAL '2 days', 156.3, 120, 48.7, 102.1, 2, 95, 3, 1);

    -- Insert some group events
    INSERT INTO public.group_events (
        group_id, created_by, title, description, event_date,
        meeting_point, meeting_latitude, meeting_longitude,
        estimated_distance, max_participants, is_public
    ) VALUES
        (group1_id, admin_user_id, 'Encontro Mensal SP',
         'Encontro mensal dos motociclistas de São Paulo',
         CURRENT_TIMESTAMP + INTERVAL '1 week',
         'Parque Ibirapuera - Portão 3', -23.5875, -46.6587,
         75.5, 20, true),
         
        (group2_id, rider_user_id, 'Trilha Serra dos Órgãos',
         'Aventura pela Serra dos Órgãos com paradas estratégicas',
         CURRENT_TIMESTAMP + INTERVAL '2 weeks',
         'Posto Shell - Entrada Teresópolis', -22.4122, -42.9664,
         180.2, 15, true);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 19. Utility functions for retrieving statistics
CREATE OR REPLACE FUNCTION public.get_user_statistics_for_date(
    target_user_id UUID,
    target_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    distance DECIMAL(10,2),
    time_minutes INTEGER,
    avg_speed DECIMAL(5,2),
    max_speed DECIMAL(5,2),
    rides INTEGER,
    xp_earned INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    COALESCE(uds.total_distance, 0),
    COALESCE(uds.total_time_minutes, 0),
    COALESCE(uds.average_speed, 0),
    COALESCE(uds.max_speed, 0),
    COALESCE(uds.total_rides, 0),
    COALESCE(uds.xp_earned, 0)
FROM public.user_daily_statistics uds
WHERE uds.user_id = target_user_id AND uds.date = target_date
UNION ALL
SELECT 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (
    SELECT 1 FROM public.user_daily_statistics 
    WHERE user_id = target_user_id AND date = target_date
)
LIMIT 1;
$$;

-- 20. Function to get location-based groups
CREATE OR REPLACE FUNCTION public.get_groups_near_user(
    target_user_id UUID,
    max_distance_km INTEGER DEFAULT 100
)
RETURNS TABLE(
    group_id UUID,
    group_name TEXT,
    city TEXT,
    state TEXT,
    member_count INTEGER,
    distance_km DECIMAL
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    user_lat DECIMAL(10,8);
    user_lng DECIMAL(11,8);
    user_city TEXT;
    user_state TEXT;
BEGIN
    -- Get user location
    SELECT up.city, up.state INTO user_city, user_state
    FROM public.user_profiles up
    WHERE up.id = target_user_id;
    
    -- If user has no location, return empty result
    IF user_city IS NULL THEN
        RETURN;
    END IF;
    
    -- Return groups in the same city/state first, then nearby ones
    RETURN QUERY
    SELECT 
        cg.id,
        cg.name,
        cg.city,
        cg.state,
        cg.member_count,
        0::DECIMAL as distance_km
    FROM public.community_groups cg
    WHERE cg.visibility = 'public'
    AND cg.city = user_city 
    AND cg.state = user_state
    AND NOT EXISTS (
        SELECT 1 FROM public.group_memberships gm 
        WHERE gm.group_id = cg.id AND gm.user_id = target_user_id
    )
    ORDER BY cg.member_count DESC, cg.is_verified DESC;
END;
$$;

-- 21. Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_statistics_community_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete in dependency order
    DELETE FROM public.group_events;
    DELETE FROM public.group_memberships;
    DELETE FROM public.community_groups;
    DELETE FROM public.user_daily_statistics;
    DELETE FROM public.ride_sessions;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;