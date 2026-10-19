import 'dart:convert';
import 'dart:html' as html;

class AutomatizacionService {
  static const String _keyReglas = 'automatizacion_reglas';
  static const String _keyHistorial = 'automatizacion_historial';
  static const String _keyConfig = 'automatizacion_config';

  // ✅ Reglas predeterminadas
  static final List<Map<String, dynamic>> reglasPredeterminadas = [
    {
      'id': 'prospecto_24h',
      'etapa': 'prospecto',
      'tiempoHoras': 24,
      'titulo': 'Seguimiento inicial',
      'mensaje': 'Hola {cliente}, soy Williams de Real Estate. Vi tu interés en {propiedad}. ¿Te gustaría agendar una visita?',
      'canal': 'whatsapp',
      'activa': true,
    },
    {
      'id': 'calificado_48h',
      'etapa': 'calificado',
      'tiempoHoras': 48,
      'titulo': 'Seguimiento calificación',
      'mensaje': 'Hola {cliente}, ¿tienes alguna duda sobre {propiedad}? Estoy aquí para ayudarte.',
      'canal': 'whatsapp',
      'activa': true,
    },
    {
      'id': 'visita_2h',
      'etapa': 'visita',
      'tiempoHoras': 2,
      'titulo': 'Post-visita',
      'mensaje': 'Hola {cliente}, ¿qué te pareció {propiedad}? ¿Te gustaría hacer una oferta?',
      'canal': 'whatsapp',
      'activa': true,
    },
    {
      'id': 'oferta_24h',
      'etapa': 'oferta',
      'tiempoHoras': 24,
      'titulo': 'Seguimiento oferta',
      'mensaje': 'Hola {cliente}, ¿necesitas más información sobre {propiedad}? Estoy disponible para resolver tus dudas.',
      'canal': 'whatsapp',
      'activa': true,
    },
    {
      'id': 'reservado_7d',
      'etapa': 'reservado',
      'tiempoHoras': 168,
      'titulo': 'Recordatorio documentos',
      'mensaje': 'Hola {cliente}, recordatorio: necesitamos los documentos para {propiedad}. ¿Pudiste reunirlos?',
      'canal': 'whatsapp',
      'activa': true,
    },
  ];

  // ✅ Obtener reglas configuradas
  static List<Map<String, dynamic>> getReglas() {
    try {
      final json = html.window.localStorage[_keyReglas];
      if (json != null) {
        return (jsonDecode(json) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      print('Error: $e');
    }
    return reglasPredeterminadas;
  }

  // ✅ Guardar reglas
  static void guardarReglas(List<Map<String, dynamic>> reglas) {
    try {
      html.window.localStorage[_keyReglas] = jsonEncode(reglas);
    } catch (e) {
      print('Error: $e');
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

  // ✅ Agregar al historial
  static void agregarAlHistorial(Map<String, dynamic> registro) {
    final historial = getHistorial();
    registro['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    registro['fecha'] = DateTime.now().toIso8601String();
    historial.add(registro);
    try {
      html.window.localStorage[_keyHistorial] = jsonEncode(historial);
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ Verificar seguimientos pendientes
  static List<Map<String, dynamic>> verificarSeguimientosPendientes() {
    final reglas = getReglas().where((r) => r['activa'] == true).toList();
    final operaciones = _getOperaciones();
    final pendientes = <Map<String, dynamic>>[];
    final ahora = DateTime.now();

    for (var op in operaciones) {
      if (op['etapa'] == 'cerrado') continue;
      
      final fechaStr = op['fechaEtapa'] ?? op['fechaCreacion'] ?? '';
      if (fechaStr.isEmpty) continue;

      try {
        final fechaEtapa = DateTime.parse(fechaStr);
        final horasTranscurridas = ahora.difference(fechaEtapa).inHours;

        for (var regla in reglas) {
          if (regla['etapa'] != op['etapa']) continue;
          
          final tiempoHoras = regla['tiempoHoras'] as int;
          if (horasTranscurridas >= tiempoHoras) {
            // Verificar si ya se envió este seguimiento
            final historial = getHistorial();
            final yaEnviado = historial.any((h) => 
              h['operacionId'] == op['id'] && h['reglaId'] == regla['id']
            );

            if (!yaEnviado) {
              pendientes.add({
                'operacion': op,
                'regla': regla,
                'horasTranscurridas': horasTranscurridas,
              });
            }
          }
        }
      } catch (e) {
        print('Error verificando seguimiento: $e');
      }
    }

    return pendientes;
  }

  // ✅ Enviar seguimiento automático
  static Map<String, dynamic> enviarSeguimiento(Map<String, dynamic> pendiente) {
    final op = pendiente['operacion'] as Map<String, dynamic>;
    final regla = pendiente['regla'] as Map<String, dynamic>;
    
    final mensaje = regla['mensaje']
        .toString()
        .replaceAll('{cliente}', op['cliente'] ?? 'cliente')
        .replaceAll('{propiedad}', op['titulo'] ?? 'propiedad');

    final telefono = op['telefono'] ?? '';
    final canal = regla['canal'] ?? 'whatsapp';

    String resultado = '';
    bool exitoso = false;

    if (canal == 'whatsapp' && telefono.isNotEmpty) {
      // Simular envío de WhatsApp
      final url = 'https://wa.me/$telefono?text=${Uri.encodeComponent(mensaje)}';
      html.window.open(url, '_blank');
      resultado = 'WhatsApp enviado a $telefono';
      exitoso = true;
    } else if (canal == 'email') {
      final email = op['email'] ?? '';
      if (email.isNotEmpty) {
        final url = 'mailto:$email?subject=Seguimiento&body=${Uri.encodeComponent(mensaje)}';
        html.window.open(url, '_blank');
        resultado = 'Email enviado a $email';
        exitoso = true;
      } else {
        resultado = 'Sin email registrado';
      }
    } else {
      resultado = 'Canal no disponible';
    }

    // Registrar en historial
    agregarAlHistorial({
      'operacionId': op['id'],
      'operacionTitulo': op['titulo'],
      'cliente': op['cliente'],
      'reglaId': regla['id'],
      'reglaTitulo': regla['titulo'],
      'mensaje': mensaje,
      'canal': canal,
      'exitoso': exitoso,
      'resultado': resultado,
    });

    return {
      'exitoso': exitoso,
      'resultado': resultado,
      'mensaje': mensaje,
    };
  }

  // ✅ Obtener operaciones del pipeline
  static List<Map<String, dynamic>> _getOperaciones() {
    try {
      final json = html.window.localStorage['pipeline_operaciones'];
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

  // ✅ Estadísticas de automatización
  static Map<String, dynamic> getEstadisticas() {
    final historial = getHistorial();
    final reglas = getReglas();
    
    final totalEnviados = historial.where((h) => h['exitoso'] == true).length;
    final totalFallidos = historial.where((h) => h['exitoso'] != true).length;
    final reglasActivas = reglas.where((r) => r['activa'] == true).length;

    return {
      'totalEnviados': totalEnviados,
      'totalFallidos': totalFallidos,
      'reglasActivas': reglasActivas,
      'totalReglas': reglas.length,
      'tasaExito': totalEnviados + totalFallidos > 0 
          ? (totalEnviados / (totalEnviados + totalFallidos) * 100) 
          : 0,
    };
  }
}