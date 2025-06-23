import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // <-- Import para InputFormatters
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

class RegisterStep2Page extends StatefulWidget {
  final String nombre;
  final String correo;
  final String password;

  const RegisterStep2Page({
    super.key,
    required this.nombre,
    required this.correo,
    required this.password,
  });

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  final edadController = TextEditingController();
  final telefonoController = TextEditingController();
  String departamento = 'Lima';
  String genero = 'Otro';
  bool mostrarFormulario = false;
  bool isLoading = false;

  final List<String> departamentos = [
    'Arequipa',
    'Ayacucho',
    'Cusco',
    'Huancayo',
    'Huaraz',
    'Lima',
    'Nazca',
    'Paracas',
    'Puno',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => mostrarFormulario = true);
    });
  }

  Future<void> registrarUsuario({bool omitido = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.correo,
            password: widget.password,
          );

      final uid = credential.user!.uid;
      final docRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

      final data = {
        'nombres': widget.nombre,
        'correo': widget.correo,
        'edad': omitido ? null : edadController.text.trim(),
        'telefono': omitido ? null : telefonoController.text.trim(),
        'departamento': omitido ? null : departamento,
        'genero': omitido ? null : genero,
        'fotoPerfilBase64': null,
      };

      await docRef.set(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            omitido
                ? 'Registro completado. Puedes agregar datos más tarde desde "Cuenta".'
                : 'Registro completado correctamente.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      });
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error: ${e.message}';
      if (e.code == 'email-already-in-use') {
        mensaje = 'El correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Correo inválido.';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es demasiado débil.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              AppImages.urlFondo,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(color: AppColors.pluzAzulOscuro),
            ),
          ),
          Positioned.fill(
            child: Container(color: AppColors.pluzAzulCapatransparente),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(AppImages.logoblanco, height: 100),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: mostrarFormulario ? 1 : 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.pluzAzulIntenso.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 40,
                              color: AppColors.naranjaIntenso,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '¡Casi listo!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: edadController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Edad',
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: genero,
                              dropdownColor: AppColors.pluzAzulIntenso,
                              iconEnabledColor: Colors.white,
                              decoration: const InputDecoration(
                                labelText: 'Género',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.wc,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items:
                                  ['Masculino', 'Femenino', 'Otro']
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) =>
                                      setState(() => genero = val ?? 'Otro'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: departamento,
                              dropdownColor: AppColors.pluzAzulIntenso,
                              iconEnabledColor: Colors.white,
                              decoration: const InputDecoration(
                                labelText: 'Ciudad',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.map,
                                  color: AppColors.naranjaIntenso,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items:
                                  departamentos
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(
                                    () => departamento = val ?? departamento,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: telefonoController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Teléfono +51',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: AppColors.naranjaIntenso,
                                ),
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.naranjaIntenso,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.naranjaIntenso,
                                )
                                : Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => registrarUsuario(),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Finalizar registro'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.naranjaIntenso,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed:
                                          () => registrarUsuario(omitido: true),
                                      icon: const Icon(Icons.skip_next),
                                      label: const Text('Omitir'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            AppColors.naranjaIntenso,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          side: const BorderSide(
                                            color: AppColors.naranjaIntenso,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
