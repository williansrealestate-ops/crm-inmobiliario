import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class ActividadesScreen extends StatefulWidget {
  final String? busqueda;
  const ActividadesScreen({super.key, this.busqueda});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  List<Map<String, dynamic>> _actividades = [];
  String _filtroTipo = 'Todas';
  String _filtroAsesor = 'Todos';
  String _filtroEstado = 'Todas';
  String _vistaActual = 'lista';

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  void _cargarActividades() {
    setState(() {
      _actividades = LocalStorageService.getActividades();
      bool necesitaGuardar = false;
      for (var actividad in _actividades) {
        if (!actividad.containsKey('asesor') || actividad['asesor'] == null) { actividad['asesor'] = ''; necesitaGuardar = true; }
        if (!actividad.containsKey('notas') || actividad['notas'] == null) { actividad['notas'] = ''; necesitaGuardar = true; }
        if (!actividad.containsKey('completada') || actividad['completada'] == null) { actividad['completada'] = false; necesitaGuardar = true; }
        if (!actividad.containsKey('prioridad') || actividad['prioridad'] == null) { actividad['prioridad'] = 'Media'; necesitaGuardar = true; }
      }
      if (necesitaGuardar) {
        for (var actividad in _actividades) {
          LocalStorageService.actualizarActividad(actividad['id'].toString(), actividad);
        }
      }
    });
  }

  bool _estaVencida(Map<String, dynamic> a) {
    if (a['completada'] == true) return false;
    final fechaStr = a['fecha'] ?? '';
    if (fechaStr.isEmpty) return false;
    try {
      final partes = fechaStr.split('/');
      final fecha = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
      final hoy = DateTime.now();
      return fecha.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    } catch (e) { return false; }
  }

  List<Map<String, dynamic>> get _actividadesFiltradas {
    final busquedaActiva = widget.busqueda ?? '';
    return _actividades.where((a) {
      final coincideTipo = _filtroTipo == 'Todas' || a['tipo'] == _filtroTipo;
      final coincideAsesor = _filtroAsesor == 'Todos' || a['asesor'] == _filtroAsesor;
      bool coincideEstado = true;
      if (_filtroEstado == 'Pendientes') coincideEstado = a['completada'] != true;
      else if (_filtroEstado == 'Completadas') coincideEstado = a['completada'] == true;
      else if (_filtroEstado == 'Vencidas') coincideEstado = _estaVencida(a);
      else if (_filtroEstado == 'Hoy') {
        final hoy = DateTime.now();
        final hoyStr = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
        coincideEstado = a['fecha'] == hoyStr;
      }
      final texto = '${a['titulo']} ${a['cliente'] ?? ''} ${a['notas'] ?? ''} ${a['asesor'] ?? ''}'.toLowerCase();
      return coincideTipo && coincideAsesor && coincideEstado && (busquedaActiva.isEmpty || texto.contains(busquedaActiva.toLowerCase()));
    }).toList()
      ..sort((a, b) {
        final prioridadOrden = {'Alta': 0, 'Media': 1, 'Baja': 2};
        final pA = prioridadOrden[a['prioridad']] ?? 1;
        final pB = prioridadOrden[b['prioridad']] ?? 1;
        if (pA != pB) return pA.compareTo(pB);
        return (a['fecha'] ?? '').compareTo(b['fecha'] ?? '');
      });
  }

  Map<String, List<Map<String, dynamic>>> get _actividadesPorAsesor {
    final agrupadas = <String, List<Map<String, dynamic>>>{};
    for (var a in _actividadesFiltradas) {
      final asesor = (a['asesor']?.toString().trim().isEmpty == true) ? 'Sin asignar' : (a['asesor'] ?? 'Sin asignar');
      if (!agrupadas.containsKey(asesor)) agrupadas[asesor] = [];
      agrupadas[asesor]!.add(a);
    }
    return agrupadas;
  }

  Set<String> _getAsesoresUnicos() {
    final asesores = <String>{};
    for (var a in _actividades) {
      final asesor = a['asesor']?.toString().trim();
      if (asesor != null && asesor.isNotEmpty) asesores.add(asesor);
    }
    return asesores;
  }

  String _formatearFecha(DateTime fecha) => '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  String _formatearHora(TimeOfDay hora) => '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  DateTime? _parsearFecha(String fechaStr) {
    if (fechaStr.isEmpty) return null;
    final partes = fechaStr.split('/');
    if (partes.length != 3) return null;
    try { return DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0])); } catch (e) { return null; }
  }

  void _mostrarFormularioActividad({Map<String, dynamic>? actividad}) {
    final esEditar = actividad != null;
    final tituloCtrl = TextEditingController(text: actividad?['titulo'] ?? '');
    final tipoCtrl = TextEditingController(text: actividad?['tipo'] ?? 'Llamada');
    final fechaCtrl = TextEditingController(text: actividad?['fecha'] ?? '');
    final horaCtrl = TextEditingController(text: actividad?['hora'] ?? '');
    final clienteCtrl = TextEditingController(text: actividad?['cliente'] ?? '');
    final asesorCtrl = TextEditingController(text: actividad?['asesor'] ?? '');
    final prioridadCtrl = TextEditingController(text: actividad?['prioridad'] ?? 'Media');
    final notasCtrl = TextEditingController(text: actividad?['notas'] ?? '');
    final clientes = LocalStorageService.getClientes();
    final asesores = LocalStorageService.getAsesores();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(esEditar ? 'Editar Actividad' : 'Nueva Actividad'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: tipoCtrl.text, decoration: const InputDecoration(labelText: 'Tipo'), items: ['Llamada', 'Reunión', 'Visita', 'Email', 'Seguimiento', 'WhatsApp'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setDialogState(() => tipoCtrl.text = v ?? '')),
              const SizedBox(height: 12),
              TextField(controller: fechaCtrl, decoration: const InputDecoration(labelText: 'Fecha', helperText: 'Toca para seleccionar', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () async { final fechaInicial = _parsearFecha(fechaCtrl.text) ?? DateTime.now(); final fechaSeleccionada = await showDatePicker(context: context, initialDate: fechaInicial, firstDate: DateTime(2020), lastDate: DateTime(2030)); if (fechaSeleccionada != null) setDialogState(() { fechaCtrl.text = _formatearFecha(fechaSeleccionada); }); }),
              const SizedBox(height: 12),
              TextField(controller: horaCtrl, decoration: const InputDecoration(labelText: 'Hora', helperText: 'Toca para seleccionar', suffixIcon: Icon(Icons.access_time)), readOnly: true, onTap: () async { TimeOfDay? horaInicial; if (horaCtrl.text.isNotEmpty) { final partes = horaCtrl.text.split(':'); if (partes.length == 2) horaInicial = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1])); } final horaSeleccionada = await showTimePicker(context: context, initialTime: horaInicial ?? TimeOfDay.now()); if (horaSeleccionada != null) setDialogState(() { horaCtrl.text = _formatearHora(horaSeleccionada); }); }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: clientes.any((c) => c['nombre'].toString() == clienteCtrl.text) ? clienteCtrl.text : null, decoration: const InputDecoration(labelText: 'Cliente'), hint: const Text('Selecciona un cliente'), items: clientes.map((c) => DropdownMenuItem<String>(value: c['nombre'].toString(), child: Text(c['nombre'].toString()))).toList(), onChanged: (v) => setDialogState(() => clienteCtrl.text = v ?? '')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: asesores.any((a) => a['nombre'].toString() == asesorCtrl.text) ? asesorCtrl.text : null, decoration: const InputDecoration(labelText: 'Asesor asignado'), hint: const Text('Selecciona un asesor'), items: asesores.map((a) => DropdownMenuItem<String>(value: a['nombre'].toString(), child: Text(a['nombre'].toString()))).toList(), onChanged: (v) => setDialogState(() => asesorCtrl.text = v ?? '')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: prioridadCtrl.text, decoration: const InputDecoration(labelText: 'Prioridad'), items: ['Alta', 'Media', 'Baja'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setDialogState(() => prioridadCtrl.text = v ?? '')),
              const SizedBox(height: 12),
              TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: 'Notas'), maxLines: 3),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () {
              final datos = {'titulo': tituloCtrl.text, 'tipo': tipoCtrl.text, 'fecha': fechaCtrl.text, 'hora': horaCtrl.text, 'cliente': clienteCtrl.text, 'asesor': asesorCtrl.text, 'prioridad': prioridadCtrl.text, 'completada': actividad?['completada'] ?? false, 'notas': notasCtrl.text};
              if (esEditar) { LocalStorageService.actualizarActividad(actividad!['id'].toString(), {...datos, 'id': actividad['id'].toString()}); } else { LocalStorageService.agregarActividad(datos); }
              Navigator.pop(ctx);
              _cargarActividades();
            }, child: Text(esEditar ? 'Guardar' : 'Agregar')),
          ],
        ),
      ),
    );
  }

  void _toggleCompletada(Map<String, dynamic> actividad) {
    LocalStorageService.actualizarActividad(actividad['id'].toString(), {...actividad, 'completada': !(actividad['completada'] ?? false)});
    _cargarActividades();
  }

  void _confirmarEliminar(Map<String, dynamic> actividad) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Eliminar Actividad'), content: Text('¿Estás seguro de eliminar "${actividad['titulo']}"?'), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
      ElevatedButton(onPressed: () { LocalStorageService.eliminarActividad(actividad['id'].toString()); Navigator.pop(ctx); _cargarActividades(); }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger), child: const Text('Eliminar')),
    ]));
  }

  Color _colorPrioridad(String p) { switch (p) { case 'Alta': return AppTheme.danger; case 'Media': return AppTheme.warning; case 'Baja': return AppTheme.success; default: return Colors.grey; } }
  IconData _iconoTipo(String t) { switch (t) { case 'Llamada': return Icons.phone; case 'Reunión': return Icons.people; case 'Visita': return Icons.location_on; case 'Email': return Icons.email; case 'Seguimiento': return Icons.track_changes; case 'WhatsApp': return Icons.message; default: return Icons.event; } }

  Widget _buildKpiCard({required IconData icon, required String value, required String label, required String subtitle, required Color color}) {
    return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
      Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
    ])));
  }

  Widget _buildActividadCard(Map<String, dynamic> a, {bool compacto = false}) {
    final completada = a['completada'] ?? false;
    final color = _colorPrioridad(a['prioridad'] ?? 'Media');
    final notas = a['notas'] ?? '';
    final asesor = a['asesor'] ?? '';
    final vencida = _estaVencida(a);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: vencida ? AppTheme.danger.withOpacity(0.5) : color.withOpacity(0.3))),
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Checkbox(value: completada, onChanged: (_) => _toggleCompletada(a), activeColor: AppTheme.success),
        const SizedBox(width: 12),
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(_iconoTipo(a['tipo'] ?? 'Llamada'), color: color, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a['titulo'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.getTextPrimaryColor(context), decoration: completada ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.calendar_today, size: 12, color: vencida ? AppTheme.danger : Colors.grey),
            const SizedBox(width: 4),
            Text('${a['fecha'] ?? ''} • ${a['hora'] ?? ''}', style: TextStyle(color: vencida ? AppTheme.danger : Colors.grey, fontSize: 13, fontWeight: vencida ? FontWeight.w600 : FontWeight.normal)),
            if (vencida) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('VENCIDA', style: TextStyle(color: AppTheme.danger, fontSize: 10, fontWeight: FontWeight.w700))),
            ],
            const SizedBox(width: 16),
            Icon(Icons.person, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(a['cliente'] ?? '', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
          if (asesor.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(children: [Icon(Icons.business, size: 12, color: AppTheme.primary), const SizedBox(width: 4), Text('Asesor: $asesor', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600))]),
          ],
          if (notas.isNotEmpty && !compacto) ...[
            const SizedBox(height: 6),
            Row(children: [Icon(Icons.note, size: 12, color: AppTheme.primary), const SizedBox(width: 4), Expanded(child: Text(notas, style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 12, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis))]),
          ],
        ])),
        const SizedBox(width: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(a['prioridad'] ?? 'Media', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20), onPressed: () => _mostrarFormularioActividad(actividad: a)),
        IconButton(icon: const Icon(Icons.delete, color: AppTheme.danger, size: 20), onPressed: () => _confirmarEliminar(a)),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final totalActividades = _actividades.length;
    final pendientes = _actividades.where((a) => a['completada'] != true).length;
    final completadas = _actividades.where((a) => a['completada'] == true).length;
    final altaPrioridad = _actividades.where((a) => a['prioridad'] == 'Alta' && a['completada'] != true).length;
    final vencidas = _actividades.where((a) => _estaVencida(a)).length;
    final hoy = DateTime.now();
    final hoyStr = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
    final actividadesHoy = _actividades.where((a) => a['fecha'] == hoyStr && a['completada'] != true).length;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(slivers: [
        SliverPersistentHeader(pinned: true, delegate: _StickyHeaderDelegate(height: 230, backgroundColor: AppTheme.getBackgroundColor(context), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Actividades', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))), const SizedBox(height: 2), Text('Gestiona tus tareas y seguimientos', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13))])),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: () => _mostrarFormularioActividad(), icon: const Icon(Icons.add, size: 16), label: const Text('Nueva Actividad', style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _buildKpiCard(icon: Icons.task, value: '$totalActividades', label: 'Total', subtitle: 'actividades', color: const Color(0xFF0D1B4C)),
            const SizedBox(width: 8),
            _buildKpiCard(icon: Icons.pending_actions, value: '$pendientes', label: 'Pendientes', subtitle: 'por realizar', color: AppTheme.danger),
            const SizedBox(width: 8),
            _buildKpiCard(icon: Icons.check_circle, value: '$completadas', label: 'Completadas', subtitle: 'realizadas', color: AppTheme.success),
            const SizedBox(width: 8),
            _buildKpiCard(icon: Icons.priority_high, value: '$altaPrioridad', label: 'Alta Prioridad', subtitle: 'urgentes', color: AppTheme.warning),
          ]),
        ])))),
        SliverPadding(padding: EdgeInsets.all(isMobile ? 16 : 24), sliver: SliverList(delegate: SliverChildListDelegate([
          Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Row(children: [Expanded(child: SegmentedButton<String>(segments: const [ButtonSegment(value: 'lista', label: Text('Lista'), icon: Icon(Icons.list, size: 16)), ButtonSegment(value: 'asesor', label: Text('Por Asesor'), icon: Icon(Icons.group, size: 16))], selected: {_vistaActual}, onSelectionChanged: (values) { setState(() { _vistaActual = values.first; }); }))]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _filtroEstado, decoration: const InputDecoration(labelText: 'Estado', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), items: ['Todas', 'Pendientes', 'Completadas', 'Vencidas', 'Hoy'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => _filtroEstado = v ?? 'Todas'))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(value: _filtroTipo, decoration: const InputDecoration(labelText: 'Tipo', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), items: ['Todas', 'Llamada', 'Reunión', 'Visita', 'Email', 'Seguimiento', 'WhatsApp'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => _filtroTipo = v ?? 'Todas'))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(value: _filtroAsesor, decoration: const InputDecoration(labelText: 'Asesor', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), items: ['Todos', ..._getAsesoresUnicos()].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => _filtroAsesor = v ?? 'Todos'))),
            ]),
            if (widget.busqueda != null && widget.busqueda!.isNotEmpty) ...[const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Text('Buscando: "${widget.busqueda}"', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600))]))],
          ]))),
          const SizedBox(height: 16),
          if (_vistaActual == 'lista') ...[
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.1), AppTheme.primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withOpacity(0.3))), child: Row(children: [
              Icon(Icons.today, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Resumen de hoy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)), Text('$actividadesHoy actividades pendientes para hoy', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13))])),
              if (vencidas > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('$vencidas vencidas', style: TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.w700))),
            ])),
            const SizedBox(height: 16),
          ],
          if (_vistaActual == 'asesor') ...[
            if (_actividadesPorAsesor.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(60), child: Center(child: Column(children: [Icon(Icons.group_off, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('No hay actividades', style: TextStyle(color: Colors.grey, fontSize: 16))]))))
            else ..._actividadesPorAsesor.entries.map((entry) {
              final asesor = entry.key;
              final actividades = entry.value;
              final completadasAsesor = actividades.where((a) => a['completada'] == true).length;
              final totalAsesor = actividades.length;
              final progreso = totalAsesor > 0 ? completadasAsesor / totalAsesor : 0.0;
              return Container(margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withOpacity(0.2))), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Icon(Icons.person, color: AppTheme.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(asesor, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.getTextPrimaryColor(context))), Text('$completadasAsesor de $totalAsesor completadas', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13))])), Text('${(progreso * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: progreso >= 0.7 ? AppTheme.success : progreso >= 0.4 ? AppTheme.warning : AppTheme.danger))]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progreso, backgroundColor: Colors.grey.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(progreso >= 0.7 ? AppTheme.success : progreso >= 0.4 ? AppTheme.warning : AppTheme.danger), minHeight: 8)),
                const SizedBox(height: 12),
                ...actividades.map((a) => _buildActividadCard(a, compacto: true)),
              ])));
            }).toList(),
          ] else ...[
            if (_actividadesFiltradas.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(60), child: Center(child: Column(children: [Icon(Icons.event_note, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('No hay actividades', style: TextStyle(color: Colors.grey, fontSize: 16))]))))
            else ..._actividadesFiltradas.map((a) => _buildActividadCard(a)).toList(),
          ],
        ]))),
      ]),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height; final Widget child; final Color backgroundColor;
  _StickyHeaderDelegate({required this.height, required this.child, required this.backgroundColor});
  @override double get minExtent => height;
  @override double get maxExtent => height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: backgroundColor, child: child);
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}