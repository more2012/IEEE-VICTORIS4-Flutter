class AlternativeMedicine {
  final String id;
  final String name;
  final String activeIngredient;
  final String dosage;
  final String manufacturer;
  final double price;
  final String description;
  final double similarityPercentage;
  final List<String> sideEffects;
  final String availability;
  final String imageUrl;

  AlternativeMedicine({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.dosage,
    required this.manufacturer,
    required this.price,
    required this.description,
    required this.similarityPercentage,
    required this.sideEffects,
    required this.availability,
    this.imageUrl = '',
  });

  factory AlternativeMedicine.fromJson(Map<String, dynamic> json) {
    return AlternativeMedicine(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      activeIngredient: json['active_ingredient']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      manufacturer: json['manufacturer']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      similarityPercentage: (json['similarity_percentage'] as num?)?.toDouble() ?? 0.0,
      sideEffects: List<String>.from(json['side_effects'] ?? []),
      availability: json['availability']?.toString() ?? 'Unknown',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active_ingredient': activeIngredient,
      'dosage': dosage,
      'manufacturer': manufacturer,
      'price': price,
      'description': description,
      'similarity_percentage': similarityPercentage,
      'side_effects': sideEffects,
      'availability': availability,
      'image_url': imageUrl,
    };
  }

  @override
  String toString() {
    return 'AlternativeMedicine{id: $id, name: $name, activeIngredient: $activeIngredient, price: $price}';
  }
}