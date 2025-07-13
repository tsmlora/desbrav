-- DESBRAV Achievements Module Migration
-- Migration: 20250713083000_achievements_module.sql
-- Module: User achievements, progress tracking, and gamification

-- 1. Create custom types for achievements
CREATE TYPE public.achievement_category AS ENUM (
    'distance', 'speed', 'exploration', 'social', 'time', 'special'
);

CREATE TYPE public.achievement_rarity AS ENUM (
    'common', 'rare', 'epic', 'legendary'
);

CREATE TYPE public.achievement_type AS ENUM (
    'progress', 'milestone', 'special_event', 'seasonal'
);

-- 2. Master achievements table (template/definition)
CREATE TABLE public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category public.achievement_category NOT NULL,
    rarity public.achievement_rarity NOT NULL,
    type public.achievement_type DEFAULT 'progress'::public.achievement_type,
    
    -- Requirements and progress
    icon_name TEXT NOT NULL,
    max_progress INTEGER NOT NULL DEFAULT 1,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    requirements TEXT NOT NULL,
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    is_hidden BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT xp_reward_positive CHECK (xp_reward >= 0),
    CONSTRAINT max_progress_positive CHECK (max_progress > 0)
);

-- 3. User achievements table (user-specific progress)
CREATE TABLE public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE,
    
    -- Progress tracking
    current_progress INTEGER DEFAULT 0,
    is_unlocked BOOLEAN DEFAULT false,
    unlocked_at TIMESTAMPTZ,
    
    -- Sharing and social
    is_shared BOOLEAN DEFAULT false,
    shared_at TIMESTAMPTZ,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(user_id, achievement_id),
    CONSTRAINT progress_valid CHECK (current_progress >= 0)
);

-- 4. Achievement statistics table
CREATE TABLE public.achievement_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Stats by category
    distance_achievements INTEGER DEFAULT 0,
    speed_achievements INTEGER DEFAULT 0,
    exploration_achievements INTEGER DEFAULT 0,
    social_achievements INTEGER DEFAULT 0,
    time_achievements INTEGER DEFAULT 0,
    special_achievements INTEGER DEFAULT 0,
    
    -- Overall stats
    total_achievements INTEGER DEFAULT 0,
    total_xp_from_achievements INTEGER DEFAULT 0,
    
    -- Rarity stats
    common_achievements INTEGER DEFAULT 0,
    rare_achievements INTEGER DEFAULT 0,
    epic_achievements INTEGER DEFAULT 0,
    legendary_achievements INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id)
);

-- 5. Essential indexes for performance
CREATE INDEX idx_achievements_category ON public.achievements(category);
CREATE INDEX idx_achievements_rarity ON public.achievements(rarity);
CREATE INDEX idx_achievements_active ON public.achievements(is_active) WHERE is_active = true;
CREATE INDEX idx_achievements_sort_order ON public.achievements(sort_order);

CREATE INDEX idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement_id ON public.user_achievements(achievement_id);
CREATE INDEX idx_user_achievements_unlocked ON public.user_achievements(is_unlocked) WHERE is_unlocked = true;
CREATE INDEX idx_user_achievements_unlocked_at ON public.user_achievements(unlocked_at DESC);

CREATE INDEX idx_achievement_statistics_user_id ON public.achievement_statistics(user_id);

-- 6. Enable RLS
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievement_statistics ENABLE ROW LEVEL SECURITY;

