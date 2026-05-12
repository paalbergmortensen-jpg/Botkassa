import 'package:cloud_firestore/cloud_firestore.dart';

enum FineStatus { unpaid, paid, appealed, deleted }

class Fine {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final String typeId;
  final String typeName;
  final double amount;
  final bool isPaid;
  final String? evidenceUrl;

  Fine({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.typeId,
    required this.typeName,
    required this.amount,
    required this.isPaid,
    this.evidenceUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'date': Timestamp.fromDate(date),
      'typeId': typeId,
      'typeName': typeName,
      'amount': amount,
      'isPaid': isPaid,
      'evidenceUrl': evidenceUrl,
    };
  }

  factory Fine.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Fine(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      typeId: data['typeId'] ?? '',
      typeName: data['typeName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      isPaid: data['isPaid'] ?? false,
      evidenceUrl: data['evidenceUrl'],
    );
  }
}
