import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Cliente de Supabase (ya inicializado en main.dart)
  static final SupabaseClient _client = Supabase.instance.client;

  // ==========================================
  // MÉTODOS PARA EL DASHBOARD (CONTEOS)
  // ==========================================
  
  static Future<Map<String, int>> obtenerConteosDashboard() async {
    try {
      // Contar registros en cada tabla
      final asesoresCount = await _client.from('asesores').count();
      final clientesCount = await _client.from('clientes').count();
      final inmueblesCount = await _client.from('inmuebles').count();

      return {
        'asesores': asesoresCount,
        'clientes': clientesCount,
        'inmuebles': inmueblesCount,
      };
    } catch (e) {
      print('Error al obtener conteos: $e');
      return {'asesores': 0, 'clientes': 0, 'inmuebles': 0};
    }
  }

  // ==========================================
  // MÉTODOS PARA OBTENER LISTAS COMPLETAS
  // ==========================================

  static Future<List<Map<String, dynamic>>> obtenerAsesores() async {
    final response = await _client.from('asesores').select('*').order('nombre');
    return response;
  }

  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final response = await _client.from('clientes').select('*').order('nombre');
    return response;
  }

  static Future<List<Map<String, dynamic>>> obtenerInmuebles() async {
    final response = await _client.from('inmuebles').select('*').order('titulo');
    return response;
  }

  // ==========================================
  // MÉTODOS PARA INSERTAR NUEVOS DATOS (FORMULARIOS)
  // ==========================================

  static Future<void> insertarAsesor(Map<String, dynamic> datos) async {
    await _client.from('asesores').insert(datos);
  }

  static Future<void> insertarCliente(Map<String, dynamic> datos) async {
    await _client.from('clientes').insert(datos);
  }

  static Future<void> insertarInmueble(Map<String, dynamic> datos) async {
    await _client.from('inmuebles').insert(datos);
  }
}