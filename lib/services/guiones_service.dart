import 'dart:convert';
import 'indexed_db_service.dart';

class GuionesService {
  static const String _claveGuiones = 'guiones_ventas';

  // ✅ Obtener guiones
  static Future<List<Map<String, dynamic>>> getGuiones() async {
    try {
      final json = await IndexedDBService.get(_claveGuiones);
      if (json != null) {
        final datos = jsonDecode(json) as List;
        return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error al obtener guiones: $e');
    }
    return [];
  }

  // ✅ Guardar guiones
  static Future<void> guardarGuiones(List<Map<String, dynamic>> guiones) async {
    await IndexedDBService.put(_claveGuiones, jsonEncode(guiones));
  }

  // ✅ Agregar guion
  static Future<void> agregarGuion(Map<String, dynamic> guion) async {
    final guiones = await getGuiones();
    guion['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    guion['fechaCreacion'] = DateTime.now().toIso8601String();
    if (!guion.containsKey('categoria')) guion['categoria'] = 'General';
    if (!guion.containsKey('activo')) guion['activo'] = true;
    guiones.add(guion);
    await guardarGuiones(guiones);
  }

  // ✅ Actualizar guion
  static Future<void> actualizarGuion(String id, Map<String, dynamic> datos) async {
    final guiones = await getGuiones();
    final index = guiones.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      guiones[index].addAll(datos);
      await guardarGuiones(guiones);
    }
  }

  // ✅ Eliminar guion
  static Future<void> eliminarGuion(String id) async {
    final guiones = (await getGuiones()).where((g) => g['id'] != id).toList();
    await guardarGuiones(guiones);
  }

  // ✅ Obtener guiones por categoría
  static Future<List<Map<String, dynamic>>> getGuionesPorCategoria(String categoria) async {
    final guiones = await getGuiones();
    return guiones.where((g) => g['categoria'] == categoria).toList();
  }

  // ✅ Obtener categorías
  static Future<List<String>> getCategorias() async {
    final guiones = await getGuiones();
    return guiones.map((g) => (g['categoria'] ?? 'General').toString()).toSet().toList();
  }
}