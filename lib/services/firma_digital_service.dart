import 'dart:convert';
import 'dart:html' as html;

class FirmaDigitalService {
  static const String _keyDocumentos = 'firma_documentos';
  static const String _keyPlantillas = 'firma_plantillas';

  // ✅ Tipos de documentos
  static const List<Map<String, dynamic>> tiposDocumento = [
    {'id': 'contrato_compraventa', 'nombre': 'Contrato de Compraventa', 'icono': ''},
    {'id': 'contrato_exclusividad', 'nombre': 'Contrato de Exclusividad', 'icono': ''},
    {'id': 'carta_oferta', 'nombre': 'Carta de Oferta', 'icono': '💼'},
    {'id': 'contrato_arrendamiento', 'nombre': 'Contrato de Arrendamiento', 'icono': '🏠'},
    {'id': 'mandato', 'nombre': 'Mandato de Venta', 'icono': ''},
    {'id': 'otro', 'nombre': 'Otro documento', 'icono': '📃'},
  ];

  // ✅ Estados de documento
  static const List<String> estados = ['borrador', 'pendiente_firma', 'firmado', 'cancelado'];

  // ✅ Obtener documentos
  static List<Map<String, dynamic>> getDocumentos() {
    try {
      final json = html.window.localStorage[_keyDocumentos];
      if (json != null) {
        return (jsonDecode(json) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  // ✅ Guardar documentos
  static void guardarDocumentos(List<Map<String, dynamic>> documentos) {
    try {
      html.window.localStorage[_keyDocumentos] = jsonEncode(documentos);
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ Crear nuevo documento
  static Map<String, dynamic> crearDocumento(Map<String, dynamic> datos) {
    final documentos = getDocumentos();
    final documento = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'fechaCreacion': DateTime.now().toIso8601String(),
      'fechaFirma': null,
      'estado': 'borrador',
      'firmaBase64': null,
      'nombreFirmante': null,
      ...datos,
    };
    documentos.add(documento);
    guardarDocumentos(documentos);
    return documento;
  }

  // ✅ Actualizar documento
  static void actualizarDocumento(String id, Map<String, dynamic> cambios) {
    final documentos = getDocumentos();
    final index = documentos.indexWhere((d) => d['id'] == id);
    if (index != -1) {
      documentos[index].addAll(cambios);
      guardarDocumentos(documentos);
    }
  }

  // ✅ Firmar documento
  static void firmarDocumento(String id, String firmaBase64, String nombreFirmante) {
    actualizarDocumento(id, {
      'estado': 'firmado',
      'firmaBase64': firmaBase64,
      'nombreFirmante': nombreFirmante,
      'fechaFirma': DateTime.now().toIso8601String(),
    });
  }

  // ✅ Eliminar documento
  static void eliminarDocumento(String id) {
    final documentos = getDocumentos().where((d) => d['id'] != id).toList();
    guardarDocumentos(documentos);
  }

  // ✅ Obtener documentos por estado
  static List<Map<String, dynamic>> getDocumentosPorEstado(String estado) {
    return getDocumentos().where((d) => d['estado'] == estado).toList();
  }

  // ✅ Estadísticas
  static Map<String, dynamic> getEstadisticas() {
    final documentos = getDocumentos();
    return {
      'total': documentos.length,
      'borradores': documentos.where((d) => d['estado'] == 'borrador').length,
      'pendientes': documentos.where((d) => d['estado'] == 'pendiente_firma').length,
      'firmados': documentos.where((d) => d['estado'] == 'firmado').length,
      'cancelados': documentos.where((d) => d['estado'] == 'cancelado').length,
    };
  }

  // ✅ Generar contenido del documento
  static String generarContenidoDocumento(Map<String, dynamic> doc) {
    final tipo = tiposDocumento.firstWhere(
      (t) => t['id'] == doc['tipoDocumento'],
      orElse: () => {'nombre': 'Documento', 'icono': '📄'},
    );
    final fecha = doc['fechaCreacion'] != null
        ? DateTime.parse(doc['fechaCreacion'])
        : DateTime.now();
    final fechaStr = '${fecha.day}/${fecha.month}/${fecha.year}';

    String contenido = '';

    switch (doc['tipoDocumento']) {
      case 'contrato_compraventa':
        contenido = '''
CONTRATO DE COMPRAVENTA

En la ciudad de ${doc['ciudad'] ?? '___________'}, a $fechaStr.

COMPARECEN:

VENDEDOR: ${doc['vendedor'] ?? '___________'}
COMPRADOR: ${doc['comprador'] ?? '___________'}

OBJETO DEL CONTRATO:

El VENDEDOR transfiere al COMPRADOR el inmueble ubicado en:
${doc['direccion'] ?? '___________'}

PRECIO DE VENTA: \$${doc['precio'] ?? '___________'}

FORMA DE PAGO:
${doc['formaPago'] ?? '___________'}

ENTREGA: El inmueble se entregará en un plazo de ${doc['plazoEntrega'] ?? '30'} días hábiles después de la firma del presente contrato.

OBSERVACIONES:
${doc['observaciones'] ?? 'Sin observaciones'}

En fe de lo cual, firman las partes.''';
        break;

      case 'carta_oferta':
        contenido = '''
CARTA DE OFERTA

Fecha: $fechaStr

A quien corresponda:

Por medio de la presente, ${doc['comprador'] ?? '___________'} manifiesta su interés en adquirir el inmueble ubicado en:

${doc['direccion'] ?? '___________'}

OFERTA ECONÓMICA:

Precio ofrecido: \$${doc['precio'] ?? '___________'}
Forma de pago: ${doc['formaPago'] ?? '___________'}
Tiempo de respuesta: ${doc['tiempoRespuesta'] ?? '48'} horas

CONDICIONES:
${doc['condiciones'] ?? 'Sin condiciones especiales'}

Esta oferta tiene validez por ${doc['validez'] ?? '7'} días naturales a partir de la fecha de firma.

Atentamente,
${doc['comprador'] ?? '___________'}''';
        break;

      case 'contrato_exclusividad':
        contenido = '''
CONTRATO DE EXCLUSIVIDAD

Fecha: $fechaStr

PROPIETARIO: ${doc['propietario'] ?? '___________'}
ASESOR: ${doc['asesor'] ?? '___________'}

Por medio del presente contrato, el PROPIETARIO otorga al ASESOR la exclusividad para la comercialización del inmueble ubicado en:

${doc['direccion'] ?? '___________'}

PRECIO DE VENTA: \$${doc['precio'] ?? '___________'}
COMISIÓN: ${doc['comision'] ?? '6'}%
VIGENCIA: ${doc['vigencia'] ?? '6'} meses

OBSERVACIONES:
${doc['observaciones'] ?? 'Sin observaciones'}''';
        break;

      case 'contrato_arrendamiento':
        contenido = '''
CONTRATO DE ARRENDAMIENTO

Fecha: $fechaStr

ARRENDADOR: ${doc['arrendador'] ?? '___________'}
ARRENDATARIO: ${doc['arrendatario'] ?? '___________'}

INMUEBLE: ${doc['direccion'] ?? '___________'}

RENTA MENSUAL: \$${doc['renta'] ?? '___________'}
DEPÓSITO: \$${doc['deposito'] ?? '___________'}
PLAZO: ${doc['plazo'] ?? '12'} meses

OBSERVACIONES:
${doc['observaciones'] ?? 'Sin observaciones'}''';
        break;

      case 'mandato':
        contenido = '''
MANDATO DE VENTA

Fecha: $fechaStr

MANDANTE: ${doc['mandante'] ?? '___________'}
MANDATARIO: ${doc['mandatario'] ?? '___________'}

INMUEBLE: ${doc['direccion'] ?? '___________'}

PRECIO MÍNIMO: \$${doc['precioMinimo'] ?? '___________'}
COMISIÓN: ${doc['comision'] ?? '6'}%
VIGENCIA: ${doc['vigencia'] ?? '6'} meses

OBSERVACIONES:
${doc['observaciones'] ?? 'Sin observaciones'}''';
        break;

      default:
        contenido = doc['contenido'] ?? 'Sin contenido';
    }

    return contenido;
  }
}