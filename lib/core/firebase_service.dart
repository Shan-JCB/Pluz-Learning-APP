import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

FirebaseFirestore db = FirebaseFirestore.instance;

// CRUD - Cursos
Future<List> getCursos() async {
  List data = [];
  QuerySnapshot snapshot = await db.collection('cursos').get();

  for (var doc in snapshot.docs) {
    final raw = doc.data();
    if (raw is Map<String, dynamic>) {
      data.add({
        "id": doc.id,
        "nombre": raw["nombre"] ?? '',
        "descripcion": raw["descripcion"] ?? '',
        "precio": raw["precio"] ?? 0.0,
        "imagen": raw["imagen"] ?? '',
        "modulos": raw["modulos"] ?? [],
      });
    }
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

// Ubicacion

Future<LatLng?> obtenerUbicacionTiendaDesdeFirestore() async {
  final snapshot = await db.collection('tienda').doc('principal').get();
  final data = snapshot.data();

  if (data != null && data['tienda'] != null) {
    final geo = data['tienda'] as GeoPoint;
    return LatLng(geo.latitude, geo.longitude);
  }
  return null;
}

Future<LatLng?> obtenerUbicacionUsuarioActual() async {
  bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
  if (!servicioHabilitado) return null;

  LocationPermission permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
    if (permiso == LocationPermission.denied) return null;
  }
  if (permiso == LocationPermission.deniedForever) return null;

  Position posicion = await Geolocator.getCurrentPosition();
  return LatLng(posicion.latitude, posicion.longitude);
}

Future<List<LatLng>> obtenerRutaEntrePuntos(
  LatLng origen,
  LatLng destino,
  String apiKey,
) async {
  final url = Uri.parse(
    "https://maps.googleapis.com/maps/api/directions/json"
    "?origin=${origen.latitude},${origen.longitude}"
    "&destination=${destino.latitude},${destino.longitude}"
    "&key=$apiKey&mode=driving",
  );

  final respuesta = await http.get(url);
  if (respuesta.statusCode == 200) {
    final data = json.decode(respuesta.body);
    final puntos = data["routes"][0]["overview_polyline"]["points"];
    return decodePolyline(puntos);
  }
  return [];
}

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polyline = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    polyline.add(LatLng(lat / 1e5, lng / 1e5));
  }

  return polyline;
}
