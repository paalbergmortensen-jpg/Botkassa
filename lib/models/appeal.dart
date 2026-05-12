import 'package:cloud_firestore/cloud_firestore.dart';

enum AppealStatus { pending, approved, rejected }
enum EvidenceType { text, image, video }

class Appeal {
  final String id;
  final String fineId;
  final String userId;
  final String userName;
  final String teamId;
  final String reason;
  final String? evidenceUrl;
  final EvidenceType evidenceType;
  final DateTime date;
  final DateTime expiryDate;
  final List<String> votesFor; // User IDs
  final List<String> votesAgainst; // User IDs
  final AppealStatus status;

  Appeal({
    required this.id,
    required this.fineId,
    required this.userId,
    required this.userName,
    required this.teamId,
    required this.reason,
    this.evidenceUrl,
    required this.evidenceType,
    required this.date,
    required this.expiryDate,
    required this.votesFor,
    required this.votesAgainst,
    this.status = AppealStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fineId': fineId,
      'userId': userId,
      'userName': userName,
      'teamId': teamId,
      'reason': reason,
      'evidenceUrl': evidenceUrl,
      'evidenceType': evidenceType.index,
      'date': Timestamp.fromDate(date),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'votesFor': votesFor,
      'votesAgainst': votesAgainst,
      'status': status.index,
    };
  }

  factory Appeal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Appeal(
      id: doc.id,
      fineId: data['fineId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      teamId: data['teamId'] ?? '',
      reason: data['reason'] ?? '',
      evidenceUrl: data['evidenceUrl'],
      evidenceType: EvidenceType.values[data['evidenceType'] ?? 0],
      date: (data['date'] as Timestamp).toDate(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      votesFor: List<String>.from(data['votesFor'] ?? []),
      votesAgainst: List<String>.from(data['votesAgainst'] ?? []),
      status: AppealStatus.values[data['status'] ?? 0],
    );
  }
}
