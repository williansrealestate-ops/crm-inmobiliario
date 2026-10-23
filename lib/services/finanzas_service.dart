import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinanzasService {
  static const String _keyIngresos = 'finanzas_ingresos';
  static const String _keyGastos = 'finanzas_gastos';
  static const String _keyMetas = 'finanzas_metas';
  static const String _keyNegocios = 'finanzas_negocios';

  // Negocios por defecto
  static final List<Map<String, dynamic>> _negociosDefault = [
    {'id': 'inmobiliario', 'nombre': 'Inmobiliario', 'icono': 'home', 'color': '0xFF3B82F6', 'presupuesto': 50000},
    {'id': 'minerales', 'nombre': 'Minerales', 'icono': 'mineral', 'color': '0xFF64748B', 'presupuesto': 30000},
    {'id': 'combustible', 'nombre': 'Combustible', 'icono': 'local_gas_station', 'color': '0xFFEF4444', 'presupuesto': 40000},
    {'id': 'agropecuario', 'nombre': 'Agropecuario', 'icono': 'agriculture', 'color': '0xFF10B981', 'presupuesto': 20000},
    {'id': 'proyectos', 'nombre': 'Proyectos', 'icono': 'engineering', 'color': '0xFFF59E0B', 'presupuesto': 60000},
    {'id': 'otros', 'nombre': 'Otros', 'icono': 'more_horiz', 'color': '0xFF6366F1', 'presupuesto': 10000},
  ];

  static Future<List<Map<String, dynamic>>> getNegocios() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyNegocios);
    if (data == null) {
      await prefs.setString(_keyNegocios, jsonEncode(_negociosDefault));
      return _negociosDefault;
    }
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> actualizarPresupuestoNegocio(String negocioId, double nuevoPresupuesto) async {
    final negocios = await getNegocios();
    final index = negocios.indexWhere((n) => n['id'] == negocioId);
    if (index != -1) {
      negocios[index]['presupuesto'] = nuevoPresupuesto;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyNegocios, jsonEncode(negocios));
    }
  }

  static Future<List<Map<String, dynamic>>> getIngresos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyIngresos);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> getGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyGastos);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> agregarIngreso(Map<String, dynamic> ingreso) async {
    final ingresos = await getIngresos();
    ingreso['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    ingreso['fecha'] = DateTime.now().toIso8601String();
    ingresos.insert(0, ingreso);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIngresos, jsonEncode(ingresos));
  }

  static Future<void> agregarGasto(Map<String, dynamic> gasto) async {
    final gastos = await getGastos();
    gasto['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    gasto['fecha'] = DateTime.now().toIso8601String();
    gastos.insert(0, gasto);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGastos, jsonEncode(gastos));
  }

  static Future<void> eliminarIngreso(String id) async {
    final ingresos = await getIngresos();
    ingresos.removeWhere((i) => i['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIngresos, jsonEncode(ingresos));
  }

  static Future<void> eliminarGasto(String id) async {
    final gastos = await getGastos();
    gastos.removeWhere((g) => g['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGastos, jsonEncode(gastos));
  }

  static Future<Map<String, dynamic>> getResumenFinanciero() async {
    final ingresos = await getIngresos();
    final gastos = await getGastos();
    final metas = await getMetas();
    final now = DateTime.now();
    
    double ingresosMes = 0, gastosMes = 0, ingresosAnio = 0, gastosAnio = 0;

    for (var ing in ingresos) {
      final fecha = DateTime.parse(ing['fecha']);
      final monto = (ing['monto'] ?? 0).toDouble();
      if (fecha.month == now.month && fecha.year == now.year) ingresosMes += monto;
      if (fecha.year == now.year) ingresosAnio += monto;
    }

    for (var gas in gastos) {
      final fecha = DateTime.parse(gas['fecha']);
      final monto = (gas['monto'] ?? 0).toDouble();
      if (fecha.month == now.month && fecha.year == now.year) gastosMes += monto;
      if (fecha.year == now.year) gastosAnio += monto;
    }

    return {
      'ingresosMes': ingresosMes,
      'gastosMes': gastosMes,
      'utilidadMes': ingresosMes - gastosMes,
      'ingresosAnio': ingresosAnio,
      'gastosAnio': gastosAnio,
      'utilidadAnio': ingresosAnio - gastosAnio,
      'metaMensual': metas['metaMensual'] ?? 100000.0,
      'metaAnual': metas['metaAnual'] ?? 1200000.0,
    };
  }

  static Future<Map<String, double>> getGastosPorCategoria() async {
    final gastos = await getGastos();
    final now = DateTime.now();
    Map<String, double> categorias = {};

    for (var gas in gastos) {
      final fecha = DateTime.parse(gas['fecha']);
      if (fecha.month == now.month && fecha.year == now.year) {
        final cat = gas['categoria'] ?? 'Otros';
        categorias[cat] = (categorias[cat] ?? 0) + (gas['monto'] ?? 0).toDouble();
      }
    }
    return categorias;
  }

  static Future<Map<String, double>> getIngresosPorNegocio() async {
    final ingresos = await getIngresos();
    final now = DateTime.now();
    Map<String, double> negocios = {};

    for (var ing in ingresos) {
      final fecha = DateTime.parse(ing['fecha']);
      if (fecha.month == now.month && fecha.year == now.year) {
        final neg = ing['negocioId'] ?? 'otros';
        negocios[neg] = (negocios[neg] ?? 0) + (ing['monto'] ?? 0).toDouble();
      }
    }
    return negocios;
  }

  static Future<Map<String, dynamic>> getMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyMetas);
    if (data == null) return {'metaMensual': 100000.0, 'metaAnual': 1200000.0};
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  static Future<void> guardarMetas(Map<String, dynamic> metas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMetas, jsonEncode(metas));
  }
}