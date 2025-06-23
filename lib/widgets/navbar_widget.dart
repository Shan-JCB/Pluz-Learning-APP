import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class NavbarWidget extends StatefulWidget {
  final void Function(int) onSelectPage;
  final int selectedIndex;

  const NavbarWidget({
    super.key,
    required this.onSelectPage,
    required this.selectedIndex,
  });

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  String? imagenBase64;
  String nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

    final data = doc.data();
    if (mounted) {
      setState(() {
        nombreUsuario = data?['nombres'] ?? 'Usuario';
        imagenBase64 = data?['fotoPerfilBase64'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;

    if (imagenBase64 != null) {
      try {
        avatarImage = MemoryImage(base64Decode(imagenBase64!));
      } catch (_) {}
    }

    return Drawer(
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
            UserAccountsDrawerHeader(
              accountName: Text(
                'Hola, $nombreUsuario!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: const SizedBox.shrink(),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: avatarImage,
                child:
                    avatarImage == null
                        ? const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.pluzAzulIntenso,
                        )
                        : null,
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
            // (continúan los ListTile sin cambios...)

            // Opciones del Drawer:
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.naranjaOscuro),
              title: const Text(
                'Inicio',
                style: TextStyle(color: AppColors.naranjaOscuro),
              ),
              selected: widget.selectedIndex == 0,
              onTap: () => widget.onSelectPage(0),
            ),
            ListTile(
              leading: const Icon(
                Icons.book_rounded,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Mis Cursos',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: widget.selectedIndex == 5,
              onTap: () => widget.onSelectPage(5),
            ),
            ListTile(
              leading: const Icon(
                Icons.location_on,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Academia',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: widget.selectedIndex == 1,
              onTap: () => widget.onSelectPage(1),
            ),
            ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Historial de Compras',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: widget.selectedIndex == 2,
              onTap: () => widget.onSelectPage(2),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Cuenta',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: widget.selectedIndex == 3,
              onTap: () => widget.onSelectPage(3),
            ),
            const Divider(color: Color.fromARGB(179, 203, 203, 203)),
            ListTile(
              leading: const Icon(
                Icons.sensor_window,
                color: AppColors.pluzAzulIntenso,
              ),
              title: const Text(
                'Sensores',
                style: TextStyle(color: AppColors.pluzAzulOscuro),
              ),
              selected: widget.selectedIndex == 4,
              onTap: () => widget.onSelectPage(4),
            ),
            const Divider(color: Color.fromARGB(179, 203, 203, 203)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
