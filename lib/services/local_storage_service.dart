import 'dart:convert';
import 'dart:html' as html;

class LocalStorageService {
  static const String _inmueblesKey = 'inmuebles';
  static const String _clientesKey = 'clientes';
  static const String _asesoresKey = 'asesores';
  static const String _actividadesKey = 'actividades';
  static const String _guionesKey = 'guiones';
  static const String _gruposKey = 'grupos';

  // ✅ NUEVO: Métodos para grupos (SÍNCRONOS como el resto)
  static List<Map<String, dynamic>> getGrupos() {
    final data = html.window.localStorage[_gruposKey];
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void agregarGrupo(Map<String, dynamic> grupo) {
    final grupos = getGrupos();
    grupo['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    grupos.add(grupo);
    html.window.localStorage[_gruposKey] = jsonEncode(grupos);
  }

  static void actualizarGrupo(String id, Map<String, dynamic> grupo) {
    final grupos = getGrupos();
    final index = grupos.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      grupos[index] = grupo;
      html.window.localStorage[_gruposKey] = jsonEncode(grupos);
    }
  }

  static void eliminarGrupo(String id) {
    final grupos = getGrupos();
    grupos.removeWhere((g) => g['id'] == id);
    html.window.localStorage[_gruposKey] = jsonEncode(grupos);
  }

  // Métodos para inmuebles
  static List<Map<String, dynamic>> getInmuebles() {
    final data = html.window.localStorage[_inmueblesKey];
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void agregarInmueble(Map<String, dynamic> inmueble) {
    final inmuebles = getInmuebles();
    inmueble['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    inmuebles.add(inmueble);
    html.window.localStorage[_inmueblesKey] = jsonEncode(inmuebles);
  }

  static void actualizarInmueble(String id, Map<String, dynamic> inmueble) {
    final inmuebles = getInmuebles();
    final index = inmuebles.indexWhere((i) => i['id'] == id);
    if (index != -1) {
      inmuebles[index] = inmueble;
      html.window.localStorage[_inmueblesKey] = jsonEncode(inmuebles);
    }
  }

  static void eliminarInmueble(String id) {
    final inmuebles = getInmuebles();
    inmuebles.removeWhere((i) => i['id'] == id);
    html.window.localStorage[_inmueblesKey] = jsonEncode(inmuebles);
  }

  // Métodos para clientes
  static List<Map<String, dynamic>> getClientes() {
    final data = html.window.localStorage[_clientesKey];
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void agregarCliente(Map<String, dynamic> cliente) {
    final clientes = getClientes();
    cliente['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    clientes.add(cliente);
    html.window.localStorage[_clientesKey] = jsonEncode(clientes);
  }

  static void actualizarCliente(String id, Map<String, dynamic> cliente) {
    final clientes = getClientes();
    final index = clientes.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      clientes[index] = cliente;
      html.window.localStorage[_clientesKey] = jsonEncode(clientes);
    }
  }

  static void eliminarCliente(String id) {
    final clientes = getClientes();
    clientes.removeWhere((c) => c['id'] == id);
    html.window.localStorage[_clientesKey] = jsonEncode(clientes);
  }

  // Métodos para asesores
  static List<Map<String, dynamic>> getAsesores() {
    final data = html.window.localStorage[_asesoresKey];
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void agregarAsesor(Map<String, dynamic> asesor) {
    final asesores = getAsesores();
    asesor['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    asesores.add(asesor);
    html.window.localStorage[_asesoresKey] = jsonEncode(asesores);
  }

  static void actualizarAsesor(String id, Map<String, dynamic> asesor) {
    final asesores = getAsesores();
    final index = asesores.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      asesores[index] = asesor;
      html.window.localStorage[_asesoresKey] = jsonEncode(asesores);
    }
  }

  static void eliminarAsesor(String id) {
    final asesores = getAsesores();
    asesores.removeWhere((a) => a['id'] == id);
    html.window.localStorage[_asesoresKey] = jsonEncode(asesores);
  }

  // Métodos para actividades
  static List<Map<String, dynamic>> getActividades() {
    final data = html.window.localStorage[_actividadesKey];
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void agregarActividad(Map<String, dynamic> actividad) {
    final actividades = getActividades();
    actividad['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    actividades.add(actividad);
    html.window.localStorage[_actividadesKey] = jsonEncode(actividades);
  }

  static void actualizarActividad(String id, Map<String, dynamic> actividad) {
    final actividades = getActividades();
    final index = actividades.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      actividades[index] = actividad;
      html.window.localStorage[_actividadesKey] = jsonEncode(actividades);
    }
  }

  static void eliminarActividad(String id) {
    final actividades = getActividades();
    actividades.removeWhere((a) => a['id'] == id);
    html.window.localStorage[_actividadesKey] = jsonEncode(actividades);
  }

  // Métodos para guiones
  static List<Map<String, dynamic>> getGuiones() {
    final data = html.window.localStorage[_guionesKey];
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static void agregarGuion(Map<String, dynamic> guion) {
    final guiones = getGuiones();
    guion['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    guiones.add(guion);
    html.window.localStorage[_guionesKey] = jsonEncode(guiones);
  }

  static void actualizarGuion(String id, Map<String, dynamic> guion) {
    final guiones = getGuiones();
    final index = guiones.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      guiones[index] = guion;
      html.window.localStorage[_guionesKey] = jsonEncode(guiones);
    }
  }

  static void eliminarGuion(String id) {
    final guiones = getGuiones();
    guiones.removeWhere((g) => g['id'] == id);
    html.window.localStorage[_guionesKey] = jsonEncode(guiones);
  }
}