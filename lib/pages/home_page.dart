import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/navbar_widget.dart';
import 'package:flutter_application_1/widgets/curso_card_widget.dart';
import 'package:flutter_application_1/core/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List> _cursos;

  @override
  void initState() {
    super.initState();
    _cursos = getCursos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academia Virtual PLUZ')),
      drawer: const NavbarWidget(),
      body: FutureBuilder(
        future: _cursos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar cursos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay cursos disponibles'));
          }

          final cursos = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: [
                const Text(
                  'Mis Cursos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...cursos.map((curso) => CursoCardWidget(curso: curso)),
              ],
            ),
          );
        },
      ),
    );
  }
}
