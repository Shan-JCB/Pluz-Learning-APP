import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/utils/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_application_1/core/firebase_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_1/pages/utils/app_images.dart';

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
              color: const Color.fromARGB(255, 255, 171, 68),
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
      // Sin AppBar
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
              : Column(
                children: [
                  // Contenedor para el mapa
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    color: AppColors.pluzCelesteMedio,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: ubicacionUsuario!,
                        zoom: 8, // zoom más cercano
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
                          infoWindow: const InfoWindow(title: 'Academia Pluz'),
                        ),
                      },
                      polylines: polylines,
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                    ),
                  ),

                  // Imagen y descripción debajo del mapa
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                AppImages.ubicacion,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.pluzAzulIntenso,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Nuestra ubicación principal se encuentra en 051, Av. San Martín 158, Huanta 05121. '
                              'Ven a visitarnos para conocer nuestras instalaciones y tomar '
                              'uno de nuestros cursos presenciales. ¡Te esperamos!',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      // Botón flotante para recargar
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.naranjaIntenso,
        onPressed: verificarYcargarDatos,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
