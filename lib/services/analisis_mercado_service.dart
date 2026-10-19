import '../services/local_storage_service.dart';

class AnalisisMercadoService {
  // ✅ Obtener todas las zonas disponibles
  static List<String> getZonasDisponibles() {
    final inmuebles = LocalStorageService.getInmuebles();
    final zonas = inmuebles
        .map((i) => (i['ubicacion'] ?? 'Sin ubicación').toString())
        .where((z) => z.isNotEmpty && z != 'Sin ubicación')
        .toSet()
        .toList();
    zonas.sort();
    return zonas;
  }

  // ✅ Obtener propiedades de una zona específica
  static List<Map<String, dynamic>> getPropiedadesPorZona(String zona) {
    return LocalStorageService.getInmuebles()
        .where((i) => (i['ubicacion'] ?? '').toString().toLowerCase() == zona.toLowerCase())
        .toList();
  }

  // ✅ Obtener propiedades similares (misma zona y tipo)
  static List<Map<String, dynamic>> getPropiedadesSimilares(String zona, String tipo) {
    return LocalStorageService.getInmuebles()
        .where((i) => 
          (i['ubicacion'] ?? '').toString().toLowerCase() == zona.toLowerCase() &&
          (i['tipo'] ?? '').toString().toLowerCase() == tipo.toLowerCase()
        )
        .toList();
  }

  // ✅ Calcular estadísticas de una lista de propiedades
  static Map<String, dynamic> calcularEstadisticas(List<Map<String, dynamic>> propiedades) {
    if (propiedades.isEmpty) {
      return {
        'cantidad': 0,
        'precioPromedio': 0.0,
        'precioMediana': 0.0,
        'precioMin': 0.0,
        'precioMax': 0.0,
        'precioPorM2': 0.0,
        'areaPromedio': 0.0,
      };
    }

    final precios = propiedades
        .map((p) => _toDouble(p['precio']))
        .where((p) => p > 0)
        .toList();
    final areas = propiedades
        .map((p) => _toDouble(p['area']))
        .where((a) => a > 0)
        .toList();

    if (precios.isEmpty) {
      return {
        'cantidad': propiedades.length,
        'precioPromedio': 0.0,
        'precioMediana': 0.0,
        'precioMin': 0.0,
        'precioMax': 0.0,
        'precioPorM2': 0.0,
        'areaPromedio': areas.isEmpty ? 0.0 : areas.reduce((a, b) => a + b) / areas.length,
      };
    }

    precios.sort();
    final total = precios.reduce((a, b) => a + b);
    final promedio = total / precios.length;
    final mediana = precios.length % 2 == 0
        ? (precios[precios.length ~/ 2 - 1] + precios[precios.length ~/ 2]) / 2
        : precios[precios.length ~/ 2];

    final areaTotal = areas.isEmpty ? 0 : areas.reduce((a, b) => a + b);
    final precioPorM2 = areaTotal > 0 ? total / areaTotal : 0.0;

    return {
      'cantidad': propiedades.length,
      'precioPromedio': promedio,
      'precioMediana': mediana,
      'precioMin': precios.first,
      'precioMax': precios.last,
      'precioPorM2': precioPorM2,
      'areaPromedio': areas.isEmpty ? 0.0 : areaTotal / areas.length,
    };
  }

  // ✅ Recomendar precio para una propiedad
  static Map<String, dynamic> recomendarPrecio({
    required String zona,
    required String tipo,
    required double area,
    required double precioPropuesto,
  }) {
    final similares = getPropiedadesSimilares(zona, tipo);
    final stats = calcularEstadisticas(similares);
    
    if (similares.isEmpty) {
      return {
        'precioRecomendado': precioPropuesto,
        'rangoMin': precioPropuesto * 0.9,
        'rangoMax': precioPropuesto * 1.1,
        'diferencia': 0.0,
        'porcentajeDiferencia': 0.0,
        'evaluacion': 'Sin datos comparables en esta zona',
        'color': 'gris',
        'confianza': 'baja',
      };
    }

    final precioPorM2Zona = stats['precioPorM2'] as double;
    final precioRecomendado = precioPorM2Zona * area;
    final diferencia = precioPropuesto - precioRecomendado;
    final porcentajeDiferencia = precioRecomendado > 0 ? (diferencia / precioRecomendado) * 100 : 0;

    String evaluacion;
    String color;
    if (porcentajeDiferencia > 10) {
      evaluacion = 'Precio sobre el mercado';
      color = 'rojo';
    } else if (porcentajeDiferencia < -10) {
      evaluacion = 'Precio bajo el mercado';
      color = 'naranja';
    } else {
      evaluacion = 'Precio competitivo';
      color = 'verde';
    }

    return {
      'precioRecomendado': precioRecomendado,
      'rangoMin': precioRecomendado * 0.9,
      'rangoMax': precioRecomendado * 1.1,
      'diferencia': diferencia,
      'porcentajeDiferencia': porcentajeDiferencia,
      'evaluacion': evaluacion,
      'color': color,
      'confianza': similares.length >= 3 ? 'alta' : 'media',
      'cantidadComparables': similares.length,
    };
  }

  // ✅ Obtener distribución de precios por zona (para gráfica)
  static List<Map<String, dynamic>> getDistribucionPreciosPorZona() {
    final zonas = getZonasDisponibles();
    return zonas.map((zona) {
      final props = getPropiedadesPorZona(zona);
      final stats = calcularEstadisticas(props);
      return {
        'zona': zona,
        'promedio': stats['precioPromedio'],
        'cantidad': stats['cantidad'],
        'color': _getColorPorZona(zona),
      };
    }).toList();
  }

  // ✅ Obtener top zonas por valor promedio
  static List<Map<String, dynamic>> getTopZonas() {
    final distribucion = getDistribucionPreciosPorZona();
    distribucion.sort((a, b) => (b['promedio'] as double).compareTo(a['promedio'] as double));
    return distribucion.take(5).toList();
  }

  // ✅ Formatear moneda
  static String formatearMoneda(double valor) {
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(2)} M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)} K';
    return '\$${valor.toStringAsFixed(0)}';
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  static String _getColorPorZona(String zona) {
    final colores = [
      '0xFF3B82F6', '0xFF10B981', '0xFFF59E0B', '0xFF8B5CF6',
      '0xFFEC4899', '0xFF06B6D4', '0xFFEF4444', '0xFF14B8A6',
    ];
    final index = zona.hashCode.abs() % colores.length;
    return colores[index];
  }
}