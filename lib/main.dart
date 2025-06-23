import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/admin/admin_dashboar_users.dart';
import 'package:flutter_application_1/pages/admin/admin_dashboard.dart';
import 'package:flutter_application_1/pages/apartados/sensores_screen.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'firebase_options.dart';

// Páginas fusionadas
import 'pages/home_page.dart';

// Rutas a Cursos
import 'package:flutter_application_1/pages/curso/add_curso_page.dart';
import 'package:flutter_application_1/pages/curso/edit_curso_page.dart';
import 'package:flutter_application_1/pages/curso/home_cursos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Agregamos el mixin
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Timer? _inactivityTimer;
  static const _timeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Nos registramos
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Quitamos el observador
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Detectamos cambios de ciclo de vida
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _handleInactivity();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeout, _handleInactivity);
  }

  void _handleInactivity() async {
    await FirebaseAuth.instance.signOut();
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  // Reinicia el temporizador ante cualquier interacción
  void _onUserInteraction([_]) {
    _startInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onUserInteraction,
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Academias Pluz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const HomePage(),
          '/cursos': (_) => const HomeCursoPage(),
          '/add_curso': (_) => const AddCursoPage(),
          '/edit_curso': (_) => const EditCursoPage(),
          '/sensores': (_) => const SensoresScreen(),
          '/admin': (_) => const AdminDashboard(),
          '/usuarios': (context) => const AdminUsuariosPage(),
        },
      ),
    );
  }
}
