import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CalendarioService {
  static final SupabaseClient _client = SupabaseService.client;

  // ✅ Obtener todos los eventos
  static Future<List<Map<String, dynamic>>> getEventos() async {
    try {
      final response = await _client
          .from('eventos')
          .select()
          .eq('activo', true)
          .order('fecha_inicio', ascending: true);

      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('❌ Error al obtener eventos: $e');
      return [];
    }
  }

  // ✅ Obtener eventos de un mes específico
  static Future<List<Map<String, dynamic>>> getEventosDelMes(int year, int month) async {
    try {
      final inicioMes = DateTime(year, month, 1).toIso8601String();
      final finMes = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

      final response = await _client
          .from('eventos')
          .select()
          .eq('activo', true)
          .gte('fecha_inicio', inicioMes)
          .lte('fecha_inicio', finMes)
          .order('fecha_inicio', ascending: true);

      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('❌ Error al obtener eventos del mes: $e');
      return [];
    }
  }

  // ✅ Agregar nuevo evento
  static Future<Map<String, dynamic>> agregarEvento(Map<String, dynamic> datos) async {
    try {
      if (!datos.containsKey('id') || datos['id'] == null) {
        datos['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final response = await _client
          .from('eventos')
          .insert({
            'id': datos['id'],
            'titulo': datos['titulo'],
            'descripcion': datos['descripcion'] ?? '',
            'tipo': datos['tipo'] ?? 'Cita',
            'fecha_inicio': datos['fecha_inicio'],
            'fecha_fin': datos['fecha_fin'],
            'ubicacion': datos['ubicacion'] ?? '',
            'cliente': datos['cliente'] ?? '',
            'asesor': datos['asesor'] ?? '',
            'inmueble': datos['inmueble'] ?? '',
            'estado': datos['estado'] ?? 'Programado',
            'color': datos['color'] ?? '#3B82F6',
            'activo': datos['activo'] ?? true,
            'recordatorio': datos['recordatorio'] ?? true,
            'minutos_recordatorio': datos['minutos_recordatorio'] ?? 30,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Error al agregar evento: $e');
      rethrow;
    }
  }

  // ✅ Actualizar evento
  static Future<Map<String, dynamic>> actualizarEvento(String id, Map<String, dynamic> datos) async {
    try {
      final updateData = <String, dynamic>{
        'titulo': datos['titulo'],
        'descripcion': datos['descripcion'],
        'tipo': datos['tipo'],
        'fecha_inicio': datos['fecha_inicio'],
        'fecha_fin': datos['fecha_fin'],
        'ubicacion': datos['ubicacion'],
        'cliente': datos['cliente'],
        'asesor': datos['asesor'],
        'inmueble': datos['inmueble'],
        'estado': datos['estado'],
        'color': datos['color'],
        'activo': datos['activo'],
        'recordatorio': datos['recordatorio'],
        'minutos_recordatorio': datos['minutos_recordionario'],
      };

      final response = await _client
          .from('eventos')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Error al actualizar evento: $e');
      rethrow;
    }
  }

  // ✅ Eliminar evento (soft delete)
  static Future<void> eliminarEvento(String id) async {
    try {
      await _client
          .from('eventos')
          .update({'activo': false})
          .eq('id', id);
    } catch (e) {
      print('❌ Error al eliminar evento: $e');
      rethrow;
    }
  }

  // ✅ Obtener estadísticas
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await _client.from('eventos').select('tipo, estado, fecha_inicio');
      
      final total = response.length;
      final programados = response.where((e) => e['estado'] == 'Programado').length;
      final completados = response.where((e) => e['estado'] == 'Completado').length;
      final cancelados = response.where((e) => e['estado'] == 'Cancelado').length;

      return {
        'total': total,
        'programados': programados,
        'completados': completados,
        'cancelados': cancelados,
      };
    } catch (e) {
      print(' Error al obtener estadísticas: $e');
      return {'total': 0, 'programados': 0, 'completados': 0, 'cancelados': 0};
    }
  }

  // ✅ Tipos de eventos
  static List<String> getTiposEvento() {
    return ['Cita', 'Reunión', 'Llamada', 'Visita', 'Cierre', 'Seguimiento', 'Otro'];
  }

  // ✅ Estados de eventos
  static List<String> getEstadosEvento() {
    return ['Programado', 'En proceso', 'Completado', 'Cancelado', 'Reprogramado'];
  }

  // ✅ Colores disponibles
  static List<String> getColoresEvento() {
    return ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#06B6D4', '#F97316'];
  }
}