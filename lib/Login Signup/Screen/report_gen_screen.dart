import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:autocuidado/Login Signup/Screen/save_and_open_pdf.dart';
import '../../utils/csv.api.dart';
import '../Services/firebase_service.dart';
import '../Services/health_data_service.dart';

class ReportGenScreen extends StatefulWidget {
  @override
  _ReportGenScreenState createState() => _ReportGenScreenState();
}

class _ReportGenScreenState extends State<ReportGenScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  // Función para generar el PDF basado en los datos del usuario
Future<void> generateUserReport(DateTime startDate, DateTime endDate) async {
  final healthData = await _firebaseService.getHealthData(startDate, endDate);

  final pdf = pw.Document();

  // Definir colores y estilos
  final baseColor = PdfColor.fromHex('#1e88e5'); // Azul
  final greyColor = PdfColor.fromHex('#b0bec5'); // Gris claro
  final headerStyle = pw.TextStyle(color: baseColor, fontSize: 24, fontWeight: pw.FontWeight.bold);
  final subHeaderStyle = pw.TextStyle(color: baseColor, fontSize: 18, fontWeight: pw.FontWeight.bold);
  final textStyle = pw.TextStyle(color: PdfColor.fromHex('#212121'), fontSize: 12);

  // Agregar una página al PDF
  pdf.addPage(pw.Page(
    margin: pw.EdgeInsets.all(32),
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título del reporte
          pw.Text('Reporte de Salud', style: headerStyle),
          pw.SizedBox(height: 10),

          // Fecha de generación del reporte
          pw.Text('Generado el: ${DateTime.now().toString()}', style: textStyle),
          pw.SizedBox(height: 20),

          // Encabezado de la sección de datos
          pw.Text('Datos de Salud:', style: subHeaderStyle),
          pw.SizedBox(height: 10),

          // Tabla para mostrar los datos en un formato más ordenado
          pw.Table.fromTextArray(
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Fecha', 'Glucosa', 'Presión Arterial', 'Peso'],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 14,
            ),
            headerDecoration: pw.BoxDecoration(color: baseColor),
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: greyColor, width: 0.5),
              ),
            ),
            cellStyle: textStyle,
            data: healthData.map((data) {
              return [
                data['timestamp'].toDate().toString().substring(0, 10), // Fecha
                data['glucose'].toString(), // Glucosa
                data['bloodPressure'].toString(), // Presión Arterial
                data['weight'].toString() // Peso
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),

          // Pie de página o sección adicional
          pw.Text(
            'Este reporte ha sido generado automáticamente por la aplicación de autocuidado para la diabetes.',
            style: pw.TextStyle(color: greyColor, fontSize: 10),
          ),
        ],
      );
    },
  ));

  final file = await SaveAndOpenDocument.savePdf(name: 'reporte_salud.pdf', pdf: pdf);
  await SaveAndOpenDocument.openPdf(file);
}


  // Función para generar el CSV basado en los datos del usuario
  Future<void> generateUserCSV(DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> healthData = await HealthDataService.getUserHealthData();

    if (healthData.isEmpty) {
      print("No hay datos de salud disponibles.");
      return;
    }

    String csvPath = await CsvApi.generateCsv(healthData);
    await CsvApi.openCsv(csvPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar Reporte', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Seleccione el tipo de reporte que desea generar:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  DateTime endDate = DateTime.now();
                  DateTime startDate = endDate.subtract(Duration(days: 7));
                  await generateUserReport(startDate, endDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Generar Reporte PDF', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  DateTime endDate = DateTime.now();
                  DateTime startDate = endDate.subtract(Duration(days: 7));
                  await generateUserCSV(startDate, endDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Generar CSV', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

