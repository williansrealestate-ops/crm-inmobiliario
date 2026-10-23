import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class MiDiaScreen extends StatefulWidget {
  final String? busqueda;
  const MiDiaScreen({super.key, this.busqueda});

  @override
  State<MiDiaScreen> createState() => _MiDiaScreenState();
}

class _MiDiaScreenState extends State<MiDiaScreen> {
  List<Map<String, dynamic>> _actividades = [];

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  void _cargarActividades() {
    setState(() { _actividades = LocalStorageService.getActividades(); });
  }

  List<Map<String, dynamic>> get _actividadesDeHoy {
    final hoy = DateTime.now();
    final hoyStr = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
    return _actividades.where((a) => a['fecha'] == hoyStr).toList();
  }

  List<Map<String, dynamic>> get _actividadesFiltradas {
    final busquedaActiva = widget.busqueda ?? '';
    final actividadesBase = _actividadesDeHoy;
    if (busquedaActiva.isEmpty) return actividadesBase;
    return actividadesBase.where((a) {
      final texto = '${a['titulo']} ${a['cliente'] ?? ''}'.toLowerCase();
      return texto.contains(busquedaActiva.toLowerCase());
    }).toList();
  }

  void _toggleCompletada(Map<String, dynamic> actividad) {
    LocalStorageService.actualizarActividad(actividad['id'].toString(), {...actividad, 'completada': !(actividad['completada'] ?? false)});
    _cargarActividades();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mi Día', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))),
            const SizedBox(height: 4),
            Text('Actividades programadas para hoy', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14)),
            const SizedBox(height: 24),
            if (widget.busqueda != null && widget.busqueda!.isNotEmpty) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.search, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Text('Buscando: "${widget.busqueda}"', style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600))])),
              const SizedBox(height: 16),
            ],
            if (_actividadesFiltradas.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(60), child: Center(child: Column(children: [const Icon(Icons.event_note, size: 64, color: Colors.grey), SizedBox(height: 16), const Text('No hay actividades para hoy', style: const TextStyle(color: Colors.grey, fontSize: 16))]))))
            else
              ..._actividadesFiltradas.map((a) {
                final completada = a['completada'] ?? false;
                final color = a['prioridad'] == 'Alta' ? AppTheme.danger : a['prioridad'] == 'Media' ? AppTheme.warning : AppTheme.success;
                return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                  Checkbox(value: completada, onChanged: (_) => _toggleCompletada(a), activeColor: AppTheme.success),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['titulo'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.getTextPrimaryColor(context), decoration: completada ? TextDecoration.lineThrough : null)),
                    const SizedBox(height: 4),
                    Text('${a['hora'] ?? ''} • ${a['cliente'] ?? ''}', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(a['tipo'] ?? 'Reunión', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))),
                ])));
              }),
          ],
        ),
      ),
    );
  }
}