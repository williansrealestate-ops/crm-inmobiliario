import 'dart:convert';
import 'indexed_db_service.dart';

class FinanzasService {
  static const String _claveTransacciones = 'transacciones_financieras';

  // ✅ Obtener transacciones
  static Future<List<Map<String, dynamic>>> getTransacciones() async {
    try {
      final json = await IndexedDBService.get(_claveTransacciones);
      if (json != null) {
        final datos = jsonDecode(json) as List;
        return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error al obtener transacciones: $e');
    }
    return [];
  }

  // ✅ Guardar transacciones
  static Future<void> guardarTransacciones(List<Map<String, dynamic>> transacciones) async {
    await IndexedDBService.put(_claveTransacciones, jsonEncode(transacciones));
  }

  // ✅ Agregar transacción
  static Future<void> agregarTransaccion(Map<String, dynamic> transaccion) async {
    final transacciones = await getTransacciones();
    transaccion['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    transaccion['fecha'] = transaccion['fecha'] ?? DateTime.now().toIso8601String().split('T')[0];
    transacciones.add(transaccion);
    await guardarTransacciones(transacciones);
  }

  // ✅ Actualizar transacción
  static Future<void> actualizarTransaccion(String id, Map<String, dynamic> datos) async {
    final transacciones = await getTransacciones();
    final index = transacciones.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      transacciones[index].addAll(datos);
      await guardarTransacciones(transacciones);
    }
  }

  // ✅ Eliminar transacción
  static Future<void> eliminarTransaccion(String id) async {
    final transacciones = (await getTransacciones()).where((t) => t['id'] != id).toList();
    await guardarTransacciones(transacciones);
  }

  // ✅ Obtener resumen financiero
  static Future<Map<String, dynamic>> getResumen() async {
    final transacciones = await getTransacciones();
    
    double ingresos = 0;
    double gastos = 0;
    
    for (var t in transacciones) {
      final monto = (t['monto'] ?? 0) as num;
      if (t['tipo'] == 'Ingreso') {
        ingresos += monto.toDouble();
      } else if (t['tipo'] == 'Gasto') {
        gastos += monto.toDouble();
      }
    }
    
    final flujoCaja = ingresos - gastos;
    
    return {
      'ingresos': ingresos,
      'gastos': gastos,
      'flujoCaja': flujoCaja,
      'totalTransacciones': transacciones.length,
    };
  }

  // ✅ Filtrar por mes
  static Future<List<Map<String, dynamic>>> getTransaccionesPorMes(int year, int month) async {
    final transacciones = await getTransacciones();
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    return transacciones.where((t) => (t['fecha'] ?? '').toString().startsWith(prefix)).toList();
  }
}