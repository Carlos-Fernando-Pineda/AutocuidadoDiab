import 'dart:io';
import 'package:pdf/widgets.dart';
import 'package:autocuidado/Login Signup/Screen/save_and_open_pdf.dart';

class ReportPdfApi {
  static Future<File> generateReportPdf(List<String> glucosaData, List<String> pesoData) async {
    final pdf = Document();

    pdf.addPage(
      Page(
        build: (context) => Column(
          children: [
            Text('Reporte de Salud', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Datos de Glucosa', style: TextStyle(fontSize: 18)),
            ...glucosaData.map((data) => Text(data)),
            SizedBox(height: 20),
            Text('Datos de Peso', style: TextStyle(fontSize: 18)),
            ...pesoData.map((data) => Text(data)),
          ],
        ),
      ),
    );

    return SaveAndOpenDocument.savePdf(name: 'reporte_salud.pdf', pdf: pdf);
  }
}
