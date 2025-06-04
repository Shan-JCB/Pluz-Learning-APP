import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class RegisterStep2Page extends StatefulWidget {
  final String nombre;
  final String correo;
  final String password;

  const RegisterStep2Page({
    super.key,
    required this.nombre,
    required this.correo,
    required this.password,
  });

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  final edadController = TextEditingController();
  final telefonoController = TextEditingController();
  final paisController = TextEditingController();
  String genero = 'Otro';
  bool mostrarFormulario = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => mostrarFormulario = true);
    });
  }

  Future<void> registrarUsuario({bool omitido = false}) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.correo,
            password: widget.password,
          );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
            'nombres': widget.nombre,
            'correo': widget.correo,
            'edad': omitido ? null : edadController.text.trim(),
            'telefono': omitido ? null : telefonoController.text.trim(),
            'pais': omitido ? null : paisController.text.trim(),
            'genero': omitido ? null : genero,
            'fotoPerfilBase64': null,
          });

      if (!mounted) return;

      if (omitido) {
        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Registro completado'),
                content: const Text(
                  'Podrás modificar y agregar tus datos en la opción "cuenta" en la barra izquierda.',
                ),
                actions: [
                  TextButton(
                    child: const Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              AppImages.urlFondo,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(color: AppColors.pluzAzulOscuro),
            ),
          ),
          Positioned.fill(
            child: Container(color: AppColors.pluzAzulCapatransparente),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(AppImages.logoblanco, height: 100),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: mostrarFormulario ? 1 : 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.pluzAzulIntenso.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 40,
                              color: AppColors.naranjaIntenso,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Casi listo!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: edadController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Edad',
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              value: genero,
                              dropdownColor: AppColors.pluzAzulIntenso,
                              iconEnabledColor: Colors.white,
                              decoration: const InputDecoration(
                                labelText: 'Género',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.wc,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items:
                                  ['Masculino', 'Femenino', 'Otro']
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => genero = val ?? 'Otro'),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: paisController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'País',
                                prefixIcon: Icon(
                                  Icons.flag,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: telefonoController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: () => registrarUsuario(),
                              icon: const Icon(Icons.check),
                              label: const Text('Finalizar registro'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.naranjaIntenso,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            ElevatedButton.icon(
                              onPressed: () => registrarUsuario(omitido: true),
                              icon: const Icon(Icons.skip_next),
                              label: const Text('Omitir'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.naranjaIntenso,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
