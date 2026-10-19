import 'dart:convert';
import 'dart:html' as html;
import 'local_storage_service.dart';
import 'finanzas_service.dart';

class PipelineService {
  static const String _keyOperaciones = 'pipeline_operaciones';

  // Etapas del pipeline
  static const List<Map<String, dynamic>> etapas = [
    {'id': 'prospecto', 'nombre': 'Prospecto', 'icono': '', 'color': '0xFF6B7280'},
    {'id': 'calificado', 'nombre': 'Calificado', 'icono': '✅', 'color': '0xFF3B82F6'},
    {'id': 'visita', 'nombre': 'Visita', 'icono': '🏠', 'color': '0xFFF59E0B'},
    {'id': 'oferta', 'nombre': 'Oferta', 'icono': '💼', 'color': '0xFF8B5CF6'},
    {'id': 'reservado', 'nombre': 'Reservado', 'icono': '🔒', 'color': '0xFFEC4899'},
    {'id': 'cerrado', 'nombre': 'Cerrado', 'icono': '🎉', 'color': '0xFF10B981'},
  ];

  // Mapeo de etapas a tipos de actividad
  static const Map<String, Map<String, dynamic>> actividadPorEtapa = {
    'calificado': {
      'tipo': 'Seguimiento',
      'titulo': 'Seguimiento a cliente calificado',
      'descripcion': 'Contactar cliente para agendar visita',
    },
    'visita': {
      'tipo': 'Visita',
      'titulo': 'Visita programada',
      'descripcion': 'Mostrar propiedad al cliente',
    },
    'oferta': {
      'tipo': 'Seguimiento',
      'titulo': 'Seguimiento de oferta',
      'descripcion': 'Dar seguimiento a oferta presentada',
    },
    'reservado': {
      'tipo': 'Seguimiento',
      'titulo': 'Seguimiento de reservación',
      'descripcion': 'Coordinar documentación y cierre',
    },
    'cerrado': {
      'tipo': 'Seguimiento',
      'titulo': 'Operación cerrada',
      'descripcion': 'Post-venta y solicitud de referidos',
    },
  };

  // ✅ NUEVO: Configuración de comisión por defecto
  static double porcentajeComisionPorDefecto = 6.0; // 6%

