import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'dart:typed_data';

class ClientesSupabaseService {
  static final SupabaseClient _client = SupabaseService.client;
  static const String _bucketFotos = 'clientes-fotos';

  // ✅ Obtener todos los clientes
  static Future<List<Map<String, dynamic>>> getClientes() async {
    final response = await _client
        .from('clientes')
        .select()
        .order('fecha_creacion', ascending: false);

    return response.map((c) => Map<String, dynamic>.from(c)).toList();
  }

  // ✅ Agregar nuevo cliente (CORREGIDO)
  static Future<Map<String, dynamic>> agregarCliente(Map<String, dynamic> datos) async {
    final response = await _client
        .from('clientes')
        .insert({
          'nombre': datos['nombre'],
          'tipo': datos['tipo'] ?? 'Comprador',
          'tipo_negocio': datos['tipo_negocio'] ?? datos['tipoNegocio'] ?? 'Inmobiliario',
          'ubicacion': datos['ubicacion'] ?? '',
          'pais': datos['pais'] ?? 'México',
          'estado': datos['estado'] ?? '',
          'telefono': datos['telefono'] ?? '',
          'presupuesto': datos['presupuesto'] ?? 0,
          'catalogo': datos['catalogo'] ?? '',
          'estado_negociacion': datos['estado_negociacion'] ?? datos['estadoNegociacion'] ?? '',
          'notas': datos['notas'] ?? '',
          'asesor': datos['asesor'] ?? datos['asesor_id'] ?? datos['asesor_nombre'] ?? '',
          'etapa': datos['etapa'] ?? 'Nuevo',
          'activo': datos['activo'] ?? true,
          'foto_url': datos['foto_url'] ?? '',
        })
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ✅ Actualizar cliente (CORREGIDO)
  static Future<Map<String, dynamic>> actualizarCliente(String id, Map<String, dynamic> datos) async {
    final updateData = <String, dynamic>{
      'nombre': datos['nombre'],
      'tipo': datos['tipo'] ?? 'Comprador',
      'tipo_negocio': datos['tipo_negocio'] ?? datos['tipoNegocio'] ?? 'Inmobiliario',
      'ubicacion': datos['ubicacion'] ?? '',
      'pais': datos['pais'] ?? 'México',
      'estado': datos['estado'] ?? '',
      'telefono': datos['telefono'] ?? '',
      'presupuesto': datos['presupuesto'] ?? 0,
      'catalogo': datos['catalogo'] ?? '',
      'estado_negociacion': datos['estado_negociacion'] ?? datos['estadoNegociacion'] ?? '',
      'notas': datos['notas'] ?? '',
      'asesor': datos['asesor'] ?? datos['asesor_id'] ?? datos['asesor_nombre'] ?? '',
      'etapa': datos['etapa'] ?? 'Nuevo',
      'activo': datos['activo'] ?? true,
    };

    if (datos.containsKey('foto_url')) {
      updateData['foto_url'] = datos['foto_url'];
    }

    final response = await _client
        .from('clientes')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  // ✅ Eliminar cliente
  static Future<void> eliminarCliente(String id) async {
    final cliente = await _client
        .from('clientes')
        .select('foto_url')
        .eq('id', id)
        .single();

    final fotoUrl = cliente['foto_url'] as String?;
    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      await _eliminarFoto(fotoUrl);
    }

    await _client
        .from('clientes')
        .delete()
        .eq('id', id);
  }

  // ✅ Subir foto de cliente
  static Future<String> subirFoto(Uint8List imagenBytes, String clienteId, String extension) async {
    final fileName = '$clienteId$extension';
    
    await _client.storage
        .from(_bucketFotos)
        .uploadBinary(fileName, imagenBytes, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _client.storage
        .from(_bucketFotos)
        .getPublicUrl(fileName);

    return publicUrl;
  }

  // ✅ Eliminar foto
  static Future<void> _eliminarFoto(String fotoUrl) async {
    try {
      final fileName = fotoUrl.split('/').last;
      await _client.storage.from(_bucketFotos).remove([fileName]);
    } catch (e) {
      print('Error al eliminar foto: $e');
    }
  }

  // ✅ Actualizar foto (elimina la anterior y sube la nueva)
  static Future<String> actualizarFoto(String clienteId, Uint8List nuevaFoto, String extension, String? fotoAnterior) async {
    if (fotoAnterior != null && fotoAnterior.isNotEmpty) {
      await _eliminarFoto(fotoAnterior);
    }
    return await subirFoto(nuevaFoto, clienteId, extension);
  }

  // ✅ Obtener estadísticas
  static Future<Map<String, dynamic>> getEstadisticas() async {
    final response = await _client
        .from('clientes')
        .select('tipo, activo');

    final total = response.length;
    final activos = response.where((c) => c['activo'] == true).length;
    final compradores = response.where((c) => c['tipo'] == 'Comprador').length;
    final inversionistas = response.where((c) => c['tipo'] == 'Inversionista').length;

    return {
      'total': total,
      'activos': activos,
      'compradores': compradores,
      'inversionistas': inversionistas,
    };
  }

  // ✅ Obtener tipos únicos
  static Future<List<String>> getTipos() async {
    final response = await _client
        .from('clientes')
        .select('tipo');

    final tipos = response
        .where((c) => c['tipo'] != null && (c['tipo'] as String).isNotEmpty)
        .map((c) => c['tipo'] as String)
        .toSet()
        .toList();
        
    return tipos;
  }

  // ✅ Importar múltiples clientes (CORREGIDO)
  static Future<void> guardarClientes(List<Map<String, dynamic>> clientes) async {
    for (var cliente in clientes) {
      await _client.from('clientes').insert({
        'nombre': cliente['nombre'],
        'tipo': cliente['tipo'] ?? 'Comprador',
        'tipo_negocio': cliente['tipo_negocio'] ?? cliente['tipoNegocio'] ?? 'Inmobiliario',
        'ubicacion': cliente['ubicacion'] ?? '',
        'pais': cliente['pais'] ?? 'México',
        'estado': cliente['estado'] ?? '',
        'telefono': cliente['telefono'] ?? '',
        'presupuesto': cliente['presupuesto'] ?? 0,
        'catalogo': cliente['catalogo'] ?? '',
        'estado_negociacion': cliente['estado_negociacion'] ?? cliente['estadoNegociacion'] ?? '',
        'notas': cliente['notas'] ?? '',
        'asesor': cliente['asesor'] ?? cliente['asesor_id'] ?? cliente['asesor_nombre'] ?? '',
        'etapa': cliente['etapa'] ?? 'Nuevo',
        'activo': cliente['activo'] ?? true,
        'foto_url': cliente['foto_url'] ?? '',
      });
    }
  }
}