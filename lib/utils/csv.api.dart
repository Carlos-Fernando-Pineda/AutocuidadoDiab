import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';

class CsvApi {
  static Future<String> generateCsv(List<Map<String, dynamic>> data) async {
    List<List<String>> csvData = [];

    // Agregar encabezados
    csvData.add(['Fecha', 'Glucosa', 'Presión Arterial', 'Peso']);

    // Agregar datos
    data.forEach((entry) {
      csvData.add([
        entry['timestamp'].toDate().toString(),
        entry['glucose'].toString(),
        entry['bloodPressure'].toString(),
        entry['weight'].toString(),
      ]);
    });

    // Generar el archivo CSV en una ubicación temporal
    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/reporte_salud.csv';

    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  static Future<void> openCsv(String filePath) async {
    // Abrir el archivo CSV con aplicaciones externas compatibles
    await OpenFile.open(filePath);
  }
}