  static List<Map<String, dynamic>> getOperaciones() {
    try {
      final json = html.window.localStorage[_keyOperaciones];
      if (json != null) {
        return (jsonDecode(json) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      print('Error obteniendo operaciones: $e');
    }
    return [];
  }

  static void guardarOperaciones(List<Map<String, dynamic>> operaciones) {
    try {
      html.window.localStorage[_keyOperaciones] = jsonEncode(operaciones);
    } catch (e) {
      print('Error guardando operaciones: $e');
    }
  }

  static void agregarOperacion(Map<String, dynamic> operacion) {
    final operaciones = getOperaciones();
    operacion['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    operacion['fechaCreacion'] = DateTime.now().toIso8601String();
    operacion['etapa'] = operacion['etapa'] ?? 'prospecto';
    operaciones.add(operacion);
    guardarOperaciones(operaciones);
  }

  static void actualizarOperacion(String id, Map<String, dynamic> cambios) {
    final operaciones = getOperaciones();
    final index = operaciones.indexWhere((o) => o['id'] == id);
    if (index != -1) {
      operaciones[index].addAll(cambios);
      guardarOperaciones(operaciones);
    }
  }

  // ✅ ACTUALIZADO: Mover operación con integración a Finanzas
  static Map<String, dynamic> moverOperacion(
    String id, 
    String nuevaEtapa, {
    bool crearActividad = true,
    bool registrarComision = false,
    double porcentajeComision = 6.0,
  }) {
    final operaciones = getOperaciones();
    final index = operaciones.indexWhere((o) => o['id'] == id);
    
    if (index != -1) {
      final operacion = operaciones[index];
      final etapaAnterior = operacion['etapa'];
      
      // Actualizar etapa
      operaciones[index]['etapa'] = nuevaEtapa;
      operaciones[index]['fechaEtapa'] = DateTime.now().toIso8601String();
      guardarOperaciones(operaciones);
      
      String actividadCreada = '';
      String comisionRegistrada = '';
      
      // ✅ Crear actividad automáticamente
      if (crearActividad && actividadPorEtapa.containsKey(nuevaEtapa)) {
        final configActividad = actividadPorEtapa[nuevaEtapa]!;
        final hoy = DateTime.now();
        final fechaStr = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
        
        final actividad = {
          'titulo': '${configActividad['titulo']}: ${operacion['titulo']}',
          'descripcion': '${configActividad['descripcion']} - Cliente: ${operacion['cliente'] ?? 'N/A'}',
          'tipo': configActividad['tipo'],
          'fecha': fechaStr,
          'hora': '${hoy.hour.toString().padLeft(2, '0')}:${hoy.minute.toString().padLeft(2, '0')}',
          'completada': false,
          'prioridad': nuevaEtapa == 'cerrado' ? 'Alta' : 'Media',
          'operacionId': id,
          'etapaAnterior': etapaAnterior,
          'etapaNueva': nuevaEtapa,
        };
        
        LocalStorageService.agregarActividad(actividad);
        actividadCreada = configActividad['titulo'];
      }
      
      // ✅ NUEVO: Registrar comisión en Finanzas si la operación se cerró
      if (registrarComision && nuevaEtapa == 'cerrado') {
        final valorOperacion = operacion['valor'] as double? ?? 0;
        final comision = valorOperacion * (porcentajeComision / 100);
        
        FinanzasService.agregarIngreso({
          'concepto': 'Comisión: ${operacion['titulo']}',
          'monto': comision,
          'cliente': operacion['cliente'] ?? 'N/A',
          'operacionId': id,
          'tipo': 'Comisión Pipeline',
          'porcentajeComision': porcentajeComision,
          'valorOperacion': valorOperacion,
        });
        
        comisionRegistrada = '\$$comision';
      }
      
      return {
        'success': true,
        'actividadCreada': actividadCreada,
        'comisionRegistrada': comisionRegistrada,
        'etapaAnterior': etapaAnterior,
        'etapaNueva': nuevaEtapa,
      };
    }
    
    return {'success': false};
  }

  static void eliminarOperacion(String id) {
    final operaciones = getOperaciones().where((o) => o['id'] != id).toList();
    guardarOperaciones(operaciones);
  }

  static List<Map<String, dynamic>> getOperacionesPorEtapa(String etapaId) {
    return getOperaciones().where((o) => o['etapa'] == etapaId).toList();
  }

  static Map<String, dynamic> getResumenPipeline() {
    final operaciones = getOperaciones();
    final resumen = <String, dynamic>{};

    for (var etapa in etapas) {
      final etapaId = etapa['id'];
      final opsEtapa = operaciones.where((o) => o['etapa'] == etapaId).toList();
      final valorTotal = opsEtapa.fold(0.0, (sum, o) => sum + (o['valor'] as double? ?? 0));
      resumen[etapaId] = {
        'cantidad': opsEtapa.length,
        'valor': valorTotal,
      };
    }

    resumen['total'] = operaciones.length;
    resumen['valorTotal'] = operaciones.fold(0.0, (sum, o) => sum + (o['valor'] as double? ?? 0));

    return resumen;
  }

  // ✅ NUEVO: Análisis para Asistente IA
  static Map<String, dynamic> getAnalisisPipeline() {
    final operaciones = getOperaciones();
    final hoy = DateTime.now();
    
    // Operaciones estancadas (más de 14 días en misma etapa)
    final estancadas = operaciones.where((o) {
      if (o['etapa'] == 'cerrado') return false;
      final fechaEtapa = o['fechaEtapa'] ?? o['fechaCreacion'] ?? '';
      if (fechaEtapa.isEmpty) return false;
      try {
        final fecha = DateTime.parse(fechaEtapa);
        return hoy.difference(fecha).inDays > 14;
      } catch (e) {
        return false;
      }
    }).toList();
    
    // Operaciones de alto valor (top 20%)
    final valores = operaciones.map((o) => o['valor'] as double? ?? 0).toList()..sort();
    final umbralAltoValor = valores.isNotEmpty ? valores[(valores.length * 0.8).floor()] : 0;
    final altoValor = operaciones.where((o) => (o['valor'] as double? ?? 0) >= umbralAltoValor).toList();
    
    // Tasa de conversión por etapa
    final total = operaciones.length;
    final cerradas = operaciones.where((o) => o['etapa'] == 'cerrado').length;
    final tasaConversion = total > 0 ? (cerradas / total * 100) : 0;
    
    // Valor promedio por etapa
    final valorPromedio = <String, double>{};
    for (var etapa in etapas) {
      final etapaId = etapa['id'];
      final opsEtapa = operaciones.where((o) => o['etapa'] == etapaId).toList();
      if (opsEtapa.isNotEmpty) {
        final total = opsEtapa.fold(0.0, (sum, o) => sum + (o['valor'] as double? ?? 0));
        valorPromedio[etapaId] = total / opsEtapa.length;
      }
    }
    
    // Predicción de cierre (operaciones en oferta/reservado con alta probabilidad)
    final prediccionCierre = operaciones.where((o) {
      return o['etapa'] == 'oferta' || o['etapa'] == 'reservado';
    }).fold(0.0, (sum, o) => sum + (o['valor'] as double? ?? 0));
    
    return {
      'total': total,
      'cerradas': cerradas,
      'tasaConversion': tasaConversion,
      'estancadas': estancadas.length,
      'estancadasLista': estancadas,
      'altoValor': altoValor.length,
      'altoValorLista': altoValor,
      'valorPromedio': valorPromedio,
      'prediccionCierre': prediccionCierre,
      'valorTotalPipeline': operaciones.fold(0.0, (sum, o) => sum + (o['valor'] as double? ?? 0)),
    };
  }

  static String formatearMoneda(double valor) {
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)}K';
    return '\$${valor.toStringAsFixed(0)}';
  }
}