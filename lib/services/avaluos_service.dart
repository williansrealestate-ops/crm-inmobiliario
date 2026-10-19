import 'dart:convert';
import 'dart:html' as html;

class AvaluosService {
  static const String _keyAvaluos = 'avaluos_profesionales';

  // Tipos de propiedad
  static const List<Map<String, dynamic>> tiposPropiedad = [
    {'id': 'casa', 'nombre': 'Casa Habitación', 'icono': ''},
    {'id': 'departamento', 'nombre': 'Departamento', 'icono': '🏢'},
    {'id': 'terreno', 'nombre': 'Terreno', 'icono': '🌳'},
    {'id': 'local', 'nombre': 'Local Comercial', 'icono': '🏪'},
    {'id': 'oficina', 'nombre': 'Oficina', 'icono': '💼'},
    {'id': 'bodega', 'nombre': 'Bodega/Industrial', 'icono': '🏭'},
  ];

  // Métodos de valuación
  static const List<Map<String, dynamic>> metodosValuacion = [
    {'id': 'comparativo', 'nombre': 'Comparativo de Mercado', 'descripcion': 'Compara con propiedades similares vendidas'},
    {'id': 'capitalizacion', 'nombre': 'Capitalización de Rentas', 'descripcion': 'Basado en ingresos por renta'},
    {'id': 'costo', 'nombre': 'Costo de Reposición', 'descripcion': 'Costo de construcción menos depreciación'},
  ];

