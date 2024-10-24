import 'package:flutter/material.dart';
import '../../Login With Google/google_auth.dart';
import 'login.dart';
import 'health_data_form.dart';  
import 'historical_data.dart';    
import 'notification_list_screen.dart';  
import 'calendar_screen.dart';
import 'report_gen_screen.dart';  
import 'education_resources_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Autocuidado Diabetes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await GoogleAuthService().signOut(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          padding: const EdgeInsets.all(10),
          children: [
            _buildMenuItem(Icons.health_and_safety, "Datos de salud", Colors.blue.shade700, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HealthDataForm(),
                ),
              );
            }),
            _buildMenuItem(Icons.history, "Datos históricos", Colors.blue.shade500, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HistoricalData(),
                ),
              );
            }),
            _buildMenuItem(Icons.medical_services, "Medicamentos", Colors.blue.shade300, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotificationListScreen(),
                ),
              );
            }),
            _buildMenuItem(Icons.calendar_today, "Calendario", Colors.blue.shade300, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(),
                ),
              );
            }),
            _buildMenuItem(Icons.file_download, "Reportes", Colors.blue.shade500, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportGenScreen(),
                ),
              );
            }),
            _buildMenuItem(Icons.book, "Recursos educativos", Colors.blue.shade700, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EducationResourcesScreen(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3), // Sombra hacia abajo
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}









