import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth/login_page.dart';
import 'package:flutter_application_1/pages/auth/register_page.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pluzAzulIntenso,
        title: Image.asset(
          AppImages.logoblanco,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.school, color: Colors.white, size: 32);
          },
        ),
        centerTitle: false,

        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            tooltip: 'Registrarse',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            tooltip: 'Iniciar sesión',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],

        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Para ícono de menú
      ),
      body: Stack(
        children: [
          // 1) Imagen de fondo ocupando todo
          Positioned.fill(
            child: Image.network(
              AppImages.urlFondo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.pluzAzulOscuro);
              },
            ),
          ),
          // 2) Capa semitransparente azul medio
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(
                229,
                103,
                182,
                227,
              ), // #63b4d0 con opacidad 50%
            ),
          ),
          // 3) Contenido principal dentro de scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Logo centrado ---
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AppImages.logoazul,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Título de bienvenida ---
                  Text(
                    '¡Bienvenid@ a Academias Pluz!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Imagen (Anuncio 1) ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      AppImages.urlAnuncio1,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: AppColors.pluzAzulOscuro,
                          child: const Icon(
                            Icons.announcement,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Párrafo sobre Pluz ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pluzAzulIntenso.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"En Academias Pluz nos dedicamos a impulsar tu formación profesional '
                      'con cursos diseñados para los retos del mercado actual. '
                      'y material actualizado. Únete a nuestra comunidad de estudiantes '
                      'y lleva tus habilidades al siguiente nivel."',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.pluzCelesteClaro1,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Imagen (Anuncio 2) ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      AppImages.urlLogeo,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: AppColors.pluzAzulOscuro,
                          child: const Icon(
                            Icons.announcement,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Imagen (Anuncio 2) ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      AppImages.urlAnuncio2,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: AppColors.pluzAzulOscuro,
                          child: const Icon(
                            Icons.announcement,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Sección de contacto ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.naranjaOscuro,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contacto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Correo: contacto@academiaspluz.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.naranjaClaro1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Teléfono: +51 123 456 789',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.naranjaClaro1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Síguenos en redes: @AcademiasPluz',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.naranjaClaro1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
