import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class ListaActividades extends StatefulWidget {
  const ListaActividades({super.key});

  @override
  State<ListaActividades> createState() => _ListaActividadesState();
}

class _ListaActividadesState extends State<ListaActividades> {
  List<Map<String, dynamic>> _actividades = [];
  String _filtro = 'Todas';
  // ✅ CORRECCIÓN 1: Campo final con ignore para unused_field
  // ignore: unused_field
  final String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  void _cargarActividades() {
    setState(() {
      _actividades = LocalStorageService.getActividades();
    });
  }

  List<Map<String, dynamic>> get _actividadesFiltradas {
    return _actividades.where((a) {
      if (_filtro == 'Todas') return true;
      if (_filtro == 'Pendientes') return a['completada'] != true;
      if (_filtro == 'Completadas') return a['completada'] == true;
      return a['tipo'] == _filtro;
    }).toList();
  }

  void _mostrarFormularioActividad({Map<String, dynamic>? actividad}) {
    final esEditar = actividad != null;
    final tituloCtrl = TextEditingController(text: actividad?['titulo'] ?? '');
    final tipoCtrl = TextEditingController(text: actividad?['tipo'] ?? 'Llamada');
    final fechaCtrl = TextEditingController(text: actividad?['fecha'] ?? '');
    final horaCtrl = TextEditingController(text: actividad?['hora'] ?? '');
    final clienteCtrl = TextEditingController(text: actividad?['cliente'] ?? '');
    final prioridadCtrl = TextEditingController(text: actividad?['prioridad'] ?? 'Media');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(esEditar ? 'Editar Actividad' : 'Nueva Actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoCtrl.text,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: ['Llamada', 'Reunión', 'Visita', 'Presentación', 'Seguimiento', 'Email', 'Firma']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => tipoCtrl.text = v ?? ''),
                ),
                const SizedBox(height: 12),
                TextField(controller: fechaCtrl, decoration: const InputDecoration(labelText: 'Fecha (DD/MM/YYYY)')),
                const SizedBox(height: 12),
                TextField(controller: horaCtrl, decoration: const InputDecoration(labelText: 'Hora (HH:MM)')),
                const SizedBox(height: 12),
                TextField(controller: clienteCtrl, decoration: const InputDecoration(labelText: 'Cliente')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prioridadCtrl.text,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: ['Alta', 'Media', 'Baja']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => prioridadCtrl.text = v ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final datos = {
                  'titulo': tituloCtrl.text,
                  'tipo': tipoCtrl.text,
                  'fecha': fechaCtrl.text,
                  'hora': horaCtrl.text,
                  'cliente': clienteCtrl.text,
                  'prioridad': prioridadCtrl.text,
                  'completada': actividad?['completada'] ?? false,
                };

                if (esEditar) {
                  // ✅ CORRECCIÓN 2: Quitado el '!' innecesario
                  LocalStorageService.actualizarActividad(actividad['id'], {...datos, 'id': actividad['id']});
                } else {
                  LocalStorageService.agregarActividad(datos);
                }

                Navigator.pop(ctx);
                _cargarActividades();
              },
              child: Text(esEditar ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> actividad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Actividad'),
        content: Text('¿Estás seguro de eliminar "${actividad['titulo']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              LocalStorageService.eliminarActividad(actividad['id']);
              Navigator.pop(ctx);
              _cargarActividades();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _toggleCompletada(Map<String, dynamic> actividad) {
    final nueva = {...actividad, 'completada': !(actividad['completada'] ?? false)};
    LocalStorageService.actualizarActividad(actividad['id'], nueva);
    _cargarActividades();
  }

  Color _colorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Alta': return AppTheme.danger;
      case 'Media': return AppTheme.warning;
      case 'Baja': return AppTheme.success;
      default: return AppTheme.textSecondary;
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'Llamada': return Icons.phone;
      case 'Reunión': return Icons.people;
      case 'Visita': return Icons.location_on;
      case 'Presentación': return Icons.slideshow;
      case 'Seguimiento': return Icons.track_changes;
      case 'Email': return Icons.email;
      case 'Firma': return Icons.edit;
      default: return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isDesktop = width >= 1200;
    final pendientes = _actividades.where((a) => a['completada'] != true).length;
    final completadas = _actividades.where((a) => a['completada'] == true).length;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : (isDesktop ? 32 : 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividades',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : (isDesktop ? 32 : 28),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.getTextPrimaryColor(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestiona tus tareas y seguimientos',
                        style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _mostrarFormularioActividad(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(isMobile ? '' : 'Nueva Actividad', style: TextStyle(fontSize: isMobile ? 0 : 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KPIs de Actividades
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = isMobile ? 2 : 4;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 1.3 : 1.8,
                  children: [
                    _buildKpiCard(
                      icon: Icons.task,
                      value: '${_actividades.length}',
                      label: 'Total',
                      subtitle: 'actividades',
                      color: const Color(0xFF0D1B4C),
                      gradient: const [Color(0xFF0D1B4C), Color(0xFF1A2F6F)],
                    ),
                    _buildKpiCard(
                      icon: Icons.pending,
                      value: '$pendientes',
                      label: 'Pendientes',
                      subtitle: 'por realizar',
                      color: AppTheme.danger,
                      gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    _buildKpiCard(
                      icon: Icons.check_circle,
                      value: '$completadas',
                      label: 'Completadas',
                      subtitle: 'realizadas',
                      color: AppTheme.success,
                      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    _buildKpiCard(
                      icon: Icons.priority_high,
                      value: '${_actividades.where((a) => a['prioridad'] == 'Alta').length}',
                      label: 'Alta Prioridad',
                      subtitle: 'urgentes',
                      color: AppTheme.warning,
                      gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Filtros
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todas', 'Pendientes', 'Completadas', 'Llamada', 'Reunión', 'Visita']
                        .map((f) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: FilterChip(
                                label: Text(f, style: const TextStyle(fontSize: 13)),
                                selected: _filtro == f,
                                onSelected: (s) => setState(() => _filtro = f),
                                backgroundColor: AppTheme.getSurfaceColor(context),
                                selectedColor: AppTheme.primary.withOpacity(0.1),
                                checkmarkColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: _filtro == f ? AppTheme.primary : AppTheme.getTextPrimaryColor(context),
                                  fontWeight: _filtro == f ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de actividades
            if (_actividadesFiltradas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_note_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay actividades', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._actividadesFiltradas.map((a) {
                final completada = a['completada'] ?? false;
                final color = _colorPrioridad(a['prioridad'] ?? 'Media');
                return Opacity(
                  opacity: completada ? 0.6 : 1.0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Checkbox(
                            value: completada,
                            onChanged: (_) => _toggleCompletada(a),
                            activeColor: AppTheme.success,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(_iconoTipo(a['tipo'] ?? 'Evento'), color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a['titulo'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.getTextPrimaryColor(context),
                                    decoration: completada ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${a['fecha']} • ${a['hora']}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.person, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      a['cliente'] ?? '',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(
                              a['prioridad'] ?? '',
                              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20),
                            onPressed: () => _mostrarFormularioActividad(actividad: a),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.danger, size: 20),
                            onPressed: () => _confirmarEliminar(a),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}