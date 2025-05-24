import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/firebase_service.dart';

class HomeProveedorPage extends StatefulWidget {
  const HomeProveedorPage({super.key});

  @override
  State<HomeProveedorPage> createState() => _HomeProveedorPageState();
}

class _HomeProveedorPageState extends State<HomeProveedorPage> {
  late Future<List> _proveedores;
  List _datosFiltrados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _proveedores = getProveedores();
    _proveedores.then((lista) {
      setState(() {
        _datosFiltrados = lista;
      });
    });
  }

  void _recargarLista() {
    setState(() {
      _proveedores = getProveedores();
      _proveedores.then((lista) {
        _filtrar(lista, _busqueda);
      });
    });
  }

  void _filtrar(List lista, String texto) {
    final filtro = texto.toLowerCase();
    setState(() {
      _datosFiltrados =
          lista.where((item) {
            final razon = item['razon_social'].toLowerCase();
            final ruc = item['ruc'].toLowerCase();
            return razon.contains(filtro) || ruc.contains(filtro);
          }).toList();
    });
  }

  Widget _campoInfo(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icono, size: 20, color: Colors.indigo),
          const SizedBox(width: 6),
          Text(
            "$titulo: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Lista de Proveedores"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _proveedores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar proveedores"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay proveedores registrados"));
          }

          final listaOriginal = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por razón social o RUC',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  onChanged: (texto) {
                    _busqueda = texto;
                    _filtrar(listaOriginal, texto);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _datosFiltrados.length,
                  itemBuilder: (context, index) {
                    final proveedor = _datosFiltrados[index];
                    return Dismissible(
                      key: Key(proveedor["uid"]),
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        final confirm = await showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(
                                  "¿Eliminar a ${proveedor['razon_social']}?",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancelar"),
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text("Eliminar"),
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                        );
                        return confirm;
                      },
                      onDismissed: (_) async {
                        await deleteProveedor(proveedor["uid"]);
                        _recargarLista();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Proveedor eliminado"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            "/edit_proveedor",
                            arguments: proveedor,
                          );
                          if (result == 'actualizado' && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Proveedor actualizado correctamente",
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                          _recargarLista();
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.store,
                                      color: Colors.indigo,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        proveedor["razon_social"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _campoInfo(
                                  Icons.credit_card,
                                  "RUC",
                                  proveedor['ruc'],
                                ),
                                _campoInfo(
                                  Icons.location_on,
                                  "Dirección",
                                  proveedor['direccion'],
                                ),
                                _campoInfo(
                                  Icons.phone,
                                  "Contacto",
                                  proveedor['contacto'],
                                ),
                                _campoInfo(
                                  Icons.email,
                                  "Email",
                                  proveedor['email'],
                                ),
                                _campoInfo(
                                  Icons.category,
                                  "Categoría",
                                  proveedor['categoria'],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "/add_proveedor");
          if (result == 'guardado' && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Proveedor guardado correctamente"),
                backgroundColor: Colors.green,
              ),
            );
            _recargarLista();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
