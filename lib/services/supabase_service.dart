import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nodhapp/models/cart_item_model.dart';
import 'package:nodhapp/models/perfume_models.dart';
import 'package:nodhapp/models/order_model.dart';
import 'package:nodhapp/screens/login/userProfile.dart'; 

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;
  // Getter for the current user's ID to use in address fetching
  String? get currentUserId => client.auth.currentUser?.id; // ⭐ ADDED/CONFIRMED GETTER

  // --------------------------------------------------------------------------
  // AUTH METHODS
  // --------------------------------------------------------------------------

  /// SIGN UP with username stored in user_metadata and user_profiles table
  Future<void> signUp(String email, String password, String username) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw 'Signup failed: User is null';
      }

      // Insert into user_profiles table
      await client.from('user_profiles').insert({
        'id': response.user!.id,
        'email': email,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Unexpected error occurred during sign up: $e';
    }
  }

  /// SIGN IN
  Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Unexpected error occurred during sign in';
    }
  }

  /// SIGN OUT
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Unexpected error occurred sending password reset email';
    }
  }

  // --------------------------------------------------------------------------
  // CART METHODS
  // --------------------------------------------------------------------------

  Future<List<CartItem>> getCartItems() async {
    if (currentUser == null) return [];
    try {
      final response = await client
          .from('cart_items')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: true);

      // Cast response to List<Map<String, dynamic>> if possible
      final data = response as List<dynamic>;

      return data
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching cart items: $e');
      return [];
    }
  }

  Future<CartItem?> upsertCartItem(Perfume perfume, String size, int quantity) async {
    if (currentUser == null) return null;

    final data = {
      'user_id': currentUser!.id,
      'product_id': perfume.id,
      'product_name': perfume.name,
      'product_brand': perfume.brand,
      'product_image_url': perfume.imageUrl,
      'product_size': size,
      'price': perfume.prices[size] ?? 0.0,
      'quantity': quantity,
    };

    try {
      final response = await client
          .from('cart_items')
          .upsert(
            data,
            onConflict: 'user_id,product_id,product_size',
          )
          .select()
          .single();

      return CartItem.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Error upserting cart item: $e');
      return null;
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      await client.from('cart_items').update({'quantity': quantity}).eq('id', cartItemId);
    } catch (e) {
      debugPrint('❌ Error updating quantity: $e');
    }
  }

  Future<void> removeCartItem(String cartItemId) async {
    try {
      await client.from('cart_items').delete().eq('id', cartItemId);
    } catch (e) {
      debugPrint('❌ Error removing cart item: $e');
    }
  }

  Future<void> clearCart() async {
    if (currentUser == null) return;
    try {
      await client.from('cart_items').delete().eq('user_id', currentUser!.id);
    } catch (e) {
      debugPrint('❌ Error clearing cart: $e');
    }
  }

  // --------------------------------------------------------------------------
  // USER PROFILE METHODS
  // --------------------------------------------------------------------------

  /// Fetch current user's profile and convert to UserProfile model.
  Future<UserProfile?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      // 1. Attempt to fetch profile using maybeSingle() which returns null if 0 rows
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); 

      if (response == null) {
        // 2. Profile does not exist (response is null) - Create it
        debugPrint('ℹ️ User profile missing, creating new record.');

        final Map<String, dynamic> newProfileData = {
          'id': user.id,
          'email': user.email,
          'username': user.userMetadata?['username'] ?? 'User ${user.id.substring(0, 4)}',
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          final newResponse = await client
              .from('user_profiles')
              .insert(newProfileData)
              .select()
              .single(); 

          // Return the newly created profile
          return UserProfile.fromMap(newResponse as Map<String, dynamic>);
        } catch (insertError) {
          debugPrint('❌ Error inserting new user profile: $insertError');
          return null; 
        }
      }

      // 3. Profile was found, return it
      return UserProfile.fromMap(response as Map<String, dynamic>);
      
    } catch (e) {
      debugPrint('❌ Unexpected error in getUserProfile: $e');
      return null;
    }
  }

  // ⭐ NEW METHOD: Fetch the user's saved shipping address from 'user_profiles'
  Future<Map<String, dynamic>?> fetchShippingAddress() async {
    if (currentUserId == null) return null;

    try {
      final response = await client
          .from('user_profiles')
          .select('full_name, address_line_1, city, postal_code')
          .eq('id', currentUserId!) // 'id' in 'user_profiles' is the user's UUID
          .maybeSingle();
      
      // response will be null if no profile exists, or the map if found
      if (response == null) return null;

      return response as Map<String, dynamic>; 
    } catch (e) {
      debugPrint('❌ Error fetching shipping address: $e');
      return null;
    }
  }

  // --- Dedicated function for saving shipping address from Checkout ---
  Future<void> saveShippingAddress({
    required String fullName,
    required String addressLine1,
    required String city,
    required String postalCode,
  }) async {
    if (currentUser == null) {
      throw 'User not authenticated. Cannot save address.';
    }

    final data = {
      'full_name': fullName,
      'address_line_1': addressLine1, 
      'city': city,
      'postal_code': postalCode, 
    };

    try {
      await client
          .from('user_profiles')
          .update(data)
          .eq('id', currentUser!.id);
          
      debugPrint('✅ Shipping address saved successfully.');
    } catch (e) {
      debugPrint('❌ Error saving shipping address: $e');
      rethrow;
    }
  }

  /// Update user profile (generic update method)
  Future<void> updateUserProfile({
    String? fullName,
    String? phone,
    String? address, // Kept for backward compatibility if used elsewhere
    // Add new address fields to the generic update method
    String? addressLine1,
    String? city,
    String? postalCode,
  }) async {
    if (currentUser == null) return;

    final data = {
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      // Mapping new fields:
      if (addressLine1 != null) 'address_line_1': addressLine1,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
    };

    if (data.isEmpty) return;

    try {
      await client.from('user_profiles').update(data).eq('id', currentUser!.id);
      debugPrint('✅ User profile updated successfully.');
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
    }
  }

  // --------------------------------------------------------------------------
  // ORDER METHODS (Status Tracking) 🚀
  // --------------------------------------------------------------------------

  /// Fetches all orders for the current user to display for tracking.
  Future<List<OrderModel>> getMyOrders() async {
    if (currentUser == null) return [];
    try {
      final response = await client
          .from('orders')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;

      return data
          .map((item) => OrderModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching user orders: $e');
      return [];
    }
  }

  /// Finalizes the checkout by creating an order record and clearing the cart.
  /// This is the function you must call after successful payment to save the order.
  Future<void> finalizeCheckout({
    required double totalAmount,
    required List<Map<String, dynamic>> orderItems, // Details of the items bought
    String initialStatus = 'Pending', // Initial status
  }) async {
    if (currentUser == null) {
      throw 'User not authenticated. Cannot finalize order.';
    }

    // 1. Create the Order Record in the 'orders' table
    try {
      // ⭐ Safety improvement: Fetch the current user's address before inserting the order
      final addressData = await fetchShippingAddress();

      await client.from('orders').insert({
        'user_id': currentUser!.id,
        'total_amount': totalAmount,
        'items': orderItems, // Assuming 'items' column is of type JSONB/JSON
        'status': initialStatus,
        'created_at': DateTime.now().toIso8601String(),
        'shipping_address': addressData, // ⭐ ADDED shipping address for record-keeping
      });
      debugPrint('✅ Order record created successfully with status: $initialStatus');
    } catch (e) {
      debugPrint('❌ Error creating order record: $e');
      throw 'Failed to create order record.';
    }

    // 2. Clear the User's Cart
    try {
      await clearCart();
      debugPrint('✅ Cart cleared successfully.');
    } catch (e) {
      debugPrint('⚠️ Warning: Order created, but failed to clear cart: $e');
      // Do not rethrow; the most important step (order creation) succeeded.
    }
  }
}