// Path: lib/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailingroom/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream untuk memantau status otentikasi pengguna
  Stream<MyUser?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) {
        return null;
      }
      // Ambil data user dari Firestore.
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return MyUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Mendaftar dengan email dan password
  Future<MyUser?> registerWithEmailAndPassword(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Simpan data user ke Firestore
      await _db.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'email': email,
        'role': role,
      });

      return MyUser(uid: user.uid, email: email, role: role);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code}');
      // Anda bisa mengembalikan pesan error yang lebih spesifik di sini
      return null;
    } catch (e) {
      print('Error: ${e.toString()}');
      return null;
    }
  }

  // Masuk dengan email dan password
  Future<MyUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Ambil data user dari Firestore
      DocumentSnapshot doc = await _db.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        return MyUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code}');
      return null;
    } catch (e) {
      print('Error: ${e.toString()}');
      return null;
    }
  }

  // Keluar (sign out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}