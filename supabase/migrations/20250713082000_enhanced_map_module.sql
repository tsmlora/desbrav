-- Enhanced Interactive Map Module Migration
-- Migration: 20250713082000_enhanced_map_module.sql
-- Module: Map with businesses, user-generated content, reviews, and real-time data

-- 1. Create custom types
CREATE TYPE public.business_type AS ENUM (
    'gas_station', 'workshop', 'restaurant', 'hotel', 'tourist_spot'
);

CREATE TYPE public.business_status AS ENUM (
    'active', 'inactive', 'permanently_closed', 'temporarily_closed'
);

CREATE TYPE public.price_range AS ENUM (
    'budget', 'moderate', 'expensive', 'luxury'
);

CREATE TYPE public.review_type AS ENUM (
    'fuel_price', 'service_quality', 'food_quality', 'accommodation', 'general'
);

-- 2. Businesses table for map support points
CREATE TABLE public.businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    business_type public.business_type NOT NULL,
    status public.business_status DEFAULT 'active'::public.business_status,
    
    -- Location data
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postal_code TEXT,
    country TEXT DEFAULT 'Brasil',
    
    -- Contact information
    phone TEXT,
    email TEXT,
    website TEXT,
    
    -- Business details
    description TEXT,
    amenities TEXT[], -- Array of available amenities
    operating_hours JSONB, -- Flexible hours structure
    price_range public.price_range,
    
    -- Ratings and statistics
    average_rating DECIMAL(3,2) DEFAULT 0.00 CHECK (average_rating >= 0 AND average_rating <= 5),
    total_reviews INTEGER DEFAULT 0 CHECK (total_reviews >= 0),
    
    -- Images and media
    primary_image_url TEXT,
    image_urls TEXT[], -- Array of image URLs
    
    -- Verification and metadata
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    added_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    verified_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT valid_coordinates CHECK (
        latitude BETWEEN -90 AND 90 AND 
        longitude BETWEEN -180 AND 180
    ),
    CONSTRAINT valid_email CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_phone CHECK (phone IS NULL OR phone ~* '^\+?[1-9]\d{1,14}$')
);

-- 3. Real-time fuel prices table
CREATE TABLE public.fuel_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES public.businesses(id) ON DELETE CASCADE,
    fuel_type TEXT NOT NULL, -- 'gasoline_common', 'gasoline_premium', 'ethanol', 'diesel'
    price_per_liter DECIMAL(5,3) NOT NULL CHECK (price_per_liter > 0),
    currency TEXT DEFAULT 'BRL',
    
    -- Data source and verification
    reported_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    verified_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    is_verified BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ
);

-- 4. Business reviews table
CREATE TABLE public.business_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES public.businesses(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Review content
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT,
    content TEXT,
    review_type public.review_type DEFAULT 'general'::public.review_type,
    
    -- Additional data
    visit_date DATE,
    recommended BOOLEAN DEFAULT true,
    photos TEXT[], -- Array of photo URLs
    
    -- Moderation
    is_verified BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(business_id, user_id, review_type) -- One review per type per user per business
);

-- 5. User favorite businesses
CREATE TABLE public.user_favorite_businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    business_id UUID REFERENCES public.businesses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, business_id)
);

-- 6. User routes and waypoints
CREATE TABLE public.user_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    
    -- Route data
    start_latitude DECIMAL(10, 8) NOT NULL,
    start_longitude DECIMAL(11, 8) NOT NULL,
    end_latitude DECIMAL(10, 8) NOT NULL,
    end_longitude DECIMAL(11, 8) NOT NULL,
    waypoints JSONB, -- Array of waypoint coordinates and business IDs
    
    -- Route statistics
    estimated_distance DECIMAL(10,2), -- In kilometers
    estimated_duration INTEGER, -- In minutes
    
    -- Sharing and visibility
    is_public BOOLEAN DEFAULT false,
    is_featured BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Essential indexes for performance
