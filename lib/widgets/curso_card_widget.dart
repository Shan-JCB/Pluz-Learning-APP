import 'package:flutter/material.dart';

class CursoCardWidget extends StatelessWidget {
  final Map<String, dynamic> curso;
  final void Function(Map<String, dynamic>)? onAgregar;
  final List<Map<String, dynamic>>? carrito; // NUEVO

  const CursoCardWidget({
    super.key,
    required this.curso,
    this.onAgregar,
    this.carrito,
  });

  String _convertirDrive(String enlace) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlace);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlace;
    }
  }

  bool _yaEnCarrito() {
    if (carrito == null) return false;
    return carrito!.any((item) => item['id'] == curso['id']);
  }

  @override
  Widget build(BuildContext context) {
    final img = _convertirDrive(curso['imagen'] ?? '');
    final yaAgregado = _yaEnCarrito();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              img,
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
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 5),
                    const Text('6 horas'),
                    const SizedBox(width: 20),
                    const Icon(Icons.lock_open, size: 18),
                    const SizedBox(width: 5),
                    Text('S/ ${curso['precio'].toString()}'),
                  ],
                ),
                const SizedBox(height: 10),
                if (onAgregar != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        yaAgregado
                            ? ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Agregado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                            : ElevatedButton.icon(
                              onPressed: () => onAgregar!(curso),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Agregar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
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
