import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocuidado/Config/range_config.dart'; // Importa la pantalla de configuración

class HistoricalData extends StatefulWidget {
  @override
  _HistoricalDataState createState() => _HistoricalDataState();
}

class _HistoricalDataState extends State<HistoricalData> {
  List<Map<String, dynamic>> _healthData = [];
  bool _showGraph = true;
  Map<String, bool> _selectedData = {
    'glucose': true,
    'bloodPressure': false,
    'weight': false,
  };
  int? touchedIndex;
  Map<String, dynamic>? _selectedDataPoint;

  // Nuevas variables para las configuraciones personalizadas
  double? _customMinGlucose;
  double? _customMaxGlucose;
  double? _customMinPressure;
  double? _customMaxPressure;
  double? _customWeightGoal;

  // Variables para manejar el rango de fechas
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchCustomRanges();
  }

  Future<void> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Query query = FirebaseFirestore.instance
          .collection('healthData')
          .where('uid', isEqualTo: user.uid);

      // Si se selecciona un rango de fechas, filtrar por el rango
      if (_startDate != null && _endDate != null) {
        query = query
            .where('timestamp', isGreaterThanOrEqualTo: _startDate)
            .where('timestamp', isLessThanOrEqualTo: _endDate);
      }

      QuerySnapshot snapshot = await query.get();

      setState(() {
        _healthData = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id;
          data['note'] = data.containsKey('note') ? data['note'] : '';  // Agregar campo de notas
          return data;
        }).toList();
      });
    }
  }

  Future<void> _fetchCustomRanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _customMinGlucose = doc['minGlucose'] ?? 70.0;
          _customMaxGlucose = doc['maxGlucose'] ?? 140.0;
          _customMinPressure = doc['minBloodPressure'] ?? 90.0;
          _customMaxPressure = doc['maxBloodPressure'] ?? 120.0;
          _customWeightGoal = doc['weightGoal'] ?? 70.0;
        });
      }
    }
  }

  // Función para seleccionar el rango de fechas
  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchData(); // Llamar a la función para filtrar los datos con el nuevo rango
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Datos Históricos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800], // Azul corporativo
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Cambiar Vista') {
                setState(() {
                  _showGraph = !_showGraph;
                });
              } else if (value == 'Seleccionar Fechas') {
                _selectDateRange();
              } else if (value == 'Configuración') {
                _navigateToSettings();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Cambiar Vista',
                child: Text(_showGraph ? 'Ver Lista' : 'Ver Gráfica'),
              ),
              PopupMenuItem(
                value: 'Seleccionar Fechas',
                child: Text('Seleccionar Fechas'),
              ),
              PopupMenuItem(
                value: 'Configuración',
                child: Text('Configuración de Rango'),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: _showGraph ? _buildChart() : _buildDataList(),
            ),
            _buildQuickFilters(),
            if (_selectedDataPoint != null) _buildSelectedDataInfo()
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RangeConfig()),
    );
    _fetchCustomRanges(); // Recargar los valores personalizados después de regresar de la configuración
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.blueAccent, 'Glucosa Mínima'),
        _buildLegendItem(Colors.redAccent, 'Glucosa Máxima'),
        _buildLegendItem(Colors.blue, 'Presión Mínima'),
        _buildLegendItem(Colors.purple, 'Presión Máxima'),
        _buildLegendItem(Colors.orangeAccent, 'Peso Meta'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent, // Azul principal
            ),
            child: Text(
              'Filtrar Datos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildFilterCheckbox('Glucosa', 'glucose', Colors.blue),
          _buildFilterCheckbox('Presión Arterial', 'bloodPressure', Colors.red),
          _buildFilterCheckbox('Peso', 'weight', Colors.green),
        ],
      ),
    );
  }


Widget _buildFilterCheckbox(String label, String key, Color color) {
  return CheckboxListTile(
    title: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700, // Color de texto más suave y uniforme
          ),
        ),
      ],
    ),
    value: _selectedData[key],
    onChanged: (value) {
      setState(() {
        _selectedData[key] = value ?? false;
      });
    },
    activeColor: Colors.blueAccent, // Color principal uniforme en toda la app
    checkColor: Colors.white, // Color de la marca de verificación
    controlAffinity: ListTileControlAffinity.leading, // Alinear la casilla de verificación a la izquierda
    contentPadding: EdgeInsets.symmetric(horizontal: 0.0), // Eliminar el padding adicional
  );
}


  // Botones rápidos de filtro para "Últimos 7 días" y "Último mes"
Widget _buildQuickFilters() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent, // Botones con el color principal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        onPressed: () {
          setState(() {
            _startDate = DateTime.now().subtract(Duration(days: 7));
            _endDate = DateTime.now();
          });
          _fetchData();
        },
        child: Text('Últimos 7 días'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        onPressed: () {
          setState(() {
            _startDate = DateTime.now().subtract(Duration(days: 30));
            _endDate = DateTime.now();
          });
          _fetchData();
        },
        child: Text('Último mes'),
      ),
    ],
  );
}


