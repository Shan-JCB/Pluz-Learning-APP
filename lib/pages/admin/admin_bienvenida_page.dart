import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class AdminBienvenidaPage extends StatelessWidget {
  const AdminBienvenidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            AppImages.fondoweb2,
            fit: BoxFit.cover,
            color: AppColors.pluzAzulCapatransparente,
            colorBlendMode: BlendMode.srcOver,
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: AppColors.pluzAzulIntenso,
                ),
                SizedBox(height: 16),
                Text(
                  '¡Bienvenido, administrador!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pluzAzulOscuro,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Desde aquí puedes gestionar los cursos y usuarios del sistema.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
