import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? imagenBase64;
  File? imagenSeleccionada;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    obtenerFotoPerfil();
  }

  Future<void> obtenerFotoPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

    final data = doc.data();
    if (data != null && data['fotoPerfilBase64'] != null) {
      setState(() {
        imagenBase64 = data['fotoPerfilBase64'];
      });
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 50);
    if (picked == null) return;

    setState(() {
      imagenSeleccionada = File(picked.path);
    });
  }

  Future<void> subirImagen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || imagenSeleccionada == null) return;

    final bytes = await imagenSeleccionada!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.update({
        'fotoPerfilBase64': base64Image,
        'correo': user.email ?? '',
      });
    } else {
      await docRef.set({
        'fotoPerfilBase64': base64Image,
        'correo': user.email ?? '',
      });
    }

    if (!mounted) return;
    setState(() {
      imagenBase64 = base64Image;
      imagenSeleccionada = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen de perfil actualizada')),
    );
  }

  Future<void> _changeEmail(BuildContext context) async {
    final controller = TextEditingController();
    final newEmail = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar correo'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Nuevo correo'),
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

    if (newEmail != null && newEmail.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser?.updateEmail(newEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo actualizado exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final controller = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
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

    if (newPassword != null && newPassword.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar cuenta'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cuenta eliminada')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    ImageProvider<Object>? imageWidget;

    if (imagenSeleccionada != null) {
      imageWidget = FileImage(imagenSeleccionada!);
    } else if (imagenBase64 != null) {
      try {
        final bytes = base64Decode(imagenBase64!);
        imageWidget = MemoryImage(bytes);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: imageWidget,
              child:
                  imageWidget == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => seleccionarImagen(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Desde galería"),
                ),
                ElevatedButton.icon(
                  onPressed: () => seleccionarImagen(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Desde cámara"),
                ),
                if (imagenSeleccionada != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: subirImagen,
                    icon: const Icon(Icons.check),
                    label: const Text("Guardar imagen"),
                  ),
              ],
            ),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Editar correo electrónico'),
            subtitle: Text(email),
            onTap: () => _changeEmail(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Cambiar contraseña'),
            onTap: () => _changePassword(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Eliminar cuenta'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