CREATE INDEX idx_businesses_location ON public.businesses USING btree (latitude, longitude);
CREATE INDEX idx_businesses_type ON public.businesses(business_type);
CREATE INDEX idx_businesses_status ON public.businesses(status);
CREATE INDEX idx_businesses_city_state ON public.businesses(city, state);
CREATE INDEX idx_businesses_rating ON public.businesses(average_rating DESC);
CREATE INDEX idx_businesses_created_at ON public.businesses(created_at);

CREATE INDEX idx_fuel_prices_business_id ON public.fuel_prices(business_id);
CREATE INDEX idx_fuel_prices_fuel_type ON public.fuel_prices(fuel_type);
CREATE INDEX idx_fuel_prices_created_at ON public.fuel_prices(created_at DESC);

CREATE INDEX idx_business_reviews_business_id ON public.business_reviews(business_id);
CREATE INDEX idx_business_reviews_user_id ON public.business_reviews(user_id);
CREATE INDEX idx_business_reviews_rating ON public.business_reviews(rating DESC);
CREATE INDEX idx_business_reviews_created_at ON public.business_reviews(created_at DESC);

CREATE INDEX idx_user_favorite_businesses_user_id ON public.user_favorite_businesses(user_id);
CREATE INDEX idx_user_routes_user_id ON public.user_routes(user_id);
CREATE INDEX idx_user_routes_public ON public.user_routes(is_public) WHERE is_public = true;

-- 8. Enable RLS
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_favorite_businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_routes ENABLE ROW LEVEL SECURITY;

-- 9. Helper functions for RLS policies
CREATE OR REPLACE FUNCTION public.can_view_business(business_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.businesses b
    WHERE b.id = business_id AND b.status = 'active'::public.business_status
)
$$;

CREATE OR REPLACE FUNCTION public.can_edit_business(business_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.businesses b
    WHERE b.id = business_id AND (
        b.added_by = auth.uid() OR
        public.is_admin_user()
    )
)
$$;

CREATE OR REPLACE FUNCTION public.can_manage_fuel_price(fuel_price_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.fuel_prices fp
    WHERE fp.id = fuel_price_id AND (
        fp.reported_by = auth.uid() OR
        public.is_admin_user()
    )
)
$$;

CREATE OR REPLACE FUNCTION public.owns_review(review_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.business_reviews br
    WHERE br.id = review_id AND br.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.owns_route(route_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_routes ur
    WHERE ur.id = route_id AND ur.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_view_route(route_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_routes ur
    WHERE ur.id = route_id AND (
        ur.user_id = auth.uid() OR
        ur.is_public = true OR
        public.is_admin_user()
    )
)
$$;

-- 10. RLS policies for businesses
CREATE POLICY "anyone_can_view_active_businesses"
ON public.businesses
FOR SELECT
TO public
USING (status = 'active'::public.business_status);

CREATE POLICY "authenticated_users_can_add_businesses"
ON public.businesses
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = added_by);

CREATE POLICY "business_contributors_can_edit"
ON public.businesses
FOR UPDATE
TO authenticated
USING (public.can_edit_business(id))
WITH CHECK (public.can_edit_business(id));

CREATE POLICY "admins_can_delete_businesses"
ON public.businesses
FOR DELETE
TO authenticated
USING (public.is_admin_user());

-- 11. RLS policies for fuel prices
CREATE POLICY "anyone_can_view_fuel_prices"
ON public.fuel_prices
FOR SELECT
TO public
USING (true);

CREATE POLICY "authenticated_users_can_report_fuel_prices"
ON public.fuel_prices
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = reported_by);

CREATE POLICY "fuel_price_reporters_can_edit"
ON public.fuel_prices
FOR UPDATE
TO authenticated
USING (public.can_manage_fuel_price(id))
WITH CHECK (public.can_manage_fuel_price(id));

-- 12. RLS policies for reviews
CREATE POLICY "anyone_can_view_reviews"
ON public.business_reviews
FOR SELECT
TO public
USING (true);

CREATE POLICY "authenticated_users_can_create_reviews"
ON public.business_reviews
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_edit_own_reviews"
ON public.business_reviews
FOR UPDATE
TO authenticated
USING (public.owns_review(id))
WITH CHECK (public.owns_review(id));

