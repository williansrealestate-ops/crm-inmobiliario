import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleMapsService {
  // ⚠️ REEMPLAZA CON TU API KEY DE GOOGLE MAPS
  static const String apiKey = 'TU_API_KEY_AQUI';
  
  /// Convierte una dirección en coordenadas (lat, lng)
  static Future<Map<String, double>?> geocodificarDireccion({
    required String direccion,
    required String municipio,
    required String estado,
    required String pais,
  }) async {
    if (apiKey == 'TU_API_KEY_AQUI') {
      // Si no hay API Key, usar coordenadas por defecto de México
      return _getCoordenadasPorDefecto(estado);
    }

    final direccionCompleta = '$direccion, $municipio, $estado, $pais';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(direccionCompleta)}&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        }
      }
    } catch (e) {
      print('Error en geocodificación: $e');
    }

    return _getCoordenadasPorDefecto(estado);
  }

  /// Coordenadas por defecto para estados de México (fallback)
  static Map<String, double> _getCoordenadasPorDefecto(String estado) {
    final coordenadas = {
      'Campeche': {'lat': 19.8305, 'lng': -90.5349},
      'Yucatán': {'lat': 20.9674, 'lng': -89.5926},
      'Querétaro': {'lat': 20.5888, 'lng': -100.3899},
      'México': {'lat': 19.4326, 'lng': -99.1332},
      'Jalisco': {'lat': 20.6597, 'lng': -103.3496},
      'Nuevo León': {'lat': 25.6866, 'lng': -100.3161},
      'Veracruz': {'lat': 19.1738, 'lng': -96.1342},
      'Puebla': {'lat': 19.0414, 'lng': -98.2063},
      'Ciudad de México': {'lat': 19.4326, 'lng': -99.1332},
    };

    return coordenadas[estado] ?? {'lat': 23.6345, 'lng': -102.5528}; // Centro de México
  }

  /// Genera URL para abrir Google Maps con navegación
  static String generarUrlNavegacion({
    required double lat,
    required double lng,
    required String nombre,
  }) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
  }

  /// Genera URL para compartir ubicación
  static String generarUrlCompartir({
    required double lat,
    required double lng,
    required String nombre,
  }) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }
}