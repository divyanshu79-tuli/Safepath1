import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../models/location_model.dart';
import '../utils/constants.dart';

/// Handles all Firestore database operations
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER ────────────────────────────────────────────────────
  Future<void> saveUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    });
  }

  // ─── LOCATION ────────────────────────────────────────────────
  Future<void> saveLocation(LocationModel location) async {
    await _db
        .collection(AppConstants.locationsCollection)
        .doc(location.userId)
        .set(location.toMap());
  }

  Future<LocationModel?> getLastLocation(String userId) async {
    final doc = await _db
        .collection(AppConstants.locationsCollection)
        .doc(userId)
        .get();
    if (doc.exists && doc.data() != null) {
      return LocationModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<LocationModel?> locationStream(String userId) {
    return _db
        .collection(AppConstants.locationsCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return LocationModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // ─── ALERTS ──────────────────────────────────────────────────
  Future<String> saveAlert(AlertModel alert) async {
    final ref = await _db
        .collection(AppConstants.alertsCollection)
        .add(alert.toMap());
    return ref.id;
  }

  Future<List<AlertModel>> getAlerts(String userId,
      {int limit = 50}) async {
    final query = await _db
        .collection(AppConstants.alertsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<AlertModel>> alertsStream(String userId) {
    return _db
        .collection(AppConstants.alertsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> markAlertRead(String alertId) async {
    await _db
        .collection(AppConstants.alertsCollection)
        .doc(alertId)
        .update({'isRead': true});
  }

  // ─── GUARDIAN ────────────────────────────────────────────────
  Future<void> saveGuardianLink(String guardianUid, String userUid) async {
    await _db
        .collection(AppConstants.guardiansCollection)
        .doc(guardianUid)
        .set({'linkedUserId': userUid, 'updatedAt': DateTime.now().toIso8601String()},
            SetOptions(merge: true));
  }

  Future<String?> getLinkedUserId(String guardianUid) async {
    final doc = await _db
        .collection(AppConstants.guardiansCollection)
        .doc(guardianUid)
        .get();
    return doc.data()?['linkedUserId'];
  }
}
