import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/app_colors.dart';

class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  String _acc = '', _gyro = '', _mag = '', _userAcc = '';
  bool _sensoresActivos = true;
  StreamSubscription? _subAcc, _subGyro, _subMag, _subUserAcc;

  @override
  void initState() {
    super.initState();
    _iniciarSensores();
  }

  void _iniciarSensores() {
    _detenerSensores();

    _subAcc = accelerometerEventStream().listen((e) {
      if (!mounted) return;
      setState(() {
        _acc =
            'X: ${e.x.toStringAsFixed(2)}  Y: ${e.y.toStringAsFixed(2)}  Z: ${e.z.toStringAsFixed(2)}';
      });
    });

    _subGyro = gyroscopeEventStream().listen((e) {
      if (!mounted) return;
      setState(() {
        _gyro =
            'X: ${e.x.toStringAsFixed(2)}  Y: ${e.y.toStringAsFixed(2)}  Z: ${e.z.toStringAsFixed(2)}';
      });
    });

    _subMag = magnetometerEventStream().listen((e) {
      if (!mounted) return;
      setState(() {
        _mag =
            'X: ${e.x.toStringAsFixed(2)}  Y: ${e.y.toStringAsFixed(2)}  Z: ${e.z.toStringAsFixed(2)}';
      });
    });

    _subUserAcc = userAccelerometerEventStream().listen((e) {
      if (!mounted) return;
      setState(() {
        _userAcc =
            'X: ${e.x.toStringAsFixed(2)}  Y: ${e.y.toStringAsFixed(2)}  Z: ${e.z.toStringAsFixed(2)}';
      });
    });
  }

  void _detenerSensores() {
    _subAcc?.cancel();
    _subGyro?.cancel();
    _subMag?.cancel();
    _subUserAcc?.cancel();
  }

  @override
  void dispose() {
    _detenerSensores();
    super.dispose();
  }

  Widget _buildSensorCard(String title, IconData icon, String data) {
    return Card(
      color: AppColors.pluzAzulIntenso,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 36),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(data, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pluzAzulCapaTrans4,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Sensores del Móvil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.pluzAzulIntenso,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _sensoresActivos ? Icons.pause_circle : Icons.play_circle,
              color:
                  Colors
                      .white, // Esto asegura que también el ícono de acción sea blanco
            ),
            tooltip: _sensoresActivos ? 'Pausar sensores' : 'Reanudar sensores',
            onPressed: () {
              setState(() {
                _sensoresActivos = !_sensoresActivos;
                _sensoresActivos ? _iniciarSensores() : _detenerSensores();
              });
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '💪 Actividad Física y Sensores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los sensores del móvil permiten detectar y analizar el movimiento del cuerpo en tiempo real. Esto es clave para promover la actividad física, medir intensidad de ejercicio y mejorar hábitos saludables mediante datos precisos.',
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _buildSensorCard('Acelerómetro', Icons.speed, _acc),
            _buildSensorCard('Giroscopio', Icons.sync, _gyro),
            _buildSensorCard('Magnetómetro', Icons.explore, _mag),
            _buildSensorCard(
              'User Acceleration',
              Icons.directions_run,
              _userAcc,
            ),
          ],
        ),
      ),
    );
  }
}
