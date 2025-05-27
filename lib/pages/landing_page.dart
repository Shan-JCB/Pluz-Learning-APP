import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Inicio/inicio_page.dart';
import 'package:flutter_application_1/pages/Inicio/catalogo_cursos_page.dart';
import 'package:flutter_application_1/pages/Inicio/auth_buttons_page.dart';
import 'package:flutter_application_1/pages/Inicio/tienda_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _paginaActual = 0;

  final List<Widget> paginas = const [
    InicioPage(),
    CursosPage(),
    TiendaScreen(),
    AuthButtonsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pluz Academy"),
        backgroundColor: const Color.fromARGB(255, 155, 198, 255),
      ),
      body: SafeArea(
        // ⬅️ Agregado para evitar que el mapa tape UI
        child: paginas[_paginaActual],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        selectedItemColor: Colors.blueAccent, // ⬅️ Mejora visibilidad
        unselectedItemColor: Colors.grey, // ⬅️ Mejora visibilidad
        type: BottomNavigationBarType.fixed, // ⬅️ Asegura visibilidad
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Cursos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Tienda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Ingresar'),
        ],
      ),
    );
  }
}
