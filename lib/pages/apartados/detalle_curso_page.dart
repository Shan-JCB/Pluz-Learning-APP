import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';

class DetalleCursoPage extends StatelessWidget {
  final Map<String, dynamic> curso;
  final bool esComprado;
  final VoidCallback? onCancelar;
  final void Function(Map<String, dynamic>)? onAgregar;
  final List<Map<String, dynamic>>? carrito;

  const DetalleCursoPage({
    super.key,
    required this.curso,
    this.esComprado = false,
    this.onCancelar,
    this.onAgregar,
    this.carrito,
  });

  String _convertirDrive(String enlace) {
    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(enlace);
    return match != null
        ? 'https://drive.google.com/uc?export=view&id=${match.group(1)}'
        : enlace;
  }

  Future<void> _cancelarSuscripcion(BuildContext context) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Cancelar suscripción?'),
            content: Text(
              '¿Deseas cancelar el acceso al curso "${curso['nombre']}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirmacion != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('compras')
        .doc(curso['id'])
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Suscripción cancelada')));
    }

    onCancelar?.call();
    Navigator.pop(context);
  }

  bool _yaEnCarrito() {
    if (carrito == null) return false;
    return carrito!.any((item) => item['id'] == curso['id']);
  }

  @override
  Widget build(BuildContext context) {
    final modulos = curso['modulos'] as List? ?? [];
    final imagenUrl = _convertirDrive(curso['imagen'] ?? '');
    final yaEnCarrito = _yaEnCarrito();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Curso'),
        backgroundColor: AppColors.pluzAzulIntenso,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagenUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 60),
                    ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Row(
              children: [
                const Icon(Icons.book, color: AppColors.pluzAzulIntenso),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    curso['nombre'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Precio
            Row(
              children: [
                const Icon(Icons.attach_money, color: AppColors.naranjaOscuro),
                const SizedBox(width: 8),
                Text(
                  'S/ ${curso['precio'].toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              curso['descripcion'],
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // Módulos
            const Text(
              'Módulos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (modulos.isEmpty)
              const Text(
                'Este curso aún no tiene módulos registrados.',
                style: TextStyle(color: Colors.grey),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(modulos.length, (index) {
                  final modulo = modulos[index];
                  final contenido = modulo['contenido'] ?? modulo.toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pluzAzulIntenso,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Módulo ${index + 1}: $contenido',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

            const SizedBox(height: 30),

            // Acción final
            Center(
              child:
                  esComprado
                      ? ElevatedButton.icon(
                        onPressed: () => _cancelarSuscripcion(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar suscripción'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      )
                      : ElevatedButton.icon(
                        onPressed:
                            yaEnCarrito || onAgregar == null
                                ? null
                                : () {
                                  onAgregar!(curso);
                                  Navigator.pop(
                                    context,
                                  ); // <- vuelve al catálogo automáticamente
                                },
                        icon: Icon(
                          yaEnCarrito
                              ? Icons.check_circle
                              : Icons.add_shopping_cart,
                        ),
                        label: Text(
                          yaEnCarrito ? 'Ya en carrito' : 'Agregar al carrito',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              yaEnCarrito
                                  ? Colors.blueGrey
                                  : AppColors.naranjaIntenso,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
