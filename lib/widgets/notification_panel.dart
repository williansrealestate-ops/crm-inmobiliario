import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/notificaciones_service.dart';
import 'ios_widgets.dart';

class NotificationPanel extends StatefulWidget {
  final VoidCallback? onNotificacionLeida;
  
  const NotificationPanel({super.key, this.onNotificacionLeida});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<Map<String, dynamic>> _notificaciones = [];
  Map<String, dynamic> _resumen = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _notificaciones = await NotificacionesService.generarNotificacionesHoy();
      _resumen = await NotificacionesService.getResumen();
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(-5, 0))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context))),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notificaciones', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('${_resumen['noLeidas'] ?? 0} sin leer', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                if (_notificaciones.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await NotificacionesService.marcarTodasComoLeidas();
                      await _cargarDatos();
                      widget.onNotificacionLeida?.call();
                    },
                    child: const Text('Marcar todas', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Resumen rápido
          if (_resumen['tienePendientes'] == true)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_resumen['vencidas'] ?? 0) > 0 
                    ? IOSColors.red.withOpacity(0.1)
                    : IOSColors.orange.withOpacity(0.1),
                border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context))),
              ),
              child: Row(
                children: [
                  Icon(
                    (_resumen['vencidas'] ?? 0) > 0 ? Icons.warning : Icons.schedule,
                    color: (_resumen['vencidas'] ?? 0) > 0 ? IOSColors.red : IOSColors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (_resumen['vencidas'] ?? 0) > 0
                          ? 'Tienes ${_resumen['vencidas']} actividades vencidas'
                          : 'Tienes ${_resumen['total']} actividades para hoy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: (_resumen['vencidas'] ?? 0) > 0 ? IOSColors.red : IOSColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Lista de notificaciones
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _notificaciones.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off, size: 64, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textTertiary),
                            const SizedBox(height: 16),
                            const Text('No hay notificaciones', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                            const SizedBox(height: 8),
                            const Text('Las actividades de hoy aparecerán aquí', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notificaciones.length,
                        itemBuilder: (context, index) => _buildNotificacionCard(_notificaciones[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacionCard(Map<String, dynamic> notif) {
    final titulo = notif['titulo'] ?? 'Sin título';
    final tipo = notif['tipo'] ?? 'Otra';
    final hora = notif['hora'] ?? '';
    final cliente = notif['cliente'] ?? '';
    final urgencia = notif['urgencia'] ?? 'normal';
    final leida = notif['leida'] ?? false;

    final colorUrgencia = _getColorPorUrgencia(urgencia);
    final iconoUrgencia = _getIconoPorUrgencia(urgencia);
    final textoUrgencia = _getTextoPorUrgencia(urgencia);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: leida 
            ? AppTheme.getSurfaceColor(context).withOpacity(0.5)
            : AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: colorUrgencia, width: 4),
          top: BorderSide(color: leida ? AppTheme.getBorderColor(context) : colorUrgencia.withOpacity(0.3)),
          right: BorderSide(color: leida ? AppTheme.getBorderColor(context) : colorUrgencia.withOpacity(0.3)),
          bottom: BorderSide(color: leida ? AppTheme.getBorderColor(context) : colorUrgencia.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorUrgencia.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconoUrgencia, color: colorUrgencia, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (hora.isNotEmpty) ...[
                          Icon(Icons.access_time, size: 12, color: IOSColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(hora, style: TextStyle(fontSize: 11, color: IOSColors.textSecondary)),
                          const SizedBox(width: 8),
                        ],
                        if (cliente.isNotEmpty) ...[
                          Icon(Icons.person, size: 12, color: IOSColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cliente,
                              style: TextStyle(fontSize: 11, color: IOSColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IOSBadge(text: textoUrgencia, color: colorUrgencia, filled: true),
            ],
          ),
          if (!leida) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    await NotificacionesService.marcarComoLeida(notif['id']);
                    await _cargarDatos();
                    widget.onNotificacionLeida?.call();
                  },
                  child: const Text('Marcar como leída', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorPorUrgencia(String urgencia) {
    switch (urgencia) {
      case 'vencida': return IOSColors.red;
      case 'urgente': return IOSColors.orange;
      case 'proxima': return IOSColors.blue;
      default: return IOSColors.textSecondary;
    }
  }

  IconData _getIconoPorUrgencia(String urgencia) {
    switch (urgencia) {
      case 'vencida': return Icons.warning;
      case 'urgente': return Icons.alarm;
      case 'proxima': return Icons.schedule;
      default: return Icons.notifications;
    }
  }

  String _getTextoPorUrgencia(String urgencia) {
    switch (urgencia) {
      case 'vencida': return 'Vencida';
      case 'urgente': return 'Urgente';
      case 'proxima': return 'Próxima';
      default: return 'Normal';
    }
  }
}