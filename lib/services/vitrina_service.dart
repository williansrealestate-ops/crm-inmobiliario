import 'dart:convert';
import 'indexed_db_service.dart';
import 'inmuebles_service.dart';

class VitrinaService {
  static const String _claveConfig = 'vitrina_config';

  // ✅ Obtener inmuebles públicos (activos)
  static Future<List<Map<String, dynamic>>> getInmueblesPublicos() async {
    final inmuebles = await InmueblesService.getInmuebles();
    return inmuebles.where((i) => i['activo'] != false).toList();
  }

  // ✅ Obtener configuración de la vitrina
  static Future<Map<String, dynamic>> getConfig() async {
    try {
      final json = await IndexedDBService.get(_claveConfig);
      if (json != null) {
        return Map<String, dynamic>.from(jsonDecode(json) as Map);
      }
    } catch (e) {
      print('Error al obtener config: $e');
    }
    return {
      'titulo': 'Real Estate CRM',
      'descripcion': 'Encuentra la propiedad de tus sueños',
      'telefono': '',
      'whatsapp': '',
      'email': '',
      'logo': '',
    };
  }

  // ✅ Guardar configuración
  static Future<void> guardarConfig(Map<String, dynamic> config) async {
    await IndexedDBService.put(_claveConfig, jsonEncode(config));
  }

  // ✅ Filtrar inmuebles
  static Future<List<Map<String, dynamic>>> filtrarInmuebles({
    String? tipo,
    double? precioMin,
    double? precioMax,
    String? ubicacion,
    int? recamarasMin,
    int? banosMin,
  }) async {
    var inmuebles = await getInmueblesPublicos();

    if (tipo != null && tipo.isNotEmpty && tipo != 'Todos') {
      inmuebles = inmuebles.where((i) => i['tipo'] == tipo).toList();
    }
    if (precioMin != null && precioMin > 0) {
      inmuebles = inmuebles.where((i) => (i['precio'] ?? 0) >= precioMin).toList();
    }
    if (precioMax != null && precioMax > 0) {
      inmuebles = inmuebles.where((i) => (i['precio'] ?? 0) <= precioMax).toList();
    }
    if (ubicacion != null && ubicacion.isNotEmpty) {
      inmuebles = inmuebles.where((i) => (i['ubicacion'] ?? '').toString().toLowerCase().contains(ubicacion.toLowerCase())).toList();
    }
    if (recamarasMin != null && recamarasMin > 0) {
      inmuebles = inmuebles.where((i) => (i['recamaras'] ?? 0) >= recamarasMin).toList();
    }
    if (banosMin != null && banosMin > 0) {
      inmuebles = inmuebles.where((i) => (i['banos'] ?? 0) >= banosMin).toList();
    }

    return inmuebles;
  }

  // ✅ Obtener tipos disponibles
  static Future<List<String>> getTiposDisponibles() async {
    final inmuebles = await getInmueblesPublicos();
    return inmuebles.map((i) => (i['tipo'] ?? 'Casa').toString()).toSet().toList();
  }

  // ✅ Obtener ubicaciones disponibles
  static Future<List<String>> getUbicacionesDisponibles() async {
    final inmuebles = await getInmueblesPublicos();
    return inmuebles.map((i) => (i['ubicacion'] ?? 'Sin ubicación').toString()).toSet().toList();
  }
}