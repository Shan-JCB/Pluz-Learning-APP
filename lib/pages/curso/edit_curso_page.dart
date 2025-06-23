import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/firebase_service.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

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
    // Validaciones básicas
    if (nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }
    final precio = double.tryParse(precioController.text);
    if (precio == null || precio < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un precio válido')));
      return;
    }

    final modulos = List.generate(
      6,
      (i) => {
        "titulo": nombresModulos[i],
        "contenido": modulosControllers[i].text,
      },
    );

    final data = {
      'nombre': nombreController.text.trim(),
      'descripcion': descripcionController.text.trim(),
      'precio': precio,
      'imagen': imagenController.text.trim(),
      'modulos': modulos,
    };

    await updateCurso(id, data);
    if (context.mounted) Navigator.pop(context, 'actualizado');
  }

  @override
  Widget build(BuildContext context) {
    final Map curso = ModalRoute.of(context)!.settings.arguments as Map;

    // Precargar datos una sola vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nombreController.text = curso['nombre'];
      descripcionController.text = curso['descripcion'];
      precioController.text = curso['precio'].toString();
      imagenController.text = curso['imagen'];
      final List modulos = curso['modulos'] ?? [];
      for (int i = 0; i < modulosControllers.length; i++) {
        modulosControllers[i].text =
            modulos.length > i ? modulos[i]['contenido'] : '';
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pluzBlancaCapaTrans1,
      appBar: AppBar(
        backgroundColor: AppColors.pluzAzulIntenso,
        title: Row(
          children: [
            Image.asset(AppImages.logoblanco, height: 28),
            const SizedBox(width: 12),
            const Text(
              'Editar Curso',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInput(
              controller: nombreController,
              label: 'Nombre del Curso',
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            _buildInput(
              controller: descripcionController,
              label: 'Descripción',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildInput(
              controller: precioController,
              label: 'Precio',
              icon: Icons.monetization_on,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput(
              controller: imagenController,
              label: 'Enlace imagen Drive',
              icon: Icons.link,
            ),
            const SizedBox(height: 24),
            const Text(
              'Contenido de los Módulos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.pluzAzulOscuro,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              modulosControllers.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildInput(
                  controller: modulosControllers[i],
                  label: nombresModulos[i],
                  icon: Icons.play_circle,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => actualizarCurso(curso['id']),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Actualizar Curso',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pluzAzulIntenso,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.pluzAzulIntenso),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.pluzAzulOscuro),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.pluzAzulIntenso),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(color: AppColors.pluzAzulOscuro),
      ),
    );
  }
}
