-- Rest Points Module Migration
-- Migration: 20250713090000_rest_points_module.sql

-- 1. Create types for rest points module
CREATE TYPE public.accommodation_price_range AS ENUM ('budget', 'mid', 'premium');
CREATE TYPE public.accommodation_type AS ENUM ('hotel', 'pousada', 'hostel', 'camping', 'apartment', 'villa');

-- 2. Rest point accommodations table
CREATE TABLE public.rest_point_accommodations (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    currency TEXT DEFAULT 'BRL',
    image_url TEXT,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0 CHECK (review_count >= 0),
    host_name TEXT,
    host_image_url TEXT,
    amenities TEXT[] DEFAULT '{}',
    has_parking BOOLEAN DEFAULT false,
    has_charging_station BOOLEAN DEFAULT false,
    allows_groups BOOLEAN DEFAULT false,
    max_guests INTEGER DEFAULT 1 CHECK (max_guests >= 1),
    price_range public.accommodation_price_range DEFAULT 'mid'::public.accommodation_price_range,
    accommodation_type public.accommodation_type DEFAULT 'hotel'::public.accommodation_type,
    airbnb_listing_id TEXT,
    booking_url TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT DEFAULT 'Brasil',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. User favorite accommodations table
CREATE TABLE public.user_favorite_accommodations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    accommodation_id TEXT REFERENCES public.rest_point_accommodations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, accommodation_id)
);

-- 4. Accommodation reviews table
CREATE TABLE public.accommodation_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accommodation_id TEXT REFERENCES public.rest_point_accommodations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT,
    comment TEXT,
    motorcycle_friendliness_rating INTEGER CHECK (motorcycle_friendliness_rating >= 1 AND motorcycle_friendliness_rating <= 5),
    safety_rating INTEGER CHECK (safety_rating >= 1 AND safety_rating <= 5),
    value_rating INTEGER CHECK (value_rating >= 1 AND value_rating <= 5),
    cleanliness_rating INTEGER CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
    helpful_count INTEGER DEFAULT 0 CHECK (helpful_count >= 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(accommodation_id, user_id)
);

-- 5. Accommodation bookings table (for tracking and analytics)
CREATE TABLE public.accommodation_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accommodation_id TEXT REFERENCES public.rest_point_accommodations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guests_count INTEGER NOT NULL CHECK (guests_count >= 1),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    booking_status TEXT DEFAULT 'pending' CHECK (booking_status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    external_booking_id TEXT,
    booking_platform TEXT DEFAULT 'airbnb',
    special_requests TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    CHECK (check_out_date > check_in_date)
);

-- 6. Create indexes for performance
CREATE INDEX idx_rest_point_accommodations_location ON public.rest_point_accommodations(latitude, longitude);
CREATE INDEX idx_rest_point_accommodations_price_range ON public.rest_point_accommodations(price_range);
CREATE INDEX idx_rest_point_accommodations_price ON public.rest_point_accommodations(price);
CREATE INDEX idx_rest_point_accommodations_rating ON public.rest_point_accommodations(rating);
CREATE INDEX idx_rest_point_accommodations_has_parking ON public.rest_point_accommodations(has_parking);
CREATE INDEX idx_rest_point_accommodations_has_charging ON public.rest_point_accommodations(has_charging_station);
CREATE INDEX idx_rest_point_accommodations_allows_groups ON public.rest_point_accommodations(allows_groups);
CREATE INDEX idx_rest_point_accommodations_city ON public.rest_point_accommodations(city);
CREATE INDEX idx_rest_point_accommodations_is_active ON public.rest_point_accommodations(is_active);

CREATE INDEX idx_user_favorite_accommodations_user_id ON public.user_favorite_accommodations(user_id);
CREATE INDEX idx_user_favorite_accommodations_accommodation_id ON public.user_favorite_accommodations(accommodation_id);

CREATE INDEX idx_accommodation_reviews_accommodation_id ON public.accommodation_reviews(accommodation_id);
CREATE INDEX idx_accommodation_reviews_user_id ON public.accommodation_reviews(user_id);
CREATE INDEX idx_accommodation_reviews_rating ON public.accommodation_reviews(rating);

CREATE INDEX idx_accommodation_bookings_user_id ON public.accommodation_bookings(user_id);
CREATE INDEX idx_accommodation_bookings_accommodation_id ON public.accommodation_bookings(accommodation_id);
CREATE INDEX idx_accommodation_bookings_check_in_date ON public.accommodation_bookings(check_in_date);
CREATE INDEX idx_accommodation_bookings_status ON public.accommodation_bookings(booking_status);

