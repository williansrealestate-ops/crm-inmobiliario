import 'package:supabase_flutter/supabase_flutter.dart';

class ClientesService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ==========================================
  // OBTENER LISTA DE CLIENTES
  // ==========================================
  static Future<List<Map<String, dynamic>>> getClientes() async {
    try {
      final response = await _client
          .from('clientes')
          .select('*')
          .order('nombre', ascending: true);
      
      return response;
    } catch (e) {
      print('❌ Error al obtener clientes: $e');
      return [];
    }
  }

  // ==========================================
  // OBTENER ESTADÍSTICAS
  // ==========================================
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final todosClientes = await _client.from('clientes').select('*');
      final total = todosClientes.length;
      final activos = todosClientes.where((c) => c['activo'] == true).length;
      final compradores = todosClientes.where((c) => c['tipo'] == 'Comprador').length;
      final inversionistas = todosClientes.where((c) => c['tipo'] == 'Inversionista').length;

      return {
        'total': total,
        'activos': activos,
        'compradores': compradores,
        'inversionistas': inversionistas,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {'total': 0, 'activos': 0, 'compradores': 0, 'inversionistas': 0};
    }
  }

  // ==========================================
  // AGREGAR NUEVO CLIENTE
  // ==========================================
  static Future<void> agregarCliente(Map<String, dynamic> datos) async {
    try {
      // Generar ID único si no viene
      if (!datos.containsKey('id') || datos['id'] == null) {
        datos['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      // ✅ CORRECCIÓN: Mapear 'asesor' correctamente (no 'asesor_id')
      if (datos.containsKey('asesor_id')) {
        datos['asesor'] = datos['asesor_id'];
        datos.remove('asesor_id');
      }

      // Asegurar que 'asesor' sea un string (nombre del asesor), no un objeto
      if (datos['asesor'] is Map) {
        datos['asesor'] = datos['asesor']['nombre'] ?? '';
      }

      await _client.from('clientes').insert(datos);
    } catch (e) {
      print('❌ Error al agregar cliente: $e');
      rethrow;
    }
  }

  // ==========================================
  // ACTUALIZAR CLIENTE EXISTENTE
  // ==========================================
  static Future<void> actualizarCliente(String id, Map<String, dynamic> datos) async {
    try {
      // ✅ CORRECCIÓN: Mapear 'asesor' correctamente
      if (datos.containsKey('asesor_id')) {
        datos['asesor'] = datos['asesor_id'];
        datos.remove('asesor_id');
      }

      // Asegurar que 'asesor' sea un string
      if (datos['asesor'] is Map) {
        datos['asesor'] = datos['asesor']['nombre'] ?? '';
      }

      await _client.from('clientes').update(datos).eq('id', id);
    } catch (e) {
      print('❌ Error al actualizar cliente: $e');
      rethrow;
    }
  }

  // ==========================================
  // ELIMINAR CLIENTE
  // ==========================================
  static Future<void> eliminarCliente(String id) async {
    try {
      await _client.from('clientes').delete().eq('id', id);
    } catch (e) {
      print('❌ Error al eliminar cliente: $e');
      rethrow;
    }
  }

  // ==========================================
  // IMPORTAR MÚLTIPLES CLIENTES
  // ==========================================
  static Future<void> guardarClientes(List<Map<String, dynamic>> clientes) async {
    try {
      final datosLimpios = clientes.map((c) {
        if (c.containsKey('asesor_id')) {
          c['asesor'] = c['asesor_id'];
          c.remove('asesor_id');
        }
        if (c['asesor'] is Map) {
          c['asesor'] = c['asesor']['nombre'] ?? '';
        }
        return c;
      }).toList();

      await _client.from('clientes').upsert(datosLimpios);
    } catch (e) {
      print('❌ Error al importar clientes: $e');
      rethrow;
    }
  }
}