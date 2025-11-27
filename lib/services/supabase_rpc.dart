// This file contains the SQL for the PostgreSQL function needed for atomic cart operations.
// Run this script once in your Supabase SQL Editor.
// This function handles both adding a new item and updating the quantity of an existing item.

const String rpcScript = '''
create or replace function add_to_cart(
  p_product_id text,
  p_product_size text,
  p_quantity int,
  p_product_name text,
  p_product_brand text,
  p_product_image_url text,
  p_price double precision
)
returns SETOF cart_items -- This returns the full row type of the 'cart_items' table
as \$\$
begin
  -- Use UPSERT functionality to either insert a new row or update an existing one.
  insert into cart_items (user_id, product_id, product_size, quantity, product_name, product_brand, product_image_url, price)
  values (auth.uid(), p_product_id, p_product_size, p_quantity, p_product_name, p_product_brand, p_product_image_url, p_price)
  on conflict (user_id, product_id, product_size)
  do update set
    -- If the item exists, add the new quantity to the existing quantity.
    quantity = cart_items.quantity + p_quantity;

  -- After the insert or update, return the final state of the row.
  return query
    select *
    from cart_items
    where user_id = auth.uid()
      and product_id = p_product_id
      and product_size = p_product_size;
end;
\$\$ language plpgsql security definer;
''';