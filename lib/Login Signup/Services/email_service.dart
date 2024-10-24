import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  Future<String> getUserEmail() async {
  // Obtener el UID del usuario autenticado
  final userId = FirebaseAuth.instance.currentUser?.uid;

  // Asegurarse de que el usuario esté autenticado
  if (userId != null) {
    // Consultar la colección 'usuarios' para obtener el correo
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
        .collection('usuarios')  // Asegúrate de que la colección es correcta
        .doc(userId)
        .get();

    // Verificar si el documento existe y tiene datos
    if (userDoc.exists && userDoc.data() != null) {
      return userDoc.data()!['email'];  // Retornar el correo del documento
    } else {
      throw Exception("No se encontró el correo del usuario.");
    }
  } else {
    throw Exception("No hay un usuario autenticado.");
  }
}
}

