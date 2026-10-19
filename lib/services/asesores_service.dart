import 'package:supabase_flutter/supabase_flutter.dart';

class AsesoresService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==========================================
  // OBTENER LISTA DE ASESORES
  // ==========================================
  static Future<List<Map<String, dynamic>>> getAsesores() async {
    try {
      final response = await _client
          .from('asesores')
          .select('*')
          .order('nombre', ascending: true);
      
      // Mapear 'comision_porcentaje' a 'comisionPorcentaje' para la UI
      return response.map((asesor) {
        asesor['comisionPorcentaje'] = asesor['comision_porcentaje'] ?? 3.0;
        return asesor;
      }).toList();
    } catch (e) {
      print('❌ Error al obtener asesores: $e');
      return [];
    }
  }

  // ==========================================
  // OBTENER GRUPOS ÚNICOS
  // ==========================================
  static Future<List<String>> getGrupos() async {
    try {
      final response = await _client
          .from('asesores')
          .select('grupo')
          .not('grupo', 'is', null);
      
      final grupos = response.map((a) => a['grupo'] as String).toSet().toList();
      grupos.sort();
      return grupos;
    } catch (e) {
      print('❌ Error al obtener grupos: $e');
      return [];
    }
  }

  // ==========================================
  // OBTENER ESTADÍSTICAS (VERSIÓN COMPATIBLE)
  // ==========================================
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      // Obtener todos los asesores y contar en memoria
      final todosAsesores = await _client.from('asesores').select('*');
      final total = todosAsesores.length;

      // Filtrar activos en memoria
      final activos = todosAsesores.where((a) => a['activo'] == true).length;

      // Sumar ventas
      int totalVentas = 0;
      for (var row in todosAsesores) {
        totalVentas += (row['ventas'] as int? ?? 0);
      }

      return {
        'total': total,
        'activos': activos,
        'totalVentas': totalVentas,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {'total': 0, 'activos': 0, 'totalVentas': 0};
    }
  }

  // ==========================================
  // AGREGAR NUEVO ASESOR
  // ==========================================
  static Future<void> agregarAsesor(Map<String, dynamic> datos) async {
    try {
      if (!datos.containsKey('id') || datos['id'] == null) {
        datos['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      if (datos.containsKey('comisionPorcentaje')) {
        datos['comision_porcentaje'] = datos['comisionPorcentaje'];
        datos.remove('comisionPorcentaje');
      }

      await _client.from('asesores').insert(datos);
    } catch (e) {
      print('❌ Error al agregar asesor: $e');
      rethrow;
    }
  }

  // ==========================================
  // ACTUALIZAR ASESOR EXISTENTE
  // ==========================================
  static Future<void> actualizarAsesor(String id, Map<String, dynamic> datos) async {
    try {
      if (datos.containsKey('comisionPorcentaje')) {
        datos['comision_porcentaje'] = datos['comisionPorcentaje'];
        datos.remove('comisionPorcentaje');
      }

      await _client.from('asesores').update(datos).eq('id', id);
    } catch (e) {
      print('❌ Error al actualizar asesor: $e');
      rethrow;
    }
  }

  // ==========================================
  // ELIMINAR ASESOR
  // ==========================================
  static Future<void> eliminarAsesor(String id) async {
    try {
      await _client.from('asesores').delete().eq('id', id);
    } catch (e) {
      print('❌ Error al eliminar asesor: $e');
      rethrow;
    }
  }

  // ==========================================
  // IMPORTAR MÚLTIPLES ASESORES
  // ==========================================
  static Future<void> guardarAsesores(List<Map<String, dynamic>> asesores) async {
    try {
      final datosLimpios = asesores.map((a) {
        if (a.containsKey('comisionPorcentaje')) {
          a['comision_porcentaje'] = a['comisionPorcentaje'];
          a.remove('comisionPorcentaje');
        }
        return a;
      }).toList();

      await _client.from('asesores').upsert(datosLimpios);
    } catch (e) {
      print('❌ Error al importar asesores: $e');
      rethrow;
    }
  }

  // ==========================================
  // GESTIÓN DE GRUPOS
  // ==========================================
  static Future<void> agregarGrupo(String nombreGrupo) async {
    print('Grupo registrado: $nombreGrupo');
  }

  static Future<void> eliminarGrupo(String nombreGrupo) async {
    try {
      await _client.from('asesores').update({'grupo': 'Sin grupo'}).eq('grupo', nombreGrupo);
    } catch (e) {
      print('❌ Error al eliminar grupo: $e');
    }
  }
}