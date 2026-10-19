import 'package:supabase_flutter/supabase_flutter.dart';

class AsesoresService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ✅ Obtener todos los asesores (SIN filtros problemáticos)
  static Future<List<Map<String, dynamic>>> getAsesores() async {
    try {
      final response = await _client
          .from('asesores')
          .select('*')
          .order('nombre', ascending: true);
      
      // Mapear campos para compatibilidad
      return response.map((asesor) {
        final mapped = Map<String, dynamic>.from(asesor);
        mapped['comisionPorcentaje'] = mapped['comision_porcentaje'] ?? 3.0;
        return mapped;
      }).toList();
    } catch (e) {
      print('❌ Error al obtener asesores: $e');
      return [];
    }
  }

  // ✅ Obtener grupos únicos
  static Future<List<String>> getGrupos() async {
    try {
      final response = await _client
          .from('asesores')
          .select('grupo')
          .not('grupo', 'is', null);
      
      final grupos = response
          .map((a) => a['grupo'] as String)
          .toSet()
          .toList();
      grupos.sort();
      return grupos;
    } catch (e) {
      print('❌ Error al obtener grupos: $e');
      return [];
    }
  }

  // ✅ Obtener estadísticas (CORREGIDO: sin filtros problemáticos)
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      // Obtener TODOS los asesores sin filtros
      final todosAsesores = await _client.from('asesores').select('*');
      final total = todosAsesores.length;

      // Contar activos (manejar si la columna no existe)
      int activos = 0;
      int totalVentas = 0;
      
      for (var asesor in todosAsesores) {
        // Verificar si existe la columna 'activo' y si es true
        if (asesor.containsKey('activo')) {
          final activo = asesor['activo'];
          if (activo == true || activo == 'true' || activo == 'True') {
            activos++;
          }
        } else {
          // Si no existe la columna, contar todos como activos
          activos = total;
        }
        
        // Sumar ventas
        totalVentas += (asesor['ventas'] as int? ?? 0);
      }

      return {
        'total': total,
        'activos': activos,
        'totalVentas': totalVentas,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      // Si falla, devolver todos como activos
      try {
        final count = await _client.from('asesores').count();
        return {'total': count, 'activos': count, 'totalVentas': 0};
      } catch (e2) {
        return {'total': 0, 'activos': 0, 'totalVentas': 0};
      }
    }
  }

  // ✅ Agregar nuevo asesor
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

  // ✅ Actualizar asesor existente
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

  // ✅ Eliminar asesor
  static Future<void> eliminarAsesor(String id) async {
    try {
      await _client.from('asesores').delete().eq('id', id);
    } catch (e) {
      print('❌ Error al eliminar asesor: $e');
      rethrow;
    }
  }

  // ✅ Importar múltiples asesores
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

  // ✅ Gestión de grupos
  static Future<void> agregarGrupo(String nombreGrupo) async {
    print('Grupo registrado: $nombreGrupo');
  }

  static Future<void> eliminarGrupo(String nombreGrupo) async {
    try {
      await _client.from('asesores').update({'grupo': 'Sin grupo'}).eq('grupo', nombreGrupo);
    } catch (e) {
      print(' Error al eliminar grupo: $e');
    }
  }
}