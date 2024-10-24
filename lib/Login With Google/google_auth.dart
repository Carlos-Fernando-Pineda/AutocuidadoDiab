import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Inicializa Firestore

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // Si el usuario cancela el inicio de sesión
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión cancelado')),
      );
      return;  // Termina el proceso aquí si el usuario cancela
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Autenticar con Firebase
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      // Verifica si el usuario ya existe en Firestore
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

      if (!userDoc.exists) {
        // Si el usuario no existe, regístralo en Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nombre': user.displayName ?? 'Usuario sin nombre',
          'uid': user.uid,
          'email': user.email,
          'createdAt': DateTime.now(),
          'photoURL': user.photoURL,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Inicio de sesión exitoso!')),
      );
    }
  } on FirebaseAuthException catch (e) {
    String message;
    if (e.code == 'account-exists-with-different-credential') {
      message = 'La cuenta ya está vinculada a otro método de inicio de sesión.';
    } else if (e.code == 'invalid-credential') {
      message = 'Credenciales inválidas. Inténtalo de nuevo.';
    } else {
      message = 'Error al iniciar sesión: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Algo salió mal. Inténtalo de nuevo.')),
    );
  }
}


  Future<void> signOut(BuildContext context) async {
    try {
      await googleSignIn.signOut();
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cierre de sesión exitoso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cerrar sesión.')),
      );
    }
  }
}

