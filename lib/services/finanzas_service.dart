import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FinanzasService {
  static const String _keyIngresos = 'finanzas_ingresos';
  static const String _keyGastos = 'finanzas_gastos';
  static const String _keyMetas = 'finanzas_metas';
  static const String _keyNegocios = 'finanzas_negocios';
  static const String _keyOperaciones = 'finanzas_operaciones';

  static final List<Map<String, dynamic>> _negociosDefault = [
    {'id': 'inmobiliario', 'nombre': 'Inmobiliario', 'icono': 'home', 'color': '0xFF3B82F6', 'presupuesto': 50000},
    {'id': 'minerales', 'nombre': 'Minerales', 'icono': 'mineral', 'color': '0xFFF59E0B', 'presupuesto': 30000},
    {'id': 'combustible', 'nombre': 'Combustible', 'icono': 'local_gas_station', 'color': '0xFF10B981', 'presupuesto': 40000},
    {'id': 'agropecuario', 'nombre': 'Agropecuario', 'icono': 'agriculture', 'color': '0xFF22C55E', 'presupuesto': 20000},
    {'id': 'proyectos', 'nombre': 'Proyectos', 'icono': 'engineering', 'color': '0xFF8B5CF6', 'presupuesto': 60000},
    {'id': 'otros', 'nombre': 'Otros', 'icono': 'more_horiz', 'color': '0xFF6366F1', 'presupuesto': 10000},
  ];

  static final List<Map<String, dynamic>> _operacionesDefault = [
    {'id': 'compra_venta', 'nombre': 'Compra/Venta', 'icono': 'swap_horiz', 'color': '0xFF3B82F6', 'presupuesto': 100000},
    {'id': 'renta', 'nombre': 'Renta', 'icono': 'home', 'color': '0xFF10B981', 'presupuesto': 50000},
    {'id': 'desarrollo', 'nombre': 'Desarrollo', 'icono': 'construction', 'color': '0xFFF59E0B', 'presupuesto': 200000},
    {'id': 'asesoria', 'nombre': 'Asesoría', 'icono': 'psychology', 'color': '0xFF8B5CF6', 'presupuesto': 30000},
    {'id': 'administracion', 'nombre': 'Administración', 'icono': 'admin_panel_settings', 'color': '0xFF06B6D4', 'presupuesto': 40000},
  ];

  // ============ NEGOCIOS ============
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

  // ============ OPERACIONES ============
  static Future<List<Map<String, dynamic>>> getOperaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyOperaciones);
    if (data == null) {
      await prefs.setString(_keyOperaciones, jsonEncode(_operacionesDefault));
      return _operacionesDefault;
    }
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> agregarOperacion(Map<String, dynamic> operacion) async {
    final operaciones = await getOperaciones();
    operacion['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    operaciones.insert(0, operacion);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOperaciones, jsonEncode(operaciones));
  }

  static Future<void> actualizarOperacion(Map<String, dynamic> operacion) async {
    final operaciones = await getOperaciones();
    final index = operaciones.indexWhere((o) => o['id'] == operacion['id']);
    if (index != -1) {
      operaciones[index] = {...operaciones[index], ...operacion};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyOperaciones, jsonEncode(operaciones));
    }
  }

  static Future<void> eliminarOperacion(String id) async {
    final operaciones = await getOperaciones();
    operaciones.removeWhere((o) => o['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOperaciones, jsonEncode(operaciones));
  }

  static Future<void> actualizarPresupuestoOperacion(String operacionId, double nuevoPresupuesto) async {
    final operaciones = await getOperaciones();
    final index = operaciones.indexWhere((o) => o['id'] == operacionId);
    if (index != -1) {
      operaciones[index]['presupuesto'] = nuevoPresupuesto;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyOperaciones, jsonEncode(operaciones));
    }
  }

  // ============ INGRESOS ============
  static Future<List<Map<String, dynamic>>> getIngresos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyIngresos);
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

  static Future<void> actualizarIngreso(Map<String, dynamic> ingreso) async {
    final ingresos = await getIngresos();
    final index = ingresos.indexWhere((i) => i['id'] == ingreso['id']);
    if (index != -1) {
      ingresos[index] = {...ingresos[index], ...ingreso};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyIngresos, jsonEncode(ingresos));
    }
  }

  static Future<void> eliminarIngreso(String id) async {
    final ingresos = await getIngresos();
    ingresos.removeWhere((i) => i['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIngresos, jsonEncode(ingresos));
  }

  // ============ GASTOS ============
  static Future<List<Map<String, dynamic>>> getGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyGastos);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> agregarGasto(Map<String, dynamic> gasto) async {
    final gastos = await getGastos();
    gasto['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    gasto['fecha'] = DateTime.now().toIso8601String();
    gastos.insert(0, gasto);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGastos, jsonEncode(gastos));
  }

  static Future<void> actualizarGasto(Map<String, dynamic> gasto) async {
    final gastos = await getGastos();
    final index = gastos.indexWhere((g) => g['id'] == gasto['id']);
    if (index != -1) {
      gastos[index] = {...gastos[index], ...gasto};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyGastos, jsonEncode(gastos));
    }
  }

  static Future<void> eliminarGasto(String id) async {
    final gastos = await getGastos();
    gastos.removeWhere((g) => g['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGastos, jsonEncode(gastos));
  }

  // ============ RESUMEN (con filtro de operación) ============
  static Future<Map<String, dynamic>> getResumenFinanciero({String? operacionId}) async {
    final ingresos = await getIngresos();
    final gastos = await getGastos();
    final metas = await getMetas();
    final now = DateTime.now();
    
    double ingresosMes = 0, gastosMes = 0, ingresosAnio = 0, gastosAnio = 0;

    for (var ing in ingresos) {
      if (operacionId != null && ing['operacionId'] != operacionId) continue;
      final fecha = DateTime.parse(ing['fecha']);
      final monto = (ing['monto'] ?? 0).toDouble();
      if (fecha.month == now.month && fecha.year == now.year) ingresosMes += monto;
      if (fecha.year == now.year) ingresosAnio += monto;
    }

    for (var gas in gastos) {
      if (operacionId != null && gas['operacionId'] != operacionId) continue;
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

  // ============ POR CATEGORÍA / NEGOCIO / OPERACIÓN ============
  static Future<Map<String, double>> getGastosPorCategoria({String? operacionId}) async {
    final gastos = await getGastos();
    final now = DateTime.now();
    Map<String, double> categorias = {};

    for (var gas in gastos) {
      if (operacionId != null && gas['operacionId'] != operacionId) continue;
      final fecha = DateTime.parse(gas['fecha']);
      if (fecha.month == now.month && fecha.year == now.year) {
        final cat = gas['categoria'] ?? 'Otros';
        categorias[cat] = (categorias[cat] ?? 0) + (gas['monto'] ?? 0).toDouble();
      }
    }
    return categorias;
  }

  static Future<Map<String, double>> getIngresosPorNegocio({String? operacionId}) async {
    final ingresos = await getIngresos();
    final now = DateTime.now();
    Map<String, double> negocios = {};

    for (var ing in ingresos) {
      if (operacionId != null && ing['operacionId'] != operacionId) continue;
      final fecha = DateTime.parse(ing['fecha']);
      if (fecha.month == now.month && fecha.year == now.year) {
        final neg = ing['negocioId'] ?? 'otros';
        negocios[neg] = (negocios[neg] ?? 0) + (ing['monto'] ?? 0).toDouble();
      }
    }
    return negocios;
  }

  static Future<Map<String, double>> getIngresosPorOperacion() async {
    final ingresos = await getIngresos();
    final operaciones = await getOperaciones();
    final now = DateTime.now();
    Map<String, double> resultado = {};

    for (var op in operaciones) {
      resultado[op['id']] = 0.0;
    }

    for (var ing in ingresos) {
      final fecha = DateTime.parse(ing['fecha']);
      if (fecha.month == now.month && fecha.year == now.year) {
        final opId = ing['operacionId'] ?? 'otros';
        resultado[opId] = (resultado[opId] ?? 0) + (ing['monto'] ?? 0).toDouble();
      }
    }
    return resultado;
  }

  static Future<Map<String, double>> getGastosPorOperacion() async {
    final gastos = await getGastos();
    final operaciones = await getOperaciones();
    final now = DateTime.now();
    Map<String, double> resultado = {};

    for (var op in operaciones) {
      resultado[op['id']] = 0.0;
    }

    for (var gas in gastos) {
      final fecha = DateTime.parse(gas['fecha']);
      if (fecha.month == now.month && fecha.year == now.year) {
        final opId = gas['operacionId'] ?? 'otros';
        resultado[opId] = (resultado[opId] ?? 0) + (gas['monto'] ?? 0).toDouble();
      }
    }
    return resultado;
  }

  // ============ METAS ============
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

  // ============ RESUMEN POR OPERACIÓN (para Dashboard) ============
  static Future<List<Map<String, dynamic>>> getResumenPorOperacion() async {
    final operaciones = await getOperaciones();
    final ingresos = await getIngresos();
    final gastos = await getGastos();
    final now = DateTime.now();
    List<Map<String, dynamic>> resultado = [];

    for (var op in operaciones) {
      double ingresosOp = 0;
      double gastosOp = 0;

      for (var ing in ingresos) {
        if (ing['operacionId'] == op['id']) {
          final fecha = DateTime.parse(ing['fecha']);
          if (fecha.month == now.month && fecha.year == now.year) {
            ingresosOp += (ing['monto'] ?? 0).toDouble();
          }
        }
      }

      for (var gas in gastos) {
        if (gas['operacionId'] == op['id']) {
          final fecha = DateTime.parse(gas['fecha']);
          if (fecha.month == now.month && fecha.year == now.year) {
            gastosOp += (gas['monto'] ?? 0).toDouble();
          }
        }
      }

      resultado.add({
        ...op,
        'ingresos': ingresosOp,
        'gastos': gastosOp,
        'balance': ingresosOp - gastosOp,
      });
    }

    return resultado;
  }

  // ============ TRANSACCIONES POR FECHA (para calendario) ============
  static Future<Map<String, List<Map<String, dynamic>>>> getTransaccionesPorFecha() async {
    final ingresos = await getIngresos();
    final gastos = await getGastos();
    Map<String, List<Map<String, dynamic>>> resultado = {};

    for (var ing in ingresos) {
      final fecha = ing['fecha'] ?? '';
      final key = fecha.substring(0, 10); // YYYY-MM-DD
      if (!resultado.containsKey(key)) resultado[key] = [];
      resultado[key]!.add({...ing, 'tipo': 'ingreso'});
    }

    for (var gas in gastos) {
      final fecha = gas['fecha'] ?? '';
      final key = fecha.substring(0, 10);
      if (!resultado.containsKey(key)) resultado[key] = [];
      resultado[key]!.add({...gas, 'tipo': 'gasto'});
    }

    return resultado;
  }
}