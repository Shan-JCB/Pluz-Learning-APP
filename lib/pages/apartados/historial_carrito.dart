import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistorialCarritoScreen extends StatelessWidget {
  const HistorialCarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión')));
    }

    final historial = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('historial')
        .orderBy('fecha', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Compras')),
      body: StreamBuilder<QuerySnapshot>(
        stream: historial.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('Sin historial aún'));
          }

          return ListView(
            children:
                docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final productos = List<Map<String, dynamic>>.from(
                    data['productos'],
                  );
                  final total = data['total'] ?? 0.0;
                  final fecha =
                      data['fecha'] != null
                          ? DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(data['fecha'].toDate())
                          : 'Fecha desconocida';

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ExpansionTile(
                      title: Text('Compra - $fecha'),
                      subtitle: Text('Total: S/ ${total.toStringAsFixed(2)}'),
                      children:
                          productos.map((prod) {
                            return ListTile(
                              title: Text(prod['nombre']),
                              trailing: Text('S/ ${prod['precio'].toString()}'),
                            );
                          }).toList(),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
