import 'dart:convert';
import 'dart:html' as html;
import 'pipeline_service.dart';
import 'finanzas_service.dart';
import 'gamificacion_service.dart';
import 'local_storage_service.dart';

class IntegracionesService {
  // ============================================
  // INTEGRACIÓN 4: Pipeline ↔ Inmuebles
  // ============================================
  
  /// Vincula una operación del pipeline con un inmueble existente
  static void vincularOperacionConInmueble(String operacionId, String inmuebleId) {
    PipelineService.actualizarOperacion(operacionId, {
      'inmuebleId': inmuebleId,
    });
    
    // Actualizar estado del inmueble según etapa de la operación
    final operaciones = PipelineService.getOperaciones();
    final operacion = operaciones.firstWhere((o) => o['id'] == operacionId, orElse: () => {});
    
    if (operacion.isNotEmpty) {
      final etapa = operacion['etapa'];
      String estadoInmueble = 'Disponible';
      
      if (etapa == 'reservado') estadoInmueble = 'Reservado';
      if (etapa == 'cerrado') estadoInmueble = 'Vendido';
      
      // ✅ CORREGIDO: Usar localStorage directamente en lugar de método inexistente
      try {
        final inmueblesJson = html.window.localStorage['inmuebles'];
        if (inmueblesJson != null) {
          final inmuebles = (jsonDecode(inmueblesJson) as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          
          final index = inmuebles.indexWhere((i) => i['id'] == inmuebleId);
          if (index != -1) {
            inmuebles[index]['estadoVenta'] = estadoInmueble;
            html.window.localStorage['inmuebles'] = jsonEncode(inmuebles);
          }
        }
      } catch (e) {
        print('Error actualizando inmueble: $e');
      }
    }
  }
  
  /// Desvincula operación de inmueble
  static void desvincularOperacionDeInmueble(String operacionId) {
    PipelineService.actualizarOperacion(operacionId, {
      'inmuebleId': null,
    });
  }
  
  /// Obtiene inmuebles disponibles para vincular
  static List<Map<String, dynamic>> getInmueblesDisponibles() {
    try {
      final inmueblesJson = html.window.localStorage['inmuebles'];
      if (inmueblesJson != null) {
        final inmuebles = (jsonDecode(inmueblesJson) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return inmuebles.where((i) => i['estadoVenta'] == 'Disponible').toList();
      }
    } catch (e) {
      print('Error obteniendo inmuebles: $e');
    }
    return [];
  }

  // ============================================
  // INTEGRACIÓN 5: Pipeline ↔ Documentos
  // ============================================
  
  /// Genera datos pre-llenados para documentos desde operación
  static Map<String, String> generarDatosDocumento(String operacionId, String tipoDocumento) {
    final operaciones = PipelineService.getOperaciones();
    final operacion = operaciones.firstWhere((o) => o['id'] == operacionId, orElse: () => {});
    
    if (operacion.isEmpty) return {};
    
    final hoy = DateTime.now();
    final fechaFormateada = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
    
    switch (tipoDocumento) {
      case 'contrato_exclusividad':
        return {
          'propietario': operacion['cliente'] ?? '',
          'direccion': operacion['titulo'] ?? '',
          'precio': PipelineService.formatearMoneda(operacion['valor'] ?? 0),
          'vigencia': '6',
          'comision': '6',
          'fecha': fechaFormateada,
        };
      
      case 'carta_oferta':
        return {
          'comprador': operacion['cliente'] ?? '',
          'vendedor': 'Por definir',
          'direccion': operacion['titulo'] ?? '',
          'precio_oferta': PipelineService.formatearMoneda(operacion['valor'] ?? 0),
          'enganche': '10',
          'fecha_entrega': fechaFormateada,
          'condiciones': 'Operación generada desde Pipeline',
        };
      
      default:
        return {};
    }
  }

  // ============================================
  // INTEGRACIÓN 6: Pipeline ↔ Calculadoras
  // ============================================
  
  /// Calcula comisión estimada para una operación
  static Map<String, double> calcularComisionOperacion(String operacionId, double porcentajeComision) {
    final operaciones = PipelineService.getOperaciones();
    final operacion = operaciones.firstWhere((o) => o['id'] == operacionId, orElse: () => {});
    
    if (operacion.isEmpty) return {};
    
    final valor = operacion['valor'] as double? ?? 0;
    final comisionBruta = valor * (porcentajeComision / 100);
    final isrEstimado = comisionBruta * 0.10;
    final comisionNeta = comisionBruta - isrEstimado;
    
    return {
      'valor': valor,
      'comisionBruta': comisionBruta,
      'isrEstimado': isrEstimado,
      'comisionNeta': comisionNeta,
    };
  }

  // ============================================
  // INTEGRACIÓN 7: Pipeline ↔ Asistente IA
  // ============================================
  
  /// Obtiene análisis completo del pipeline para el Asistente IA
  static Map<String, dynamic> getAnalisisCompletoPipeline() {
    return PipelineService.getAnalisisPipeline();
  }

  // ============================================
  // INTEGRACIÓN 8: Finanzas ↔ Calculadoras
  // ============================================
  
  /// Calcula comisión neta para registro en finanzas
  static Map<String, double> calcularComisionParaFinanzas(double monto, double porcentajeComision) {
    final comisionBruta = monto * (porcentajeComision / 100);
    final isrEstimado = comisionBruta * 0.10;
    final comisionNeta = comisionBruta - isrEstimado;
    
    return {
      'comisionBruta': comisionBruta,
      'isrEstimado': isrEstimado,
      'comisionNeta': comisionNeta,
    };
  }

  // ============================================
  // INTEGRACIÓN 9: Gamificación ↔ Pipeline
  // ============================================
  
  /// Registra puntos por mover operación en pipeline
  static Map<String, dynamic> registrarPuntosPipeline(String operacionId, String nuevaEtapa) {
    Map<String, dynamic> resultado = {'puntos': 0, 'badgesNuevos': <Map<String, dynamic>>[]};
    
    switch (nuevaEtapa) {
      case 'calificado':
        resultado = GamificacionService.agregarPuntos(10, 'Calificó prospecto en pipeline');
        break;
      case 'visita':
        resultado = GamificacionService.agregarPuntos(15, 'Agendó visita en pipeline');
        break;
      case 'oferta':
        resultado = GamificacionService.agregarPuntos(25, 'Generó oferta en pipeline');
        break;
      case 'reservado':
        resultado = GamificacionService.agregarPuntos(35, 'Reservó operación en pipeline');
        break;
      case 'cerrado':
        resultado = GamificacionService.agregarPuntos(100, 'Cerró operación en pipeline');
        break;
    }
    
    return resultado;
  }
  
  /// Verifica badges especiales de pipeline
  static List<Map<String, dynamic>> verificarBadgesPipeline() {
    final perfil = GamificacionService.getPerfil();
    final operaciones = PipelineService.getOperaciones();
    final cerradas = operaciones.where((o) => o['etapa'] == 'cerrado').length;
    
    final badges = <Map<String, dynamic>>[];
    final badgesEspeciales = perfil['badgesEspeciales'] as List? ?? [];
    
    // Badge por primera venta
    if (cerradas >= 1 && !badgesEspeciales.contains('primera_venta')) {
      badges.add({
        'id': 'primera_venta',
        'nombre': 'Primera Venta',
        'descripcion': 'Cerraste tu primera operación',
        'icono': '🏆',
      });
    }
    
    // Badge por 5 ventas
    if (cerradas >= 5 && !badgesEspeciales.contains('cinco_ventas')) {
      badges.add({
        'id': 'cinco_ventas',
        'nombre': 'Top Seller',
        'descripcion': 'Cerraste 5 operaciones',
        'icono': '⭐',
      });
    }
    
    // Badge por 10 ventas
    if (cerradas >= 10 && !badgesEspeciales.contains('diez_ventas')) {
      badges.add({
        'id': 'diez_ventas',
        'nombre': 'Master Closer',
        'descripcion': 'Cerraste 10 operaciones',
        'icono': '👑',
      });
    }
    
    return badges;
  }

  // ============================================
  // INTEGRACIÓN 10: Gamificación ↔ Finanzas
  // ============================================
  
  /// Registra puntos por alcanzar metas financieras
  static Map<String, dynamic> verificarMetasFinancieras() {
    final resumen = FinanzasService.getResumenFinanciero();
    final metas = FinanzasService.getMetas();
    final perfil = GamificacionService.getPerfil();
    
    Map<String, dynamic> resultado = {'puntos': 0, 'badgesNuevos': <Map<String, dynamic>>[]};
    
    // Meta mensual alcanzada
    if (resumen['ingresosMes'] >= metas['metaMensual']) {
      resultado = GamificacionService.agregarPuntos(50, 'Alcanzó meta mensual');
    }
    
    // Meta anual alcanzada
    if (resumen['ingresosAnio'] >= metas['metaAnual']) {
      final resultadoAnual = GamificacionService.agregarPuntos(200, 'Alcanzó meta anual');
      resultado['puntos'] = (resultado['puntos'] as int) + (resultadoAnual['puntosGanados'] as int);
      if (resultadoAnual['badgesNuevos'] != null) {
        resultado['badgesNuevos'] = resultadoAnual['badgesNuevos'];
      }
    }
    
    // Badge por primer ingreso
    final badgesFinancieros = perfil['badgesFinancieros'] as List? ?? [];
    if (resumen['ingresosMes'] > 0 && !badgesFinancieros.contains('primer_ingreso')) {
      (resultado['badgesNuevos'] as List).add({
        'id': 'primer_ingreso',
        'nombre': 'Primer Ingreso',
        'descripcion': 'Registraste tu primer ingreso',
        'icono': '💵',
      });
    }
    
    // Badge por superar meta
    if (resumen['ingresosMes'] > metas['metaMensual'] * 1.5) {
      (resultado['badgesNuevos'] as List).add({
        'id': 'super_meta',
        'nombre': 'Super Meta',
        'descripcion': 'Superaste tu meta en 50%',
        'icono': '🚀',
      });
    }
    
    return resultado;
  }

  // ============================================
  // MÉTODO MAESTRO: Ejecutar todas las integraciones al mover operación
  // ============================================
  
  /// Ejecuta todas las integraciones cuando se mueve una operación
  static Map<String, dynamic> ejecutarIntegracionesAlMover(
    String operacionId,
    String nuevaEtapa, {
    bool crearActividad = true,
    bool registrarComision = false,
    double porcentajeComision = 6.0,
    String? inmuebleId,
  }) {
    Map<String, dynamic> resultado = {
      'success': true,
      'actividadCreada': '',
      'comisionRegistrada': '',
      'puntosGanados': 0,
      'badgesNuevos': <Map<String, dynamic>>[],
      'inmuebleActualizado': false,
    };
    
    // 1. Mover operación y crear actividad (Integración 1)
    final resultadoMovimiento = PipelineService.moverOperacion(
      operacionId,
      nuevaEtapa,
      crearActividad: crearActividad,
      registrarComision: registrarComision,
      porcentajeComision: porcentajeComision,
    );
    
    resultado['actividadCreada'] = resultadoMovimiento['actividadCreada'];
    resultado['comisionRegistrada'] = resultadoMovimiento['comisionRegistrada'];
    
    // 2. Vincular con inmueble si se proporciona (Integración 4)
    if (inmuebleId != null && inmuebleId.isNotEmpty) {
      vincularOperacionConInmueble(operacionId, inmuebleId);
      resultado['inmuebleActualizado'] = true;
    }
    
    // 3. Registrar puntos de gamificación (Integración 9)
    final resultadoGamificacion = registrarPuntosPipeline(operacionId, nuevaEtapa);
    resultado['puntosGanados'] = resultadoGamificacion['puntosGanados'];
    resultado['badgesNuevos'] = resultadoGamificacion['badgesNuevos'];
    
    // 4. Verificar badges especiales de pipeline
    final badgesEspeciales = verificarBadgesPipeline();
    if (badgesEspeciales.isNotEmpty) {
      resultado['badgesNuevos'] = [...(resultado['badgesNuevos'] as List), ...badgesEspeciales];
    }
    
    // 5. Verificar metas financieras si se registró comisión (Integración 10)
    if (registrarComision && nuevaEtapa == 'cerrado') {
      final resultadoMetas = verificarMetasFinancieras();
      resultado['puntosGanados'] = (resultado['puntosGanados'] as int) + (resultadoMetas['puntos'] as int);
      if (resultadoMetas['badgesNuevos'] != null && (resultadoMetas['badgesNuevos'] as List).isNotEmpty) {
        resultado['badgesNuevos'] = [...(resultado['badgesNuevos'] as List), ...resultadoMetas['badgesNuevos']];
      }
    }
    
    return resultado;
  }
}