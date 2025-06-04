import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/auth_service.dart';
import 'package:flutter_application_1/pages/landing_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _authService = AuthService();
  final picker = ImagePicker();

  File? imagenSeleccionada;
  String? imagenBase64;
  String? edad, genero, pais, telefono;
  final user = FirebaseAuth.instance.currentUser;
  final Map<String, TextEditingController> controllers = {
    'nombres': TextEditingController(), // NUEVO
    'edad': TextEditingController(),
    'pais': TextEditingController(),
    'telefono': TextEditingController(),
  };
  String selectedGenero = 'Otro';

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final data = await _authService.getUserData();
    if (mounted && data != null) {
      setState(() {
        imagenBase64 = data['fotoPerfilBase64'];
        edad = data['edad'];
        genero = data['genero'] ?? 'Otro';
        pais = data['pais'];
        telefono = data['telefono'];
        controllers['nombres']?.text = data['nombres'] ?? ''; //
        controllers['edad']?.text = edad ?? '';
        controllers['pais']?.text = pais ?? '';
        controllers['telefono']?.text = telefono ?? '';
        selectedGenero = genero ?? 'Otro';
      });
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 50);
    if (picked != null) {
      setState(() => imagenSeleccionada = File(picked.path));
    }
  }

  Future<void> guardarImagen() async {
    if (imagenSeleccionada != null) {
      await _authService.uploadProfileImage(imagenSeleccionada!);
      // Refrescar inmediatamente la imagen desde Firestore
      final data = await _authService.getUserData();
      if (mounted && data != null) {
        setState(() {
          imagenBase64 = data['fotoPerfilBase64'];
          imagenSeleccionada = null;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen de perfil actualizada')),
      );
    }
  }

  Future<void> eliminarImagen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({'fotoPerfilBase64': null});

    setState(() {
      imagenBase64 = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Foto de perfil eliminada')));
  }

  Future<bool> _reauthenticateUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final controller = TextEditingController();
    final nuevaPWD = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirma tu contraseña'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Contraseña actual'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (nuevaPWD == null || nuevaPWD.isEmpty) return false;

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: nuevaPWD,
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } on FirebaseAuthException catch (e) {
      // Si falla la credencial, informar al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reautenticación fallida: ${e.message}')),
      );
      return false;
    }
  }

  Future<void> cambiarContrasena() async {
    final controller = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cambiar contraseña'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Nueva contraseña'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );

    if (newPassword != null && newPassword.length >= 6) {
      await _authService.updatePassword(newPassword);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
    } else if (newPassword != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? '';
    ImageProvider? imageWidget;

    if (imagenSeleccionada != null) {
      imageWidget = FileImage(imagenSeleccionada!);
    } else if (imagenBase64 != null) {
      try {
        imageWidget = MemoryImage(base64Decode(imagenBase64!));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.pluzAzulCapaTrans4,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Encabezado con avatar
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.pluzAzulIntenso,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: imageWidget,
                      backgroundColor: AppColors.pluzCelesteClaro2,
                      child:
                          imageWidget == null
                              ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    if (imagenBase64 != null)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.naranjaIntenso,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: eliminarImagen,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          iconSize: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botones para seleccionar imagen
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pluzAzulIntenso,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => seleccionarImagen(ImageSource.gallery),
                  icon: const Icon(Icons.image, size: 20),
                  label: const Text("Galería"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pluzAzulIntenso,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => seleccionarImagen(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text("Cámara"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botón para guardar imagen
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  imagenSeleccionada != null
                      ? Center(
                        child: ElevatedButton.icon(
                          key: const ValueKey('guardar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranjaMedio,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: guardarImagen,
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text("Guardar imagen"),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            const Divider(height: 40, thickness: 1, color: Colors.grey),

            // Tarjeta de información de cuenta
            Card(
              color: AppColors.pluzBlancaCapaTrans1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de la Cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pluzAzulIntenso,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(
                        Icons.email,
                        color: AppColors.pluzAzulOscuro,
                      ),
                      title: const Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pluzAzulOscuro,
                        ),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.lock,
                        color: AppColors.pluzAzulOscuro,
                      ),
                      title: const Text(
                        'Contraseña',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pluzAzulOscuro,
                        ),
                      ),
                      subtitle: const Text(
                        '••••••••',
                        style: TextStyle(color: Colors.black54),
                      ),
                      trailing: TextButton(
                        onPressed: cambiarContrasena,
                        child: const Text(
                          'Cambiar',
                          style: TextStyle(color: AppColors.naranjaIntenso),
                        ),
                      ),
                    ),
                    TextField(
                      controller: controllers['nombres'],
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.pluzAzulIntenso,
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                        ),
                        labelStyle: TextStyle(color: AppColors.pluzAzulOscuro),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.pluzAzulOscuro,
                      ),
                      onChanged:
                          (val) => _authService.updateUserField('nombres', val),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de perfil adicional
            Card(
              color: AppColors.pluzBlancaCapaTrans1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles Personales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pluzAzulIntenso,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controllers['edad'],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.pluzAzulOscuro),
                      decoration: InputDecoration(
                        labelText: 'Edad',
                        labelStyle: const TextStyle(
                          color: AppColors.pluzAzulOscuro,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged:
                          (val) => _authService.updateUserField('edad', val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGenero,
                      decoration: InputDecoration(
                        labelText: 'Género',
                        labelStyle: const TextStyle(
                          color: AppColors.pluzAzulOscuro,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items:
                          ['Masculino', 'Femenino', 'Otro']
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(
                                    g,
                                    style: const TextStyle(
                                      color: AppColors.pluzAzulOscuro,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedGenero = val);
                          _authService.updateUserField('genero', val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controllers['pais'],
                      style: const TextStyle(color: AppColors.pluzAzulOscuro),
                      decoration: InputDecoration(
                        labelText: 'País',
                        labelStyle: const TextStyle(
                          color: AppColors.pluzAzulOscuro,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged:
                          (val) => _authService.updateUserField('pais', val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controllers['telefono'],
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.pluzAzulOscuro),
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        labelStyle: const TextStyle(
                          color: AppColors.pluzAzulOscuro,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.pluzAzulIntenso,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged:
                          (val) =>
                              _authService.updateUserField('telefono', val),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Eliminar cuenta',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        // 1) Confirmación inicial
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Eliminar cuenta'),
                                content: const Text(
                                  '¿Estás seguro de que deseas eliminar tu cuenta?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm != true) return;

                        try {
                          // 2) Intentar eliminar directamente
                          await _authService.deleteAccount();
                          await FirebaseAuth.instance.signOut();

                          // 3) Navegar a LandingPage
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LandingPage(),
                            ),
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'requires-recent-login') {
                            // 4) Si requiere reautenticación, la pedimos:
                            final reautenticado =
                                await _reauthenticateUsuario();
                            if (reautenticado) {
                              // 5) Reintentar eliminar cuenta
                              try {
                                await _authService.deleteAccount();
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LandingPage(),
                                  ),
                                  (route) => false,
                                );
                              } on FirebaseAuthException catch (e2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al eliminar: ${e2.message}',
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            // Otro error de FirebaseAuth
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.message}')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
