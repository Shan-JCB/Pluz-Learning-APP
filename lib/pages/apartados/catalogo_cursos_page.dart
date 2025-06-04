import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/widgets/curso_card_widget.dart';
import 'package:flutter_application_1/pages/apartados/carrito_screen.dart';

class CursosPage extends StatefulWidget {
  const CursosPage({super.key});

  @override
  State<CursosPage> createState() => _CursosPageState();
}

class _CursosPageState extends State<CursosPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _cursosOriginal;
  List _cursosFiltrados = [];
  List<Map<String, dynamic>> carrito = [];

  String _filtroTexto = '';
  bool _ordenAscendente = true;

  late AnimationController _iconAnimationController;
  late Animation<double> _scaleAnimation;

  Future<List<Map<String, dynamic>>> getCursosFiltrandoComprados() async {
    final todos = await getCursos();
    final user = FirebaseAuth.instance.currentUser;

    final comprasSnap =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('compras')
            .get();

    final compradosIds = comprasSnap.docs.map((e) => e.id).toSet();

    return todos
        .where((curso) => !compradosIds.contains(curso['id']))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _cursosOriginal = getCursosFiltrandoComprados();
    _cursosOriginal.then((data) {
      setState(() {
        _cursosFiltrados = data;
      });
    });

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  void agregarAlCarrito(Map<String, dynamic> producto) {
    setState(() {
      carrito.add(producto);
    });

    _iconAnimationController.forward().then((_) {
      _iconAnimationController.reverse();
    });
  }

  void irAlCarrito() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarritoScreen(carrito: carrito)),
    );
    setState(() {}); // refrescar cantidad al volver
  }

  String _normalizar(String texto) {
    const normal = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'a',
      'É': 'e',
      'Í': 'i',
      'Ó': 'o',
      'Ú': 'u',
      'ñ': 'n',
      'Ñ': 'n',
    };
    var salida = texto.toLowerCase();
    normal.forEach((original, reemplazo) {
      salida = salida.replaceAll(original, reemplazo);
    });
    return salida;
  }

  void _filtrar(String texto) {
    setState(() {
      _filtroTexto = _normalizar(texto.trim());
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
          final nombre = curso['nombre']?.toString() ?? '';
          final nombreNorm = _normalizar(nombre);
          return nombreNorm.contains(_filtroTexto);
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
    return Scaffold(
      // Ya no hay AppBar
      body: Padding(
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
                    _ordenAscendente
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: AppColors.pluzAzulIntenso,
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
                          return CursoCardWidget(
                            curso: _cursosFiltrados[index],
                            onAgregar: agregarAlCarrito,
                            carrito: carrito,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      // Carrito como FloatingActionButton con conteo
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                backgroundColor: AppColors.naranjaOscuro,
                onPressed: irAlCarrito,
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              if (carrito.isNotEmpty)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${carrito.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
