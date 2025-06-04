import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ----------------- AUTENTICACIÓN ----------------- //

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error en inicio de sesión: $e');
      rethrow;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ----------------- GESTIÓN DE CUENTA ----------------- //

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  // ----------------- FOTO DE PERFIL ----------------- //

  Future<void> uploadProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.update({
        'fotoPerfilBase64': base64Image,
        'correo': user.email ?? '',
      });
    } else {
      await docRef.set({
        'fotoPerfilBase64': base64Image,
        'correo': user.email ?? '',
      });
    }
  }

  Future<String?> getBase64ProfileImage() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
    return doc.data()?['fotoPerfilBase64'];
  }

  // ----------------- DATOS DEL USUARIO ----------------- //

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
    return doc.data();
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update(newData);
  }

  Future<void> updateUserField(String field, String value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({field: value});
  }
}
