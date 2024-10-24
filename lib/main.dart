import 'package:autocuidado/Login%20Signup/Screen/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login Signup/Screen/home_screen.dart';
import 'package:autocuidado/utils/notification_helper.dart'; // Notificaciones helper
import 'package:permission_handler/permission_handler.dart';

// Solicitar permisos para notificaciones
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationHelper.initializeNotifications();

  // Solicitar permisos para notificaciones
  await requestNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _requestStoragePermission();

    // Verificar el estado de login después de la inicialización de las notificaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

Future<void> _requestStoragePermission() async {
  if (await Permission.storage.isGranted) {
    print('Permiso de almacenamiento ya concedido');
  } else if (await Permission.storage.isDenied) {
    print('Permiso de almacenamiento denegado');
  } else {
    // Solicitar permisos para Android 13+
    if (await Permission.photos.request().isGranted ||
        await Permission.videos.request().isGranted ||
        await Permission.audio.request().isGranted) {
      print('Permisos para medios concedidos');
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      print('Permiso de gestión de almacenamiento concedido');
    } else {
      print('Permisos denegados');
    }
  }
}

  // Verificar si el usuario ya está autenticado
  void _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}







