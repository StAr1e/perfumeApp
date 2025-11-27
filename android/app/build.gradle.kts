// File: cart_manager.dart
import 'package:flutter/material.dart';
import 'cart_item_model.dart';
import 'perfume_model.dart';
import 'supabase_service.dart';

class CartManager extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  Function()? onAuthRequired;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  CartManager() {
    // Listen to auth changes to automatically fetch/clear the cart.
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        fetchCartItems();
      } else {
        _cartItems = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cartItems = await _supabaseService.getCartItems();
    } catch (e) {
      debugPrint("Error fetching cart items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Perfume perfume, String size, int quantity) async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      onAuthRequired?.call();
      return;
    }

    // Use the robust upsert RPC which handles both inserts and updates atomically.
    final upsertedItem = await _supabaseService.upsertCartItem(perfume, size, quantity);

    if (upsertedItem != null) {
      // Find if the item already exists in the local list to update it, otherwise add it.
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.productId == upsertedItem.productId && item.size == upsertedItem.size
      );

      if (existingItemIndex != -1) {
        // Item exists, replace it with the definitive version from the database.
        _cartItems[existingItemIndex] = upsertedItem;
      } else {
        // This is a new item, add it to the local cart list.
        _cartItems.add(upsertedItem);
      }
    } else {
      // If the upsert fails for some reason, refresh the whole cart to ensure consistency.
      await fetchCartItems();
    }
    
    notifyListeners();
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    final itemIndex = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      if (newQuantity > 0) {
        _cartItems[itemIndex].quantity = newQuantity;
        await _supabaseService.updateCartItemQuantity(cartItemId, newQuantity);
      } else {
        await removeFromCart(cartItemId);
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    await _supabaseService.removeCartItem(cartItemId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    await _supabaseService.clearCart();
    _cartItems.clear();
    notifyListeners();
  }
}

// File: supabase_rpc.dart
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

// File: supabase_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_item_model.dart';
import 'perfume_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Future<void> signUp(String email, String password) async {
    try {
      await client.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Cart Methods
  Future<List<CartItem>> getCartItems() async {
    if (currentUser == null) return [];
    try {
      final response = await client
          .from('cart_items')
          .select()
          .order('created_at', ascending: true);
      
      return response.map((item) => CartItem.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      return [];
    }
  }

  Future<CartItem?> upsertCartItem(Perfume perfume, String size, int quantity) async {
    if (currentUser == null) return null;
    try {
      final response = await client.rpc('add_to_cart', params: {
        'p_product_id': perfume.id,
        'p_product_size': size,
        'p_quantity': quantity,
        'p_product_name': perfume.name,
        'p_product_brand': perfume.brand,
        'p_product_image_url': perfume.imageUrl,
        'p_price': perfume.prices[size] ?? 0.0,
      });

      if (response != null && response is List && response.isNotEmpty) {
        return CartItem.fromMap(response.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error upserting cart item: $e');
      return null;
    }
  }

  Future<CartItem?> addCartItem(CartItem item) async {
    try {
      final response = await client
          .from('cart_items')
          .insert(item.toMap())
          .select()
          .single();
      
      return CartItem.fromMap(response);
    } catch (e) {
      debugPrint('Error adding cart item: $e');
      return null;
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      await client
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId);
    } catch (e) {
      debugPrint('Error updating cart item: $e');
    }
  }

  Future<void> removeCartItem(String cartItemId) async {
    try {
      await client
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
    } catch (e) {
      debugPrint('Error removing cart item: $e');
    }
  }

  Future<void> clearCart() async {
    if (currentUser == null) return;
    try {
      await client
          .from('cart_items')
          .delete()
          .eq('user_id', currentUser!.id);
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
}

//Dependencies: [device_preview,google_fonts,cached_network_image,flutter_animate,shimmer,supabase_flutter,cupertino_icons]
//Permissions: []