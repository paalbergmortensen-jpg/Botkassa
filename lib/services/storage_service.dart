import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<String?> uploadFineEvidence(String filePath, String fineId) async {
    if (kIsWeb) return null; // Storage not configured for web preview

    try {
      final ref = _storage.ref().child('fines').child('$fineId.jpg');
      // Use dynamic constructor call to hide from web compiler
      final dynamic file = (File as dynamic)(filePath);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
