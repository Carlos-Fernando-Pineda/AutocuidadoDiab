import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthDataService {
  static Future<List<Map<String, dynamic>>> getUserHealthData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final uid = user.uid;

    // Filtrar los datos de Firestore por usuario (uid) y rango de fechas
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('healthData')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .get();

    // Extraer los datos y convertirlos en una lista de mapas
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
