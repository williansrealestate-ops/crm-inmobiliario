import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class MapaService {
  static final SupabaseClient _client = SupabaseService.client;

  // ✅ Obtener todos los inmuebles con coordenadas
  static Future<List<Map<String, dynamic>>> getInmueblesConCoordenadas() async {
    try {
      final response = await _client
          .from('inmuebles')
          .select()
          .eq('activo', true)
          .not('latitud', 'is', null)
          .not('longitud', 'is', null);

      return response.map((i) => Map<String, dynamic>.from(i)).toList();
    } catch (e) {
      print('❌ Error al obtener inmuebles con coordenadas: $e');
      return [];
    }
  }

  // ✅ Obtener estadísticas de inmuebles por tipo
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await _client.from('inmuebles').select('tipo, precio');
      
      final total = response.length;
      final valorTotal = response.fold<double>(0, (sum, i) {
        final precio = i['precio'];
        if (precio is num) return sum + precio.toDouble();
        if (precio is String) return sum + (double.tryParse(precio) ?? 0);
        return sum;
      });
      
      final tipos = <String, int>{};
      for (var i in response) {
        final tipo = i['tipo'] ?? 'Sin tipo';
        tipos[tipo] = (tipos[tipo] ?? 0) + 1;
      }

      return {
        'total': total,
        'valorTotal': valorTotal,
        'tipos': tipos,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {'total': 0, 'valorTotal': 0.0, 'tipos': {}};
    }
  }
}