/// supabaseConstant.dart
/// Contains Supabase table and column constants for easy reference in the project.

class SupabaseConstants {
  // -----------------------
  // Tables
  // -----------------------
  static const String usersTable = 'users';
  static const String perfumesTable = 'perfumes';
  static const String cartTable = 'cart_items';
  static const String ordersTable = 'orders';
  static const String favoritesTable = 'favorites';

  // -----------------------
  // Columns - Users
  // -----------------------
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userCreatedAt = 'created_at';

  // -----------------------
  // Columns - Perfumes
  // -----------------------
  static const String perfumeId = 'id';
  static const String perfumeName = 'name';
  static const String perfumeBrand = 'brand';
  static const String perfumeImageUrl = 'image_url';
  static const String perfumePrices = 'prices';
  static const String perfumeCreatedAt = 'created_at';

  // -----------------------
  // Columns - Cart Items
  // -----------------------
  static const String cartId = 'id';
  static const String cartUserId = 'user_id';
  static const String cartProductId = 'product_id';
  static const String cartProductName = 'product_name';
  static const String cartProductBrand = 'product_brand';
  static const String cartProductImageUrl = 'product_image_url';
  static const String cartProductSize = 'product_size';
  static const String cartPrice = 'price';
  static const String cartQuantity = 'quantity';
  static const String cartCreatedAt = 'created_at';

  // -----------------------
  // Columns - Orders
  // -----------------------
  static const String orderId = 'id';
  static const String orderUserId = 'user_id';
  static const String orderTotalAmount = 'total_amount';
  static const String orderStatus = 'status';
  static const String orderCreatedAt = 'created_at';

  // -----------------------
  // Columns - Favorites
  // -----------------------
  static const String favoriteId = 'id';
  static const String favoriteUserId = 'user_id';
  static const String favoriteProductId = 'product_id';
  static const String favoriteCreatedAt = 'created_at';

  // -----------------------
  // Supabase related constants
  // -----------------------
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
