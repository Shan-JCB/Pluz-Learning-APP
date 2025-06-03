import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Inicio/catalogo_cursos_page.dart';
import 'package:flutter_application_1/widgets/navbar_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academia Virtual PLUZ')),
      drawer: const NavbarWidget(),

      // En lugar de usar FutureBuilder directamente, mostramos CursosPage
      body: const CursosPage(),
    );
  }
}