-- 7. Enable RLS
ALTER TABLE public.rest_point_accommodations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_favorite_accommodations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accommodation_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accommodation_bookings ENABLE ROW LEVEL SECURITY;

-- 8. Helper functions for RLS policies
CREATE OR REPLACE FUNCTION public.is_accommodation_owner(accommodation_id TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.rest_point_accommodations rpa
    WHERE rpa.id = accommodation_id
    -- In a real system, you'd have host_id to check ownership
    -- For now, allowing public read access to accommodations
)
$$;

CREATE OR REPLACE FUNCTION public.is_favorite_owner(favorite_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_favorite_accommodations ufa
    WHERE ufa.id = favorite_id AND ufa.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_review_owner(review_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.accommodation_reviews ar
    WHERE ar.id = review_id AND ar.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.is_booking_owner(booking_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.accommodation_bookings ab
    WHERE ab.id = booking_id AND ab.user_id = auth.uid()
)
$$;

-- 9. RLS policies
-- Accommodations are publicly readable
CREATE POLICY "accommodations_public_read"
ON public.rest_point_accommodations
FOR SELECT
TO public
USING (is_active = true);

-- Only admins can modify accommodations
CREATE POLICY "accommodations_admin_manage"
ON public.rest_point_accommodations
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

-- Users can manage their own favorites
CREATE POLICY "users_manage_own_favorites"
ON public.user_favorite_accommodations
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Reviews are publicly readable
CREATE POLICY "reviews_public_read"
ON public.accommodation_reviews
FOR SELECT
TO public
USING (true);

-- Users can manage their own reviews
CREATE POLICY "users_manage_own_reviews"
ON public.accommodation_reviews
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_update_own_reviews"
ON public.accommodation_reviews
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_delete_own_reviews"
ON public.accommodation_reviews
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Users can manage their own bookings
CREATE POLICY "users_manage_own_bookings"
ON public.accommodation_bookings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Admins can view all bookings for analytics
CREATE POLICY "admins_view_all_bookings"
ON public.accommodation_bookings
FOR SELECT
TO authenticated
USING (public.is_admin_user());

-- 10. Function to update updated_at timestamp
CREATE TRIGGER update_rest_point_accommodations_updated_at
    BEFORE UPDATE ON public.rest_point_accommodations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_accommodation_reviews_updated_at
    BEFORE UPDATE ON public.accommodation_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_accommodation_bookings_updated_at
    BEFORE UPDATE ON public.accommodation_bookings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 11. Function to calculate accommodation rating from reviews
CREATE OR REPLACE FUNCTION public.update_accommodation_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update accommodation rating based on reviews
    UPDATE public.rest_point_accommodations
    SET 
        rating = (
            SELECT ROUND(AVG(rating::DECIMAL), 2)
            FROM public.accommodation_reviews
            WHERE accommodation_id = COALESCE(NEW.accommodation_id, OLD.accommodation_id)
        ),
        review_count = (
            SELECT COUNT(*)
            FROM public.accommodation_reviews
            WHERE accommodation_id = COALESCE(NEW.accommodation_id, OLD.accommodation_id)
        )
    WHERE id = COALESCE(NEW.accommodation_id, OLD.accommodation_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- 12. Triggers to update accommodation rating
CREATE TRIGGER update_accommodation_rating_on_review_insert
    AFTER INSERT ON public.accommodation_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_accommodation_rating();

CREATE TRIGGER update_accommodation_rating_on_review_update
    AFTER UPDATE ON public.accommodation_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_accommodation_rating();

CREATE TRIGGER update_accommodation_rating_on_review_delete
    AFTER DELETE ON public.accommodation_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_accommodation_rating();

-- 13. Mock data for development
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO user1_id FROM public.user_profiles WHERE email = 'admin@desbrav.com' LIMIT 1;
    SELECT id INTO user2_id FROM public.user_profiles WHERE email = 'rider@desbrav.com' LIMIT 1;

    -- Insert sample accommodations
    INSERT INTO public.rest_point_accommodations (
        id, title, description, price, image_url, latitude, longitude,
        rating, review_count, host_name, host_image_url, amenities,
        has_parking, has_charging_station, allows_groups, max_guests,
        price_range, accommodation_type, city, state, address
    ) VALUES
        ('1', 'Pousada do Motociclista', 
         'Acomodação especial para motociclistas com garagem segura e oficina básica.',
         120.0, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
         -23.5505, -46.6333, 4.8, 156, 'Carlos Santos',
         'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
         ARRAY['Garagem Segura', 'Wi-Fi', 'Café da Manhã', 'Oficina Básica'],
         true, false, true, 4, 'mid'::public.accommodation_price_range,
         'pousada'::public.accommodation_type, 'São Paulo', 'SP',
         'Rua das Motos, 123 - Vila Madalena'),
         
        ('2', 'Hostel Adventure Riders',
         'Hostel temático para aventureiros de duas rodas com ambiente descontraído.',
         85.0, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
         -23.5615, -46.6455, 4.5, 89, 'Marina Silva',
         'https://images.unsplash.com/photo-1494790108755-2616b612b601?w=150',
         ARRAY['Estacionamento', 'Cozinha Compartilhada', 'Área Social', 'Mapas de Rota'],
         true, true, true, 8, 'budget'::public.accommodation_price_range,
         'hostel'::public.accommodation_type, 'São Paulo', 'SP',
         'Av. Paulista, 2000 - Bela Vista'),
         
        ('3', 'Villa Premium Bikers',
         'Villa de luxo com amenidades premium e serviços exclusivos para motociclistas.',
         350.0, 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
         -23.5405, -46.6255, 4.9, 234, 'Roberto Lima',
         'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
         ARRAY['Garagem Premium', 'Spa', 'Piscina', 'Serviço de Limpeza', 'Estação de Carga Elétrica'],
         true, true, false, 2, 'premium'::public.accommodation_price_range,
         'villa'::public.accommodation_type, 'São Paulo', 'SP',
         'Rua Luxo, 456 - Jardins'),
         
        ('4', 'Camping Rota das Montanhas',
         'Camping especializado em turismo de motocicleta com estrutura completa.',
         45.0, 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
         -23.5705, -46.6155, 4.3, 67, 'Ana Pereira',
         'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
         ARRAY['Área de Camping', 'Banheiros', 'Fogueira', 'Trilhas'],
         true, false, true, 6, 'budget'::public.accommodation_price_range,
         'camping'::public.accommodation_type, 'São Paulo', 'SP',
         'Estrada da Serra, km 45');

    -- Insert sample favorites
    IF user1_id IS NOT NULL THEN
        INSERT INTO public.user_favorite_accommodations (user_id, accommodation_id)
        VALUES 
            (user1_id, '1'),
            (user1_id, '3');
    END IF;

    IF user2_id IS NOT NULL THEN
        INSERT INTO public.user_favorite_accommodations (user_id, accommodation_id)
        VALUES 
            (user2_id, '2'),
            (user2_id, '4');
    END IF;

    -- Insert sample reviews
    IF user1_id IS NOT NULL THEN
        INSERT INTO public.accommodation_reviews (
            accommodation_id, user_id, rating, title, comment,
            motorcycle_friendliness_rating, safety_rating, value_rating, cleanliness_rating
        ) VALUES
            ('1', user1_id, 5, 'Excelente para motociclistas!',
             'Ótima estrutura para quem viaja de moto. Garagem segura e staff muito atencioso.',
             5, 5, 4, 5),
            ('2', user1_id, 4, 'Bom custo-benefício',
             'Hostel com ambiente legal e outros motociclistas. Estacionamento poderia ser melhor.',
             4, 4, 5, 4);
    END IF;

    IF user2_id IS NOT NULL THEN
        INSERT INTO public.accommodation_reviews (
            accommodation_id, user_id, rating, title, comment,
            motorcycle_friendliness_rating, safety_rating, value_rating, cleanliness_rating
        ) VALUES
            ('3', user2_id, 5, 'Luxo total!',
             'Experiência incrível. Vale cada centavo para uma viagem especial.',
             5, 5, 3, 5),
            ('4', user2_id, 4, 'Aventura na natureza',
             'Camping muito bem estruturado. Perfeito para quem gosta de contato com a natureza.',
             4, 4, 5, 4);
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 14. Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_rest_points_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete in dependency order
    DELETE FROM public.accommodation_bookings;
    DELETE FROM public.accommodation_reviews;
    DELETE FROM public.user_favorite_accommodations;
    DELETE FROM public.rest_point_accommodations;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;