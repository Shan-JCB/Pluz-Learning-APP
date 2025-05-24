import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Bienvenido a Pluz Academy\n\n'
          'Una academia virtual para el aprendizaje continuo. '
          'Ofrecemos una variedad de cursos en línea accesibles desde cualquier lugar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
