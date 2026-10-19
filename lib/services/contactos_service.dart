import 'dart:convert';
import 'dart:html' as html;

class ContactosService {
  static const String _keyContactos = 'contactos_profesionales';

  static const List<Map<String, dynamic>> categorias = [
    {'id': 'notario', 'nombre': 'Notarios', 'icono': '⚖️', 'color': '0xFF3B82F6'},
    {'id': 'abogado', 'nombre': 'Abogados', 'icono': '📋', 'color': '0xFF8B5CF6'},
    {'id': 'valuador', 'nombre': 'Valuadores', 'icono': '', 'color': '0xFF10B981'},
    {'id': 'seguros', 'nombre': 'Agentes de Seguros', 'icono': '🛡️', 'color': '0xFFF59E0B'},
    {'id': 'broker', 'nombre': 'Brókers Hipotecarios', 'icono': '💰', 'color': '0xFFEC4899'},
    {'id': 'fotografo', 'nombre': 'Fotógrafos', 'icono': '📷', 'color': '0xFF6366F1'},
    {'id': 'arquitecto', 'nombre': 'Arquitectos', 'icono': '🏗️', 'color': '0xFF14B8A6'},
    {'id': 'otro', 'nombre': 'Otros', 'icono': '👤', 'color': '0xFF64748B'},
  ];

  static List<Map<String, dynamic>> getContactos() {
    try {
      final json = html.window.localStorage[_keyContactos];
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

  static void guardarContactos(List<Map<String, dynamic>> contactos) {
    try {
      html.window.localStorage[_keyContactos] = jsonEncode(contactos);
    } catch (e) {
      print('Error: $e');
    }
  }

  static void agregarContacto(Map<String, dynamic> contacto) {
    final contactos = getContactos();
    contacto['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    contacto['fechaCreacion'] = DateTime.now().toIso8601String();
    contacto['calificacion'] = contacto['calificacion'] ?? 5;
    contacto['operacionesJuntas'] = contacto['operacionesJuntas'] ?? 0;
    contactos.add(contacto);
    guardarContactos(contactos);
  }

  static void actualizarContacto(String id, Map<String, dynamic> cambios) {
    final contactos = getContactos();
    final index = contactos.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      contactos[index].addAll(cambios);
      guardarContactos(contactos);
    }
  }

  static void eliminarContacto(String id) {
    final contactos = getContactos().where((c) => c['id'] != id).toList();
    guardarContactos(contactos);
  }

  static List<Map<String, dynamic>> getContactosPorCategoria(String categoriaId) {
    return getContactos().where((c) => c['categoria'] == categoriaId).toList();
  }

  static void incrementarOperaciones(String id) {
    final contactos = getContactos();
    final index = contactos.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      contactos[index]['operacionesJuntas'] = (contactos[index]['operacionesJuntas'] ?? 0) + 1;
      guardarContactos(contactos);
    }
  }
}