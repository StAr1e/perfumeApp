class OrderModel {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items, 
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    // Safely parse the createdAt string.
    final DateTime parsedCreatedAt = map['created_at'] != null 
        ? DateTime.parse(map['created_at'] as String) 
        : DateTime.now();

    // Safely parse the items list, handling null or non-list data if necessary.
    final List<dynamic> rawItems = map['items'] is List ? map['items'] as List<dynamic> : [];
    final List<Map<String, dynamic>> parsedItems = rawItems
        .whereType<Map<String, dynamic>>() // Filter out non-map entries just in case
        .toList();

    return OrderModel(
      id: map['id']?.toString() ?? 'N/A',
      status: map['status']?.toString() ?? 'Unknown',
      // FIX: Ensure 'total_amount' is safely converted to a double from whatever 'num' type it is.
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0, 
      createdAt: parsedCreatedAt,
      items: parsedItems,
    );
  }
}