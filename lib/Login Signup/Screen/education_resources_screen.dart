import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';  // Necesario para abrir enlaces web

class EducationResourcesScreen extends StatelessWidget {
  const EducationResourcesScreen({Key? key}) : super(key: key);

  // Función para abrir enlaces web
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Educación y Recursos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Sección 1: Información básica sobre la diabetes
          _buildSectionTitle('¿Qué es la Diabetes?'),
          _buildBodyText(
            'La diabetes es una enfermedad crónica que afecta la manera en que el cuerpo regula el azúcar en sangre (glucosa).',
          ),
          SizedBox(height: 16),

          // Sección 2: Dieta recomendada
          _buildSectionTitle('Dieta Recomendada'),
          _buildBodyText(
            'Seguir una dieta saludable puede ayudarte a controlar la diabetes. Aquí tienes algunos consejos básicos:',
          ),
          _buildListItem('• Mantén una alimentación balanceada con frutas y verduras.'),
          _buildListItem('• Evita los carbohidratos procesados y azúcares refinados.'),
          _buildListItem('• Controla el tamaño de las porciones.'),
          SizedBox(height: 16),

          // Sección 3: Ejercicio
          _buildSectionTitle('Ejercicio Físico'),
          _buildBodyText(
            'El ejercicio regular puede ayudarte a controlar tus niveles de glucosa. Algunos ejercicios recomendados incluyen:',
          ),
          _buildListItem('• Caminar 30 minutos al día.'),
          _buildListItem('• Natación o ciclismo.'),
          _buildListItem('• Ejercicios de fuerza como pesas.'),
          SizedBox(height: 16),

          // Sección 4: Manejo del estrés
          _buildSectionTitle('Manejo del Estrés'),
          _buildBodyText(
            'El estrés puede afectar los niveles de glucosa. Aquí algunos consejos para manejarlo:',
          ),
          _buildListItem('• Practica técnicas de respiración profunda.'),
          _buildListItem('• Intenta yoga o meditación.'),
          _buildListItem('• Dormir lo suficiente cada noche.'),
          SizedBox(height: 16),

          // Sección 5: Enlaces a recursos
          _buildSectionTitle('Recursos Externos'),
          _buildLinkItem(
              'American Diabetes Association', 'https://www.diabetes.org/'),
          _buildLinkItem(
              'Organización Mundial de la Salud (OMS)', 'https://www.who.int/es/news-room/fact-sheets/detail/diabetes'),
          _buildLinkItem(
              'Guías sobre Nutrición (Diabetes UK)', 'https://www.diabetes.org.uk/guide-to-diabetes/enjoy-food/eating-with-diabetes'),
          _buildLinkItem(
              'Centros para el Control y la Prevención de Enfermedades (CDC)', 'https://www.cdc.gov/diabetes/basics/index.html'),
        ],
      ),
    );
  }

  // Widget para construir títulos de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Widget para construir el texto del cuerpo
  Widget _buildBodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // Widget para construir elementos de lista
  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  // Widget para construir enlaces web
  Widget _buildLinkItem(String title, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 16.0,
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: () => _launchURL(url),  // Abrir enlace web al tocar
    );
  }
}

