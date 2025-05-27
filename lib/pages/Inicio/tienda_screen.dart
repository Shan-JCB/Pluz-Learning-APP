import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/core/firebase_service.dart';
import 'package:geolocator/geolocator.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  LatLng? ubicacionUsuario;
  LatLng? ubicacionTienda;
  GoogleMapController? mapController;
  Set<Polyline> polylines = {};
  bool cargando = true;

  final String apiKey = "AIzaSyBIZrptkE0IGakPhzMzMpq4PaW_gw_D1vk";

  @override
  void initState() {
    super.initState();
    verificarYcargarDatos();
  }

  Future<void> verificarYcargarDatos() async {
    setState(() {
      cargando = true;
    });

    bool gpsActivo = await Geolocator.isLocationServiceEnabled();
    if (!gpsActivo) {
      mostrarMensaje("GPS desactivado. Actívalo para usar el mapa");
      setState(() => cargando = false);
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      permiso = await Geolocator.requestPermission();
      if (permiso != LocationPermission.always &&
          permiso != LocationPermission.whileInUse) {
        mostrarMensaje("Permiso de ubicación denegado");
        setState(() => cargando = false);
        return;
      }
    }

    await cargarDatos();
  }

  Future<void> cargarDatos() async {
    final usuario = await obtenerUbicacionUsuarioActual();
    final tienda = await obtenerUbicacionTiendaDesdeFirestore();

    if (usuario != null && tienda != null) {
      final ruta = await obtenerRutaEntrePuntos(usuario, tienda, apiKey);
      if (mounted) {
        setState(() {
          ubicacionUsuario = usuario;
          ubicacionTienda = tienda;
          polylines = {
            Polyline(
              polylineId: const PolylineId("ruta"),
              color: Colors.blueAccent,
              width: 5,
              points: ruta,
            ),
          };
          cargando = false;
        });
      }
    } else {
      mostrarMensaje("No se pudo obtener la ubicación");
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "Reintentar",
            textColor: Colors.white,
            onPressed: () => verificarYcargarDatos(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("¿Dónde nos ubicamos?"),
        backgroundColor: const Color.fromARGB(255, 198, 238, 244),
      ),
      body:
          cargando
              ? const Center(child: CircularProgressIndicator())
              : (ubicacionUsuario == null || ubicacionTienda == null)
              ? const Center(
                child: Text(
                  "No se pudo obtener ubicaciones.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: ubicacionUsuario!,
                      zoom: 9,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('usuario'),
                        position: ubicacionUsuario!,
                        infoWindow: const InfoWindow(title: 'Tu ubicación'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                      ),
                      Marker(
                        markerId: const MarkerId('tienda'),
                        position: ubicacionTienda!,
                        infoWindow: const InfoWindow(title: 'FarmaVida S.A.C.'),
                      ),
                    },
                    polylines: polylines,
                    onMapCreated: (controller) => mapController = controller,
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      backgroundColor: Colors.orangeAccent,
                      onPressed: verificarYcargarDatos,
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              ),
    );
  }
}
