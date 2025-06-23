import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget para cursos en el CATÁLOGO
class CursoCatalogoCard extends StatelessWidget {
  final Map<String, dynamic> curso;
  final void Function(Map<String, dynamic>) onAgregar;
  final List<Map<String, dynamic>> carrito;

  const CursoCatalogoCard({
    super.key,
    required this.curso,
    required this.onAgregar,
    required this.carrito,
  });

  String _convertirDrive(String enlace) {
    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(enlace);
    return match != null
        ? 'https://drive.google.com/uc?export=view&id=${match.group(1)}'
        : enlace;
  }

  bool _yaEnCarrito() {
    return carrito.any((item) => item['id'] == curso['id']);
  }

  @override
  Widget build(BuildContext context) {
    final yaAgregado = _yaEnCarrito();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              _convertirDrive(curso['imagen'] ?? ''),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso['nombre'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  curso['descripcion'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text('S/ ${curso['precio'].toString()}'),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: yaAgregado ? null : () => onAgregar(curso),
                    icon: Icon(
                      yaAgregado ? Icons.check_circle : Icons.add_shopping_cart,
                    ),
                    label: Text(yaAgregado ? 'Agregado' : 'Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          yaAgregado ? Colors.blueGrey : Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
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

/// Widget para cursos COMPRADOS
class CursoCompradoCard extends StatelessWidget {
  final Map<String, dynamic> curso;
  final VoidCallback onCancelado;

  const CursoCompradoCard({
    super.key,
    required this.curso,
    required this.onCancelado,
  });

  String _convertirDrive(String enlace) {
    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(enlace);
    return match != null
        ? 'https://drive.google.com/uc?export=view&id=${match.group(1)}'
        : enlace;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              _convertirDrive(curso['imagen'] ?? ''),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  curso['nombre'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  curso['descripcion'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.schedule, size: 18),
                    SizedBox(width: 5),
                    Text('6 horas'),
                    SizedBox(width: 20),
                    Icon(Icons.lock_open, size: 18),
                    SizedBox(width: 5),
                    Text('Acceso completo'),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar suscripción'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final confirmacion = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('¿Cancelar suscripción?'),
                              content: Text(
                                '¿Estás seguro de que deseas cancelar el acceso a "${curso['nombre']}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Suscripción cancelada'),
                          ),
                        );
                      }

                      onCancelado(); // Actualiza lista en la vista
                    },
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
