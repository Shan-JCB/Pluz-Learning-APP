import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Cambiar correo

  // Cambiar correo sin verificación
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
        // Aquí no usamos verifyBeforeUpdateEmail, solo actualizamos el correo
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

  // Cambiar contraseña
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

  // Eliminar cuenta
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

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
