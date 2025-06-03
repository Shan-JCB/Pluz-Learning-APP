import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/auth_service.dart';
import 'package:flutter_application_1/pages/auth/login_page.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> handleRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Completa todos los campos');
      return;
    }

    if (password.length < 6) {
      showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().register(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          showMessage('Ese correo ya está registrado');
          break;
        case 'invalid-email':
          showMessage('Correo inválido');
          break;
        case 'weak-password':
          showMessage('Contraseña muy débil');
          break;
        default:
          showMessage('Error: ${e.message}');
      }
    } catch (e) {
      showMessage('Error inesperado');
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                    Container(
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
                          const Text(
                            'Registro',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: emailController,
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
                          const SizedBox(height: 16),
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
                          isLoading
                              ? const CircularProgressIndicator(
                                color: AppColors.naranjaIntenso,
                              )
                              : ElevatedButton.icon(
                                onPressed: handleRegister,
                                icon: const Icon(Icons.app_registration),
                                label: const Text('Registrarse'),
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
                              style: TextStyle(color: AppColors.naranjaIntenso),
                            ),
                          ),
                        ],
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
