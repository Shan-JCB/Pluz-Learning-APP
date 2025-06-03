import 'package:flutter/material.dart';
//Utilidades:
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';
import 'package:flutter_application_1/widgets/navbar_widget.dart';
//Rutas:
import 'package:flutter_application_1/pages/apartados/catalogo_cursos_page.dart';
import 'package:flutter_application_1/pages/apartados/tienda_screen.dart';
import 'package:flutter_application_1/pages/apartados/carrito_screen.dart';
import 'package:flutter_application_1/pages/auth/account_page.dart';
import 'package:flutter_application_1/pages/curso/home_cursos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Índice de la página seleccionada:
  /// 0 = Catálogo de Cursos
  /// 1 = Tienda (mapa)
  /// 2 = Carrito
  /// 3 = Cuenta
  /// 4 = CRUD Cursos
  int _selectedIndex = 0;

  /// Lista de Widgets que se mostrarán en el body según _selectedIndex
  final List<Widget> _pages = const [
    CursosPage(), // 0
    TiendaScreen(), // 1
    CarritoScreen(carrito: []), // 2
    AccountPage(), // 3
    HomeCursoPage(), // 4 - CRUD Cursos (temporalmente el mismo widget)
  ];

  void _onSelectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Cerrar el Drawer automáticamente
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // importante para que se vea el fondo
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            // Imagen de fondo
            Positioned.fill(
              child: Image.network(
                AppImages.urlnavbarhome,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.pluzAzulIntenso);
                },
              ),
            ),
            // Capa semitransparente
            Positioned.fill(
              child: Container(color: AppColors.pluzAzulCapaTrans2),
            ),
          ],
        ),
        title: Image.asset(
          AppImages.logoblanco,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.school, color: Colors.white, size: 32);
          },
        ),
        centerTitle: false,
      ),

      drawer: NavbarWidget(
        onSelectPage: _onSelectPage,
        selectedIndex: _selectedIndex,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
