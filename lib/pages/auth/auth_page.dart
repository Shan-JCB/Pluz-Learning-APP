import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      // 👉 Navegación a HomePage
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 194, 234, 255),
              Color.fromARGB(255, 55, 141, 191),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://drive.google.com/uc?export=view&id=1bojC0XeooeKTirNNorOp9LkIlZiAQsA6',
                    height: 100,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.school,
                          size: 80,
                          color: Colors.white,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isLogin ? 'Iniciar Sesión' : 'Registrarse',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 13, 79, 192),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isLogin ? Icons.login_rounded : Icons.app_registration,
                        size: 40,
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color(0xFFFF9800),
                          ),
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF9800)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFFFF9800),
                          ),
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFF9800)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Color(0xFFFF9800),
                          )
                          : ElevatedButton.icon(
                            onPressed: handleAuth,
                            icon: Icon(
                              isLogin ? Icons.login : Icons.app_registration,
                            ),
                            label: Text(
                              isLogin ? 'Iniciar Sesión' : 'Registrarse',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              foregroundColor: Colors.white,
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
                          style: const TextStyle(color: Color(0xFFFFA726)),
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
    );
  }
}
