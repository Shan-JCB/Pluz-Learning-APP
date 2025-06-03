import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/Inicio/tienda_screen.dart';
import 'package:flutter_application_1/pages/auth/account_page.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Usuario';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Mi Cuenta'),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40),
            ),
          ),

          // CRUD Cursos
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('CRUD Cursos'),
            onTap: () => Navigator.pushNamed(context, '/cursos'),
          ),

          // Cuenta
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Cuenta'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
            },
          ),

          // Ubicación a la tienda
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Ubicación a la tienda'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TiendaScreen()),
              );
            },
          ),

          // Cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
