import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/notificaciones_inapp_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  Widget build(BuildContext context) {
    final notificaciones = NotificacionesInAppService.getNotificaciones();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 8), Text('Notificaciones')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (notificaciones.any((n) => n['leida'] != true))
            TextButton(
              onPressed: () {
                NotificacionesInAppService.marcarTodasLeidas();
                setState(() {});
              },
              child: const Text('Marcar todas', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notificaciones.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Color(0xFF10B981), size: 64), SizedBox(height: 16), Text('¡Todo al día!', style: TextStyle(fontSize: 18, color: Color(0xFF64748B)))]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final notif = notificaciones[index];
                final esAlta = notif['prioridad'] == 'alta';
                final color = esAlta ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notif['leida'] == true ? Colors.white : color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: notif['leida'] == true ? const Color(0xFFE2E8F0) : color),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 40,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['titulo'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                            const SizedBox(height: 4),
                            Text(notif['mensaje'], style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      if (notif['leida'] != true)
                        IconButton(
                          icon: const Icon(Icons.check, size: 18),
                          onPressed: () {
                            NotificacionesInAppService.marcarLeida(notif['id']);
                            setState(() {});
                          },
                          color: color,
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}