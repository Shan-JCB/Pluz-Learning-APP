import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class NavbarWidget extends StatelessWidget {
  final void Function(int) onSelectPage;
  final int selectedIndex;

  const NavbarWidget({
    super.key,
    required this.onSelectPage,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Usuario';

    return Drawer(
      // Envolvemos el ListView en un Container con BoxDecoration que usa imagen de fondo + capa semitransparente
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.fondo3),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppColors.pluzBlancaCapaTrans1,
              BlendMode.srcOver,
            ),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header con imagen de fondo y capa semitransparente
            UserAccountsDrawerHeader(
              accountName: const Text(
                'Mi Cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.pluzAzulIntenso,
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.cabecera1),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.pluzAzulCapatransparente,
                    BlendMode.srcOver,
                  ),
                ),
              ),
            ),

            // 0: Inicio / Catálogo de Cursos
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.naranjaOscuro),
              title: const Text(
                'Inicio',
                style: TextStyle(color: AppColors.naranjaOscuro),
              ),
              selected: selectedIndex == 0,
              onTap: () => onSelectPage(0),
            ),

            // 1: Tienda (mapa)
            ListTile(
              leading: const Icon(
                Icons.location_on,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Ubicación a la tienda',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: selectedIndex == 1,
              onTap: () => onSelectPage(1),
            ),

            // 2: Carrito
            ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Mi Carrito',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: selectedIndex == 2,
              onTap: () => onSelectPage(2),
            ),

            // 3: Cuenta
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Cuenta',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: selectedIndex == 3,
              onTap: () => onSelectPage(3),
            ),

            const Divider(color: Color.fromARGB(179, 203, 203, 203)),

            // 4: CRUD Cursos
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.pluzAzulIntenso),
              title: const Text(
                'CRUD Cursos',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: selectedIndex == 4,
              onTap: () => onSelectPage(4),
            ),

            const Divider(color: Color.fromARGB(179, 203, 203, 203)),

            // Cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
