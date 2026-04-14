import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/rutinas/presentation/screens/crear_rutina_screen.dart';
import 'features/ejercicios/presentation/screens/guia_ejercicios_screen.dart';
import 'shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VitalFitnessApp());
}

class VitalFitnessApp extends StatelessWidget {
  const VitalFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VitalFitness',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.carbonBlack,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyberLime,
          secondary: AppColors.electricViolet,
          background: AppColors.carbonBlack,
        ),
        fontFamily: null,
      ),

      // ── Rutas nombradas ────────────────────────────────────────────────────
      routes: {
        '/login':           (context) => const LoginScreen(),
        '/register':        (context) => const RegisterScreen(),
        '/crear-rutina':    (context) => const CrearRutinaScreen(),
        '/guia-ejercicios': (context) => const GuiaEjerciciosScreen(),
      },

      // ── Auth guard ─────────────────────────────────────────────────────────
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.carbonBlack,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.cyberLime,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return snapshot.hasData
              ? const AppShell()
              : const LoginScreen();
        },
      ),
    );
  }
}
