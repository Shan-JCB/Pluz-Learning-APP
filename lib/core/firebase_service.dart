import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// CRUD - Proveedores
Future<List> getProveedores() async {
  List data = [];
  QuerySnapshot snapshot = await db.collection('proveedores').get();

  for (var doc in snapshot.docs) {
    final d = doc.data() as Map<String, dynamic>;
    data.add({
      "uid": doc.id,
      "razon_social": d["razon_social"],
      "ruc": d["ruc"],
      "direccion": d["direccion"],
      "contacto": d["contacto"],
      "email": d["email"],
      "categoria": d["categoria"],
    });
  }
  return data;
}

Future<void> addProveedor(Map<String, dynamic> datos) async {
  await db.collection("proveedores").add(datos);
}

Future<void> updateProveedor(String uid, Map<String, dynamic> datos) async {
  await db.collection("proveedores").doc(uid).set(datos);
}

Future<void> deleteProveedor(String uid) async {
  await db.collection("proveedores").doc(uid).delete();
}

// CRUD - Cursos
Future<List> getCursos() async {
  List data = [];
  QuerySnapshot snapshot = await db.collection('cursos').get();

  for (var doc in snapshot.docs) {
    final d = doc.data() as Map<String, dynamic>;
    data.add({
      "id": doc.id,
      "nombre": d["nombre"],
      "descripcion": d["descripcion"],
      "precio": d["precio"],
      "imagen": d["imagen"],
      "modulos": d["modulos"] ?? [],
    });
  }
  return data;
}

Future<void> addCurso(Map<String, dynamic> datos) async {
  await db.collection("cursos").add(datos);
}

Future<void> updateCurso(String id, Map<String, dynamic> datos) async {
  await db.collection("cursos").doc(id).set(datos);
}

Future<void> deleteCurso(String id) async {
  await db.collection("cursos").doc(id).delete();
}
