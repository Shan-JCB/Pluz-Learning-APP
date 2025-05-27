import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/landing_page.dart';
import 'firebase_options.dart';

// Páginas fusionadas
import 'pages/home_page.dart';

//Rutas a Cursos
import 'package:flutter_application_1/pages/curso/add_curso_page.dart';
import 'package:flutter_application_1/pages/curso/edit_curso_page.dart';
import 'package:flutter_application_1/pages/curso/home_cursos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Firebase CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LandingPage(),

      routes: {
        // Después de login, HomePage mostrará el CRUD
        '/home': (_) => const HomePage(),

        // Rutas Cursos
        '/cursos': (_) => const HomeCursoPage(),
        '/add_curso': (_) => const AddCursoPage(),
        '/edit_curso': (_) => const EditCursoPage(),
      },
    );
  }
}
