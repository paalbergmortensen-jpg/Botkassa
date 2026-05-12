import 'package:cloud_firestore/cloud_firestore.dart';

class Appeal {
  final String id;
  final String fineId;
  final String videoUrl;
  final int yesVotes;
  final int noVotes;
  final DateTime expiresAt;

  Appeal({
    required this.id,
    required this.fineId,
    required this.videoUrl,
    required this.yesVotes,
    required this.noVotes,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fineId': fineId,
      'videoUrl': videoUrl,
      'yesVotes': yesVotes,
      'noVotes': noVotes,
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory Appeal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Appeal(
      id: doc.id,
      fineId: data['fineId'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      yesVotes: data['yesVotes'] ?? 0,
      noVotes: data['noVotes'] ?? 0,
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }
}
