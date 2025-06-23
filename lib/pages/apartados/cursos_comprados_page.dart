import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/apartados/detalle_curso_page.dart';
import 'package:flutter_application_1/widgets/curso_card_widget.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';

class CursosCompradosPage extends StatefulWidget {
  const CursosCompradosPage({super.key});

  @override
  State<CursosCompradosPage> createState() => _CursosCompradosPageState();
}

class _CursosCompradosPageState extends State<CursosCompradosPage> {
  List<Map<String, dynamic>> _todosLosCursos = [];
  List<Map<String, dynamic>> _cursosFiltrados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('compras')
            .get();

    final cursos = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      _todosLosCursos = cursos;
      _cursosFiltrados = cursos;
    });
  }

  void _filtrarCursos(String texto) {
    final filtro = texto.toLowerCase().trim();
    setState(() {
      _busqueda = texto;
      _cursosFiltrados =
          _todosLosCursos.where((curso) {
            final nombre = (curso['nombre'] ?? '').toString().toLowerCase();
            return nombre.contains(filtro);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pluzAzulIntenso,
      appBar: AppBar(
        title: const Text('Mis Cursos'),
        backgroundColor: AppColors.pluzAzulIntenso,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          _todosLosCursos.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No tienes cursos comprados.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar curso por nombre...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _filtrarCursos,
                    ),
                  ),
                  Expanded(
                    child:
                        _cursosFiltrados.isEmpty
                            ? const Center(
                              child: Text(
                                'No se encontraron resultados.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: _cursosFiltrados.length,
                              itemBuilder: (context, index) {
                                final curso = _cursosFiltrados[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => DetalleCursoPage(
                                              curso: curso,
                                              esComprado: true,
                                              onCancelar: () => _cargarCursos(),
                                            ),
                                      ),
                                    );
                                  },
                                  child: CursoCompradoCard(
                                    curso: curso,
                                    onCancelado: () => _cargarCursos(),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
