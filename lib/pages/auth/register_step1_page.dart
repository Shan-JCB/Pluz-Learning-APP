import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';
import 'register_step2_page.dart';
import 'login_page.dart';

class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool mostrarFormulario = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => mostrarFormulario = true);
    });
  }

  void continuarRegistro() {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña mínima de 6 caracteres')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => RegisterStep2Page(
              nombre: nombre,
              correo: correo,
              password: password,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo e imagen
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
                    // Logo superior
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
                              Icons.app_registration,
                              size: 40,
                              color: AppColors.naranjaIntenso,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Registrate!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo: Nombres
                            TextField(
                              controller: nombreController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Nombres completos',
                                prefixIcon: Icon(
                                  Icons.person,
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

                            // Campo: Correo
                            TextField(
                              controller: correoController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(
                                  Icons.email,
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

                            // Campo: Contraseña
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(
                                  Icons.lock,
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

                            // Botón continuar
                            ElevatedButton.icon(
                              onPressed: continuarRegistro,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Continuar'),
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

                            const SizedBox(height: 12),

                            // Botón hacia logeo
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                '¿Ya tienes una cuenta? Inicia sesión',
                                style: TextStyle(
                                  color: AppColors.naranjaIntenso,
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
