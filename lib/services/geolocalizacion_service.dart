import 'dart:html' as html;
import 'dart:math';

class GeolocalizacionService {
  static const double latitudMexico = 23.6345;
  static const double longitudMexico = -102.5528;

  static Map<String, double> generarCoordenadasAleatorias({double latBase = latitudMexico, double lngBase = longitudMexico, double radioKm = 50}) {
    final random = Random();
    final latOffset = (random.nextDouble() - 0.5) * (radioKm / 111);
    final lngOffset = (random.nextDouble() - 0.5) * (radioKm / (111 * cos(latBase * pi / 180)));
    return {'lat': latBase + latOffset, 'lng': lngBase + lngOffset};
  }

  static double calcularDistancia({required double lat1, required double lng1, required double lat2, required double lng2}) {
    const radioTierra = 6371;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radioTierra * c;
  }

  static int calcularTiempoEstimado(double distanciaKm) {
    return ((distanciaKm / 40) * 60).round();
  }

  static List<Map<String, dynamic>> optimizarRuta({required double latOrigen, required double lngOrigen, required List<Map<String, dynamic>> destinos}) {
    if (destinos.isEmpty) return [];
    List<Map<String, dynamic>> rutaOptima = [];
    List<Map<String, dynamic>> pendientes = List.from(destinos);
    double latActual = latOrigen, lngActual = lngOrigen;

    while (pendientes.isNotEmpty) {
      int indiceMasCercano = 0;
      double distanciaMasCorta = double.infinity;
      for (int i = 0; i < pendientes.length; i++) {
        final destino = pendientes[i];
        final distancia = calcularDistancia(lat1: latActual, lng1: lngActual, lat2: (destino['lat'] as double?) ?? latitudMexico, lng2: (destino['lng'] as double?) ?? longitudMexico);
        if (distancia < distanciaMasCorta) { distanciaMasCorta = distancia; indiceMasCercano = i; }
      }
      final siguiente = pendientes.removeAt(indiceMasCercano);
      siguiente['distanciaDesdeAnterior'] = distanciaMasCorta;
      siguiente['tiempoEstimado'] = calcularTiempoEstimado(distanciaMasCorta);
      rutaOptima.add(siguiente);
      latActual = siguiente['lat'] ?? latitudMexico;
      lngActual = siguiente['lng'] ?? longitudMexico;
    }
    return rutaOptima;
  }

  static String generarUrlRutaCompleta({required double latOrigen, required double lngOrigen, required List<Map<String, dynamic>> destinos}) {
    if (destinos.isEmpty) return 'https://www.google.com/maps/@$latOrigen,$lngOrigen,15z';
    String url = 'https://www.google.com/maps/dir/$latOrigen,$lngOrigen/';
    for (var destino in destinos) url += '${destino['lat'] ?? latitudMexico},${destino['lng'] ?? longitudMexico}/';
    return url;
  }

  // ✅ CORREGIDO: Null-safety y casting a double
  static Future<Map<String, double>> obtenerUbicacionActual() async {
    try {
      final geolocation = html.window.navigator.geolocation;
      if (geolocation == null) return {'lat': latitudMexico, 'lng': longitudMexico};
      final position = await geolocation.getCurrentPosition();
      final coords = position.coords;
      return {
        'lat': (coords?.latitude ?? latitudMexico).toDouble(),
        'lng': (coords?.longitude ?? longitudMexico).toDouble(),
      };
    } catch (e) {
      return {'lat': latitudMexico, 'lng': longitudMexico};
    }
  }
}