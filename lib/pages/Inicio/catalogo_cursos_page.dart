import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';
import 'package:flutter_application_1/widgets/curso_card_widget.dart';

class CursosPage extends StatefulWidget {
  const CursosPage({super.key});

  @override
  State<CursosPage> createState() => _CursosPageState();
}

class _CursosPageState extends State<CursosPage> {
  late Future<List> _cursosOriginal;
  List _cursosFiltrados = [];
  String _filtroTexto = '';
  bool _ordenAscendente = true;

  @override
  void initState() {
    super.initState();
    _cursosOriginal = getCursos();
    _cursosOriginal.then((data) {
      setState(() {
        _cursosFiltrados = data;
      });
    });
  }

  void _filtrar(String texto) {
    setState(() {
      _filtroTexto = texto.toLowerCase();
    });
    _actualizarLista();
  }

  void _ordenarPorPrecio() {
    setState(() {
      _ordenAscendente = !_ordenAscendente;
    });
    _actualizarLista();
  }

  void _actualizarLista() async {
    final lista = await _cursosOriginal;
    final filtrada =
        lista.where((curso) {
          final nombre = curso['nombre'].toString().toLowerCase();
          final descripcion = curso['descripcion'].toString().toLowerCase();
          return nombre.contains(_filtroTexto) ||
              descripcion.contains(_filtroTexto);
        }).toList();

    filtrada.sort((a, b) {
      final pa = a['precio'] ?? 0;
      final pb = b['precio'] ?? 0;
      return _ordenAscendente ? pa.compareTo(pb) : pb.compareTo(pa);
    });

    setState(() {
      _cursosFiltrados = filtrada;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar cursos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filtrar,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Ordenar por precio:'),
              IconButton(
                icon: Icon(
                  _ordenAscendente ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.green,
                ),
                onPressed: _ordenarPorPrecio,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _cursosFiltrados.isEmpty
                    ? const Center(child: Text('No se encontraron cursos'))
                    : ListView.builder(
                      itemCount: _cursosFiltrados.length,
                      itemBuilder: (context, index) {
                        return CursoCardWidget(curso: _cursosFiltrados[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
