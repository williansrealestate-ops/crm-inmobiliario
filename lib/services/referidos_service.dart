import 'dart:convert';
import 'dart:html' as html;

class ReferidosService {
  static const String _keyReferidos = 'referidos_datos';
  static const String _keyConfig = 'referidos_config';
  static const String _keyHistorial = 'referidos_historial';

  // ✅ Niveles de referidor (con \$ escapado correctamente)
  static const List<Map<String, dynamic>> niveles = [
    {'nombre': 'Bronce', 'minimo': 0, 'maximo': 2, 'color': '0xFFCD7F32', 'icono': '🥉', 'recompensa': '5% descuento en próxima comisión'},
    {'nombre': 'Plata', 'minimo': 3, 'maximo': 5, 'color': '0xFFC0C0C0', 'icono': '🥈', 'recompensa': '10% descuento + Gift Card \$500'},
    {'nombre': 'Oro', 'minimo': 6, 'maximo': 10, 'color': '0xFFFFD700', 'icono': '🥇', 'recompensa': '15% descuento + Gift Card \$1,500'},
    {'nombre': 'Platino', 'minimo': 11, 'maximo': 999, 'color': '0xFFE5E4E2', 'icono': '💎', 'recompensa': '20% descuento + Gift Card \$3,000 + Viaje'},
  ];

  // ✅ Obtener datos de referidos
  static Map<String, dynamic> getDatos() {
    try {
      final json = html.window.localStorage[_keyReferidos];
      if (json != null) {
        return Map<String, dynamic>.from(jsonDecode(json));
      }
    } catch (e) {
      print('Error: $e');
    }
    return {
      'codigoPropio': _generarCodigo(),
      'totalReferidos': 0,
      'referidosExitosos': 0,
      'puntosGanados': 0,
      'nivelActual': 'Bronce',
      'fechaRegistro': DateTime.now().toIso8601String(),
    };
  }

  // ✅ Guardar datos
  static void guardarDatos(Map<String, dynamic> datos) {
    try {
      html.window.localStorage[_keyReferidos] = jsonEncode(datos);
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ Generar código único
  static String _generarCodigo() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String codigo = 'RE-';
    for (int i = 0; i < 6; i++) {
      codigo += chars[(random + i * 7) % chars.length];
    }
    return codigo;
  }

  // ✅ Registrar nuevo referido
  static Map<String, dynamic> registrarReferido({
    required String codigoReferidor,
    required String nombreReferido,
    required String telefonoReferido,
    required String emailReferido,
  }) {
    final historial = getHistorial();
    
    final datosReferidor = getDatosPorCodigo(codigoReferidor);
    if (datosReferidor == null) {
      return {'exitoso': false, 'mensaje': 'Código de referido inválido'};
    }

    final yaExiste = historial.any((r) => 
      r['emailReferido'] == emailReferido || r['telefonoReferido'] == telefonoReferido
    );
    if (yaExiste) {
      return {'exitoso': false, 'mensaje': 'Este cliente ya fue referido anteriormente'};
    }

    final nuevoReferido = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'codigoReferidor': codigoReferidor,
      'nombreReferido': nombreReferido,
      'telefonoReferido': telefonoReferido,
      'emailReferido': emailReferido,
      'fechaRegistro': DateTime.now().toIso8601String(),
      'estado': 'pendiente',
      'operacionCerrada': false,
      'recompensaEntregada': false,
    };
    historial.add(nuevoReferido);
    guardarHistorial(historial);

    _actualizarContadorReferidor(codigoReferidor);

    return {'exitoso': true, 'mensaje': 'Referido registrado exitosamente'};
  }

  // ✅ Obtener datos por código
  static Map<String, dynamic>? getDatosPorCodigo(String codigo) {
    final datos = getDatos();
    if (datos['codigoPropio'] == codigo) {
      return datos;
    }
    return null;
  }

