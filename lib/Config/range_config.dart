import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RangeConfig extends StatefulWidget {
  @override
  _RangeConfigState createState() => _RangeConfigState();
}

class _RangeConfigState extends State<RangeConfig> with SingleTickerProviderStateMixin {
  final TextEditingController _minGlucoseController = TextEditingController();
  final TextEditingController _maxGlucoseController = TextEditingController();
  final TextEditingController _minPressureController = TextEditingController();
  final TextEditingController _maxPressureController = TextEditingController();
  final TextEditingController _weightGoalController = TextEditingController();
  
  // Variables para la animación
  Color _buttonColor = Colors.blue;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();

    // Inicialización de AnimationController y animaciones de color
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.green).animate(_controller)
      ..addListener(() {
        setState(() {
          _buttonColor = _colorAnimation.value!;
        });
      });
  }

  Future<void> _loadCurrentValues() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _minGlucoseController.text = (doc['minGlucose'] ?? 70).toString();
          _maxGlucoseController.text = (doc['maxGlucose'] ?? 140).toString();
          _minPressureController.text = (doc['minBloodPressure'] ?? 90).toString();
          _maxPressureController.text = (doc['maxBloodPressure'] ?? 120).toString();
          _weightGoalController.text = (doc['weightGoal'] ?? 70).toString();
        });
      }
    }
  }

  Future<void> _saveRanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      double? minGlucose = double.tryParse(_minGlucoseController.text);
      double? maxGlucose = double.tryParse(_maxGlucoseController.text);
      double? minPressure = double.tryParse(_minPressureController.text);
      double? maxPressure = double.tryParse(_maxPressureController.text);
      double? weightGoal = double.tryParse(_weightGoalController.text);

      if (minGlucose != null && maxGlucose != null &&
          minPressure != null && maxPressure != null &&
          weightGoal != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'minGlucose': minGlucose,
          'maxGlucose': maxGlucose,
          'minBloodPressure': minPressure,
          'maxBloodPressure': maxPressure,
          'weightGoal': weightGoal,
        }, SetOptions(merge: true));

        // Iniciar la animación
        _controller.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rangos guardados exitosamente')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar Rangos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _minGlucoseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Glucosa Mínima'),
            ),
            TextField(
              controller: _maxGlucoseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Glucosa Máxima'),
            ),
            TextField(
              controller: _minPressureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Presión Arterial Mínima'),
            ),
            TextField(
              controller: _maxPressureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Presión Arterial Máxima'),
            ),
            TextField(
              controller: _weightGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Meta de Peso'),
            ),
            SizedBox(height: 20),
            // El botón de guardar ahora usa AnimatedContainer para la animación de color
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              child: ElevatedButton(
                onPressed: _saveRanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor, // Color animado
                ),
                child: Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


