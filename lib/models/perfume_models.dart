class Perfume {
  final String id;
  final String name;
  final String brand;
  final String description;
  final Map<String, double> prices;
  final String imageUrl;
  final Map<String, String> notes;
  final String category;
  

  Perfume({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.prices,
    required this.imageUrl,
    required this.notes,
    required this.category,
  });
}