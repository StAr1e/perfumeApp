import 'package:flutter/foundation.dart';
import 'package:nodhapp/models/cart_item_model.dart';
import 'package:nodhapp/services/supabase_service.dart';
import 'package:nodhapp/models/perfume_models.dart';

class CartManager extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  Function()? onAuthRequired;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

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
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 💥 FIX: Wrapper method to support simple calls from PerfumeCard 💥
  Future<void> addItem(Perfume perfume) async {
    // Assuming default size and quantity for a quick add button
    const defaultSize = '50ml'; // Use a default size relevant to your app
    const defaultQuantity = 1;
    await addToCart(perfume, defaultSize, defaultQuantity);
  }


  Future<void> addToCart(Perfume perfume, String size, int quantity) async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      onAuthRequired?.call();
      return;
    }

    try {
      final upsertedItem =
          await _supabaseService.upsertCartItem(perfume, size, quantity);

      if (upsertedItem != null) {
        final existingIndex = _cartItems.indexWhere((item) =>
            item.productId == upsertedItem.productId &&
            item.size == upsertedItem.size);

        if (existingIndex != -1) {
          _cartItems[existingIndex] = upsertedItem;
        } else {
          _cartItems.add(upsertedItem);
        }
        notifyListeners();
      } else {
        debugPrint("Upsert returned null, refreshing cart...");
        await fetchCartItems();
      }
    } catch (e) {
      debugPrint("Error adding item to cart: $e");
      await fetchCartItems(); // Ensure consistency
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) return;

    if (newQuantity > 0) {
      _cartItems[index].quantity = newQuantity;
      try {
        await _supabaseService.updateCartItemQuantity(cartItemId, newQuantity);
      } catch (e) {
        debugPrint("Error updating quantity: $e");
      }
    } else {
      await removeFromCart(cartItemId);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(String cartItemId) async {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    try {
      await _supabaseService.removeCartItem(cartItemId);
    } catch (e) {
      debugPrint("Error removing cart item: $e");
    }
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    notifyListeners();
    try {
      await _supabaseService.clearCart();
    } catch (e) {
      debugPrint("Error clearing cart: $e");
    }
  }
}