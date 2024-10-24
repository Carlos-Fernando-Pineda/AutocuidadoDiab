import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditMedicationScreen extends StatefulWidget {
  final String medicationId;

  EditMedicationScreen({required this.medicationId});

  @override
  _EditMedicationScreenState createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _medicationNameController = TextEditingController();
  TextEditingController _frequencyController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicationData();
  }

  void _loadMedicationData() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot medicationSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medications')
        .doc(widget.medicationId)
        .get();

    setState(() {
      _medicationNameController.text = medicationSnapshot['medicationName'];
      _frequencyController.text = medicationSnapshot['frequency'];
      _timeController.text = DateFormat('HH:mm').format(medicationSnapshot['time'].toDate());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // Fondo gris claro
      appBar: AppBar(
        title: Text('Editar Medicamento'),
        backgroundColor: Color(0xFF1565C0), // Azul oscuro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo para nombre del medicamento
              TextFormField(
                controller: _medicationNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Medicamento',
                  labelStyle: TextStyle(color: Color(0xFF42A5F5)), // Azul claro para la etiqueta
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF42A5F5)), // Borde azul claro
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1565C0)), // Borde azul oscuro al enfocar
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del medicamento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Campo para frecuencia
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: 'Frecuencia',
                  labelStyle: TextStyle(color: Color(0xFF42A5F5)), // Azul claro para la etiqueta
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF42A5F5)), // Borde azul claro
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1565C0)), // Borde azul oscuro al enfocar
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la frecuencia';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Campo para seleccionar la hora
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Hora de Recordatorio',
                  labelStyle: TextStyle(color: Color(0xFF42A5F5)), // Azul claro para la etiqueta
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF42A5F5)), // Borde azul claro
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1565C0)), // Borde azul oscuro al enfocar
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeController.text = pickedTime.format(context);
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              
              // Botón para guardar cambios
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateMedication();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1565C0), // Fondo azul oscuro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  'Guardar Cambios',
                  style: TextStyle(color: Colors.white), // Texto blanco
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMedication() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Parse the time from the text controller
    List<String> timeParts = _timeController.text.split(":");
    TimeOfDay time = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // Update medication in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medications')
        .doc(widget.medicationId)
        .update({
      'medicationName': _medicationNameController.text,
      'frequency': _frequencyController.text,
      'time': DateTime(2024, 1, 1, time.hour, time.minute), // Actualiza con una fecha dummy
    });

    // Muestra un mensaje de éxito y regresa a la lista de medicamentos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medicamento actualizado con éxito')),
    );
    Navigator.pop(context);
  }
}



