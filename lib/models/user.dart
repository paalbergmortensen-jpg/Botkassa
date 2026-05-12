import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, player }

class AppUser {
  final String id;
  final String name;
  final UserRole role;
  final String? teamId;
  final double balance;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.teamId,
    required this.balance,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role.index,
      'teamId': teamId,
      'balance': balance,
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      role: UserRole.values[data['role'] ?? 1],
      teamId: data['teamId'],
      balance: (data['balance'] ?? 0).toDouble(),
    );
  }
}
