import 'dart:convert';
import 'indexed_db_service.dart';

class CalculadorasService {
  static const String _claveCalculos = 'calculos_guardados';

  // ✅ Calcular comisión
  static Map<String, dynamic> calcularComision({
    required double precioVenta,
    required double porcentajeComision,
    double iva = 16,
  }) {
    final comisionBruta = precioVenta * (porcentajeComision / 100);
    final ivaCalculado = comisionBruta * (iva / 100);
    final comisionNeta = comisionBruta - ivaCalculado;

    return {
      'precioVenta': precioVenta,
      'porcentajeComision': porcentajeComision,
      'comisionBruta': comisionBruta,
      'iva': ivaCalculado,
      'comisionNeta': comisionNeta,
    };
  }

  // ✅ Calcular hipoteca
  static Map<String, dynamic> calcularHipoteca({
    required double precioPropiedad,
    required double enganche,
    required double tasaAnual,
    required int plazoAnios,
  }) {
    final montoPrestamo = precioPropiedad - enganche;
    final tasaMensual = tasaAnual / 100 / 12;
    final numeroPagos = plazoAnios * 12;

    double pagoMensual = 0;
    if (tasaMensual > 0) {
      pagoMensual = montoPrestamo * (tasaMensual * _pow(1 + tasaMensual, numeroPagos)) / (_pow(1 + tasaMensual, numeroPagos) - 1);
    } else {
      pagoMensual = montoPrestamo / numeroPagos;
    }

    final totalPagar = pagoMensual * numeroPagos;
    final totalIntereses = totalPagar - montoPrestamo;

    return {
      'montoPrestamo': montoPrestamo,
      'pagoMensual': pagoMensual,
      'totalPagar': totalPagar,
      'totalIntereses': totalIntereses,
      'numeroPagos': numeroPagos,
    };
  }

  // ✅ Calcular ROI
  static Map<String, dynamic> calcularROI({
    required double inversionInicial,
    required double ingresoAnual,
    required double gastosAnuales,
    int periodoAnios = 1,
  }) {
    final gananciaNeta = (ingresoAnual - gastosAnuales) * periodoAnios;
    final roi = (gananciaNeta / inversionInicial) * 100;
    final roiAnual = roi / periodoAnios;
    final paybackPeriod = inversionInicial / (ingresoAnual - gastosAnuales);

    return {
      'inversionInicial': inversionInicial,
      'gananciaNeta': gananciaNeta,
      'roi': roi,
      'roiAnual': roiAnual,
      'paybackPeriod': paybackPeriod,
    };
  }

  // ✅ Guardar cálculo
  static Future<void> guardarCalculo(Map<String, dynamic> calculo) async {
    final calculos = await getCalculos();
    calculo['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    calculo['fecha'] = DateTime.now().toIso8601String();
    calculos.add(calculo);
    await IndexedDBService.put(_claveCalculos, jsonEncode(calculos));
  }

  // ✅ Obtener cálculos guardados
  static Future<List<Map<String, dynamic>>> getCalculos() async {
    try {
      final json = await IndexedDBService.get(_claveCalculos);
      if (json != null) {
        final datos = jsonDecode(json) as List;
        return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error al obtener cálculos: $e');
    }
    return [];
  }

  // ✅ Eliminar cálculo
  static Future<void> eliminarCalculo(String id) async {
    final calculos = (await getCalculos()).where((c) => c['id'] != id).toList();
    await IndexedDBService.put(_claveCalculos, jsonEncode(calculos));
  }

  // Helper para potencia
  static double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}