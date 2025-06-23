import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';

class AdminCursosPage extends StatefulWidget {
  const AdminCursosPage({super.key});

  @override
  State<AdminCursosPage> createState() => _AdminCursosPageState();
}

class _AdminCursosPageState extends State<AdminCursosPage> {
  late Future<List> _cursosFuture;
  List _datosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  void _cargarCursos() {
    _cursosFuture = getCursos();
    _cursosFuture.then((lista) {
      setState(() {
        _datosFiltrados = lista;
      });
    });
  }

  void _recargar() => _cargarCursos();

  void _filtrar(List lista, String texto) {
    final filtro = texto.toLowerCase();
    setState(() {
      _datosFiltrados =
          lista
              .where(
                (item) =>
                    (item['nombre'] as String).toLowerCase().contains(filtro),
              )
              .toList();
    });
  }

  Future<void> _confirmarEliminacion(String id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("¿Eliminar '$nombre'?"),
            content: const Text(
              "Esta acción no se puede deshacer. ¿Deseas continuar?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await deleteCurso(id);
      _recargar();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Curso eliminado"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editarCurso(Map curso) async {
    final res = await Navigator.pushNamed(
      context,
      '/edit_curso',
      arguments: curso,
    );
    if (res == 'actualizado' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Curso actualizado"),
          backgroundColor: Colors.blue,
        ),
      );
      _recargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar curso',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (texto) {
                    _cursosFuture.then((lista) => _filtrar(lista, texto));
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pluzAzulIntenso,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Agregar Curso",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final res = await Navigator.pushNamed(context, '/add_curso');
                  if (res == 'guardado' && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Curso agregado"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _recargar();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<List>(
            future: _cursosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      "Cargando cursos...",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Expanded(
                  child: Center(child: Text("Error al cargar cursos")),
                );
              }
              final cursos = snapshot.data ?? [];
              if (cursos.isEmpty) {
                return const Expanded(
                  child: Center(child: Text("No hay cursos disponibles")),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: _datosFiltrados.length,
                  itemBuilder: (context, i) {
                    final curso = _datosFiltrados[i];
                    final modulos = curso['modulos'] ?? [];
                    final cantidadModulos =
                        modulos is List ? modulos.length : 5;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.pluzAzulCapaTrans4,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.book,
                            color: AppColors.pluzAzulIntenso,
                            size: 32,
                          ),
                        ),
                        title: Text(
                          curso['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              curso['descripcion'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text("S/ ${curso['precio']}"),
                            Text("Módulos: $cantidadModulos"),
                          ],
                        ),
                        onTap: () => _editarCurso(curso),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarCurso(curso),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => _confirmarEliminacion(
                                    curso['id'],
                                    curso['nombre'],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
