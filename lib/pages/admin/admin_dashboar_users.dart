import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('usuarios').get();
    final todos =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'nombres': data['nombres'] ?? 'Sin nombre',
            'correo': data['correo'] ?? '',
            'edad': data['edad'] ?? '',
            'telefono': data['telefono'] ?? '',
            'genero': data['genero'] ?? '',
            'pais': data['pais'] ?? '',
            'fotoPerfilBase64': data['fotoPerfilBase64'],
          };
        }).toList();

    todos.sort(
      (a, b) => a['nombres'].toString().compareTo(b['nombres'].toString()),
    );

    setState(() {
      usuarios = todos;
      usuariosFiltrados = List.from(usuarios);
    });
  }

  void editarUsuario(Map<String, dynamic> usuario) {
    final nombreCtrl = TextEditingController(text: usuario['nombres']);
    final edadCtrl = TextEditingController(text: usuario['edad']);
    final telCtrl = TextEditingController(text: usuario['telefono']);

    final generos = ['Masculino', 'Femenino', 'Otro'];
    final departamentos = [
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

    String genero =
        generos.contains(usuario['genero']) ? usuario['genero'] : 'Otro';
    String pais =
        departamentos.contains(usuario['pais']) ? usuario['pais'] : 'Lima';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar Usuario'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: edadCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Edad'),
                  ),
                  TextField(
                    controller: telCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  DropdownButtonFormField(
                    value: genero,
                    items:
                        generos
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                    onChanged: (val) => genero = val!,
                    decoration: const InputDecoration(labelText: 'Género'),
                  ),
                  DropdownButtonFormField(
                    value: pais,
                    items:
                        departamentos
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                    onChanged: (val) => pais = val!,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final nombre = nombreCtrl.text.trim();
                  final edadTexto = edadCtrl.text.trim();
                  final telefono = telCtrl.text.trim();

                  final edad = int.tryParse(edadTexto);

                  if (nombre.isEmpty || edadTexto.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('El nombre y la edad son obligatorios.'),
                      ),
                    );
                    return;
                  }

                  if (edad == null || edad < 10 || edad > 24) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La edad debe estar entre 10 y 24 años.'),
                      ),
                    );
                    return;
                  }

                  if (edad < 18 && telefono.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Si el usuario es menor de edad, debe registrar el número del tutor o apoderado.',
                        ),
                      ),
                    );
                    return;
                  }

                  if (telefono.isNotEmpty && telefono.length != 9) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El número de teléfono debe tener exactamente 9 dígitos.',
                        ),
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(usuario['id'])
                      .update({
                        'nombres': nombre,
                        'edad': edadTexto,
                        'telefono': telefono,
                        'genero': genero,
                        'pais': pais,
                      });

                  Navigator.pop(context);
                  cargarUsuarios();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario actualizado correctamente.'),
                    ),
                  );
                },

                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void eliminarUsuario(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar usuario'),
            content: const Text(
              '¿Estás seguro de eliminar esta cuenta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
      cargarUsuarios();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar usuario',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (query) {
              setState(() {
                if (query.isEmpty) {
                  usuariosFiltrados = List.from(usuarios);
                } else {
                  usuariosFiltrados =
                      usuarios.where((u) {
                        final nombre = u['nombres'].toString().toLowerCase();
                        final correo = u['correo'].toString().toLowerCase();
                        return nombre.contains(query.toLowerCase()) ||
                            correo.contains(query.toLowerCase());
                      }).toList();
                }
              });
            },
          ),
          const SizedBox(height: 20),
          usuariosFiltrados.isEmpty
              ? const Expanded(child: Center(child: Text('No hay usuarios')))
              : Expanded(
                child: ListView.builder(
                  itemCount: usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final usuario = usuariosFiltrados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child:
                              usuario['fotoPerfilBase64'] != null
                                  ? Image.memory(
                                    base64Decode(usuario['fotoPerfilBase64']),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) =>
                                            const Icon(Icons.person),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                        ),
                        title: Text(
                          usuario['nombres'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(usuario['correo']),
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.pluzAzulIntenso,
                              ),
                              onPressed: () => editarUsuario(usuario),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarUsuario(usuario['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
