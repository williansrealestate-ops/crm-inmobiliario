import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'dart:typed_data';

class InmueblesSupabaseService {
  static final SupabaseClient _client = SupabaseService.client;
  static const String _bucketFotos = 'inmuebles-fotos';

  // ✅ Obtener todos los inmuebles
  static Future<List<Map<String, dynamic>>> getInmuebles() async {
    final response = await _client
        .from('inmuebles')
        .select()
        .order('fecha_registro', ascending: false);

    return response.map((i) => Map<String, dynamic>.from(i)).toList();
  }

  // ✅ Agregar nuevo inmueble (CORREGIDO)
  static Future<Map<String, dynamic>> agregarInmueble(Map<String, dynamic> datos) async {
    // Generar ID único si no viene
    final id = datos['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Mapear asesor_id a asesor si existe
    final asesorValor = datos['asesor'] ?? datos['asesor_id'] ?? '';

    final response = await _client
        .from('inmuebles')
        .insert({
          'id': id,
          'titulo': datos['titulo'] ?? 'Sin título',
          'tipo': datos['tipo'] ?? 'Casa',
          'ubicacion': datos['ubicacion'] ?? '',
          'precio': _toDouble(datos['precio']) ?? 0,
          'recamaras': datos['recamaras'] ?? 0,
          'banos': datos['banos'] ?? 0,
          'area': _toDouble(datos['area']) ?? 0,
          'descripcion': datos['descripcion'] ?? '',
          'video_url': datos['video_url'] ?? datos['videoUrl'] ?? '',
          'asesor': asesorValor,
          'activo': datos['activo'] ?? true,
          'latitud': _toDouble(datos['latitud']),
          'longitud': _toDouble(datos['longitud']),
          'fotos': datos['fotos'] ?? [],
        })
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ✅ Actualizar inmueble (CORREGIDO)
  static Future<Map<String, dynamic>> actualizarInmueble(String id, Map<String, dynamic> datos) async {
    final updateData = <String, dynamic>{
      'titulo': datos['titulo'],
      'tipo': datos['tipo'],
      'ubicacion': datos['ubicacion'],
      'precio': _toDouble(datos['precio']),
      'recamaras': datos['recamaras'],
      'banos': datos['banos'],
      'area': _toDouble(datos['area']),
      'descripcion': datos['descripcion'],
      'video_url': datos['video_url'] ?? datos['videoUrl'],
      'activo': datos['activo'],
    };

    // Mapear asesor_id a asesor si existe
    if (datos.containsKey('asesor_id')) {
      updateData['asesor'] = datos['asesor_id'];
    } else if (datos.containsKey('asesor')) {
      updateData['asesor'] = datos['asesor'];
    }

    if (datos.containsKey('latitud')) updateData['latitud'] = _toDouble(datos['latitud']);
    if (datos.containsKey('longitud')) updateData['longitud'] = _toDouble(datos['longitud']);
    if (datos.containsKey('fotos')) updateData['fotos'] = datos['fotos'];

    final response = await _client
        .from('inmuebles')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ✅ Eliminar inmueble
  static Future<void> eliminarInmueble(String id) async {
    await _client
        .from('inmuebles')
        .delete()
        .eq('id', id);
  }

  // ✅ Subir foto de inmueble
  static Future<String> subirFoto(Uint8List imagenBytes, String inmuebleId, String extension) async {
    final fileName = '$inmuebleId${DateTime.now().millisecondsSinceEpoch}$extension';
    
    await _client.storage
        .from(_bucketFotos)
        .uploadBinary(fileName, imagenBytes, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _client.storage
        .from(_bucketFotos)
        .getPublicUrl(fileName);

    return publicUrl;
  }

  // ✅ Obtener tipos únicos
  static Future<List<String>> getTipos() async {
    final response = await _client
        .from('inmuebles')
        .select('tipo');

    final tipos = response
        .where((i) => i['tipo'] != null && (i['tipo'] as String).isNotEmpty)
        .map((i) => i['tipo'] as String)
        .toSet()
        .toList();
        
    return tipos.isEmpty 
        ? ['Casa', 'Departamento', 'Terreno', 'Local', 'Oficina', 'Hacienda', 'Gasolinera', 'Mina'] 
        : tipos;
  }

  // ✅ Importar múltiples inmuebles (CORREGIDO)
  static Future<void> guardarInmuebles(List<Map<String, dynamic>> inmuebles) async {
    final datosLimpios = inmuebles.map((i) {
      final datos = Map<String, dynamic>.from(i);
      // Mapear asesor_id a asesor
      if (datos.containsKey('asesor_id')) {
        datos['asesor'] = datos['asesor_id'];
        datos.remove('asesor_id');
      }
      // Eliminar tipo_negocio si existe, ya que no está en el esquema de inmuebles
      datos.remove('tipo_negocio');
      return datos;
    }).toList();

    await _client.from('inmuebles').upsert(datosLimpios);
  }

  // ✅ Conversión segura para cualquier tipo de dato numérico
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', ''));
    if (value is num) return value.toDouble();
    return null;
  }
}