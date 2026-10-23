import 'dart:convert';
import 'dart:html' as html;

class ComisionesService {
  static const String _keyComisiones = 'comisiones_datos';
  static const String _keyConfig = 'comisiones_config';

  // ✅ Configuración por defecto
  static Map<String, dynamic> getConfig() {
    try {
      final json = html.window.localStorage[_keyConfig];
      if (json != null) return Map<String, dynamic>.from(jsonDecode(json));
    } catch (e) {}
    return {
      'porcentajeBase': 3.0,
      'porcentajeAltoValor': 4.0,
      'umbralAltoValor': 2000000,
      'splitAsesor': 70,
      'splitAgencia': 30,
    };
  }

  static void guardarConfig(Map<String, dynamic> config) {
    html.window.localStorage[_keyConfig] = jsonEncode(config);
  }

  // ✅ Calcular comisión de una operación
  static Map<String, dynamic> calcularComision({
    required double valorOperacion,
    required String asesor,
    required String tipoOperacion,
  }) {
    final config = getConfig();
    final umbral = (config['umbralAltoValor'] as num).toDouble();
    final porcentajeBase = (config['porcentajeBase'] as num).toDouble();
    final porcentajeAlto = (config['porcentajeAltoValor'] as num).toDouble();
    final splitAsesor = (config['splitAsesor'] as num).toDouble();

    // Determinar porcentaje según valor
    final porcentaje = valorOperacion >= umbral ? porcentajeAlto : porcentajeBase;
    final comisionTotal = valorOperacion * (porcentaje / 100);
    final comisionAsesor = comisionTotal * (splitAsesor / 100);
    final comisionAgencia = comisionTotal - comisionAsesor;

    // Bono por tipo de operación
    double bono = 0;
    if (tipoOperacion == 'Renta') bono = 5000;
    if (tipoOperacion == 'Venta' && valorOperacion >= umbral) bono = 10000;

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'valorOperacion': valorOperacion,
      'porcentaje': porcentaje,
      'comisionTotal': comisionTotal,
      'comisionAsesor': comisionAsesor,
      'comisionAgencia': comisionAgencia,
      'bono': bono,
      'totalPagar': comisionAsesor + bono,
      'asesor': asesor,
      'tipoOperacion': tipoOperacion,
      'fecha': DateTime.now().toIso8601String(),
      'estado': 'pendiente',
    };
  }

  // ✅ Guardar comisión
  static void guardarComision(Map<String, dynamic> comision) {
    final comisiones = getComisiones();
    comisiones.add(comision);
    html.window.localStorage[_keyComisiones] = jsonEncode(comisiones);
  }

  // ✅ Obtener todas las comisiones
  static List<Map<String, dynamic>> getComisiones() {
    try {
      final json = html.window.localStorage[_keyComisiones];
      if (json != null) {
        return (jsonDecode(json) as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {}
    return [];
  }

  // ✅ Obtener comisiones por asesor
  static List<Map<String, dynamic>> getComisionesPorAsesor(String asesor) {
    return getComisiones().where((c) => c['asesor'] == asesor).toList();
  }

  // ✅ Obtener comisiones por estado
  static List<Map<String, dynamic>> getComisionesPorEstado(String estado) {
    return getComisiones().where((c) => c['estado'] == estado).toList();
  }

  // ✅ Actualizar estado de comisión
  static void actualizarEstado(String id, String estado) {
    final comisiones = getComisiones();
    final index = comisiones.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      comisiones[index]['estado'] = estado;
      if (estado == 'pagada') {
        comisiones[index]['fechaPago'] = DateTime.now().toIso8601String();
      }
      html.window.localStorage[_keyComisiones] = jsonEncode(comisiones);
    }
  }

  // ✅ Eliminar comisión
  static void eliminarComision(String id) {
    final comisiones = getComisiones().where((c) => c['id'] != id).toList();
    html.window.localStorage[_keyComisiones] = jsonEncode(comisiones);
  }

  // ✅ Estadísticas generales
  static Map<String, dynamic> getEstadisticas() {
    final comisiones = getComisiones();
    final total = comisiones.fold<double>(0, (sum, c) => sum + (c['comisionTotal'] as num).toDouble());
    final pagadas = comisiones.where((c) => c['estado'] == 'pagada').fold<double>(0, (sum, c) => sum + (c['totalPagar'] as num).toDouble());
    final pendientes = comisiones.where((c) => c['estado'] == 'pendiente').fold<double>(0, (sum, c) => sum + (c['totalPagar'] as num).toDouble());
    final esteMes = comisiones.where((c) {
      final fecha = DateTime.parse(c['fecha']);
      final ahora = DateTime.now();
      return fecha.month == ahora.month && fecha.year == ahora.year;
    }).fold<double>(0, (sum, c) => sum + (c['comisionTotal'] as num).toDouble());

    return {
      'total': total,
      'pagadas': pagadas,
      'pendientes': pendientes,
      'esteMes': esteMes,
      'cantidad': comisiones.length,
      'cantidadPagadas': comisiones.where((c) => c['estado'] == 'pagada').length,
      'cantidadPendientes': comisiones.where((c) => c['estado'] == 'pendiente').length,
    };
  }

  // ✅ Formatear moneda
  static String formatearMoneda(double valor) {
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(2)} M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(1)} K';
    return '\$${valor.toStringAsFixed(0)}';
  }
}