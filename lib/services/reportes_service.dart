import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ReportesService {
  static final SupabaseClient _client = SupabaseService.client;

  // ✅ Ventas por asesor (simulado con inmuebles vendidos)
  static Future<List<Map<String, dynamic>>> getVentasPorAsesor() async {
    try {
      // Obtener todos los inmuebles con asesor
      final inmuebles = await _client
          .from('inmuebles')
          .select('asesor, precio')
          .not('asesor', 'is', null);

      // Agrupar por asesor y sumar precios
      Map<String, double> ventasPorAsesor = {};
      
      for (var inmueble in inmuebles) {
        final asesor = inmueble['asesor']?.toString() ?? 'Sin asesor';
        final precio = _toDouble(inmueble['precio']);
        
        ventasPorAsesor[asesor] = (ventasPorAsesor[asesor] ?? 0) + precio;
      }

      // Convertir a lista y ordenar
      final resultado = ventasPorAsesor.entries
          .map((e) => {'asesor': e.key, 'total': e.value})
          .toList();
      
      resultado.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));
      
      return resultado;
    } catch (e) {
      print('❌ Error al obtener ventas por asesor: $e');
      return [];
    }
  }

  // ✅ Embudo de conversión de clientes
  static Future<Map<String, int>> getEmbudoConversion() async {
    try {
      final clientes = await _client
          .from('clientes')
          .select('etapa');

      Map<String, int> embudo = {
        'Nuevo': 0,
        'Contactado': 0,
        'Propuesta': 0,
        'Negociación': 0,
        'Cerrado': 0,
      };

      for (var cliente in clientes) {
        final etapa = cliente['etapa']?.toString() ?? 'Nuevo';
        if (embudo.containsKey(etapa)) {
          embudo[etapa] = (embudo[etapa] ?? 0) + 1;
        }
      }

      return embudo;
    } catch (e) {
      print('❌ Error al obtener embudo: $e');
      return {'Nuevo': 0, 'Contactado': 0, 'Propuesta': 0, 'Negociación': 0, 'Cerrado': 0};
    }
  }

  // ✅ Ingresos proyectados vs reales
  static Future<Map<String, dynamic>> getIngresosProyectadosVsReales() async {
    try {
      final clientes = await _client
          .from('clientes')
          .select('presupuesto, etapa');

      double ingresosProyectados = 0;
      double ingresosReales = 0;

      for (var cliente in clientes) {
        final presupuesto = _toDouble(cliente['presupuesto']);
        final etapa = cliente['etapa']?.toString() ?? 'Nuevo';
        
        ingresosProyectados += presupuesto;
        
        if (etapa == 'Cerrado') {
          ingresosReales += presupuesto;
        }
      }

      return {
        'proyectados': ingresosProyectados,
        'reales': ingresosReales,
        'diferencia': ingresosProyectados - ingresosReales,
        'porcentajeCierre': ingresosProyectados > 0 
            ? (ingresosReales / ingresosProyectados * 100) 
            : 0,
      };
    } catch (e) {
      print('❌ Error al obtener ingresos: $e');
      return {'proyectados': 0, 'reales': 0, 'diferencia': 0, 'porcentajeCierre': 0};
    }
  }

  // ✅ Top 10 propiedades más visitadas (simulado con clientes interesados)
  static Future<List<Map<String, dynamic>>> getTopPropiedades() async {
    try {
      final clientes = await _client
          .from('clientes')
          .select('catalogo, ubicacion');

      Map<String, int> propiedadesVisitadas = {};

      for (var cliente in clientes) {
        final catalogo = cliente['catalogo']?.toString() ?? '';
        final ubicacion = cliente['ubicacion']?.toString() ?? '';
        
        if (catalogo.isNotEmpty) {
          final key = '$catalogo - $ubicacion';
          propiedadesVisitadas[key] = (propiedadesVisitadas[key] ?? 0) + 1;
        }
      }

      final resultado = propiedadesVisitadas.entries
          .map((e) => {'propiedad': e.key, 'visitas': e.value})
          .toList();
      
      resultado.sort((a, b) => (b['visitas'] as int).compareTo(a['visitas'] as int));
      
      return resultado.take(10).toList();
    } catch (e) {
      print('❌ Error al obtener top propiedades: $e');
      return [];
    }
  }

  // ✅ Estadísticas generales
  static Future<Map<String, dynamic>> getEstadisticasGenerales() async {
    try {
      final totalClientes = await _client.from('clientes').count();
      final totalInmuebles = await _client.from('inmuebles').count();
      final totalAsesores = await _client.from('asesores').count();

      return {
        'totalClientes': totalClientes,
        'totalInmuebles': totalInmuebles,
        'totalAsesores': totalAsesores,
      };
    } catch (e) {
      print(' Error al obtener estadísticas: $e');
      return {'totalClientes': 0, 'totalInmuebles': 0, 'totalAsesores': 0};
    }
  }

  // ✅ Conversión segura
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}