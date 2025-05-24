import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';

class EditProveedorPage extends StatefulWidget {
  const EditProveedorPage({super.key});

  @override
  State<EditProveedorPage> createState() => _EditProveedorPageState();
}

class _EditProveedorPageState extends State<EditProveedorPage> {
  final razonController = TextEditingController();
  final rucController = TextEditingController();
  final direccionController = TextEditingController();
  final contactoController = TextEditingController();
  final emailController = TextEditingController();
  final categoriaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map data = ModalRoute.of(context)!.settings.arguments as Map;

    razonController.text = data["razon_social"];
    rucController.text = data["ruc"];
    direccionController.text = data["direccion"];
    contactoController.text = data["contacto"];
    emailController.text = data["email"];
    categoriaController.text = data["categoria"];

    return Scaffold(
      appBar: AppBar(title: Text("Editar Proveedor")),
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
                await updateProveedor(data["uid"], {
                  "razon_social": razonController.text,
                  "ruc": rucController.text,
                  "direccion": direccionController.text,
                  "contacto": contactoController.text,
                  "email": emailController.text,
                  "categoria": categoriaController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context, 'actualizado');
                }
              },
              child: Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
