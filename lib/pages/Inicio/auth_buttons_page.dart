import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth/auth_page.dart';

class AuthButtonsPage extends StatelessWidget {
  const AuthButtonsPage({super.key});

  void _navegarAutenticacion(BuildContext context, bool login) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AuthPage(initLogin: login)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Registrarse'),
            onPressed: () => _navegarAutenticacion(context, false),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión'),
            onPressed: () => _navegarAutenticacion(context, true),
          ),
        ],
      ),
    );
  }
}
