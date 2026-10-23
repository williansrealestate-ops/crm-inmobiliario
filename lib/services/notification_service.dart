import 'dart:convert';
import 'indexed_db_service.dart';
import 'actividades_service.dart';

class NotificacionesService {
  static const String _claveNotificaciones = 'notificaciones';
  static const String _claveConfigNotif = 'config_notificaciones';

  static Future<List<Map<String, dynamic>>> getNotificaciones() async {
    try {
      final json = await IndexedDBService.get(_claveNotificaciones);
      if (json != null) {
        final datos = jsonDecode(json) as List;
        return datos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  static Future<void> guardarNotificaciones(List<Map<String, dynamic>> notificaciones) async {
    await IndexedDBService.put(_claveNotificaciones, jsonEncode(notificaciones));
  }

  static Future<List<Map<String, dynamic>>> generarNotificacionesHoy() async {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    final actividades = await ActividadesService.getActividadesPorFecha(hoy);
    final notificaciones = <Map<String, dynamic>>[];
    final ahora = DateTime.now();
    final horaActual = '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
    
    for (var act in actividades) {
      if (act['completada'] == true) continue;
      final horaAct = act['hora'] ?? '';
      final titulo = act['titulo'] ?? 'Actividad pendiente';
      final tipo = act['tipo'] ?? 'Otra';
      final cliente = act['cliente'] ?? '';
      String urgencia = 'normal';
      if (horaAct.isNotEmpty && horaAct.compareTo(horaActual) < 0) {
        urgencia = 'vencida';
      } else if (horaAct.isNotEmpty) {
        final diferencia = _diferenciaMinutos(horaActual, horaAct);
        if (diferencia <= 30) {
          urgencia = 'urgente';
        } else if (diferencia <= 60) urgencia = 'proxima';
      }
      notificaciones.add({
        'id': 'notif_${act['id']}',
        'actividadId': act['id'],
        'titulo': titulo,
        'tipo': tipo,
        'hora': horaAct,
        'cliente': cliente,
        'fecha': hoy,
        'urgencia': urgencia,
        'leida': false,
        'fechaCreacion': DateTime.now().toIso8601String(),
      });
    }
    return notificaciones;
  }

  static Future<Map<String, dynamic>> getResumen() async {
    final notificaciones = await generarNotificacionesHoy();
    return {
      'total': notificaciones.length,
      'noLeidas': notificaciones.where((n) => n['leida'] == false).length,
      'vencidas': notificaciones.where((n) => n['urgencia'] == 'vencida').length,
      'urgentes': notificaciones.where((n) => n['urgencia'] == 'urgente').length,
      'proximas': notificaciones.where((n) => n['urgencia'] == 'proxima').length,
      'tienePendientes': notificaciones.isNotEmpty,
    };
  }

  static Future<void> marcarComoLeida(String id) async {
    final notificaciones = await getNotificaciones();
    final index = notificaciones.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      notificaciones[index]['leida'] = true;
      await guardarNotificaciones(notificaciones);
    }
  }

  static Future<void> marcarTodasComoLeidas() async {
    final notificaciones = await getNotificaciones();
    for (var n in notificaciones) {
      n['leida'] = true;
    }
    await guardarNotificaciones(notificaciones);
  }

  static Future<void> eliminarNotificacion(String id) async {
    final notificaciones = (await getNotificaciones()).where((n) => n['id'] != id).toList();
    await guardarNotificaciones(notificaciones);
  }

  static Future<void> limpiarAntiguas() async {
    final notificaciones = await getNotificaciones();
    final hace7Dias = DateTime.now().subtract(const Duration(days: 7));
    final filtradas = notificaciones.where((n) {
      final fecha = DateTime.tryParse(n['fechaCreacion'] ?? '');
      return fecha != null && fecha.isAfter(hace7Dias);
    }).toList();
    await guardarNotificaciones(filtradas);
  }

  static Future<Map<String, dynamic>> getConfig() async {
    try {
      final json = await IndexedDBService.get(_claveConfigNotif);
      if (json != null) {
        return Map<String, dynamic>.from(jsonDecode(json) as Map);
      }
    } catch (e) {}
    return {'activadas': true, 'sonido': true, 'recordatorioMinutos': 30};
  }

  static Future<void> guardarConfig(Map<String, dynamic> config) async {
    await IndexedDBService.put(_claveConfigNotif, jsonEncode(config));
  }

  static int _diferenciaMinutos(String hora1, String hora2) {
    try {
      final p1 = hora1.split(':');
      final p2 = hora2.split(':');
      return (int.parse(p2[0]) * 60 + int.parse(p2[1])) - (int.parse(p1[0]) * 60 + int.parse(p1[1]));
    } catch (e) {
      return 999;
    }
  }
}