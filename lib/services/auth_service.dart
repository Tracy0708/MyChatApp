import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_chat_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web-specific implementation using Firebase Auth directly
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // Use Firebase Auth popup for web
        final UserCredential userCredential = await _auth.signInWithPopup(
          googleProvider,
        );

        // Create or update user document in Firestore
        if (userCredential.user != null) {
          await _createOrUpdateUserDocument(userCredential.user!);
        }

        return userCredential;
      } else {
        // Mobile implementation using google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null; // User canceled the sign-in
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        // Create or update user document in Firestore
        if (userCredential.user != null) {
          await _createOrUpdateUserDocument(userCredential.user!);
        }

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      final now = DateTime.now();

      if (docSnapshot.exists) {
        // Update existing user using set with merge to avoid update errors
        await userDoc.set({
          'lastSeen': now.millisecondsSinceEpoch,
          'isOnline': true,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL,
        }, SetOptions(merge: true));
      } else {
        // Create new user
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL,
          createdAt: now,
          lastSeen: now,
          isOnline: true,
        );

        await userDoc.set(userModel.toMap());
      }
    } catch (e) {
      print('Error creating/updating user document: $e');
      // If there's still an error, just log it and continue
    }
  } // Update user online status

  Future<void> updateUserOnlineStatus(bool isOnline) async {
    final user = currentUser;
    if (user != null) {
      try {
        // Use set with merge to create the document if it doesn't exist
        await _firestore.collection('users').doc(user.uid).set({
          'isOnline': isOnline,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error updating user online status: $e');
        // If the document doesn't exist, create it
        await _createOrUpdateUserDocument(user);
      }
    }
  }

  // Get user model from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user model: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Update online status before signing out
      await updateUserOnlineStatus(false);

      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}
