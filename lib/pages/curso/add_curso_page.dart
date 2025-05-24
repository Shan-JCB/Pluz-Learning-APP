import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCursoPage extends StatefulWidget {
  const AddCursoPage({super.key});

  @override
  State<AddCursoPage> createState() => _AddCursoPageState();
}

class _AddCursoPageState extends State<AddCursoPage> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final imagenController = TextEditingController();

  final List<TextEditingController> modulosControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<String> nombresModulos = [
    "Módulo 1",
    "Módulo 2",
    "Módulo 3",
    "Módulo 4",
    "Módulo 5",
    "Cuestionario",
  ];

  Future<void> guardarCurso() async {
    final modulos = List.generate(
      6,
      (i) => {
        "titulo": nombresModulos[i],
        "contenido": modulosControllers[i].text,
      },
    );

    final data = {
      'nombre': nombreController.text,
      'descripcion': descripcionController.text,
      'precio': double.tryParse(precioController.text) ?? 0.0,
      'imagen': imagenController.text,
      'modulos': modulos,
    };

    await FirebaseFirestore.instance.collection('cursos').add(data);
    if (context.mounted) {
      Navigator.pop(context, 'guardado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Curso')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre del Curso"),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: "Precio"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imagenController,
              decoration: const InputDecoration(
                labelText: "Enlace de imagen de Google Drive",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Contenido de los Módulos:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < modulosControllers.length; i++)
              TextField(
                controller: modulosControllers[i],
                decoration: InputDecoration(labelText: nombresModulos[i]),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardarCurso,
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
