class FuelTypeModel {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  const FuelTypeModel({
    required this.id,
    required this.name,
    required this.price,
    this.isAvailable = true,
  });

  factory FuelTypeModel.fromMap(Map<String, dynamic> map) {
    return FuelTypeModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'isAvailable': isAvailable,
      };
}
