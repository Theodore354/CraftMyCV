// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_helper_app/models/index.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  /// Save (create or update) a CV document under the user's collection.
  /// Returns the Firestore document ID used.
  static Future<String> saveCv(String userId, CvModel cv) async {
    final userRef = _db.collection('users').doc(userId).collection('cvs');

    if (cv.id == null || cv.id!.isEmpty) {
      // Create new doc
      final docRef = await userRef.add(cv.toJson());
      return docRef.id;
    } else {
      // Update existing or create with provided ID
      final docRef = userRef.doc(cv.id);
      await docRef.set(cv.toJson(), SetOptions(merge: true));
      return docRef.id;
    }
  }

  /// Load all CVs for a user.
  static Future<List<CvModel>> getCvs(String userId) async {
    final snapshot =
        await _db.collection('users').doc(userId).collection('cvs').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final cv = CvModel.fromJson(data);
      // Ensure Firestore ID is also set
      return cv.copyWith(id: doc.id);
    }).toList();
  }

  /// Delete a CV by ID
  static Future<void> deleteCv(String userId, String cvId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cvs')
        .doc(cvId)
        .delete();
  }
}
