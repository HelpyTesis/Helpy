import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helpy/screens/forgot_password_screen.dart';
import 'package:helpy/screens/login_screen.dart';
import 'package:helpy/screens/register_screen.dart';
import 'package:helpy/screens/chat_screen.dart'; // Importa la pantalla de chat
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Opciones de Firebase para Android
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helpy App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgotPassword': (context) =>
            const ForgotPasswordScreen(), // Aquí defines la ruta
        '/chat': (context) =>
            const ChatScreen(), // Ruta del chat si ya la tienes
      },
    );
  }
}
