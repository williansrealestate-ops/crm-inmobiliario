import 'dart:html' as html; // ✅ IMPORT AGREGADO
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../services/geolocalizacion_service.dart';
import '../../services/local_storage_service.dart';

class GeolocalizacionScreen extends StatefulWidget {
  const GeolocalizacionScreen({super.key});

  @override
  State<GeolocalizacionScreen> createState() => _GeolocalizacionScreenState();
}

class _GeolocalizacionScreenState extends State<GeolocalizacionScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _marcadores = {};
  List<Map<String, dynamic>> _visitasOptimizadas = [];
  Map<String, double> _ubicacionActual = {'lat': GeolocalizacionService.latitudMexico, 'lng': GeolocalizacionService.longitudMexico};
  bool _cargando = true;

  @override
  void initState() { super.initState(); _inicializarMapa(); }

  Future<void> _inicializarMapa() async {
    setState(() => _cargando = true);
    _ubicacionActual = await GeolocalizacionService.obtenerUbicacionActual();
    final visitasDelDia = _generarVisitasSimuladas();
    _visitasOptimizadas = GeolocalizacionService.optimizarRuta(latOrigen: _ubicacionActual['lat']!, lngOrigen: _ubicacionActual['lng']!, destinos: visitasDelDia);
    _crearMarcadores();
    setState(() => _cargando = false);
    if (_visitasOptimizadas.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(_visitasOptimizadas.first['lat'] ?? _ubicacionActual['lat']!, _visitasOptimizadas.first['lng'] ?? _ubicacionActual['lng']!)));
    }
  }

  List<Map<String, dynamic>> _generarVisitasSimuladas() {
    final actividades = LocalStorageService.getActividades().where((a) => a['tipo'] == 'Visita' && a['completada'] != true).toList();
    if (actividades.isEmpty) {
      return List.generate(3, (index) {
        final coords = GeolocalizacionService.generarCoordenadasAleatorias(latBase: _ubicacionActual['lat']!, lngBase: _ubicacionActual['lng']!, radioKm: 30);
        return {'id': 'sim_$index', 'titulo': 'Visita Propiedad ${index + 1}', 'cliente': 'Cliente ${index + 1}', 'direccion': 'Calle Ejemplo ${index + 1}', 'lat': coords['lat'], 'lng': coords['lng'], 'hora': '${10 + index}:00'};
      });
    }
    return actividades.map((a) {
      final coords = GeolocalizacionService.generarCoordenadasAleatorias(latBase: _ubicacionActual['lat']!, lngBase: _ubicacionActual['lng']!, radioKm: 30);
      return {'id': a['id'], 'titulo': a['titulo'] ?? 'Visita', 'cliente': a['cliente'] ?? 'Cliente', 'direccion': a['direccion'] ?? 'Sin dirección', 'lat': coords['lat'], 'lng': coords['lng'], 'hora': a['hora'] ?? '09:00'};
    }).toList();
  }

  void _crearMarcadores() {
    _marcadores.clear();
    _marcadores.add(Marker(markerId: const MarkerId('ubicacion_actual'), position: LatLng(_ubicacionActual['lat']!, _ubicacionActual['lng']!), infoWindow: const InfoWindow(title: '📍 Tu ubicación'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
    for (int i = 0; i < _visitasOptimizadas.length; i++) {
      final visita = _visitasOptimizadas[i];
      _marcadores.add(Marker(markerId: MarkerId('visita_$i'), position: LatLng(visita['lat']!, visita['lng']!), infoWindow: InfoWindow(title: '${i + 1}. ${visita['titulo']}', snippet: '${visita['cliente']} • ${visita['hora']}'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(title: const Row(children: [Icon(Icons.route, color: Colors.white), SizedBox(width: 8), Text('Rutas y Mapa')]), backgroundColor: AppTheme.primary, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _inicializarMapa)]),
      body: _cargando ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(flex: 2, child: GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(_ubicacionActual['lat']!, _ubicacionActual['lng']!), zoom: 12), markers: _marcadores, onMapCreated: (controller) => _mapController = controller, myLocationEnabled: true, myLocationButtonEnabled: true)),
          Expanded(flex: 1, child: Container(decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 12, offset: const Offset(0, -4))]), child: Column(
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context)))), child: Row(
                children: [
                  const Icon(Icons.route, color: Color(0xFF3B82F6), size: 24), const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ruta Optimizada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))), Text('${_visitasOptimizadas.length} visitas', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)))])),
                  ElevatedButton.icon(
                    onPressed: () { 
                      final url = GeolocalizacionService.generarUrlRutaCompleta(latOrigen: _ubicacionActual['lat']!, lngOrigen: _ubicacionActual['lng']!, destinos: _visitasOptimizadas); 
                      html.window.open(url, '_blank'); // ✅ AHORA FUNCIONA GRACIAS AL IMPORT
                    }, 
                    icon: const Icon(Icons.navigation, size: 16), 
                    label: const Text('Iniciar', style: TextStyle(fontSize: 12)), 
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white)
                  ),
                ],
              )),
              Expanded(child: _visitasOptimizadas.isEmpty ? const Center(child: Text('No hay visitas programadas')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _visitasOptimizadas.length, itemBuilder: (context, index) {
                final visita = _visitasOptimizadas[index];
                return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.getSurfaceElevatedColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))), child: Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w800, fontSize: 16)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(visita['titulo'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))), Text('${visita['cliente']} • ${visita['hora']}', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context)))])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${(visita['distanciaDesdeAnterior'] ?? 0.0).toStringAsFixed(1)} km', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))), Text('${visita['tiempoEstimado'] ?? 0} min', style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context)))]),
                  ],
                ));
              })),
            ],
          ))),
        ],
      ),
    );
  }
}