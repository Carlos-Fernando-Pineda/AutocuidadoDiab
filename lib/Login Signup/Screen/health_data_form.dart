import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:tflite_flutter/tflite_flutter.dart';

class HealthDataForm extends StatefulWidget {
  @override
  _HealthDataFormState createState() => _HealthDataFormState();
}

class _HealthDataFormState extends State<HealthDataForm> {
  bool _glucoseEnabled = false;
  bool _bloodPressureEnabled = false;
  bool _weightEnabled = false;

  final _glucoseController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();  

  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/modelo_glucosa.tflite');
      print('Modelo cargado correctamente.');
    } catch (e) {
      print('Error al cargar el modelo: $e');
    }
  }

  String _obtenerRecomendacion(double prediccion) {
    if (prediccion < 70) {
      return "Tus niveles de glucosa están bajos. Considera consumir algo de azúcar o consultar a un médico.";
    } else if (prediccion >= 7000 && prediccion <= 14000) {
      return "Tus niveles de glucosa están dentro del rango normal.";
    } else {
      return "Tus niveles de glucosa están altos. Considera cambios en tu dieta o consulta médica.";
    }
  }

  Future<void> _makePrediction(double glucose, double bloodPressure, double weight) async {
    if (_interpreter == null) {
      print('El modelo no está cargado.');
      return;
    }

    var input = [glucose, bloodPressure, weight];
    var output = List.filled(1, 0.0).reshape([1, 1]);

    _interpreter!.run(input, output);
    double prediction = output[0][0];

    _showPredictionResult(prediction);
  }

  void _showPredictionResult(double result) {
    String mensajePrediccion = "Predicción: ${result.toStringAsFixed(2)} mg/dL";
    String recomendacion = _obtenerRecomendacion(result);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultado de la Predicción'),
          content: Text("$mensajePrediccion\n\nRecomendación: $recomendacion"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _submitData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    int fieldsFilled = 0;
    double? glucose, bloodPressure, weight;

    if (_glucoseEnabled && _glucoseController.text.isNotEmpty) {
      glucose = double.parse(_glucoseController.text);
      fieldsFilled++;
    }
    if (_bloodPressureEnabled && _bloodPressureController.text.isNotEmpty) {
      bloodPressure = double.parse(_bloodPressureController.text);
      fieldsFilled++;
    }
    if (_weightEnabled && _weightController.text.isNotEmpty) {
      weight = double.parse(_weightController.text);
      fieldsFilled++;
    }

    if (fieldsFilled >= 2) {
      FirebaseFirestore.instance.collection('healthData').add({
        'uid': user.uid,
        'glucose': glucose,
        'bloodPressure': bloodPressure,
        'weight': weight,
        'note': _noteController.text.isNotEmpty ? _noteController.text : null,
        'timestamp': Timestamp.now(),
      }).then((_) {
        if (glucose != null && bloodPressure != null && weight != null) {
          _makePrediction(glucose, bloodPressure, weight);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe llenar al menos 2 campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Datos de Salud", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent, // Color de fondo para consistencia
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCheckboxTile("Glucosa en la sangre", _glucoseEnabled, (value) {
              setState(() { _glucoseEnabled = value!; });
            }, _glucoseController, 'Glucosa (mg/dL)'),
            
            _buildCheckboxTile("Presión Arterial", _bloodPressureEnabled, (value) {
              setState(() { _bloodPressureEnabled = value!; });
            }, _bloodPressureController, 'Presión Arterial (mmHg)'),
            
            _buildCheckboxTile("Peso", _weightEnabled, (value) {
              setState(() { _weightEnabled = value!; });
            }, _weightController, 'Peso (kg)'),

            // Campo de notas
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitData,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.save),
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged, TextEditingController controller, String labelText) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          value: value,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    _bloodPressureController.dispose();
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}





