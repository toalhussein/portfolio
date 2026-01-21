-- Add is_read column to contact_messages table if it doesn't exist
-- Run this in Supabase SQL Editor

-- Add the is_read column
ALTER TABLE public.contact_messages 
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE NOT NULL;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_contact_messages_is_read 
ON public.contact_messages(is_read);

-- Update existing records to be unread by default
UPDATE public.contact_messages 
SET is_read = FALSE 
WHERE is_read IS NULL;
