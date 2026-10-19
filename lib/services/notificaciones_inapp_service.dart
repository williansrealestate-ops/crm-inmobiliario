import 'dart:convert';
import 'dart:html' as html;

class NotificacionesInAppService {
  static const String _keyNotificaciones = 'notificaciones_inapp';
  static const String _keyLeidas = 'notificaciones_leidas';

  static List<Map<String, dynamic>> getNotificaciones() {
    final notifs = <Map<String, dynamic>>[];
    final ahora = DateTime.now();
    final hoyStr = '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}';

    // Notificaciones automáticas basadas en datos
    try {
      // Actividades del día
      final actividades = jsonDecode(html.window.localStorage['actividades'] ?? '[]') as List;
      for (var act in actividades) {
        if (act['fecha'] == hoyStr && act['completada'] != true) {
          notifs.add({
            'id': 'act_${act['id']}',
            'tipo': 'actividad',
            'titulo': '📋 Actividad pendiente hoy',
            'mensaje': act['titulo'] ?? 'Actividad sin título',
            'fecha': ahora.toIso8601String(),
            'leida': false,
            'prioridad': 'alta',
          });
        }
      }
    } catch (e) {}

    // Operaciones estancadas
    try {
      final operaciones = jsonDecode(html.window.localStorage['pipeline_operaciones'] ?? '[]') as List;
      for (var op in operaciones) {
        if (op['etapa'] != 'cerrado') {
          final fechaStr = op['fechaEtapa'] ?? op['fechaCreacion'] ?? '';
          if (fechaStr.isNotEmpty) {
            try {
              final fecha = DateTime.parse(fechaStr);
              final dias = ahora.difference(fecha).inDays;
              if (dias > 14) {
                notifs.add({
                  'id': 'op_${op['id']}',
                  'tipo': 'pipeline',
                  'titulo': '⚠️ Operación estancada',
                  'mensaje': '${op['titulo']} lleva $dias días en ${op['etapa']}',
                  'fecha': ahora.toIso8601String(),
                  'leida': false,
                  'prioridad': 'media',
                });
              }
            } catch (e) {}
          }
        }
      }
    } catch (e) {}

    return notifs;
  }

  static int getNoLeidas() {
    return getNotificaciones().where((n) => n['leida'] != true).length;
  }

  static void marcarLeida(String id) {
    try {
      final leidas = jsonDecode(html.window.localStorage[_keyLeidas] ?? '[]') as List;
      leidas.add(id);
      html.window.localStorage[_keyLeidas] = jsonEncode(leidas);
    } catch (e) {}
  }

  static void marcarTodasLeidas() {
    final notifs = getNotificaciones();
    try {
      final leidas = jsonDecode(html.window.localStorage[_keyLeidas] ?? '[]') as List;
      for (var n in notifs) {
        leidas.add(n['id']);
      }
      html.window.localStorage[_keyLeidas] = jsonEncode(leidas.toSet().toList());
    } catch (e) {}
  }
}