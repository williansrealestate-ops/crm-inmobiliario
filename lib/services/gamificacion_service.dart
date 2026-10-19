import 'dart:convert';
import 'dart:html' as html;

class GamificacionService {
  static const String _keyPerfil = 'gamificacion_perfil';
  static const String _keyBadges = 'gamificacion_badges';
  static const String _keyHistorial = 'gamificacion_historial';

  static Map<String, dynamic> _obtenerPerfil() {
    try {
      final json = html.window.localStorage[_keyPerfil];
      if (json != null) return Map<String, dynamic>.from(jsonDecode(json));
    } catch (e) {
      print('Error obteniendo perfil: $e');
    }
    return {
      'puntos': 0,
      'nivel': 1,
      'nombreNivel': 'Novato',
      'temasLeidos': <String>[],
      'scriptsGenerados': 0,
      'documentosCreados': 0,
      'sentimientosAnalizados': 0,
      'diasConsecutivos': 1,
      'ultimaVisita': DateTime.now().toIso8601String(),
    };
  }

  static void _guardarPerfil(Map<String, dynamic> perfil) {
    try {
      html.window.localStorage[_keyPerfil] = jsonEncode(perfil);
    } catch (e) {
      print('Error guardando perfil: $e');
    }
  }

  static List<Map<String, dynamic>> _obtenerBadges() {
    try {
      final json = html.window.localStorage[_keyBadges];
      if (json != null) {
        return (jsonDecode(json) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      print('Error obteniendo badges: $e');
    }
    return [];
  }

  static void _guardarBadges(List<Map<String, dynamic>> badges) {
    try {
      html.window.localStorage[_keyBadges] = jsonEncode(badges);
    } catch (e) {
      print('Error guardando badges: $e');
    }
  }

  static Map<String, dynamic> getPerfil() => _obtenerPerfil();
  static List<Map<String, dynamic>> getBadges() => _obtenerBadges();

  // ✅ Sistema de niveles
  static String _obtenerNombreNivel(int puntos) {
    if (puntos >= 1000) return ' Maestro Inmobiliario';
    if (puntos >= 500) return ' Experto';
    if (puntos >= 250) return '🥇 Profesional';
    if (puntos >= 100) return '🥈 Avanzado';
    if (puntos >= 50) return '🥉 Intermedio';
    return ' Novato';
  }

  static int _obtenerNivel(int puntos) {
    if (puntos >= 1000) return 6;
    if (puntos >= 500) return 5;
    if (puntos >= 250) return 4;
    if (puntos >= 100) return 3;
    if (puntos >= 50) return 2;
    return 1;
  }

  // ✅ Agregar puntos por acción
  static Map<String, dynamic> agregarPuntos(int cantidad, String motivo) {
    final perfil = _obtenerPerfil();
    final puntosAnteriores = perfil['puntos'] as int;
    final nuevosPuntos = puntosAnteriores + cantidad;
    
    perfil['puntos'] = nuevosPuntos;
    perfil['nivel'] = _obtenerNivel(nuevosPuntos);
    perfil['nombreNivel'] = _obtenerNombreNivel(nuevosPuntos);

    // Registrar en historial
    final historial = _obtenerHistorial();
    historial.add({
      'fecha': DateTime.now().toIso8601String(),
      'puntos': cantidad,
      'motivo': motivo,
      'total': nuevosPuntos,
    });
    _guardarHistorial(historial);

    _guardarPerfil(perfil);
    
    // Verificar si subió de nivel
    final nivelAnterior = _obtenerNivel(puntosAnteriores);
    final nivelNuevo = _obtenerNivel(nuevosPuntos);
    final subioNivel = nivelNuevo > nivelAnterior;

    // Verificar badges desbloqueados
    final badgesNuevos = _verificarBadges(perfil);

    return {
      'puntos': nuevosPuntos,
      'puntosGanados': cantidad,
      'nivel': nivelNuevo,
      'nombreNivel': perfil['nombreNivel'],
      'subioNivel': subioNivel,
      'badgesNuevos': badgesNuevos,
    };
  }

  // ✅ Marcar tema como leído
  static Map<String, dynamic> marcarTemaLeido(String temaId) {
    final perfil = _obtenerPerfil();
    final temasLeidos = List<String>.from(perfil['temasLeidos'] ?? []);
    
    if (!temasLeidos.contains(temaId)) {
      temasLeidos.add(temaId);
      perfil['temasLeidos'] = temasLeidos;
      _guardarPerfil(perfil);
      return agregarPuntos(25, 'Leyó tema: $temaId');
    }
    return {'puntos': perfil['puntos'], 'puntosGanados': 0, 'subioNivel': false, 'badgesNuevos': []};
  }

  // ✅ Registrar acción
  static Map<String, dynamic> registrarScriptGenerado() {
    final perfil = _obtenerPerfil();
    perfil['scriptsGenerados'] = (perfil['scriptsGenerados'] ?? 0) + 1;
    _guardarPerfil(perfil);
    return agregarPuntos(15, 'Generó un script');
  }

  static Map<String, dynamic> registrarDocumentoCreado() {
    final perfil = _obtenerPerfil();
    perfil['documentosCreados'] = (perfil['documentosCreados'] ?? 0) + 1;
    _guardarPerfil(perfil);
    return agregarPuntos(20, 'Creó un documento');
  }

  static Map<String, dynamic> registrarSentimientoAnalizado() {
    final perfil = _obtenerPerfil();
    perfil['sentimientosAnalizados'] = (perfil['sentimientosAnalizados'] ?? 0) + 1;
    _guardarPerfil(perfil);
    return agregarPuntos(10, 'Analizó sentimiento');
  }

  // ✅ Sistema de Badges
  static List<Map<String, dynamic>> _verificarBadges(Map<String, dynamic> perfil) {
    final badgesObtenidos = _obtenerBadges();
    final idsObtenidos = badgesObtenidos.map((b) => b['id']).toSet();
    final nuevosBadges = <Map<String, dynamic>>[];

    final todosBadges = _todosLosBadges();
    for (var badge in todosBadges) {
      if (idsObtenidos.contains(badge['id'])) continue;
      
      bool desbloqueado = false;
      switch (badge['tipo']) {
        case 'temas':
          desbloqueado = (perfil['temasLeidos'] as List).length >= badge['requerido'];
          break;
        case 'scripts':
          desbloqueado = (perfil['scriptsGenerados'] ?? 0) >= badge['requerido'];
          break;
        case 'documentos':
          desbloqueado = (perfil['documentosCreados'] ?? 0) >= badge['requerido'];
          break;
        case 'puntos':
          desbloqueado = (perfil['puntos'] ?? 0) >= badge['requerido'];
          break;
      }

      if (desbloqueado) {
        badge['fechaObtencion'] = DateTime.now().toIso8601String();
        badgesObtenidos.add(badge);
        nuevosBadges.add(badge);
      }
    }

    if (nuevosBadges.isNotEmpty) {
      _guardarBadges(badgesObtenidos);
    }

    return nuevosBadges;
  }

  static List<Map<String, dynamic>> _todosLosBadges() {
    return [
      {'id': 'lector_1', 'nombre': 'Lector Curioso', 'descripcion': 'Lee tu primer tema', 'icono': '📖', 'tipo': 'temas', 'requerido': 1},
      {'id': 'lector_5', 'nombre': 'Estudioso', 'descripcion': 'Lee 5 temas', 'icono': '📚', 'tipo': 'temas', 'requerido': 5},
      {'id': 'lector_9', 'nombre': 'Erudito', 'descripcion': 'Lee todos los temas', 'icono': '', 'tipo': 'temas', 'requerido': 9},
      {'id': 'script_1', 'nombre': 'Guionista', 'descripcion': 'Genera tu primer script', 'icono': '✍️', 'tipo': 'scripts', 'requerido': 1},
      {'id': 'script_10', 'nombre': 'Maestro del Guión', 'descripcion': 'Genera 10 scripts', 'icono': '🎬', 'tipo': 'scripts', 'requerido': 10},
      {'id': 'doc_1', 'nombre': 'Documentador', 'descripcion': 'Crea tu primer documento', 'icono': '📄', 'tipo': 'documentos', 'requerido': 1},
      {'id': 'doc_10', 'nombre': 'Notario Digital', 'descripcion': 'Crea 10 documentos', 'icono': '⚖️', 'tipo': 'documentos', 'requerido': 10},
      {'id': 'puntos_50', 'nombre': 'En Crecimiento', 'descripcion': 'Alcanza 50 puntos', 'icono': '🌟', 'tipo': 'puntos', 'requerido': 50},
      {'id': 'puntos_250', 'nombre': 'Profesional', 'descripcion': 'Alcanza 250 puntos', 'icono': '🏅', 'tipo': 'puntos', 'requerido': 250},
      {'id': 'puntos_1000', 'nombre': 'Leyenda', 'descripcion': 'Alcanza 1000 puntos', 'icono': '👑', 'tipo': 'puntos', 'requerido': 1000},
    ];
  }

  // ✅ Historial de puntos
  static List<Map<String, dynamic>> _obtenerHistorial() {
    try {
      final json = html.window.localStorage[_keyHistorial];
      if (json != null) {
        return (jsonDecode(json) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      print('Error obteniendo historial: $e');
    }
    return [];
  }

  static void _guardarHistorial(List<Map<String, dynamic>> historial) {
    try {
      // Mantener solo los últimos 50 registros
      if (historial.length > 50) historial = historial.sublist(historial.length - 50);
      html.window.localStorage[_keyHistorial] = jsonEncode(historial);
    } catch (e) {
      print('Error guardando historial: $e');
    }
  }

  static List<Map<String, dynamic>> getHistorial() => _obtenerHistorial();

  // ✅ Progreso hacia siguiente nivel
  static Map<String, dynamic> getProgresoNivel() {
    final perfil = _obtenerPerfil();
    final puntos = perfil['puntos'] as int;
    
    final limites = [0, 50, 100, 250, 500, 1000];
    final nivelActual = _obtenerNivel(puntos);
    final puntosNivelActual = limites[nivelActual - 1];
    final puntosNivelSiguiente = nivelActual < 6 ? limites[nivelActual] : 1000;
    final progreso = ((puntos - puntosNivelActual) / (puntosNivelSiguiente - puntosNivelActual)).clamp(0.0, 1.0);
    
    return {
      'nivelActual': nivelActual,
      'nombreNivel': perfil['nombreNivel'],
      'puntos': puntos,
      'puntosNivelActual': puntosNivelActual,
      'puntosNivelSiguiente': puntosNivelSiguiente,
      'progreso': progreso,
      'faltan': puntosNivelSiguiente - puntos,
    };
  }

  // ✅ Reset (para pruebas)
  static void resetTodo() {
    html.window.localStorage.remove(_keyPerfil);
    html.window.localStorage.remove(_keyBadges);
    html.window.localStorage.remove(_keyHistorial);
  }
}