CREATE POLICY "users_can_delete_own_reviews"
ON public.business_reviews
FOR DELETE
TO authenticated
USING (public.owns_review(id) OR public.is_admin_user());

-- 13. RLS policies for favorites
CREATE POLICY "users_manage_own_favorites"
ON public.user_favorite_businesses
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 14. RLS policies for routes
CREATE POLICY "users_can_view_accessible_routes"
ON public.user_routes
FOR SELECT
TO authenticated
USING (public.can_view_route(id));

CREATE POLICY "authenticated_users_can_create_routes"
ON public.user_routes
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users_can_edit_own_routes"
ON public.user_routes
FOR UPDATE
TO authenticated
USING (public.owns_route(id))
WITH CHECK (public.owns_route(id));

CREATE POLICY "users_can_delete_own_routes"
ON public.user_routes
FOR DELETE
TO authenticated
USING (public.owns_route(id));

-- 15. Function to update business ratings
CREATE OR REPLACE FUNCTION public.update_business_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update business rating and review count
    UPDATE public.businesses SET
        average_rating = (
            SELECT COALESCE(AVG(rating::DECIMAL), 0)
            FROM public.business_reviews
            WHERE business_id = COALESCE(NEW.business_id, OLD.business_id)
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM public.business_reviews
            WHERE business_id = COALESCE(NEW.business_id, OLD.business_id)
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.business_id, OLD.business_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- 16. Triggers for automatic rating updates
CREATE TRIGGER update_business_rating_on_review_insert
    AFTER INSERT ON public.business_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_business_rating();

CREATE TRIGGER update_business_rating_on_review_update
    AFTER UPDATE ON public.business_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_business_rating();

CREATE TRIGGER update_business_rating_on_review_delete
    AFTER DELETE ON public.business_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_business_rating();

-- 17. Function to update updated_at timestamp
CREATE TRIGGER update_businesses_updated_at
    BEFORE UPDATE ON public.businesses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_fuel_prices_updated_at
    BEFORE UPDATE ON public.fuel_prices
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_business_reviews_updated_at
    BEFORE UPDATE ON public.business_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_routes_updated_at
    BEFORE UPDATE ON public.user_routes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 18. Mock data for development and testing
DO $$
DECLARE
    admin_user_id UUID;
    rider_user_id UUID;
    business1_id UUID := gen_random_uuid();
    business2_id UUID := gen_random_uuid();
    business3_id UUID := gen_random_uuid();
    business4_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user IDs
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE email = 'admin@desbrav.com' LIMIT 1;
    SELECT id INTO rider_user_id FROM public.user_profiles WHERE email = 'rider@desbrav.com' LIMIT 1;

    -- Insert sample businesses
    INSERT INTO public.businesses (
        id, name, business_type, latitude, longitude, address, city, state,
        phone, description, amenities, operating_hours, price_range,
        primary_image_url, added_by, is_verified, average_rating, total_reviews
    ) VALUES
        (business1_id, 'Posto Shell Centro', 'gas_station'::public.business_type, 
         -23.5505, -46.6333, 'Av. Paulista, 1000 - Bela Vista', 'São Paulo', 'SP',
         '(11) 3456-7890', 'Posto 24 horas com conveniência completa',
         ARRAY['conveniencia', 'banheiro', 'wifi', 'calibragem'],
         '{"monday": "00:00-23:59", "tuesday": "00:00-23:59", "wednesday": "00:00-23:59", "thursday": "00:00-23:59", "friday": "00:00-23:59", "saturday": "00:00-23:59", "sunday": "00:00-23:59"}'::jsonb,
         'moderate'::public.price_range,
         'https://images.pexels.com/photos/33688/delicate-arch-night-stars-landscape.jpg?auto=compress&cs=tinysrgb&w=800',
         admin_user_id, true, 4.2, 18),
         
        (business2_id, 'Oficina Moto Expert', 'workshop'::public.business_type,
         -23.5489, -46.6388, 'Rua Augusta, 500 - Consolação', 'São Paulo', 'SP',
         '(11) 2345-6789', 'Especializada em motos esportivas e touring',
         ARRAY['revisao', 'pneus', 'eletrica', 'pintura'],
         '{"monday": "08:00-18:00", "tuesday": "08:00-18:00", "wednesday": "08:00-18:00", "thursday": "08:00-18:00", "friday": "08:00-18:00", "saturday": "08:00-12:00", "sunday": "closed"}'::jsonb,
         'moderate'::public.price_range,
         'https://images.pexels.com/photos/190537/pexels-photo-190537.jpeg?auto=compress&cs=tinysrgb&w=800',
         admin_user_id, true, 4.7, 23),
         
        (business3_id, 'Restaurante do Motoqueiro', 'restaurant'::public.business_type,
         -23.5520, -46.6311, 'Rua da Consolação, 200 - Centro', 'São Paulo', 'SP',
         '(11) 1234-5678', 'Comida caseira para motociclistas',
         ARRAY['estacionamento', 'marmitex', 'delivery', 'wifi'],
         '{"monday": "11:00-22:00", "tuesday": "11:00-22:00", "wednesday": "11:00-22:00", "thursday": "11:00-22:00", "friday": "11:00-23:00", "saturday": "11:00-23:00", "sunday": "11:00-21:00"}'::jsonb,
         'budget'::public.price_range,
         'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg?auto=compress&cs=tinysrgb&w=800',
         rider_user_id, true, 4.5, 31),
         
        (business4_id, 'Pousada Rota das Motos', 'hotel'::public.business_type,
         -23.5467, -46.6407, 'Rua Haddock Lobo, 300 - Cerqueira César', 'São Paulo', 'SP',
         '(11) 9876-5432', 'Pousada especializada para motociclistas',
         ARRAY['garagem_segura', 'wifi', 'cafe_manha', 'lavanderia'],
         '{"monday": "00:00-23:59", "tuesday": "00:00-23:59", "wednesday": "00:00-23:59", "thursday": "00:00-23:59", "friday": "00:00-23:59", "saturday": "00:00-23:59", "sunday": "00:00-23:59"}'::jsonb,
         'moderate'::public.price_range,
         'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=800',
         rider_user_id, true, 4.3, 15);

    -- Insert fuel prices
    INSERT INTO public.fuel_prices (business_id, fuel_type, price_per_liter, reported_by, is_verified)
    VALUES
        (business1_id, 'gasoline_common', 5.89, admin_user_id, true),
        (business1_id, 'gasoline_premium', 6.12, admin_user_id, true),
        (business1_id, 'ethanol', 4.23, admin_user_id, true);

    -- Insert sample reviews
    INSERT INTO public.business_reviews (business_id, user_id, rating, title, content, review_type, visit_date, recommended)
    VALUES
        (business1_id, rider_user_id, 4, 'Ótimo atendimento', 'Posto bem localizado, preços justos e atendimento 24h.', 'general'::public.review_type, CURRENT_DATE - INTERVAL '5 days', true),
        (business2_id, rider_user_id, 5, 'Melhor oficina da região', 'Profissionais competentes e preço justo. Recomendo!', 'service_quality'::public.review_type, CURRENT_DATE - INTERVAL '10 days', true),
        (business3_id, admin_user_id, 4, 'Comida boa e barata', 'Perfeito para uma parada rápida durante a viagem.', 'food_quality'::public.review_type, CURRENT_DATE - INTERVAL '3 days', true);

    -- Insert favorite businesses
    INSERT INTO public.user_favorite_businesses (user_id, business_id)
    VALUES
        (rider_user_id, business2_id),
        (rider_user_id, business3_id),
        (admin_user_id, business1_id);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 19. Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_map_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete in dependency order
    DELETE FROM public.user_favorite_businesses;
    DELETE FROM public.business_reviews;
    DELETE FROM public.fuel_prices;
    DELETE FROM public.user_routes;
    DELETE FROM public.businesses;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;