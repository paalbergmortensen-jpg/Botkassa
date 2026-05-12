import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String code;
  final String ownerId;
  final bool isSubscriptionActive;

  Team({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    required this.isSubscriptionActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'ownerId': ownerId,
      'isSubscriptionActive': isSubscriptionActive,
    };
  }

  factory Team.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Team(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      ownerId: data['ownerId'] ?? '',
      isSubscriptionActive: data['isSubscriptionActive'] ?? false,
    );
  }
}
