import 'package:flutter/material.dart';
import 'register_step1_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirige automáticamente al paso 1 al cargar
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterStep1Page()),
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
