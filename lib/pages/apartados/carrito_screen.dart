import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          .doc(curso['id']) // Asegúrate de que cada curso tenga un campo 'id'
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
        title: const Text('Mi Carrito'),
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
              icon: const Icon(Icons.check),
              onPressed: finalizarCompra,
              tooltip: 'Finalizar compra',
            ),
        ],
      ),
      body:
          widget.carrito.isEmpty
              ? const Center(child: Text('Tu carrito está vacío'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.carrito.length,
                      itemBuilder: (context, index) {
                        final producto = widget.carrito[index];
                        return Card(
                          child: ListTile(
                            leading: Image.network(
                              _convertirDrive(producto['imagen'] ?? ''),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(producto['nombre']),
                            subtitle: Text('S/ ${producto['precio']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarDelCarrito(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total: S/ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
