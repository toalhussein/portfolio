-- Add new columns to projects table for enhanced project details
-- Run this in your Supabase SQL Editor

-- Add github_url column
ALTER TABLE public.projects 
ADD COLUMN IF NOT EXISTS github_url TEXT;

-- Add play_store_url column
ALTER TABLE public.projects 
ADD COLUMN IF NOT EXISTS play_store_url TEXT;

-- Add key_features column (array of text)
ALTER TABLE public.projects 
ADD COLUMN IF NOT EXISTS key_features TEXT[] DEFAULT '{}';

-- Add screenshots column (array of text URLs)
ALTER TABLE public.projects 
ADD COLUMN IF NOT EXISTS screenshots TEXT[] DEFAULT '{}';

-- Add comments for documentation
COMMENT ON COLUMN public.projects.github_url IS 'GitHub repository URL';
COMMENT ON COLUMN public.projects.play_store_url IS 'Google Play Store URL';
COMMENT ON COLUMN public.projects.key_features IS 'Array of key features/highlights';
COMMENT ON COLUMN public.projects.screenshots IS 'Array of screenshot URLs from storage';
