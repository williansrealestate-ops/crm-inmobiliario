import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class InmueblesService {
  static final SupabaseClient _client = SupabaseService.client;

  // ✅ Obtener todos los inmuebles
  static Future<List<Map<String, dynamic>>> getInmuebles() async {
    try {
      final response = await _client
          .from('inmuebles')
          .select()
          .order('fecha_registro', ascending: false);

      return response.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('❌ Error al obtener inmuebles: $e');
      return [];
    }
  }

  // ✅ Agregar nuevo inmueble
  static Future<Map<String, dynamic>> agregarInmueble(Map<String, dynamic> datos) async {
    try {
      if (!datos.containsKey('id') || datos['id'] == null) {
        datos['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final response = await _client
          .from('inmuebles')
          .insert({
            'id': datos['id'],
            'titulo': datos['titulo'] ?? 'Sin título',
            'tipo': datos['tipo'] ?? 'Casa',
            'ubicacion': datos['ubicacion'] ?? '',
            'precio': _toDouble(datos['precio']),
            'recamaras': datos['recamaras'] ?? 0,
            'banos': datos['banos'] ?? 0,
            'area': _toDouble(datos['area']),
            'descripcion': datos['descripcion'] ?? '',
            'asesor': datos['asesor'] ?? datos['asesor_id'] ?? '',
            'activo': datos['activo'] ?? true,
            'latitud': _toDouble(datos['latitud']),
            'longitud': _toDouble(datos['longitud']),
            'fotos': datos['fotos'] ?? [],
            'video_url': datos['video_url'] ?? datos['videoUrl'] ?? '',
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Error al agregar inmueble: $e');
      rethrow;
    }
  }

  // ✅ Actualizar inmueble existente
  static Future<Map<String, dynamic>> actualizarInmueble(String id, Map<String, dynamic> datos) async {
    try {
      final updateData = <String, dynamic>{
        'titulo': datos['titulo'],
        'tipo': datos['tipo'],
        'ubicacion': datos['ubicacion'],
        'precio': _toDouble(datos['precio']),
        'recamaras': datos['recamaras'],
        'banos': datos['banos'],
        'area': _toDouble(datos['area']),
        'descripcion': datos['descripcion'],
        'activo': datos['activo'] ?? true,
      };

      if (datos.containsKey('asesor_id')) {
        updateData['asesor'] = datos['asesor_id'];
      } else if (datos.containsKey('asesor')) {
        updateData['asesor'] = datos['asesor'];
      }

      if (datos.containsKey('latitud')) updateData['latitud'] = _toDouble(datos['latitud']);
      if (datos.containsKey('longitud')) updateData['longitud'] = _toDouble(datos['longitud']);
      if (datos.containsKey('fotos')) updateData['fotos'] = datos['fotos'];
      if (datos.containsKey('video_url')) updateData['video_url'] = datos['video_url'];
      if (datos.containsKey('videoUrl')) updateData['video_url'] = datos['videoUrl'];

      final response = await _client
          .from('inmuebles')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Error al actualizar inmueble: $e');
      rethrow;
    }
  }

  // ✅ Eliminar inmueble
  static Future<void> eliminarInmueble(String id) async {
    try {
      await _client.from('inmuebles').delete().eq('id', id);
    } catch (e) {
      print('❌ Error al eliminar inmueble: $e');
      rethrow;
    }
  }

  // ✅ Obtener estadísticas (CORREGIDO: _toDouble ahora devuelve double seguro)
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await _client.from('inmuebles').select('precio, tipo, activo');
      
      final total = response.length;
      final valorTotal = response.fold<double>(0.0, (sum, i) => sum + _toDouble(i['precio']));
      final tipos = response.map((i) => i['tipo'].toString()).toSet().length;
      final activos = response.where((i) => i['activo'] == true).length;

      return {
        'total': total,
        'valorTotal': valorTotal,
        'tipos': tipos,
        'activos': activos,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {'total': 0, 'valorTotal': 0.0, 'tipos': 0, 'activos': 0};
    }
  }

  // ✅ Obtener tipos únicos
  static Future<List<String>> getTipos() async {
    try {
      final response = await _client.from('inmuebles').select('tipo');
      
      final tipos = response
          .where((i) => i['tipo'] != null && (i['tipo'] as String).isNotEmpty)
          .map((i) => i['tipo'] as String)
          .toSet()
          .toList();
          
      if (tipos.isEmpty) {
        return ['Casa', 'Departamento', 'Terreno', 'Local', 'Oficina', 'Hacienda', 'Gasolinera', 'Mina'];
      }
      
      return tipos;
    } catch (e) {
      print('❌ Error al obtener tipos: $e');
      return ['Casa', 'Departamento', 'Terreno', 'Local', 'Oficina', 'Hacienda', 'Gasolinera', 'Mina'];
    }
  }

  // ✅ Importar múltiples inmuebles
  static Future<void> guardarInmuebles(List<Map<String, dynamic>> inmuebles) async {
    try {
      final datosLimpios = inmuebles.map((i) {
        final datos = Map<String, dynamic>.from(i);
        if (datos.containsKey('asesor_id')) {
          datos['asesor'] = datos['asesor_id'];
          datos.remove('asesor_id');
        }
        datos.remove('tipo_negocio'); // No existe en la tabla inmuebles
        return datos;
      }).toList();

      await _client.from('inmuebles').upsert(datosLimpios);
    } catch (e) {
      print('❌ Error al importar inmuebles: $e');
      rethrow;
    }
  }

  // ✅ Conversión segura: SIEMPRE devuelve double (nunca null)
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}