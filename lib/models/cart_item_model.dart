import 'perfume_models.dart';

class CartItem {
  final String? id; 
  final String userId;
  final String productId;
  final String name;
  final String brand;
  final String imageUrl;
  final String size; 
  final double price;
  int quantity;
  final DateTime createdAt;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.size,
    required this.price,
    required this.quantity,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  
  factory CartItem.fromPerfume(
    Perfume perfume,
    String userId,
    String size,
    int quantity,
  ) {
    return CartItem(
      userId: userId,
      productId: perfume.id,
      name: perfume.name,
      brand: perfume.brand,
      imageUrl: perfume.imageUrl,
      size: size,
      price: perfume.prices[size] ?? 0.0,
      quantity: quantity < 1 ? 1 : quantity, 
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      productId: map['product_id']?.toString() ?? '',
      name: map['product_name']?.toString() ?? '',
      brand: map['product_brand']?.toString() ?? '',
      imageUrl: map['product_image_url']?.toString() ?? '',
      size: map['product_size']?.toString() ?? '50ml',
      price: map['price'] != null ? (map['price'] as num).toDouble() : 0.0,
      quantity: map['quantity'] != null ? map['quantity'] as int : 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': name,
      'product_brand': brand,
      'product_image_url': imageUrl,
      'product_size': size,
      'price': price,
      'quantity': quantity < 1 ? 1 : quantity, // ensure quantity >= 1
    };
  }

  
  Map<String, dynamic> toMapForOrder() {
    return {
      'product_id': productId,
      'product_name': name,
      'product_brand': brand,
      'product_image_url': imageUrl,
      'size': size,
      'price_per_unit': price,
      'quantity': quantity,
      'subtotal': price * quantity,
    };
  }
}