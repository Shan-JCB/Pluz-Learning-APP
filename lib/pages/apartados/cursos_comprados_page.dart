import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/widgets/curso_card_widget.dart';

class CursosCompradosPage extends StatefulWidget {
  const CursosCompradosPage({super.key});

  @override
  State<CursosCompradosPage> createState() => _CursosCompradosPageState();
}

class _CursosCompradosPageState extends State<CursosCompradosPage> {
  Future<List<Map<String, dynamic>>> obtenerCursosComprados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('compras')
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerCursosComprados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes cursos comprados.'));
          }

          final cursosComprados = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cursosComprados.length,
            itemBuilder: (context, index) {
              final curso = cursosComprados[index];
              return CursoCardWidget(curso: curso, esComprado: true);
            },
          );
        },
      ),
    );
  }
}
