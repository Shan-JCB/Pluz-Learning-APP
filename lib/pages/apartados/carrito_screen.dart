import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> finalizarCompra() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.carrito.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    // Guardar en historial
    await firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('historial')
        .add({
          'fecha': FieldValue.serverTimestamp(),
          'productos': widget.carrito,
          'total': total,
        });

    // Guardar en compras
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra finalizada con éxito')),
    );
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarDelCarrito(index),
                            ),
                          ),
                        );
                      },
                    ),
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