  // ✅ Actualizar contador
  static void _actualizarContadorReferidor(String codigo) {
    final datos = getDatos();
    if (datos['codigoPropio'] == codigo) {
      datos['totalReferidos'] = (datos['totalReferidos'] as int) + 1;
      _actualizarNivel(datos);
      guardarDatos(datos);
    }
  }

  // ✅ Actualizar nivel
  static void _actualizarNivel(Map<String, dynamic> datos) {
    final total = datos['totalReferidos'] as int;
    String nuevoNivel = 'Bronce';
    
    for (var nivel in niveles) {
      if (total >= nivel['minimo'] && total <= nivel['maximo']) {
        nuevoNivel = nivel['nombre'];
        break;
      }
    }
    
    datos['nivelActual'] = nuevoNivel;
  }

  // ✅ Marcar referido como exitoso (operación cerrada)
  static void marcarReferidoExitoso(String referidoId) {
    final historial = getHistorial();
    final index = historial.indexWhere((r) => r['id'] == referidoId);
    
    if (index != -1) {
      historial[index]['estado'] = 'exitoso';
      historial[index]['operacionCerrada'] = true;
      historial[index]['fechaCierre'] = DateTime.now().toIso8601String();
      guardarHistorial(historial);

      final codigoReferidor = historial[index]['codigoReferidor'];
      final datos = getDatos();
      if (datos['codigoPropio'] == codigoReferidor) {
        datos['referidosExitosos'] = (datos['referidosExitosos'] as int) + 1;
        datos['puntosGanados'] = (datos['puntosGanados'] as int) + 100;
        guardarDatos(datos);
      }
    }
  }

  // ✅ Obtener historial
  static List<Map<String, dynamic>> getHistorial() {
    try {
      final json = html.window.localStorage[_keyHistorial];
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

  // ✅ Guardar historial
  static void guardarHistorial(List<Map<String, dynamic>> historial) {
    try {
      html.window.localStorage[_keyHistorial] = jsonEncode(historial);
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ Obtener referidos del usuario actual
  static List<Map<String, dynamic>> getMisReferidos() {
    final datos = getDatos();
    final codigo = datos['codigoPropio'];
    return getHistorial().where((r) => r['codigoReferidor'] == codigo).toList();
  }

  // ✅ Obtener nivel actual
  static Map<String, dynamic> getNivelActual() {
    final datos = getDatos();
    final nivelNombre = datos['nivelActual'];
    return niveles.firstWhere(
      (n) => n['nombre'] == nivelNombre,
      orElse: () => niveles.first,
    );
  }

  // ✅ Obtener siguiente nivel
  static Map<String, dynamic>? getSiguienteNivel() {
    final datos = getDatos();
    final nivelActual = datos['nivelActual'];
    final index = niveles.indexWhere((n) => n['nombre'] == nivelActual);
    
    if (index < niveles.length - 1) {
      return niveles[index + 1];
    }
    return null;
  }

  // ✅ Generar link de referido
  static String generarLinkReferido() {
    final datos = getDatos();
    final codigo = datos['codigoPropio'];
    return 'https://realestate-crm.com/referido?codigo=$codigo';
  }

  // ✅ Estadísticas
  static Map<String, dynamic> getEstadisticas() {
    final datos = getDatos();
    final historial = getHistorial();
    final misReferidos = getMisReferidos();
    
    return {
      'codigoPropio': datos['codigoPropio'],
      'totalReferidos': datos['totalReferidos'],
      'referidosExitosos': datos['referidosExitosos'],
      'puntosGanados': datos['puntosGanados'],
      'nivelActual': datos['nivelActual'],
      'tasaConversion': misReferidos.isEmpty ? 0 : 
        (misReferidos.where((r) => r['estado'] == 'exitoso').length / misReferidos.length * 100),
      'referidosPendientes': misReferidos.where((r) => r['estado'] == 'pendiente').length,
      'referidosExitososLista': misReferidos.where((r) => r['estado'] == 'exitoso').length,
    };
  }
}