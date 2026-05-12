import 'package:cloud_firestore/cloud_firestore.dart';

class FineType {
  final String id;
  final String name;
  final double price;
  final String icon;

  FineType({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'icon': icon,
    };
  }

  factory FineType.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return FineType(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      icon: data['icon'] ?? '💰',
    );
  }
}
