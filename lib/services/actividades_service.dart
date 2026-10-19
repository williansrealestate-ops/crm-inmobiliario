import 'dart:convert';
import 'indexed_db_service.dart';

class ActividadesService {
  static const String _claveActividades = 'actividades';

  // ✅ Obtener todas las actividades
  static Future<List<Map<String, dynamic>>> getActividades() async {
    try {
      final json = await IndexedDBService.get(_claveActividades);
      if (json != null) {
        final datos = jsonDecode(json) as List;
        return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error al obtener actividades: $e');
    }
    return [];
  }

  // ✅ Guardar actividades
  static Future<void> guardarActividades(List<Map<String, dynamic>> actividades) async {
    await IndexedDBService.put(_claveActividades, jsonEncode(actividades));
  }

  // ✅ Agregar nueva actividad
  static Future<void> agregarActividad(Map<String, dynamic> actividad) async {
    final actividades = await getActividades();
    actividad['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    actividad['fechaCreacion'] = DateTime.now().toIso8601String();
    if (!actividad.containsKey('completada')) actividad['completada'] = false;
    actividades.add(actividad);
    await guardarActividades(actividades);
  }

  // ✅ Actualizar actividad
  static Future<void> actualizarActividad(String id, Map<String, dynamic> datos) async {
    final actividades = await getActividades();
    final index = actividades.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      actividades[index].addAll(datos);
      await guardarActividades(actividades);
    }
  }

  // ✅ Eliminar actividad
  static Future<void> eliminarActividad(String id) async {
    final actividades = (await getActividades()).where((a) => a['id'] != id).toList();
    await guardarActividades(actividades);
  }

  // ✅ Marcar como completada
  static Future<void> toggleCompletada(String id) async {
    final actividades = await getActividades();
    final index = actividades.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      actividades[index]['completada'] = !(actividades[index]['completada'] ?? false);
      await guardarActividades(actividades);
    }
  }

  // ✅ Obtener estadísticas
  static Future<Map<String, dynamic>> getEstadisticas() async {
    final actividades = await getActividades();
    final total = actividades.length;
    final completadas = actividades.where((a) => a['completada'] == true).length;
    final pendientes = total - completadas;
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    final actividadesHoy = actividades.where((a) => (a['fecha'] ?? '').toString().startsWith(hoy)).length;

    return {
      'total': total,
      'completadas': completadas,
      'pendientes': pendientes,
      'hoy': actividadesHoy,
    };
  }

  // ✅ Filtrar por tipo
  static Future<List<Map<String, dynamic>>> getActividadesPorTipo(String tipo) async {
    final actividades = await getActividades();
    return actividades.where((a) => a['tipo'] == tipo).toList();
  }

  // ✅ Filtrar por fecha
  static Future<List<Map<String, dynamic>>> getActividadesPorFecha(String fecha) async {
    final actividades = await getActividades();
    return actividades.where((a) => (a['fecha'] ?? '').toString().startsWith(fecha)).toList();
  }
}