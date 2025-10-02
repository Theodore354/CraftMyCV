import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cv_helper_app/models/cv_model.dart';

class FirestoreService {
  static CollectionReference<Map<String, dynamic>> _userCvsRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('cvs');

  /// One-shot fetch (sorted by last update).
  static Future<List<CvModel>> getCvs(String uid) async {
    final snap =
        await _userCvsRef(uid).orderBy('updatedAt', descending: true).get();
    return snap.docs.map((d) => CvModel.fromMap(d.data(), id: d.id)).toList();
  }

  /// Live stream (handy for list screens).
  static Stream<List<CvModel>> watchCvs(String uid) {
    return _userCvsRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => CvModel.fromMap(d.data(), id: d.id)).toList(),
        );
  }

  /// Fetch a single CV.
  static Future<CvModel?> getCv(String uid, String cvId) async {
    final doc = await _userCvsRef(uid).doc(cvId).get();
    if (!doc.exists) return null;
    return CvModel.fromMap(doc.data()!, id: doc.id);
  }

  /// Watch a single CV.
  static Stream<CvModel?> watchCv(String uid, String cvId) {
    return _userCvsRef(uid).doc(cvId).snapshots().map((d) {
      if (!d.exists) return null;
      return CvModel.fromMap(d.data()!, id: d.id);
    });
  }

  /// Create or update. Returns the document id.
  static Future<String> upsertCv(String uid, CvModel cv) async {
    if (cv.id.isEmpty) {
      // Create
      final doc = _userCvsRef(uid).doc(); // auto id
      final data = <String, dynamic>{
        ...cv.toMap(),
        'id': doc.id, // optional but convenient
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await doc.set(data);
      return doc.id;
    } else {
      // Update
      final data = <String, dynamic>{
        ...cv.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _userCvsRef(uid).doc(cv.id).set(data, SetOptions(merge: true));
      return cv.id;
    }
  }

  static Future<void> deleteCv(String uid, String cvId) async {
    await _userCvsRef(uid).doc(cvId).delete();
  }

  /// Optional: one-time fixer if you ever saved `updatedAt` as int in the past.
  /// Run it once to standardize types so orderBy works reliably.
  static Future<void> normalizeUpdatedAt(String uid) async {
    final col = _userCvsRef(uid);
    final snap = await col.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.set(d.reference, {
        'updatedAt': FieldValue.serverTimestamp(),
        // set createdAt too if you want to ensure it's present everywhere
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
