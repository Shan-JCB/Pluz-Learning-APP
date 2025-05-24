import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';

class HomeCursoPage extends StatefulWidget {
  const HomeCursoPage({super.key});

  @override
  State<HomeCursoPage> createState() => _HomeCursoPageState();
}

class _HomeCursoPageState extends State<HomeCursoPage> {
  late Future<List> _cursos;
  List _datosFiltrados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cursos = getCursos();
    _cursos.then((lista) {
      setState(() {
        _datosFiltrados = lista;
      });
    });
  }

  void _recargarLista() {
    setState(() {
      _cursos = getCursos();
      _cursos.then((lista) {
        _filtrar(lista, _busqueda);
      });
    });
  }

  void _filtrar(List lista, String texto) {
    final filtro = texto.toLowerCase();
    setState(() {
      _datosFiltrados =
          lista.where((item) {
            final nombre = item['nombre'].toLowerCase();
            return nombre.contains(filtro);
          }).toList();
    });
  }

  String convertirEnlaceDriveADirecto(String enlaceDrive) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlaceDrive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Lista de Cursos"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _cursos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar cursos"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay cursos registrados"));
          }

          final listaOriginal = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (texto) {
                    _busqueda = texto;
                    _filtrar(listaOriginal, texto);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _datosFiltrados.length,
                  itemBuilder: (context, index) {
                    final curso = _datosFiltrados[index];
                    final imagen = convertirEnlaceDriveADirecto(
                      curso['imagen'],
                    );

                    return Dismissible(
                      key: Key(curso["id"]),
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        final confirm = await showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text("¿Eliminar '${curso['nombre']}'?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancelar"),
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text("Eliminar"),
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                        );
                        return confirm;
                      },
                      onDismissed: (_) async {
                        await deleteCurso(curso["id"]);
                        _recargarLista();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Curso eliminado"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Image.network(
                          imagen,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                        ),
                        title: Text(curso['nombre']),
                        subtitle: Text("S/ ${curso['precio'].toString()}"),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            "/edit_curso",
                            arguments: curso,
                          );
                          if (result == 'actualizado' && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Curso actualizado correctamente",
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                          _recargarLista();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "/add_curso");
          if (result == 'guardado' && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Curso guardado correctamente"),
                backgroundColor: Colors.green,
              ),
            );
            _recargarLista();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
