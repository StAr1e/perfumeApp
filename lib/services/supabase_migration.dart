// This file contains the SQL migration script to update the 'cart_items' table.
// Run this script in your Supabase SQL Editor.

const String migrationScript = '''
-- Add the new column with a default value for existing rows, making migration safe.
ALTER TABLE cart_items ADD COLUMN IF NOT EXISTS product_size TEXT NOT NULL DEFAULT '50ml';

-- Drop the old unique constraint if it exists.
-- The name 'cart_items_user_id_product_id_key' is the standard name Supabase generates.
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_user_id_product_id_key;

-- We also drop the new constraint name just in case this script is run multiple times to make it idempotent.
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_user_id_product_id_product_size_key;

-- Add the new, more specific unique constraint to prevent duplicate entries for the same user, product, and size.
ALTER TABLE cart_items ADD CONSTRAINT cart_items_user_id_product_id_product_size_key UNIQUE (user_id, product_id, product_size);

-- Add the new column to the RLS policies to ensure it's selectable.
-- The existing policies for INSERT, UPDATE, DELETE already cover all columns, but SELECT needs to be specific.
-- Recreating the SELECT policy ensures the new column is included.
DROP POLICY IF EXISTS "Users can view their own cart items" ON cart_items;
CREATE POLICY "Users can view their own cart items"
ON cart_items
FOR SELECT
USING (auth.uid() = user_id);
''';