  static List<Map<String, dynamic>> getAvaluos() {
    try {
      final json = html.window.localStorage[_keyAvaluos];
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

  static void guardarAvaluos(List<Map<String, dynamic>> avaluos) {
    try {
      html.window.localStorage[_keyAvaluos] = jsonEncode(avaluos);
    } catch (e) {
      print('Error: $e');
    }
  }

  static void agregarAvaluo(Map<String, dynamic> avaluo) {
    final avaluos = getAvaluos();
    avaluo['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    avaluo['fechaCreacion'] = DateTime.now().toIso8601String();
    avaluo['fechaAvaluo'] = DateTime.now().toIso8601String();
    avaluos.add(avaluo);
    guardarAvaluos(avaluos);
  }

  static void actualizarAvaluo(String id, Map<String, dynamic> cambios) {
    final avaluos = getAvaluos();
    final index = avaluos.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      avaluos[index].addAll(cambios);
      guardarAvaluos(avaluos);
    }
  }

  static void eliminarAvaluo(String id) {
    final avaluos = getAvaluos().where((a) => a['id'] != id).toList();
    guardarAvaluos(avaluos);
  }

  static Map<String, dynamic>? getAvaluo(String id) {
    final avaluos = getAvaluos();
    try {
      return avaluos.firstWhere((a) => a['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ Cálculo de avalúo por método comparativo
  static double calcularComparativo({
    required List<Map<String, dynamic>> comparables,
    required double areaTerreno,
    required double areaConstruccion,
  }) {
    if (comparables.isEmpty) return 0;

    double sumaValoresAjustados = 0;
    int comparablesValidos = 0;

    for (var comp in comparables) {
      double valor = comp['valorVenta'] ?? 0;
      if (valor <= 0) continue;

      // Ajuste por área de terreno
      if (areaTerreno > 0 && comp['areaTerreno'] > 0) {
        double factorArea = areaTerreno / comp['areaTerreno'];
        valor *= factorArea;
      }

      // Ajuste por área de construcción
      if (areaConstruccion > 0 && comp['areaConstruccion'] > 0) {
        double factorConst = areaConstruccion / comp['areaConstruccion'];
        valor *= factorConst;
      }

      // Ajuste por ubicación (factor de 0.9 a 1.1)
      double factorUbicacion = comp['factorUbicacion'] ?? 1.0;
      valor *= factorUbicacion;

      // Ajuste por antigüedad
      int antiguedad = comp['antiguedad'] ?? 0;
      double factorAntiguedad = 1.0 - (antiguedad * 0.02); // 2% por año
      if (factorAntiguedad < 0.7) factorAntiguedad = 0.7;
      valor *= factorAntiguedad;

      // Ajuste por acabados (0.9 básico, 1.0 medio, 1.15 lujo)
      double factorAcabados = comp['factorAcabados'] ?? 1.0;
      valor *= factorAcabados;

      sumaValoresAjustados += valor;
      comparablesValidos++;
    }

    if (comparablesValidos == 0) return 0;
    return sumaValoresAjustados / comparablesValidos;
  }

  // ✅ Cálculo por capitalización de rentas
  static double calcularCapitalizacion({
    required double rentaMensual,
    required double tasaCapitalizacion,
  }) {
    if (rentaMensual <= 0 || tasaCapitalizacion <= 0) return 0;
    double rentaAnual = rentaMensual * 12;
    return rentaAnual / (tasaCapitalizacion / 100);
  }

  // ✅ Cálculo por costo de reposición
  static double calcularCosto({
    required double valorTerreno,
    required double areaConstruccion,
    required double costoPorM2,
    required int antiguedad,
  }) {
    if (areaConstruccion <= 0 || costoPorM2 <= 0) return valorTerreno;
    
    double costoConstruccion = areaConstruccion * costoPorM2;
    double depreciacion = costoConstruccion * (antiguedad * 0.02); // 2% por año
    if (depreciacion > costoConstruccion * 0.5) depreciacion = costoConstruccion * 0.5; // Máx 50%
    
    return valorTerreno + (costoConstruccion - depreciacion);
  }

  // ✅ Generar reporte de avalúo
  static String generarReporte(Map<String, dynamic> avaluo) {
    final tipo = tiposPropiedad.firstWhere((t) => t['id'] == avaluo['tipoPropiedad'], orElse: () => {'nombre': 'No especificado', 'icono': '🏠'});
    final metodo = metodosValuacion.firstWhere((m) => m['id'] == avaluo['metodoValuacion'], orElse: () => {'nombre': 'No especificado'});
    final valorAvaluo = avaluo['valorAvaluo'] ?? 0;
    final fecha = DateTime.parse(avaluo['fechaAvaluo'] ?? DateTime.now().toIso8601String());

    String reporte = '''
═══════════════════════════════════════════════════════════
                    REPORTE DE AVALÚO PROFESIONAL
═══════════════════════════════════════════════════════════

📋 DATOS GENERALES
Fecha de avalúo: ${fecha.day}/${fecha.month}/${fecha.year}
Tipo de propiedad: ${tipo['icono']} ${tipo['nombre']}
Método de valuación: ${metodo['nombre']}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 UBICACIÓN
Dirección: ${avaluo['direccion'] ?? 'No especificada'}
Colonia: ${avaluo['colonia'] ?? 'No especificada'}
Ciudad: ${avaluo['ciudad'] ?? 'No especificada'}
Estado: ${avaluo['estado'] ?? 'No especificada'}
Código Postal: ${avaluo['codigoPostal'] ?? 'No especificado'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏗️ CARACTERÍSTICAS FÍSICAS
''';

    if (avaluo['areaTerreno'] != null) {
      reporte += '• Área de terreno: ${avaluo['areaTerreno']} m²\n';
    }
    if (avaluo['areaConstruccion'] != null) {
      reporte += '• Área de construcción: ${avaluo['areaConstruccion']} m²\n';
    }
    if (avaluo['antiguedad'] != null) {
      reporte += '• Antigüedad: ${avaluo['antiguedad']} años\n';
    }
    if (avaluo['habitaciones'] != null) {
      reporte += '• Habitaciones: ${avaluo['habitaciones']}\n';
    }
    if (avaluo['banos'] != null) {
      reporte += '• Baños: ${avaluo['banos']}\n';
    }
    if (avaluo['estacionamientos'] != null) {
      reporte += '• Estacionamientos: ${avaluo['estacionamientos']}\n';
    }

    reporte += '''

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💰 VALUACIÓN
''';

    if (avaluo['metodoValuacion'] == 'comparativo') {
      reporte += 'Método: Comparativo de Mercado\n';
      reporte += 'Número de comparables: ${(avaluo['comparables'] as List?)?.length ?? 0}\n';
      if (avaluo['comparables'] != null) {
        reporte += '\nPropiedades comparables:\n';
        for (var comp in avaluo['comparables'] as List) {
          reporte += '• ${comp['direccion']}: \$${_formatearNumero(comp['valorVenta'] ?? 0)}\n';
        }
      }
    } else if (avaluo['metodoValuacion'] == 'capitalizacion') {
      reporte += 'Método: Capitalización de Rentas\n';
      reporte += 'Renta mensual: \$${_formatearNumero(avaluo['rentaMensual'] ?? 0)}\n';
      reporte += 'Tasa de capitalización: ${avaluo['tasaCapitalizacion']}%\n';
      reporte += 'Renta anual: \$${_formatearNumero((avaluo['rentaMensual'] ?? 0) * 12)}\n';
    } else if (avaluo['metodoValuacion'] == 'costo') {
      reporte += 'Método: Costo de Reposición\n';
      reporte += 'Valor del terreno: \$${_formatearNumero(avaluo['valorTerreno'] ?? 0)}\n';
      reporte += 'Costo por m²: \$${_formatearNumero(avaluo['costoPorM2'] ?? 0)}\n';
      reporte += 'Depreciación: ${avaluo['antiguedad']} años\n';
    }

    reporte += '''

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 VALOR ESTIMADO

VALOR DE AVALÚO: \$${_formatearNumero(valorAvaluo)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 OBSERVACIONES
${avaluo['observaciones'] ?? 'Sin observaciones adicionales'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ DISCLAIMER
Este avalúo es una estimación basada en los datos proporcionados y los métodos de valuación aplicados. 
No constituye un avalúo oficial certificado. Para fines legales o fiscales, se recomienda contratar 
un perito valuador certificado.

═══════════════════════════════════════════════════════════
                    Fin del Reporte
═══════════════════════════════════════════════════════════
''';

    return reporte;
  }

  static String _formatearNumero(double valor) {
    return valor.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}