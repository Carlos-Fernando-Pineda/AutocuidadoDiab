import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocuidado/utils/notification_helper.dart';

class AddMedicationScreen extends StatefulWidget {
  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _medicationName = '';
  String _dosage = '';
  TimeOfDay _time = TimeOfDay.now();
  String _frequency = 'Diario';
  String _reminderType = 'Notificación';

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);

      if (selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: La hora seleccionada ya pasó")),
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: No hay usuario autenticado")),
        );
        return;
      }

      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .add({
          'medicationName': _medicationName,
          'dosage': _dosage,
          'time': Timestamp.fromDate(selectedDateTime),
          'frequency': _frequency,
          'reminderType': _reminderType,
          'createdAt': FieldValue.serverTimestamp(),
          'isEnabled': true,
        });

        String _medicationId = docRef.id;

        if (_reminderType == 'Notificación') {
          await NotificationHelper.scheduleNotification(
            _medicationId,
            selectedDateTime,
            title: _medicationName,
            body: 'Es hora de tomar tu medicamento',
          );
        } else if (_reminderType == 'Alarma') {
          int intervalInHours = _getIntervalInHours(_frequency);
          await NotificationHelper.scheduleAlarm(
            _medicationId,
            selectedDateTime,
            intervalInHours,
            title: _medicationName,
            body: 'Es hora de tu dosis',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medicamento guardado exitosamente")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar el medicamento: ${e.toString()}")),
        );
      }
    }
  }

  int _getIntervalInHours(String frequency) {
    switch (frequency) {
      case 'Cada 6 horas':
        return 6;
      case 'Cada 8 horas':
        return 8;
      case 'Cada 12 horas':
        return 12;
      case 'Cada 24 horas':
        return 24;
      case 'Cada 2 días':
        return 48;
      case 'Semanal':
        return 168;
      default:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEFF1), // Gris suave para el fondo
      appBar: AppBar(
        title: Text("Agregar Medicamento"),
        backgroundColor: Color(0xFF0277BD), // Azul
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Nombre del medicamento"),
              _buildTextField(
                hintText: 'Ingresa el nombre del medicamento',
                onSaved: (value) => _medicationName = value!,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 16),
              _buildSectionTitle("Dosis"),
              _buildTextField(
                hintText: 'Ingresa la dosis',
                onSaved: (value) => _dosage = value!,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 16),
              _buildSectionTitle("Frecuencia"),
              _buildDropdown(
                value: _frequency,
                items: [
                  'Diario',
                  'Cada 6 horas',
                  'Cada 8 horas',
                  'Cada 12 horas',
                  'Cada 24 horas',
                  'Cada 2 días',
                  'Semanal',
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _frequency = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildSectionTitle("Hora de recordatorio"),
              _buildTimePicker(),
              SizedBox(height: 16),
              _buildSectionTitle("Tipo de recordatorio"),
              _buildDropdown(
                value: _reminderType,
                items: ['Notificación', 'Alarma'],
                onChanged: (String? newValue) {
                  setState(() {
                    _reminderType = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveMedication,
                  child: Text('Guardar Medicamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0277BD), // Azul
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF455A64), // Gris oscuro para los títulos
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        hintText: hintText,
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
      value: value,
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.access_time, color: Color(0xFF0277BD)), // Azul para el ícono
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: _time,
            );
            if (pickedTime != null) {
              setState(() {
                _time = pickedTime;
              });
            }
          },
        ),
        Text(
          "${_time.format(context)}",
          style: TextStyle(fontSize: 16, color: Color(0xFF455A64)), // Gris oscuro para el texto
        ),
      ],
    );
  }
}






