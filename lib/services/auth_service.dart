import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Handles Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email/password and save user to Firestore
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    String? guardianEmail,
    String? guardianName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email.trim(),
      phone: phone,
      userType: userType,
      guardianEmail: guardianEmail,
      guardianName: guardianName,
      safeRadiusMeters: AppConstants.defaultSafeRadius,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .set(user.toMap());

    return user;
  }

  /// Sign in with email/password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return await getUserData(credential.user!.uid);
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  /// Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
