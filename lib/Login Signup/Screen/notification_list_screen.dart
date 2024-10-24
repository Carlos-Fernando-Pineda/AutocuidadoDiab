import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_medication_screen.dart';
import 'edit_medication_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocuidado/utils/notification_helper.dart';  // Importar el helper de notificaciones

class NotificationListScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // Fondo gris claro
      appBar: AppBar(
        title: Text('Notificaciones Activas'),
        backgroundColor: Color(0xFF1565C0), // Azul oscuro
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('medications')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var medications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              var medication = medications[index];
              bool isEnabled = medication['isEnabled'] ?? true; // Por defecto, activado

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Fondo blanco para cada item
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1), // Sombra ligera
                      blurRadius: 4,
                      offset: Offset(0, 2), // Sombra hacia abajo
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    medication['medicationName'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Texto principal en negro
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frecuencia: ${medication['frequency']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575), // Texto secundario gris
                        ),
                      ),
                      Text(
                        'Recordatorio: ${isEnabled ? "Activo" : "Desactivado"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575), // Texto secundario gris
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Switch para habilitar/deshabilitar la alarma
                      Switch(
                        value: isEnabled,
                        activeColor: Color(0xFF42A5F5), // Azul para el switch activo
                        onChanged: (value) async {
                          // Actualizar el estado de isEnabled en Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('medications')
                              .doc(medication.id)
                              .update({'isEnabled': value});

                          if (value) {
                            // Reactivar la notificación/alarma
                            await NotificationHelper.scheduleNotification(
                              medication.id,
                              medication['time'].toDate(),
                              title: medication['medicationName'],
                              body: 'Es hora de tomar tu medicamento',
                            );
                          } else {
                            // Cancelar la notificación/alarma
                            await NotificationHelper.cancelNotification(medication.id);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Color(0xFF42A5F5)), // Icono de editar en azul
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMedicationScreen(
                                medicationId: medication.id,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent), // Icono de eliminar en rojo
                        onPressed: () async {
                          // Eliminar el medicamento de Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('medications')
                              .doc(medication.id)
                              .delete();

                          // Cancelar la notificación/alarma correspondiente
                          await NotificationHelper.cancelNotification(medication.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Medicamento eliminado")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicationScreen(),
            ),
          );
        },
        backgroundColor: Color(0xFF42A5F5), // Botón flotante en azul claro
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


