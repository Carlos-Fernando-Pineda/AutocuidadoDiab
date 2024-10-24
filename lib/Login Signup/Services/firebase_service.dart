import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Obtener datos de la colección healthData por rango de fechas y UID del usuario
  Future<List<Map<String, dynamic>>> getHealthData(DateTime startDate, DateTime endDate) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('healthData')
        .where('uid', isEqualTo: currentUser.uid)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
