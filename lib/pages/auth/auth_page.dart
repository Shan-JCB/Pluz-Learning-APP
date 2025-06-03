import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';
import '../../core/auth_service.dart';

class AuthPage extends StatefulWidget {
  final bool initLogin;
  const AuthPage({super.key, this.initLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLogin = widget.initLogin;
  }

  void showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> handleAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Completa todos los campos');
      return;
    }

    if (!isLogin && password.length < 6) {
      showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    AuthService authService = AuthService();

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await authService.signIn(email, password);
        showMessage('Sesión iniciada correctamente');
      } else {
        await authService.register(email, password);
        showMessage('Cuenta registrada correctamente');
      }

      // Navegar a HomePage
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          showMessage('No existe una cuenta con ese correo');
          break;
        case 'wrong-password':
          showMessage('La contraseña es incorrecta');
          break;
        case 'invalid-credential':
          showMessage('Correo o contraseña incorrectos');
          break;
        case 'email-already-in-use':
          showMessage('Ese correo ya está registrado');
          break;
        case 'invalid-email':
          showMessage('El correo no es válido');
          break;
        case 'weak-password':
          showMessage('La contraseña es demasiado débil');
          break;
        default:
          showMessage('Error: ${e.message}');
      }
    } catch (e) {
      showMessage('Error inesperado: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Imagen de fondo
          Positioned.fill(
            child: Image.network(
              AppImages.urlFondo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.pluzAzulOscuro);
              },
            ),
          ),
          // 2) Capa semitransparente con color PLUZ
          Positioned.fill(
            child: Container(color: AppColors.pluzAzulCapatransparente),
          ),
          // 3) Contenido principal centrado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo centrado en la parte superior
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AppImages.logoblanco,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school,
                            size: 80,
                            color: AppColors.pluzBlanco,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contenedor de campos y botones
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.pluzAzulIntenso.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isLogin
                                ? Icons.login_rounded
                                : Icons.app_registration,
                            size: 40,
                            color: AppColors.naranjaIntenso,
                          ),
                          // Título según modo (Login o Registro)
                          Text(
                            isLogin ? 'Iniciar Sesión' : 'Registrate!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.pluzBlanco,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campo de correo
                          TextField(
                            controller: emailController,
                            style: const TextStyle(
                              color: AppColors.pluzCelesteClaro1,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email,
                                color: AppColors.naranjaIntenso,
                              ),
                              labelText: 'Correo electrónico',
                              labelStyle: const TextStyle(
                                color: AppColors.pluzCelesteClaro2,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.pluzCelesteClaro2,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.naranjaIntenso,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Campo de contraseña
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(
                              color: AppColors.pluzCelesteClaro1,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: AppColors.naranjaIntenso,
                              ),
                              labelText: 'Contraseña',
                              labelStyle: const TextStyle(
                                color: AppColors.pluzCelesteClaro2,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.pluzCelesteClaro2,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.naranjaIntenso,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Botón de acción o indicador de carga
                          isLoading
                              ? const CircularProgressIndicator(
                                color: AppColors.naranjaIntenso,
                              )
                              : ElevatedButton.icon(
                                onPressed: handleAuth,
                                icon: Icon(
                                  isLogin
                                      ? Icons.login
                                      : Icons.app_registration,
                                ),
                                label: Text(
                                  isLogin ? 'Iniciar Sesión' : 'Registrarse',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.naranjaIntenso,
                                  foregroundColor: AppColors.pluzBlanco,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                              ),

                          const SizedBox(height: 12),

                          // Texto para cambiar entre Login/Registro
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin
                                  ? '¿No tienes una cuenta? Regístrate aquí'
                                  : '¿Ya tienes una cuenta? Inicia sesión',
                              style: const TextStyle(
                                color: AppColors.naranjaIntenso,
                              ),
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
