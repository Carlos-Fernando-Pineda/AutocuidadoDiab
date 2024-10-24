import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Ocurrió un error";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        // Register user in Firebase Auth
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Add user to Firestore database
        await _firestore.collection("usuarios").doc(cred.user!.uid).set({
          'nombre': name,
          'uid': cred.user!.uid,
          'email': email,
          'createdAt': DateTime.now(),
        });

        res = "Éxito";
      } else {
        res = "Porfavor llene todos los campos";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Log In User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Ocurrió un error";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // Log in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "Éxito";
      } else {
        res = "Porfavor llene todos los campos";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete User and remove from Firestore
  Future<String> deleteUser() async {
    String res = "Ocurrió un error";
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user from Firestore
        await _firestore.collection('usuarios').doc(user.uid).delete();

        // Delete user from Firebase Authentication
        await user.delete();

        res = "Usuario eliminado correctamente";
      } else {
        res = "No se encontró el usuario";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
