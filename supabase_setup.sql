-- ===================================================================
-- SUPABASE DATABASE SETUP FOR PORTFOLIO WEBSITE
-- ===================================================================
-- Author: Alhussein AbdelSabour (@toalhussein)
-- Description: Complete database schema with tables and RLS policies
-- ===================================================================

-- ===================================================================
-- 1. CREATE TABLES
-- ===================================================================

-- Projects table: Stores portfolio projects
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    tech_stack TEXT NOT NULL,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Contact messages table: Stores messages from contact form
CREATE TABLE IF NOT EXISTS public.contact_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Admins table: Links Supabase auth users to admin role
CREATE TABLE IF NOT EXISTS public.admins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ===================================================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ===================================================================

CREATE INDEX IF NOT EXISTS idx_projects_created_at ON public.projects(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created_at ON public.contact_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_messages_is_read ON public.contact_messages(is_read);
CREATE INDEX IF NOT EXISTS idx_admins_user_id ON public.admins(user_id);

-- ===================================================================
-- 3. CREATE UPDATED_AT TRIGGER FUNCTION
-- ===================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to projects table
DROP TRIGGER IF EXISTS set_updated_at ON public.projects;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.projects
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ===================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ===================================================================

-- Enable RLS on all tables
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- ===================================================================
-- Projects Table Policies
-- ===================================================================

-- Policy: Anyone can read projects (for public portfolio display)
CREATE POLICY "Anyone can read projects"
    ON public.projects
    FOR SELECT
    TO public
    USING (true);

-- Policy: Only admins can insert projects
CREATE POLICY "Admins can insert projects"
    ON public.projects
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- Policy: Only admins can update projects
CREATE POLICY "Admins can update projects"
    ON public.projects
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- Policy: Only admins can delete projects
CREATE POLICY "Admins can delete projects"
    ON public.projects
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- ===================================================================
-- Contact Messages Table Policies
-- ===================================================================

-- Policy: Anyone can insert contact messages (for public contact form)
CREATE POLICY "Anyone can insert contact messages"
    ON public.contact_messages
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Policy: Only admins can read contact messages
CREATE POLICY "Admins can read contact messages"
    ON public.contact_messages
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- Policy: Only admins can update contact messages (for marking as read)
CREATE POLICY "Admins can update contact messages"
    ON public.contact_messages
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- Policy: Only admins can delete contact messages
CREATE POLICY "Admins can delete contact messages"
    ON public.contact_messages
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- ===================================================================
-- Admins Table Policies
-- ===================================================================

-- Policy: Only admins can read the admins table
CREATE POLICY "Admins can read admins table"
    ON public.admins
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.admins
            WHERE admins.user_id = auth.uid()
        )
    );

-- ===================================================================
-- 5. CREATE STORAGE BUCKET FOR PROJECT IMAGES
-- ===================================================================

-- Create storage bucket for project images (execute in Supabase Dashboard -> Storage)
-- Bucket name: project-images
-- Public: true (so images can be accessed without authentication)

-- Note: Run this in the Supabase Dashboard SQL Editor:
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('project-images', 'project-images', true)
-- ON CONFLICT (id) DO NOTHING;

-- Storage Policy: Anyone can read project images
-- CREATE POLICY "Anyone can read project images"
--     ON storage.objects
--     FOR SELECT
--     TO public
--     USING (bucket_id = 'project-images');

-- Storage Policy: Only admins can upload project images
-- CREATE POLICY "Admins can upload project images"
--     ON storage.objects
--     FOR INSERT
--     TO authenticated
--     WITH CHECK (
--         bucket_id = 'project-images' AND
--         EXISTS (
--             SELECT 1 FROM public.admins
--             WHERE admins.user_id = auth.uid()
--         )
--     );

-- Storage Policy: Only admins can delete project images
-- CREATE POLICY "Admins can delete project images"
--     ON storage.objects
--     FOR DELETE
--     TO authenticated
--     USING (
--         bucket_id = 'project-images' AND
--         EXISTS (
--             SELECT 1 FROM public.admins
--             WHERE admins.user_id = auth.uid()
--         )
--     );

-- ===================================================================
-- 6. INSERT SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ===================================================================

-- Sample projects (you can remove this after testing)
-- INSERT INTO public.projects (title, description, tech_stack, image_url)
-- VALUES 
--     ('Flutter E-Commerce App', 'A full-featured e-commerce mobile application built with Flutter', 'Flutter, Dart, Firebase, Stripe', NULL),
--     ('Restaurant Booking System', 'Mobile app for restaurant table booking with real-time updates', 'Flutter, Dart, Supabase, Google Maps', NULL),
--     ('Fitness Tracker', 'Track your workouts and progress with this comprehensive fitness app', 'Flutter, Dart, SQLite, Charts', NULL);

-- ===================================================================
-- 7. ADD YOUR ADMIN USER
-- ===================================================================

-- After creating a user in Supabase Auth, add them to the admins table:
-- 
-- Step 1: Go to Supabase Dashboard -> Authentication -> Users
-- Step 2: Create a new user with email and password
-- Step 3: Copy the user's UUID
-- Step 4: Run this query (replace USER_UUID and EMAIL with your values):
--
-- INSERT INTO public.admins (user_id, email)
-- VALUES ('USER_UUID_HERE', 'your-email@example.com');
--
-- Example:
-- INSERT INTO public.admins (user_id, email)
-- VALUES ('123e4567-e89b-12d3-a456-426614174000', 'admin@example.com');

-- ===================================================================
-- SETUP COMPLETE!
-- ===================================================================
-- 
-- Next steps:
-- 1. Update your Flutter app's AppConstants with Supabase URL and anon key
-- 2. Create an admin user in Supabase Auth
-- 3. Add the admin user to the admins table
-- 4. Create the storage bucket for project images
-- 5. Test the app!
-- 
-- ===================================================================