Widget _buildChart() {
  return _healthData.isEmpty
      ? Center(
          child: Text(
            'No hay datos disponibles',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600, // Color del texto suavizado
            ),
          ),
        )
      : Column(
          children: [
            Expanded(
              flex: 3,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20, // Ajuste de intervalos
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300, // Líneas más suaves
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          if (value % 20 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: _getFilteredLineBarData(),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: _buildReferenceLines(),
                  ),
                  lineTouchData: LineTouchData(
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (touchResponse != null && touchResponse.lineBarSpots != null) {
                        setState(() {
                          touchedIndex = touchResponse.lineBarSpots!.first.x.toInt();
                          _selectedDataPoint = _healthData[touchedIndex!];
                        });
                      } else {
                        setState(() {
                          touchedIndex = null;
                          _selectedDataPoint = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        );
}


  // Agrega las nuevas líneas de referencia para presión arterial y peso
List<HorizontalLine> _buildReferenceLines() {
  return [
    if (_customMinGlucose != null)
      HorizontalLine(
        y: _customMinGlucose!,
        color: Colors.green,
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.centerRight,
          labelResolver: (line) => 'Glucosa Mínima',
        ),
      ),
    if (_customMaxGlucose != null)
      HorizontalLine(
        y: _customMaxGlucose!,
        color: Colors.red,
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.centerRight,
          labelResolver: (line) => 'Glucosa Máxima',
        ),
      ),
    if (_customMinPressure != null)
      HorizontalLine(
        y: _customMinPressure!,
        color: Colors.blue,
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.centerRight,
          labelResolver: (line) => 'Presión Mínima',
        ),
      ),
    if (_customMaxPressure != null)
      HorizontalLine(
        y: _customMaxPressure!,
        color: Colors.purple,
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.centerRight,
          labelResolver: (line) => 'Presión Máxima',
        ),
      ),
    if (_customWeightGoal != null)
      HorizontalLine(
        y: _customWeightGoal!,
        color: Colors.orange,
        strokeWidth: 1,
        dashArray: [5, 5],
        label: HorizontalLineLabel(
          show: true,
          alignment: Alignment.centerRight,
          labelResolver: (line) => 'Peso Meta',
        ),
      ),
  ];
}


  Widget _buildDataList() {
    return ListView.builder(
      itemCount: _healthData.length,
      itemBuilder: (context, index) {
        final data = _healthData[index];
        return ListTile(
          title: Text('Dato ${index + 1}'),
          subtitle: Text(
            'Glucosa: ${data['glucose']} - Presión Arterial: ${data['bloodPressure']} - Peso: ${data['weight']}',
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteData(data['docId']);
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteData(String docId) async {
    await FirebaseFirestore.instance.collection('healthData').doc(docId).delete();
    _fetchData();
  }

Widget _buildSelectedDataInfo() {
  return Container(
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información seleccionada:'),
        Text('Glucosa: ${_selectedDataPoint!['glucose']}'),
        Text('Presión Arterial: ${_selectedDataPoint!['bloodPressure']}'),
        Text('Peso: ${_selectedDataPoint!['weight']}'),
        if (_selectedDataPoint!['note'] != null && _selectedDataPoint!['note'].isNotEmpty)
          Text('Nota: ${_selectedDataPoint!['note']}'),
      ],
    ),
  );
}


  Widget _buildFilters() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text('Glucosa'),
          value: _selectedData['glucose'],
          onChanged: (value) {
            setState(() {
              _selectedData['glucose'] = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: Text('Presión Arterial'),
          value: _selectedData['bloodPressure'],
          onChanged: (value) {
            setState(() {
              _selectedData['bloodPressure'] = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: Text('Peso'),
          value: _selectedData['weight'],
          onChanged: (value) {
            setState(() {
              _selectedData['weight'] = value ?? false;
            });
          },
        ),
      ],
    );
  }

  List<LineChartBarData> _getFilteredLineBarData() {
    List<LineChartBarData> lineBars = [];

if (_selectedData['glucose']!) {
  lineBars.add(_buildLineChartBarData(
    spots: _healthData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      // Verifica si el dato es un número, si no lo es, usa double.parse
      final glucoseValue = (data['glucose'] is double)
          ? data['glucose']
          : double.tryParse(data['glucose'].toString()) ?? 0.0;
      return FlSpot(index.toDouble(), glucoseValue);
    }).toList(),
    color: Colors.blue,
  ));
}

if (_selectedData['bloodPressure']!) {
  lineBars.add(_buildLineChartBarData(
    spots: _healthData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      // Verifica si el dato es un número, si no lo es, usa double.parse
      final pressureValue = (data['bloodPressure'] is double)
          ? data['bloodPressure']
          : double.tryParse(data['bloodPressure'].toString()) ?? 0.0;
      return FlSpot(index.toDouble(), pressureValue);
    }).toList(),
    color: Colors.red,
  ));
}

if (_selectedData['weight']!) {
  lineBars.add(_buildLineChartBarData(
    spots: _healthData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      // Verifica si el dato es un número, si no lo es, usa double.parse
      final weightValue = (data['weight'] is double)
          ? data['weight']
          : double.tryParse(data['weight'].toString()) ?? 0.0;
      return FlSpot(index.toDouble(), weightValue);
    }).toList(),
    color: Colors.green,
  ));
}

    return lineBars;
  }

  LineChartBarData _buildLineChartBarData({
    required List<FlSpot> spots,
    required Color color,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      dotData: FlDotData(show: true),
      barWidth: 2,
    );
  }
}

















