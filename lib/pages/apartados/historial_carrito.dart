import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class HistorialCarritoScreen extends StatelessWidget {
  const HistorialCarritoScreen({super.key});

  Future<void> _confirmarYLimpiarHistorial(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Limpiar historial'),
            content: const Text(
              '¿Estás seguro de que deseas borrar todo el historial?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      final historialRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('historial');
      final docs = await historialRef.get();
      for (var doc in docs.docs) {
        await doc.reference.delete();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial borrado exitosamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Debes iniciar sesión',
            style: TextStyle(fontSize: 16, color: AppColors.pluzAzulOscuro),
          ),
        ),
      );
    }

    final historial = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('historial')
        .orderBy('fecha', descending: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pluzAzulIntenso,
        iconTheme: const IconThemeData(color: Colors.white), // flecha blanca
        title: const Text(
          'Historial de Compras',
          style: TextStyle(color: Colors.white), // texto blanco
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Limpiar historial',
            onPressed: () => _confirmarYLimpiarHistorial(context),
          ),
        ],
      ),

      body: Column(
        children: [
          // Banner decorativo debajo del AppBar
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.cabecera1),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.pluzAzulCapatransparente,
                  BlendMode.srcOver,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Tus compras recientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: historial.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.naranjaIntenso,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_sharp,
                          size: 80,
                          color: AppColors.pluzAzulCapaTrans2,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Historial vacío',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final productos = List<Map<String, dynamic>>.from(
                      data['productos'],
                    );
                    final total = data['total'] ?? 0.0;
                    final fecha =
                        data['fecha'] != null
                            ? DateFormat(
                              'dd/MM/yyyy – HH:mm',
                            ).format(data['fecha'].toDate())
                            : 'Fecha desconocida';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        iconColor: AppColors.pluzAzulOscuro,
                        collapsedIconColor: AppColors.pluzAzulOscuro,

                        // --- MODIFICAR ESTE "title" para agregar el icono de eliminar individual ---
                        title: Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag,
                              color: AppColors.naranjaIntenso,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Compra - $fecha',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pluzAzulOscuro,
                                ),
                              ),
                            ),
                            // --- NUEVO: Botón para eliminar esta compra específica ---
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Eliminar esta compra',
                              onPressed: () async {
                                // 1) Borrar el documento correspondiente en Firestore
                                await FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(user.uid)
                                    .collection('historial')
                                    .doc(doc.id)
                                    .delete();

                                // 2) Mostrar un snack de confirmación
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Compra eliminada'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        // --- resto del ExpansionTile (subtitle y children) permanece igual ---
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text(
                            'Total: S/ ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.pluzAzulOscuro,
                            ),
                          ),
                        ),
                        children: [
                          const Divider(color: Colors.grey),
                          ...productos.map((prod) {
                            return ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: AppColors.pluzAzulOscuro,
                              ),
                              title: Text(
                                prod['nombre'],
                                style: const TextStyle(
                                  color: AppColors.pluzAzulOscuro,
                                ),
                              ),
                              trailing: Text(
                                'S/ ${prod['precio'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.pluzAzulIntenso,
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
