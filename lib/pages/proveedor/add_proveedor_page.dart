import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';

class AddProveedorPage extends StatefulWidget {
  const AddProveedorPage({super.key});

  @override
  State<AddProveedorPage> createState() => _AddProveedorPageState();
}

class _AddProveedorPageState extends State<AddProveedorPage> {
  final razonController = TextEditingController();
  final rucController = TextEditingController();
  final direccionController = TextEditingController();
  final contactoController = TextEditingController();
  final emailController = TextEditingController();
  final categoriaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Proveedor")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            TextField(
              controller: razonController,
              decoration: InputDecoration(labelText: "Razón Social"),
            ),
            TextField(
              controller: rucController,
              decoration: InputDecoration(labelText: "RUC"),
            ),
            TextField(
              controller: direccionController,
              decoration: InputDecoration(labelText: "Dirección"),
            ),
            TextField(
              controller: contactoController,
              decoration: InputDecoration(labelText: "Contacto"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: categoriaController,
              decoration: InputDecoration(labelText: "Categoría"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await addProveedor({
                  "razon_social": razonController.text,
                  "ruc": rucController.text,
                  "direccion": direccionController.text,
                  "contacto": contactoController.text,
                  "email": emailController.text,
                  "categoria": categoriaController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context, 'guardado');
                }
              },
              child: Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
