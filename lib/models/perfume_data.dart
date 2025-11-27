import 'package:nodhapp/models/perfume_models.dart';

class PerfumeData {
  static List<Perfume> getPerfumes() {
    return [
      // FIX 1: Changed Perfumed to Perfume
      Perfume(
        id: 'p1',
        name: 'HOTHi',
        brand: 'NODH',
        // FIX 2: Added 'category'
        category: 'Fresh', 
        description:
            'A fresh, aquatic fragrance that captures the essence of a coastal breeze, with hints of citrus and sea salt.',
        prices: {'50ml': 120, '100ml': 180},
        imageUrl: 'assets/hothi.jpeg',
        notes: {
          'top': 'Bergamot, Lemon, Sea Salt',
          'heart': 'Jasmine, Lily, Marine Accord',
          'base': 'Cedarwood, Musk, Ambergris',
        },
      ),
      Perfume(
        id: 'p2',
        name: 'QAZI',
        brand: 'NODH',
        // FIX 2: Added 'category'
        category: 'Spicy', 
        description:
            'A mysterious and seductive scent with deep woody notes, spicy undertones, and a touch of dark chocolate.',
        prices: {'50ml': 185, '100ml': 250},
        imageUrl: 'assets/qazi.png',
        notes: {
          'top': 'Black Pepper, Cardamom',
          'heart': 'Oud, Sandalwood, Dark Chocolate',
          'base': 'Vanilla, Tonka Bean, Vetiver',
        },
      ),
      Perfume(
        id: 'p3',
        name: 'MISK',
        brand: 'NODH',
        // FIX 2: Added 'category'
        category: 'Floral', 
        description:
            'An elegant and romantic floral bouquet, dominated by lush roses and peonies, with a soft powdery finish.',
        prices: {'50ml': 150, '100ml': 220},
        imageUrl: 'assets/misk.png',
        notes: {
          'top': 'Peony, Lychee, Freesia',
          'heart': 'Rose, Magnolia, Lily of the Valley',
          'base': 'White Musk, Cedar, Amber',
        },
      ),
      Perfume(
        id: 'p4',
        name: 'HOTHI',
        brand: 'NODH',
        // FIX 2: Added 'category'
        category: 'Citrus', 
        description: 'A vibrant and zesty fragrance that evokes a sun-drenched citrus orchard in the Mediterranean.',
        prices: {'50ml': 95, '100ml': 140},
        imageUrl: 'assets/hothii.jpeg',
        notes: {
          'top': 'Grapefruit, Mandarin, Verbena',
          'heart': 'Neroli, Basil, Orange Blossom',
          'base': 'Oakmoss, Patchouli',
        },
      ),
      Perfume(
        id: 'p5',
        name: 'MUSK',
        brand: 'NODH',
        // FIX 2: Added 'category'
        category: 'Spicy', 
        description: 'A warm and inviting scent that wraps you in a cozy blanket of amber, vanilla, and exotic spices.',
        prices: {'50ml': 160, '100ml': 235},
        imageUrl: 'assets/musk.jpeg',
        notes: {
          'top': 'Cinnamon, Clove',
          'heart': 'Labdanum, Incense',
          'base': 'Amber, Vanilla, Benzoin',
        },
      ),
      Perfume(
        id: 'p6',
        name: 'NODH',
        brand: 'NODH',
        // FIX 2: Added 'category'
        category: 'Woody', 
        description:
            'A grounded and sophisticated fragrance with dominant notes of vetiver and patchouli, reminiscent of a forest floor after rain.',
        prices: {'50ml': 140, '100ml': 205},
        imageUrl: 'assets/nodhh.jpeg',
        notes: {
          'top': 'Pink Pepper, Bergamot',
          'heart': 'Vetiver, Iris',
          'base': 'Patchouli, Oakmoss, Leather',
        },
      ),
    ];
  }
}