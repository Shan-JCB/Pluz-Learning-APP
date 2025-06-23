import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/admin/admin_dashboar_users.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';
import 'admin_cursos_page.dart';
import 'admin_bienvenida_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _screen = const AdminBienvenidaPage();
  String _selectedRoute = '/';

  void _selectRoute(String? route) {
    setState(() {
      _selectedRoute = route ?? '/';
      switch (_selectedRoute) {
        case '/cursos':
          _screen = const AdminCursosPage();
          break;
        case '/usuarios':
          _screen = const AdminUsuariosPage();
          break;
        case '/logout':
          _logout();
          break;
        default:
          _screen = const AdminBienvenidaPage();
      }
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.pluzAzulIntenso,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GestureDetector(
          onTap: () => _selectRoute('/'),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(AppImages.logoblanco, height: 32),
              ),
              const SizedBox(width: 12),
              const Text(
                '/ Panel Administrador',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            },
          ),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: const Color.fromARGB(170, 21, 101, 166),
        activeBackgroundColor: AppColors.pluzAzulOscuro,
        textStyle: const TextStyle(color: Colors.white),
        activeTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconColor: Colors.white,
        activeIconColor: Colors.white,
        header: GestureDetector(
          onTap: () => _selectRoute('/'),
          child: Container(
            height: 80,
            color: AppColors.pluzAzulOscuro,
            child: const Center(
              child: Text(
                '🏠 Pluz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        items: [
          AdminMenuItem(
            title: 'Usuarios',
            icon: Icons.people,
            route: '/usuarios',
          ),
          AdminMenuItem(title: 'Cursos', icon: Icons.book, route: '/cursos'),
        ],
        footer: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            color: AppColors.pluzAzulIntenso,
          ),
          child: GestureDetector(
            onTap: _logout,
            child: Row(
              children: const [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 7),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        selectedRoute: _selectedRoute,
        onSelected: (item) => _selectRoute(item.route),
      ),

      body: Column(
        children: [
          if (_selectedRoute == '/')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.pluzAzulCapaTrans4,
              child: const Text(
                'Bienvenido al panel de administración de Pluz Learning. Aquí puedes gestionar cursos y usuarios de manera eficiente.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          Expanded(child: _screen),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.pluzAzulOscuro,
            alignment: Alignment.center,
            child: const Text(
              '© 2025 Pluz Learning. Todos los derechos reservados.',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
