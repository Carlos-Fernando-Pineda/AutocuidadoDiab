import 'package:flutter/material.dart';
import 'package:autocuidado/Login%20Signup/Widget/button.dart';

import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import '../Widget/text_field.dart';
import 'home_screen.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signupUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text);

    if (res == "Éxito") {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen de cabecera desde un enlace en línea
              SizedBox(
                height: height / 3.5,
                child: Image.network(
                  'https://i.pinimg.com/736x/a1/63/5a/a1635a385346150378f7d1d04617a1f0.jpg', // Reemplaza con un enlace válido
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Error al cargar la imagen');
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Título de la pantalla
              Text(
                'Crea una cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Por favor, completa los campos a continuación',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),

              // Campos de texto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    TextFieldInput(
                      icon: Icons.person_outline,
                      textEditingController: nameController,
                      hintText: 'Introduce tu nombre',
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    TextFieldInput(
                      icon: Icons.email_outlined,
                      textEditingController: emailController,
                      hintText: 'Introduce tu email',
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextFieldInput(
                      icon: Icons.lock_outline,
                      textEditingController: passwordController,
                      hintText: 'Introduce tu contraseña',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Botón de registro
              isLoading
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MyButtons(
                        onTap: signupUser,
                        text: "Registrarse",
                        style: null,
                      ),
                    ),
              const SizedBox(height: 20),

              // Línea separadora
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: Colors.grey.shade300),
                  ),
                  const Text("  o  "),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey.shade300),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Opción para ir al inicio de sesión
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Inicia sesión",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
