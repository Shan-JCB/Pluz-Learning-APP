import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/admin/admin_dashboard.dart';
import 'package:flutter_application_1/pages/admin/web_login_page.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';
import 'package:flutter_application_1/pages/landing_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Timer(const Duration(seconds: 3), _navegarSegunPlataforma);
  }

  void _navegarSegunPlataforma() {
    // Si estamos en Web, abrimos siempre el dashboard de admin
    if (kIsWeb) {
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  user != null
                      ? const AdminDashboard()
                      : const WebLoginPage(), // Nueva pantalla login web
        ),
      );

      return;
    }

    // En móvil, si hay sesión vamos a Home, si no a Landing
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const HomePage() : const LandingPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pluzAzulIntenso,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(AppImages.logoblanco, height: 120),
          ),
        ),
      ),
    );
  }
}
