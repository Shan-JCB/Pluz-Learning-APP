import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pages/apartados/detalle_curso_page.dart';
import 'package:flutter_application_1/pages/apartados/pago_exitoso_page.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'historial_carrito.dart';

class CarritoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;

  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  double get total =>
      widget.carrito.fold(0, (sum, item) => sum + (item['precio'] ?? 0));

  void eliminarDelCarrito(int index) {
    setState(() {
      widget.carrito.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado del carrito')),
    );
  }

  Future<List<Map<String, dynamic>>> _buscarCursosSimilares() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final firestore = FirebaseFirestore.instance;

    // 1. Obtener IDs de cursos comprados
    final comprasSnap =
        await firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('compras')
            .get();

    final idsComprados = comprasSnap.docs.map((e) => e.id).toSet();

    // 2. Obtener todos los cursos del catálogo
    final cursosSnap = await firestore.collection('cursos').get();

    final cursosCatalogo =
        cursosSnap.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'nombre': data['nombre'],
            'descripcion': data['descripcion'],
            'precio': data['precio'],
            'imagen': data['imagen'],
            'modulos': data['modulos'],
          };
        }).toList();

    // 3. Categorías en el carrito
    final categoriasCarrito =
        widget.carrito
            .map(
              (e) =>
                  (e['descripcion'] ?? '')
                      .toString()
                      .split('-')
                      .first
                      .trim()
                      .toLowerCase(),
            )
            .toSet();

    final idsCarrito = widget.carrito.map((e) => e['id']).toSet();

    // 4. Filtrar recomendados por categoría
    final recomendados =
        cursosCatalogo.where((curso) {
          final categoria =
              (curso['descripcion'] ?? '')
                  .toString()
                  .split('-')
                  .first
                  .trim()
                  .toLowerCase();

          return categoriasCarrito.contains(categoria) &&
              !idsCarrito.contains(curso['id']) &&
              !idsComprados.contains(curso['id']);
        }).toList();

    // 5. Si no hay recomendados, devolver 5 cursos aleatorios
    if (recomendados.isEmpty) {
      final cursosDisponibles =
          cursosCatalogo
              .where(
                (curso) =>
                    !idsCarrito.contains(curso['id']) &&
                    !idsComprados.contains(curso['id']),
              )
              .toList();

      cursosDisponibles.shuffle();
      return cursosDisponibles.take(5).toList();
    }

    return recomendados;
  }

  Widget _recomendacionesVisuales(List<Map<String, dynamic>> cursos) {
    if (cursos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Cursos recomendados basados en tu carrito:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.pluzAzulIntenso,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cursos.length,
            itemBuilder: (context, index) {
              final curso = cursos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => DetalleCursoPage(
                            curso: curso,
                            esComprado: false,
                            carrito: widget.carrito,
                            onAgregar: (nuevoCurso) {
                              setState(() {
                                widget.carrito.add(nuevoCurso);
                              });
                            },
                          ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          _convertirDrive(curso['imagen'] ?? ''),
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 110,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              curso['nombre'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'S/ ${curso['precio'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.naranjaIntenso,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Agregar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.naranjaIntenso,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  if (widget.carrito.length >= 5) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No puedes agregar más de 5 cursos al carrito',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    widget.carrito.add(curso);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> finalizarCompra() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.carrito.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    try {
      // 🔎 Obtener datos del usuario
      final docUser =
          await firestore.collection('usuarios').doc(user.uid).get();
      final data = docUser.data() ?? {};

      final edadTexto = (data['edad'] ?? '').toString().trim();
      final telefonoTexto = (data['telefono'] ?? '').toString().trim();
      final edad = int.tryParse(edadTexto);

      // ❌ Validar campos vacíos
      if (edadTexto.isEmpty || telefonoTexto.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Completa los campos de edad y teléfono en tu perfil antes de realizar una compra.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // ❌ Validar si la edad está fuera del rango permitido
      if (edad == null || edad < 10 || edad > 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La edad debe estar entre 10 y 24 años para realizar una compra.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // ❌ Validar si es menor de edad sin número de tutor
      if (edad < 18 && telefonoTexto.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Si eres menor de edad, debes registrar el número de tu tutor o apoderado.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 🔎 Validar cantidad total de cursos comprados
      final comprasSnapshot =
          await firestore
              .collection('usuarios')
              .doc(user.uid)
              .collection('compras')
              .get();

      final totalActual = comprasSnapshot.docs.length;
      final totalNuevo = totalActual + widget.carrito.length;

      if (totalNuevo > 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ya tienes cursos en suscripción. Completa primero antes de adquirir más.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // ✅ Guardar en historial
      await firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('historial')
          .add({
            'fecha': FieldValue.serverTimestamp(),
            'productos': widget.carrito,
            'total': total,
          });

      // ✅ Guardar en compras
      for (final curso in widget.carrito) {
        await firestore
            .collection('usuarios')
            .doc(user.uid)
            .collection('compras')
            .doc(curso['id'])
            .set(curso);
      }

      setState(() {
        widget.carrito.clear();
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PagoExitosoPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al finalizar la compra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _convertirDrive(String enlace) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlace);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    }
    return enlace;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Asegúrate de no desactivar la flecha de regresar:
        automaticallyImplyLeading: true,

        // 2. Fondo del AppBar (puede quedar igual que antes)
        backgroundColor: AppColors.pluzAzulIntenso,

        // 3. Forzar que todos los iconos (flecha, acciones) sean blancos:
        iconTheme: const IconThemeData(color: Colors.white),

        // 4. Título en color blanco:
        title: const Text('Mi Carrito', style: TextStyle(color: Colors.white)),

        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialCarritoScreen(),
                  ),
                ),
          ),
          if (widget.carrito.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: finalizarCompra,
              tooltip: 'Finalizar compra',
            ),
        ],
      ),

      body:
          widget.carrito.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.pluzAzulCapaTrans2,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tu carrito está vacío',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.carrito.length,
                      itemBuilder: (context, index) {
                        final producto = widget.carrito[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => DetalleCursoPage(
                                        curso: producto,
                                        esComprado: false,
                                        carrito: widget.carrito,
                                        onAgregar: null, // ya está en carrito
                                      ),
                                ),
                              );
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _convertirDrive(producto['imagen'] ?? ''),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              title: Text(
                                producto['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pluzAzulOscuro,
                                ),
                              ),
                              subtitle: Text(
                                'S/ ${producto['precio'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => eliminarDelCarrito(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _buscarCursosSimilares(),
                    builder: (context, snapshot) {
                      // Si ya hay 5 cursos en el carrito, no mostrar recomendaciones
                      if (widget.carrito.length >= 5) {
                        return const SizedBox.shrink();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return _recomendacionesVisuales(snapshot.data!);
                    },
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pluzAzulCapaTrans4,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Resumen de tu compra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pluzBlanco,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total de artículos: ${widget.carrito.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.pluzBlanco,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total a pagar: S/ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pluzBlanco,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              widget.carrito.isNotEmpty
                                  ? finalizarCompra
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranjaIntenso,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'PAGAR AHORA',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
