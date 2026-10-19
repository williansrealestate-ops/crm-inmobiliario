import 'dart:convert';
import 'dart:html' as html;
import 'pipeline_service.dart';
import 'finanzas_service.dart';

class AnaliticasService {
  // ✅ Obtener métricas principales (KPIs)
  static Map<String, dynamic> getKPIs() {
    final pipeline = PipelineService.getResumenPipeline();
    final finanzas = FinanzasService.getResumenFinanciero();
    
    final totalOperaciones = pipeline['total'] as int;
    final cerradas = pipeline['cerrado']['cantidad'] as int;
    final tasaConversion = totalOperaciones > 0 ? (cerradas / totalOperaciones) * 100 : 0.0;
    
    final ingresosMes = finanzas['ingresosMes'] as double;
    final metaMes = finanzas['metaMensual'] as double;
    final cumplimientoMeta = metaMes > 0 ? (ingresosMes / metaMes) * 100 : 0.0;

    // Simulación de tiempo promedio de cierre (en días)
    final tiempoPromedioCierre = 45; 
    final ticketPromedio = cerradas > 0 ? (pipeline['cerrado']['valor'] as double) / cerradas : 0.0;

    return {
      'tasaConversion': tasaConversion,
      'cumplimientoMeta': cumplimientoMeta,
      'tiempoPromedioCierre': tiempoPromedioCierre,
      'ticketPromedio': ticketPromedio,
      'operacionesActivas': totalOperaciones - cerradas,
    };
  }

  // ✅ Obtener datos para gráfica de fuentes de leads
  static List<Map<String, dynamic>> getFuentesLeads() {
    // En una app real, esto vendría de un campo 'fuente' en los clientes
    return [
      {'nombre': 'Redes Sociales', 'valor': 35, 'color': '0xFF3B82F6'},
      {'nombre': 'Referidos', 'valor': 25, 'color': '0xFF10B981'},
      {'nombre': 'Portales Inmobiliarios', 'valor': 20, 'color': '0xFFF59E0B'},
      {'nombre': 'Walk-in / Oficina', 'valor': 15, 'color': '0xFF8B5CF6'},
      {'nombre': 'Otros', 'valor': 5, 'color': '0xFF64748B'},
    ];
  }

  // ✅ Obtener datos para proyección de ingresos (últimos 6 meses + proyección)
  static List<Map<String, dynamic>> getProyeccionIngresos() {
    final meses = ['Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final historial = FinanzasService.getHistorialMensual();
    
    // Si hay historial real, lo usamos; si no, generamos datos simulados realistas
    List<double> ingresos = [];
    List<double> proyeccion = [];
    
    for (int i = 0; i < 6; i++) {
      if (i < historial.length) {
        ingresos.add((historial[i]['ingresos'] as double) / 1000); // En miles
      } else {
        ingresos.add(0);
      }
      
      // Proyección: último mes + 10% de crecimiento estimado
      double ultimoIngreso = ingresos.lastWhere((val) => val > 0, orElse: () => 100);
      proyeccion.add(ultimoIngreso * 1.1);
    }

    return List.generate(6, (index) => {
      'mes': meses[index],
      'ingresos': ingresos[index],
      'proyeccion': proyeccion[index],
    });
  }

  // ✅ Obtener conversión por etapa del pipeline
  static List<Map<String, dynamic>> getConversionPorEtapa() {
    final pipeline = PipelineService.getResumenPipeline();
    final etapas = PipelineService.etapas;
    
    return etapas.map((etapa) {
      final etapaId = etapa['id'] as String;
      final datos = pipeline[etapaId] as Map<String, dynamic>;
      final cantidad = (datos['cantidad'] as num).toInt();
      
      // Simulación de tasa de conversión por etapa
      double tasa = 0;
      switch (etapaId) {
        case 'prospecto': tasa = 100; break;
        case 'calificado': tasa = 65; break;
        case 'visita': tasa = 40; break;
        case 'oferta': tasa = 25; break;
        case 'reservado': tasa = 15; break;
        case 'cerrado': tasa = 10; break;
      }
      
      return {
        'nombre': etapa['nombre'],
        'icono': etapa['icono'],
        'cantidad': cantidad,
        'tasa': tasa,
        'color': etapa['color'],
      };
    }).toList();
  }
}