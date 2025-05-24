import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCursoPage extends StatefulWidget {
  const EditCursoPage({super.key});

  @override
  State<EditCursoPage> createState() => _EditCursoPageState();
}

class _EditCursoPageState extends State<EditCursoPage> {
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

  Future<void> actualizarCurso(String id) async {
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

    await FirebaseFirestore.instance.collection('cursos').doc(id).set(data);
    if (context.mounted) {
      Navigator.pop(context, 'actualizado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map curso = ModalRoute.of(context)!.settings.arguments as Map;

    // Precargar campos principales
    nombreController.text = curso['nombre'];
    descripcionController.text = curso['descripcion'];
    precioController.text = curso['precio'].toString();
    imagenController.text = curso['imagen'];

    final List modulos = curso['modulos'] ?? [];

    for (int i = 0; i < modulosControllers.length; i++) {
      modulosControllers[i].text =
          modulos.length > i ? modulos[i]['contenido'] : '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Curso')),
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
              "Módulos del Curso",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < modulosControllers.length; i++)
              TextField(
                controller: modulosControllers[i],
                decoration: InputDecoration(labelText: nombresModulos[i]),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => actualizarCurso(curso['id']),
              child: const Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
