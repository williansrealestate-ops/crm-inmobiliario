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

  // ============ MIGRACIÓN AUTOMÁTICA DE DATOS ANTIGUOS ============
  
  // Normaliza un ingreso antiguo al nuevo formato
  static Map<String, dynamic> _normalizarIngreso(Map<String, dynamic> ing) {
    // Copia para no modificar el original
    final normalizado = Map<String, dynamic>.from(ing);
    
    // Campos obligatorios con valores por defecto si no existen
    normalizado.putIfAbsent('id', () => DateTime.now().millisecondsSinceEpoch.toString());
    normalizado.putIfAbsent('fecha', () => DateTime.now().toIso8601String());
    normalizado.putIfAbsent('monto', () => 0.0);
    normalizado.putIfAbsent('concepto', () => 'Sin concepto');
    normalizado.putIfAbsent('negocioId', () => 'otros');
    normalizado.putIfAbsent('operacionId', () => '');
    normalizado.putIfAbsent('categoria', () => '');
    normalizado.putIfAbsent('asunto', () => '');
    normalizado.putIfAbsent('tipo', () => 'ingreso');
    
    // Normalizar monto a double
    if (normalizado['monto'] is int) {
      normalizado['monto'] = (normalizado['monto'] as int).toDouble();
    } else if (normalizado['monto'] is String) {
      normalizado['monto'] = double.tryParse(normalizado['monto']) ?? 0.0;
    }
    
    return normalizado;
  }

  // Normaliza un gasto antiguo al nuevo formato
  static Map<String, dynamic> _normalizarGasto(Map<String, dynamic> gas) {
    final normalizado = Map<String, dynamic>.from(gas);
    
    normalizado.putIfAbsent('id', () => DateTime.now().millisecondsSinceEpoch.toString());
    normalizado.putIfAbsent('fecha', () => DateTime.now().toIso8601String());
    normalizado.putIfAbsent('monto', () => 0.0);
    normalizado.putIfAbsent('concepto', () => 'Sin concepto');
    normalizado.putIfAbsent('negocioId', () => 'otros');
    normalizado.putIfAbsent('operacionId', () => '');
    normalizado.putIfAbsent('categoria', () => '');
    normalizado.putIfAbsent('asunto', () => '');
    normalizado.putIfAbsent('tipo', () => 'gasto');
    
    if (normalizado['monto'] is int) {
      normalizado['monto'] = (normalizado['monto'] as int).toDouble();
    } else if (normalizado['monto'] is String) {
      normalizado['monto'] = double.tryParse(normalizado['monto']) ?? 0.0;
    }
    
    return normalizado;
  }

  // ============ NEGOCIOS ============
  static Future<List<Map<String, dynamic>>> getNegocios() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyNegocios);
    if (data == null) {
      await prefs.setString(_keyNegocios, jsonEncode(_negociosDefault));
      return _negociosDefault;
    }
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    } catch (e) {
      print('Error al cargar negocios: $e');
    }
    return _negociosDefault;
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
    try {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    } catch (e) {
      print('Error al cargar operaciones: $e');
    }
    return _operacionesDefault;
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

  // ============ INGRESOS (CON MIGRACIÓN AUTOMÁTICA) ============
  static Future<List<Map<String, dynamic>>> getIngresos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyIngresos);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      // ✅ MIGRACIÓN: Normalizar cada ingreso al nuevo formato
      return decoded
          .map((e) => _normalizarIngreso(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Error al cargar ingresos: $e');
      return [];
    }
  }

  static Future<void> agregarIngreso(Map<String, dynamic> ingreso) async {
    final ingresos = await getIngresos();
    final normalizado = _normalizarIngreso(ingreso);
    normalizado['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    if (!normalizado.containsKey('fecha') || normalizado['fecha'] == null) {
      normalizado['fecha'] = DateTime.now().toIso8601String();
    }
    ingresos.insert(0, normalizado);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIngresos, jsonEncode(ingresos));
  }

  static Future<void> actualizarIngreso(Map<String, dynamic> ingreso) async {
    final ingresos = await getIngresos();
    final index = ingresos.indexWhere((i) => i['id'] == ingreso['id']);
    if (index != -1) {
      ingresos[index] = _normalizarIngreso({...ingresos[index], ...ingreso});
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

  // ============ GASTOS (CON MIGRACIÓN AUTOMÁTICA) ============
  static Future<List<Map<String, dynamic>>> getGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyGastos);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      // ✅ MIGRACIÓN: Normalizar cada gasto al nuevo formato
      return decoded
          .map((e) => _normalizarGasto(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('Error al cargar gastos: $e');
      return [];
    }
  }

  static Future<void> agregarGasto(Map<String, dynamic> gasto) async {
    final gastos = await getGastos();
    final normalizado = _normalizarGasto(gasto);
    normalizado['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    if (!normalizado.containsKey('fecha') || normalizado['fecha'] == null) {
      normalizado['fecha'] = DateTime.now().toIso8601String();
    }
    gastos.insert(0, normalizado);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGastos, jsonEncode(gastos));
  }

  static Future<void> actualizarGasto(Map<String, dynamic> gasto) async {
    final gastos = await getGastos();
    final index = gastos.indexWhere((g) => g['id'] == gasto['id']);
    if (index != -1) {
      gastos[index] = _normalizarGasto({...gastos[index], ...gasto});
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
      // ✅ Manejar registros sin operacionId (datos antiguos)
      if (operacionId != null && operacionId.isNotEmpty) {
        final ingOpId = ing['operacionId'] ?? '';
        if (ingOpId != operacionId) continue;
      }
      try {
        final fecha = DateTime.parse(ing['fecha'] ?? DateTime.now().toIso8601String());
        final monto = (ing['monto'] ?? 0).toDouble();
        if (fecha.month == now.month && fecha.year == now.year) ingresosMes += monto;
        if (fecha.year == now.year) ingresosAnio += monto;
      } catch (e) {
        print('Error procesando ingreso: $e');
      }
    }

    for (var gas in gastos) {
      if (operacionId != null && operacionId.isNotEmpty) {
        final gasOpId = gas['operacionId'] ?? '';
        if (gasOpId != operacionId) continue;
      }
      try {
        final fecha = DateTime.parse(gas['fecha'] ?? DateTime.now().toIso8601String());
        final monto = (gas['monto'] ?? 0).toDouble();
        if (fecha.month == now.month && fecha.year == now.year) gastosMes += monto;
        if (fecha.year == now.year) gastosAnio += monto;
      } catch (e) {
        print('Error procesando gasto: $e');
      }
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
      if (operacionId != null && operacionId.isNotEmpty) {
        final gasOpId = gas['operacionId'] ?? '';
        if (gasOpId != operacionId) continue;
      }
      try {
        final fecha = DateTime.parse(gas['fecha'] ?? DateTime.now().toIso8601String());
        if (fecha.month == now.month && fecha.year == now.year) {
          final cat = gas['categoria'] ?? 'Otros';
          categorias[cat] = (categorias[cat] ?? 0) + (gas['monto'] ?? 0).toDouble();
        }
      } catch (e) {
        print('Error procesando gasto por categoría: $e');
      }
    }
    return categorias;
  }

  static Future<Map<String, double>> getIngresosPorNegocio({String? operacionId}) async {
    final ingresos = await getIngresos();
    final now = DateTime.now();
    Map<String, double> negocios = {};

    for (var ing in ingresos) {
      if (operacionId != null && operacionId.isNotEmpty) {
        final ingOpId = ing['operacionId'] ?? '';
        if (ingOpId != operacionId) continue;
      }
      try {
        final fecha = DateTime.parse(ing['fecha'] ?? DateTime.now().toIso8601String());
        if (fecha.month == now.month && fecha.year == now.year) {
          final neg = ing['negocioId'] ?? 'otros';
          negocios[neg] = (negocios[neg] ?? 0) + (ing['monto'] ?? 0).toDouble();
        }
      } catch (e) {
        print('Error procesando ingreso por negocio: $e');
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
      try {
        final fecha = DateTime.parse(ing['fecha'] ?? DateTime.now().toIso8601String());
        if (fecha.month == now.month && fecha.year == now.year) {
          final opId = ing['operacionId'] ?? '';
          if (opId.isNotEmpty) {
            resultado[opId] = (resultado[opId] ?? 0) + (ing['monto'] ?? 0).toDouble();
          } else {
            // Datos antiguos sin operación → asignar a "otros" o primera operación
            if (resultado.containsKey('compra_venta')) {
              resultado['compra_venta'] = (resultado['compra_venta'] ?? 0) + (ing['monto'] ?? 0).toDouble();
            }
          }
        }
      } catch (e) {
        print('Error procesando ingreso por operación: $e');
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
      try {
        final fecha = DateTime.parse(gas['fecha'] ?? DateTime.now().toIso8601String());
        if (fecha.month == now.month && fecha.year == now.year) {
          final opId = gas['operacionId'] ?? '';
          if (opId.isNotEmpty) {
            resultado[opId] = (resultado[opId] ?? 0) + (gas['monto'] ?? 0).toDouble();
          } else {
            if (resultado.containsKey('compra_venta')) {
              resultado['compra_venta'] = (resultado['compra_venta'] ?? 0) + (gas['monto'] ?? 0).toDouble();
            }
          }
        }
      } catch (e) {
        print('Error procesando gasto por operación: $e');
      }
    }
    return resultado;
  }

  // ============ METAS ============
  static Future<Map<String, dynamic>> getMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyMetas);
    if (data == null) return {'metaMensual': 100000.0, 'metaAnual': 1200000.0};
    try {
      return Map<String, dynamic>.from(jsonDecode(data));
    } catch (e) {
      return {'metaMensual': 100000.0, 'metaAnual': 1200000.0};
    }
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
        try {
          if (ing['operacionId'] == op['id']) {
            final fecha = DateTime.parse(ing['fecha'] ?? DateTime.now().toIso8601String());
            if (fecha.month == now.month && fecha.year == now.year) {
              ingresosOp += (ing['monto'] ?? 0).toDouble();
            }
          }
        } catch (e) {
          print('Error: $e');
        }
      }

      for (var gas in gastos) {
        try {
          if (gas['operacionId'] == op['id']) {
            final fecha = DateTime.parse(gas['fecha'] ?? DateTime.now().toIso8601String());
            if (fecha.month == now.month && fecha.year == now.year) {
              gastosOp += (gas['monto'] ?? 0).toDouble();
            }
          }
        } catch (e) {
          print('Error: $e');
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
      try {
        final fecha = ing['fecha'] ?? DateTime.now().toIso8601String();
        final key = fecha.substring(0, 10);
        if (!resultado.containsKey(key)) resultado[key] = [];
        resultado[key]!.add({...ing, 'tipo': 'ingreso'});
      } catch (e) {
        print('Error: $e');
      }
    }

    for (var gas in gastos) {
      try {
        final fecha = gas['fecha'] ?? DateTime.now().toIso8601String();
        final key = fecha.substring(0, 10);
        if (!resultado.containsKey(key)) resultado[key] = [];
        resultado[key]!.add({...gas, 'tipo': 'gasto'});
      } catch (e) {
        print('Error: $e');
      }
    }

    return resultado;
  }

  // ============ FUNCIÓN DE MIGRACIÓN EXPLÍCITA ============
  // Llamar esta función una vez después de importar un respaldo antiguo
  static Future<void> migrarDatosAntiguos() async {
    print(' Iniciando migración de datos...');
    
    final ingresos = await getIngresos();
    final gastos = await getGastos();
    
    // Re-guardar ingresos normalizados
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIngresos, jsonEncode(ingresos));
    await prefs.setString(_keyGastos, jsonEncode(gastos));
    
    print('✅ Migración completada: ${ingresos.length} ingresos, ${gastos.length} gastos');
  }
}