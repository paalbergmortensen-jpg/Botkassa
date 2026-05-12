import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../models/user.dart';
import '../models/fine.dart';
import '../models/fine_type.dart';
import '../models/appeal.dart';
import 'auth_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).streamUser(user.uid);
});

final teamFinesProvider = StreamProvider<List<Fine>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null || profile.teamId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).streamFines(profile.teamId!);
});

final teamLeaderboardProvider = StreamProvider<List<AppUser>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null || profile.teamId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).streamTeamPlayers(profile.teamId!);
});

final teamAppealsProvider = StreamProvider<List<Appeal>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null || profile.teamId == null) return Stream.value([]);
  return ref.watch(firestoreServiceProvider).streamAppeals(profile.teamId!);
});

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Teams
  Future<String> createTeamWithCode(String name, String ownerId) async {
    String code = _generateRandomCode();
    
    // Ensure code is unique (simple check)
    final existing = await _db.collection('teams').where('code', isEqualTo: code).get();
    if (existing.docs.isNotEmpty) {
      code = _generateRandomCode(); // Try once more
    }

    final teamDoc = _db.collection('teams').doc();
    final team = Team(
      id: teamDoc.id,
      name: name,
      code: code,
      ownerId: ownerId,
      isSubscriptionActive: true,
    );

    await teamDoc.set(team.toMap());
    
    // Update user's teamId and role
    await _db.collection('users').doc(ownerId).update({
      'teamId': teamDoc.id,
      'role': UserRole.admin.index,
    });

    return code;
  }

  Future<bool> joinTeam(String code, String userId) async {
    final query = await _db.collection('teams').where('code', isEqualTo: code).get();
    if (query.docs.isEmpty) return false;

    final teamId = query.docs.first.id;
    await _db.collection('users').doc(userId).update({
      'teamId': teamId,
      'role': UserRole.player.index,
    });
    return true;
  }

  String _generateRandomCode() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 6);
  }

  Stream<Team?> streamTeam(String teamId) {
    return _db.collection('teams').doc(teamId).snapshots().map((doc) {
      if (doc.exists) return Team.fromFirestore(doc);
      return null;
    });
  }

  // Users
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Stream<AppUser?> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) return AppUser.fromFirestore(doc);
      return null;
    });
  }

  Stream<List<AppUser>> streamTeamPlayers(String teamId) {
    return _db
        .collection('users')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  // Fines
  Future<void> addFine(Fine fine) async {
    await _db.collection('fines').add(fine.toMap());
  }

  Stream<List<Fine>> streamFines(String teamId) {
    return _db
        .collection('fines')
        .where('teamId', isEqualTo: teamId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Fine.fromFirestore(doc)).toList());
  }

  // Appeals
  Future<void> createAppeal(Appeal appeal) async {
    await _db.collection('appeals').doc(appeal.id).set(appeal.toMap());
  }

  Future<void> voteOnAppeal(String appealId, String userId, bool isFor) async {
    final field = isFor ? 'votesFor' : 'votesAgainst';
    await _db.collection('appeals').doc(appealId).update({
      field: FieldValue.arrayUnion([userId]),
    });
  }

  Stream<List<Appeal>> streamAppeals(String teamId) {
    return _db
        .collection('appeals')
        .where('teamId', isEqualTo: teamId)
        .where('status', isEqualTo: AppealStatus.pending.index)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Appeal.fromFirestore(doc)).toList());
  }

  // Fine Types
  Future<void> addFineType(FineType type) async {
    await _db.collection('fineTypes').doc(type.id).set(type.toMap());
  }

  Future<void> deleteFineType(String typeId) async {
    await _db.collection('fineTypes').doc(typeId).delete();
  }

  Stream<List<FineType>> streamFineTypes() {
    return _db.collection('fineTypes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FineType.fromFirestore(doc)).toList();
    });
  }
}