-- 7. Helper functions for RLS policies
CREATE OR REPLACE FUNCTION public.owns_user_achievement(user_achievement_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_achievements ua
    WHERE ua.id = user_achievement_id AND ua.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_view_user_achievements(target_user_id UUID)
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

-- 8. RLS policies for achievements
CREATE POLICY "anyone_can_view_active_achievements"
ON public.achievements
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admins_can_manage_achievements"
ON public.achievements
FOR ALL
TO authenticated
USING (public.is_admin_user())
WITH CHECK (public.is_admin_user());

-- 9. RLS policies for user achievements
CREATE POLICY "users_can_view_accessible_achievements"
ON public.user_achievements
FOR SELECT
TO authenticated
USING (public.can_view_user_achievements(user_id));

CREATE POLICY "users_can_manage_own_achievements"
ON public.user_achievements
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 10. RLS policies for achievement statistics
CREATE POLICY "users_can_view_accessible_statistics"
ON public.achievement_statistics
FOR SELECT
TO authenticated
USING (public.can_view_user_achievements(user_id));

CREATE POLICY "users_can_manage_own_statistics"
ON public.achievement_statistics
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 11. Function to update achievement statistics
CREATE OR REPLACE FUNCTION public.update_achievement_statistics()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    achievement_category public.achievement_category;
    achievement_rarity public.achievement_rarity;
    achievement_xp INTEGER;
BEGIN
    -- Get the user ID and achievement details
    target_user_id := COALESCE(NEW.user_id, OLD.user_id);
    
    -- Get achievement details
    SELECT a.category, a.rarity, a.xp_reward
    INTO achievement_category, achievement_rarity, achievement_xp
    FROM public.achievements a
    WHERE a.id = COALESCE(NEW.achievement_id, OLD.achievement_id);
    
    -- Ensure statistics record exists
    INSERT INTO public.achievement_statistics (user_id)
    VALUES (target_user_id)
    ON CONFLICT (user_id) DO NOTHING;
    
    -- Update statistics based on trigger operation
    IF TG_OP = 'INSERT' AND NEW.is_unlocked = true THEN
        -- Achievement unlocked
        UPDATE public.achievement_statistics
        SET 
            total_achievements = total_achievements + 1,
            total_xp_from_achievements = total_xp_from_achievements + achievement_xp,
            distance_achievements = distance_achievements + CASE WHEN achievement_category = 'distance' THEN 1 ELSE 0 END,
            speed_achievements = speed_achievements + CASE WHEN achievement_category = 'speed' THEN 1 ELSE 0 END,
            exploration_achievements = exploration_achievements + CASE WHEN achievement_category = 'exploration' THEN 1 ELSE 0 END,
            social_achievements = social_achievements + CASE WHEN achievement_category = 'social' THEN 1 ELSE 0 END,
            time_achievements = time_achievements + CASE WHEN achievement_category = 'time' THEN 1 ELSE 0 END,
            special_achievements = special_achievements + CASE WHEN achievement_category = 'special' THEN 1 ELSE 0 END,
            common_achievements = common_achievements + CASE WHEN achievement_rarity = 'common' THEN 1 ELSE 0 END,
            rare_achievements = rare_achievements + CASE WHEN achievement_rarity = 'rare' THEN 1 ELSE 0 END,
            epic_achievements = epic_achievements + CASE WHEN achievement_rarity = 'epic' THEN 1 ELSE 0 END,
            legendary_achievements = legendary_achievements + CASE WHEN achievement_rarity = 'legendary' THEN 1 ELSE 0 END,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = target_user_id;
        
    ELSIF TG_OP = 'UPDATE' AND OLD.is_unlocked = false AND NEW.is_unlocked = true THEN
        -- Achievement newly unlocked
        UPDATE public.achievement_statistics
        SET 
            total_achievements = total_achievements + 1,
            total_xp_from_achievements = total_xp_from_achievements + achievement_xp,
            distance_achievements = distance_achievements + CASE WHEN achievement_category = 'distance' THEN 1 ELSE 0 END,
            speed_achievements = speed_achievements + CASE WHEN achievement_category = 'speed' THEN 1 ELSE 0 END,
            exploration_achievements = exploration_achievements + CASE WHEN achievement_category = 'exploration' THEN 1 ELSE 0 END,
            social_achievements = social_achievements + CASE WHEN achievement_category = 'social' THEN 1 ELSE 0 END,
            time_achievements = time_achievements + CASE WHEN achievement_category = 'time' THEN 1 ELSE 0 END,
            special_achievements = special_achievements + CASE WHEN achievement_category = 'special' THEN 1 ELSE 0 END,
            common_achievements = common_achievements + CASE WHEN achievement_rarity = 'common' THEN 1 ELSE 0 END,
            rare_achievements = rare_achievements + CASE WHEN achievement_rarity = 'rare' THEN 1 ELSE 0 END,
            epic_achievements = epic_achievements + CASE WHEN achievement_rarity = 'epic' THEN 1 ELSE 0 END,
            legendary_achievements = legendary_achievements + CASE WHEN achievement_rarity = 'legendary' THEN 1 ELSE 0 END,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = target_user_id;
        
    ELSIF TG_OP = 'DELETE' AND OLD.is_unlocked = true THEN
        -- Achievement removed (rare case)
        UPDATE public.achievement_statistics
        SET 
            total_achievements = GREATEST(0, total_achievements - 1),
            total_xp_from_achievements = GREATEST(0, total_xp_from_achievements - achievement_xp),
            distance_achievements = GREATEST(0, distance_achievements - CASE WHEN achievement_category = 'distance' THEN 1 ELSE 0 END),
            speed_achievements = GREATEST(0, speed_achievements - CASE WHEN achievement_category = 'speed' THEN 1 ELSE 0 END),
            exploration_achievements = GREATEST(0, exploration_achievements - CASE WHEN achievement_category = 'exploration' THEN 1 ELSE 0 END),
            social_achievements = GREATEST(0, social_achievements - CASE WHEN achievement_category = 'social' THEN 1 ELSE 0 END),
            time_achievements = GREATEST(0, time_achievements - CASE WHEN achievement_category = 'time' THEN 1 ELSE 0 END),
            special_achievements = GREATEST(0, special_achievements - CASE WHEN achievement_category = 'special' THEN 1 ELSE 0 END),
            common_achievements = GREATEST(0, common_achievements - CASE WHEN achievement_rarity = 'common' THEN 1 ELSE 0 END),
            rare_achievements = GREATEST(0, rare_achievements - CASE WHEN achievement_rarity = 'rare' THEN 1 ELSE 0 END),
            epic_achievements = GREATEST(0, epic_achievements - CASE WHEN achievement_rarity = 'epic' THEN 1 ELSE 0 END),
            legendary_achievements = GREATEST(0, legendary_achievements - CASE WHEN achievement_rarity = 'legendary' THEN 1 ELSE 0 END),
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = target_user_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;

-- 12. Triggers for automatic statistics updates
CREATE TRIGGER update_achievement_statistics_on_insert
    AFTER INSERT ON public.user_achievements
    FOR EACH ROW EXECUTE FUNCTION public.update_achievement_statistics();

CREATE TRIGGER update_achievement_statistics_on_update
    AFTER UPDATE ON public.user_achievements
    FOR EACH ROW EXECUTE FUNCTION public.update_achievement_statistics();

CREATE TRIGGER update_achievement_statistics_on_delete
    AFTER DELETE ON public.user_achievements
    FOR EACH ROW EXECUTE FUNCTION public.update_achievement_statistics();

-- 13. Function to check and unlock achievements
CREATE OR REPLACE FUNCTION public.check_and_unlock_achievement(
    target_user_id UUID,
    achievement_name TEXT,
    current_progress INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    achievement_record public.achievements;
    user_achievement_record public.user_achievements;
    achievement_unlocked BOOLEAN := false;
BEGIN
    -- Get the achievement definition
    SELECT * INTO achievement_record
    FROM public.achievements
    WHERE name = achievement_name AND is_active = true;
    
    IF achievement_record.id IS NULL THEN
        RETURN false;
    END IF;
    
    -- Get or create user achievement record
    SELECT * INTO user_achievement_record
    FROM public.user_achievements
    WHERE user_id = target_user_id AND achievement_id = achievement_record.id;
    
    IF user_achievement_record.id IS NULL THEN
        -- Create new user achievement record
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress)
        VALUES (target_user_id, achievement_record.id, current_progress);
        
        -- Check if achievement should be unlocked
        IF current_progress >= achievement_record.max_progress THEN
            UPDATE public.user_achievements
            SET is_unlocked = true, unlocked_at = CURRENT_TIMESTAMP
            WHERE user_id = target_user_id AND achievement_id = achievement_record.id;
            
            achievement_unlocked := true;
        END IF;
    ELSE
        -- Update existing record
        UPDATE public.user_achievements
        SET 
            current_progress = GREATEST(current_progress, user_achievement_record.current_progress),
            is_unlocked = CASE 
                WHEN current_progress >= achievement_record.max_progress THEN true 
                ELSE is_unlocked 
            END,
            unlocked_at = CASE 
                WHEN current_progress >= achievement_record.max_progress AND unlocked_at IS NULL THEN CURRENT_TIMESTAMP 
                ELSE unlocked_at 
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = target_user_id AND achievement_id = achievement_record.id;
        
        -- Check if achievement was just unlocked
        IF current_progress >= achievement_record.max_progress AND NOT user_achievement_record.is_unlocked THEN
            achievement_unlocked := true;
        END IF;
    END IF;
    
    RETURN achievement_unlocked;
END;
$$;

-- 14. Function to update updated_at timestamp
CREATE TRIGGER update_achievements_updated_at
    BEFORE UPDATE ON public.achievements
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_achievements_updated_at
    BEFORE UPDATE ON public.user_achievements
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_achievement_statistics_updated_at
    BEFORE UPDATE ON public.achievement_statistics
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 15. Initial achievement definitions
DO $$
DECLARE
    admin_user_id UUID;
    rider_user_id UUID;
    joao_user_id UUID;
    achievement_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE email = 'admin@desbrav.com' LIMIT 1;
    SELECT id INTO rider_user_id FROM public.user_profiles WHERE email = 'rider@desbrav.com' LIMIT 1;
    SELECT id INTO joao_user_id FROM public.user_profiles WHERE email = 'joao@desbrav.com' LIMIT 1;

    -- Insert master achievement definitions
    INSERT INTO public.achievements (name, description, category, rarity, icon_name, max_progress, xp_reward, requirements, sort_order) VALUES
        ('Primeiro Quilômetro', 'Complete sua primeira viagem de motocicleta', 'distance'::public.achievement_category, 'common'::public.achievement_rarity, 'motorcycle', 1, 50, 'Complete 1 km de viagem', 1),
        ('Explorador Urbano', 'Visite 10 pontos de interesse diferentes na cidade', 'exploration'::public.achievement_category, 'rare'::public.achievement_rarity, 'location_city', 10, 150, 'Visite 10 pontos de interesse', 2),
        ('Velocista', 'Atinja 120 km/h em uma viagem segura', 'speed'::public.achievement_category, 'epic'::public.achievement_rarity, 'speed', 120, 300, 'Atinja 120 km/h com segurança', 3),
        ('Maratonista', 'Complete uma viagem de 500 km em um dia', 'distance'::public.achievement_category, 'epic'::public.achievement_rarity, 'route', 500, 500, 'Complete 500 km em uma viagem', 4),
        ('Socialite', 'Participe de 5 eventos da comunidade', 'social'::public.achievement_category, 'rare'::public.achievement_rarity, 'group', 5, 200, 'Participe de 5 eventos', 5),
        ('Resistência', 'Viaje por 8 horas consecutivas', 'time'::public.achievement_category, 'epic'::public.achievement_rarity, 'access_time', 8, 400, 'Viaje por 8 horas seguidas', 6),
        ('Aventureiro Noturno', 'Complete uma viagem noturna de 100 km', 'special'::public.achievement_category, 'legendary'::public.achievement_rarity, 'nights_stay', 100, 750, 'Complete 100 km durante a noite', 7),
        ('Descobridor', 'Encontre 25 pontos de apoio diferentes', 'exploration'::public.achievement_category, 'rare'::public.achievement_rarity, 'explore', 25, 250, 'Visite 25 pontos de apoio', 8),
        ('Veterano', 'Complete 100 viagens', 'distance'::public.achievement_category, 'epic'::public.achievement_rarity, 'military_tech', 100, 600, 'Complete 100 viagens', 9),
        ('Lenda das Estradas', 'Percorra 10.000 km totais', 'distance'::public.achievement_category, 'legendary'::public.achievement_rarity, 'star', 10000, 1000, 'Percorra 10.000 km totais', 10);

    -- Create user achievements for demo users
    IF admin_user_id IS NOT NULL THEN
        -- Admin user unlocked achievements
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress, is_unlocked, unlocked_at)
        SELECT 
            admin_user_id,
            a.id,
            a.max_progress,
            true,
            CURRENT_TIMESTAMP - INTERVAL '30 days' + (RANDOM() * INTERVAL '25 days')
        FROM public.achievements a
        WHERE a.name IN ('Primeiro Quilômetro', 'Explorador Urbano', 'Velocista', 'Socialite');
        
        -- Admin user in progress achievements
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress, is_unlocked)
        SELECT 
            admin_user_id,
            a.id,
            CASE 
                WHEN a.name = 'Maratonista' THEN 320
                WHEN a.name = 'Resistência' THEN 6
                WHEN a.name = 'Descobridor' THEN 18
                ELSE 0
            END,
            false
        FROM public.achievements a
        WHERE a.name IN ('Maratonista', 'Resistência', 'Descobridor');
    END IF;
    
    IF rider_user_id IS NOT NULL THEN
        -- Rider user unlocked achievements
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress, is_unlocked, unlocked_at)
        SELECT 
            rider_user_id,
            a.id,
            a.max_progress,
            true,
            CURRENT_TIMESTAMP - INTERVAL '25 days' + (RANDOM() * INTERVAL '20 days')
        FROM public.achievements a
        WHERE a.name IN ('Primeiro Quilômetro', 'Explorador Urbano');
        
        -- Rider user in progress achievements
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress, is_unlocked)
        SELECT 
            rider_user_id,
            a.id,
            CASE 
                WHEN a.name = 'Velocista' THEN 75
                WHEN a.name = 'Socialite' THEN 3
                WHEN a.name = 'Descobridor' THEN 8
                ELSE 0
            END,
            false
        FROM public.achievements a
        WHERE a.name IN ('Velocista', 'Socialite', 'Descobridor');
    END IF;
    
    IF joao_user_id IS NOT NULL THEN
        -- João user unlocked achievements
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress, is_unlocked, unlocked_at)
        SELECT 
            joao_user_id,
            a.id,
            a.max_progress,
            true,
            CURRENT_TIMESTAMP - INTERVAL '20 days' + (RANDOM() * INTERVAL '15 days')
        FROM public.achievements a
        WHERE a.name IN ('Primeiro Quilômetro', 'Explorador Urbano', 'Velocista', 'Maratonista', 'Socialite');
        
        -- João user in progress achievements
        INSERT INTO public.user_achievements (user_id, achievement_id, current_progress, is_unlocked)
        SELECT 
            joao_user_id,
            a.id,
            CASE 
                WHEN a.name = 'Aventureiro Noturno' THEN 45
                WHEN a.name = 'Descobridor' THEN 20
                WHEN a.name = 'Veterano' THEN 65
                ELSE 0
            END,
            false
        FROM public.achievements a
        WHERE a.name IN ('Aventureiro Noturno', 'Descobridor', 'Veterano');
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 16. Cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_achievements_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete in dependency order
    DELETE FROM public.achievement_statistics;
    DELETE FROM public.user_achievements;
    DELETE FROM public.achievements;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;