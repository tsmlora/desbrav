-- Profile Photo Storage Module Migration
-- Migration: 20250713085000_profile_photo_storage.sql

-- Create avatars storage bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for avatars bucket
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Function to clean up old avatar files when new one is uploaded
CREATE OR REPLACE FUNCTION public.cleanup_old_avatars()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    old_avatar_path TEXT;
    old_filename TEXT;
BEGIN
    -- Check if avatar_url changed and there was an old URL
    IF OLD.avatar_url IS NOT NULL AND 
       NEW.avatar_url IS NOT NULL AND 
       OLD.avatar_url != NEW.avatar_url AND
       OLD.avatar_url LIKE '%/storage/v1/object/public/avatars/%' THEN
        
        -- Extract the filename from the old URL
        old_avatar_path := split_part(OLD.avatar_url, '/storage/v1/object/public/avatars/', 2);
        
        IF old_avatar_path != '' THEN
            -- Delete the old avatar file from storage
            DELETE FROM storage.objects 
            WHERE bucket_id = 'avatars' AND name = old_avatar_path;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Trigger to cleanup old avatars
CREATE TRIGGER cleanup_old_avatars_trigger
    AFTER UPDATE OF avatar_url ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.cleanup_old_avatars();

-- Update existing user profiles with sample avatar URLs for demonstration
DO $$
DECLARE
    sample_avatars TEXT[] := ARRAY[
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=150&h=150&fit=crop&crop=face',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'
    ];
    counter INTEGER := 1;
    profile_record RECORD;
BEGIN
    -- Add sample avatars to existing profiles that don't have one
    FOR profile_record IN 
        SELECT id FROM public.user_profiles 
        WHERE avatar_url IS NULL 
        ORDER BY created_at
    LOOP
        UPDATE public.user_profiles 
        SET avatar_url = sample_avatars[((counter - 1) % array_length(sample_avatars, 1)) + 1]
        WHERE id = profile_record.id;
        
        counter := counter + 1;
    END LOOP;
END $$;