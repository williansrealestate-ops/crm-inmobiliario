import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<Map<String, dynamic>> _actividades = [];
  String _vistaActual = 'mes'; // 'mes', 'dia', 'agenda'
  String _filtroTipo = 'Todos';
  String _filtroAsesor = 'Todos';

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

  // ✅ Obtener eventos de un día específico
  List<Map<String, dynamic>> _eventosDelDia(DateTime dia) {
    final diaStr = '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';
    return _actividades.where((a) {
      if (a['fecha'] == null) return false;
      final coincideTipo = _filtroTipo == 'Todos' || a['tipo'] == _filtroTipo;
      final coincideAsesor = _filtroAsesor == 'Todos' || a['asesor'] == _filtroAsesor;
      return a['fecha'] == diaStr && coincideTipo && coincideAsesor;
    }).toList()
      ..sort((a, b) => (a['hora'] ?? '').compareTo(b['hora'] ?? ''));
  }

  // ✅ Eventos del mes actual
  List<Map<String, dynamic>> get _eventosDelMes {
    return _actividades.where((a) {
      if (a['fecha'] == null) return false;
      try {
        final partes = a['fecha'].split('/');
        final fechaEvento = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
        final coincideTipo = _filtroTipo == 'Todos' || a['tipo'] == _filtroTipo;
        final coincideAsesor = _filtroAsesor == 'Todos' || a['asesor'] == _filtroAsesor;
        return fechaEvento.year == _currentMonth.year &&
               fechaEvento.month == _currentMonth.month &&
               coincideTipo && coincideAsesor;
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort((a, b) => (a['fecha'] ?? '').compareTo(b['fecha'] ?? ''));
  }

  // ✅ Próximos eventos (desde hoy en adelante, no completados)
  List<Map<String, dynamic>> get _proximosEventos {
    final ahora = DateTime.now();
    return _actividades.where((a) {
      if (a['fecha'] == null || a['completada'] == true) return false;
      try {
        final partes = a['fecha'].split('/');
        final fechaEvento = DateTime(
          int.parse(partes[2]),
          int.parse(partes[1]),
          int.parse(partes[0]),
        );
        final coincideTipo = _filtroTipo == 'Todos' || a['tipo'] == _filtroTipo;
        final coincideAsesor = _filtroAsesor == 'Todos' || a['asesor'] == _filtroAsesor;
        return fechaEvento.isAfter(ahora.subtract(const Duration(days: 1))) && coincideTipo && coincideAsesor;
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort((a, b) => (a['fecha'] ?? '').compareTo(b['fecha'] ?? ''));
  }

  // ✅ Verificar si un día tiene eventos
  bool _diaTieneEventos(DateTime dia) {
    final diaStr = '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';
    return _actividades.any((a) => a['fecha'] == diaStr);
  }

  // ✅ Contar eventos de un día
  int _contarEventosDia(DateTime dia) {
    final diaStr = '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';
    return _actividades.where((a) => a['fecha'] == diaStr).length;
  }

  // ✅ Obtener tipos de eventos de un día
  Set<String> _tiposDelDia(DateTime dia) {
    final diaStr = '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';
    return _actividades.where((a) => a['fecha'] == diaStr).map((a) => (a['tipo'] ?? 'Reunión').toString()).toSet();
  }

  // ✅ Verificar si está vencida
  bool _estaVencida(Map<String, dynamic> a) {
    if (a['completada'] == true) return false;
    final fechaStr = a['fecha'] ?? '';
    if (fechaStr.isEmpty) return false;
    try {
      final partes = fechaStr.split('/');
      final fecha = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
      final hoy = DateTime.now();
      return fecha.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    } catch (e) {
      return false;
    }
  }

  Set<String> _getAsesoresUnicos() {
    final asesores = <String>{};
    for (var a in _actividades) {
      final asesor = a['asesor']?.toString().trim();
      if (asesor != null && asesor.isNotEmpty) {
        asesores.add(asesor);
      }
    }
    return asesores;
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'Llamada': return const Color(0xFF3B82F6);
      case 'Reunión': return const Color(0xFFF59E0B);
      case 'Visita': return const Color(0xFF10B981);
      case 'Email': return const Color(0xFF8B5CF6);
      case 'Seguimiento': return const Color(0xFFEC4899);
      case 'WhatsApp': return const Color(0xFF14B8A6);
      default: return Colors.grey;
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'Llamada': return Icons.phone;
      case 'Reunión': return Icons.people;
      case 'Visita': return Icons.location_on;
      case 'Email': return Icons.email;
      case 'Seguimiento': return Icons.track_changes;
      case 'WhatsApp': return Icons.message;
      default: return Icons.event;
    }
  }

  void _mostrarFormularioEvento({Map<String, dynamic>? actividad}) {
    final esEditar = actividad != null;
    final tituloCtrl = TextEditingController(text: actividad?['titulo'] ?? '');
    final tipoCtrl = TextEditingController(text: actividad?['tipo'] ?? 'Llamada');
    final fechaCtrl = TextEditingController(text: actividad?['fecha'] ?? _formatearFecha(_selectedDate));
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
          title: Text(esEditar ? 'Editar Evento' : 'Nuevo Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoCtrl.text,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: ['Llamada', 'Reunión', 'Visita', 'Email', 'Seguimiento', 'WhatsApp']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => tipoCtrl.text = v ?? ''),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fechaCtrl,
                  decoration: const InputDecoration(labelText: 'Fecha', helperText: 'Toca para seleccionar', suffixIcon: Icon(Icons.calendar_today)),
                  readOnly: true,
                  onTap: () async {
                    final fechaInicial = _parsearFecha(fechaCtrl.text) ?? _selectedDate;
                    final fechaSeleccionada = await showDatePicker(context: context, initialDate: fechaInicial, firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (fechaSeleccionada != null) {
                      setDialogState(() {
                        fechaCtrl.text = _formatearFecha(fechaSeleccionada);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: horaCtrl,
                  decoration: const InputDecoration(labelText: 'Hora', helperText: 'Toca para seleccionar', suffixIcon: Icon(Icons.access_time)),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? horaInicial;
                    if (horaCtrl.text.isNotEmpty) {
                      final partes = horaCtrl.text.split(':');
                      if (partes.length == 2) {
                        horaInicial = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
                      }
                    }
                    final horaSeleccionada = await showTimePicker(context: context, initialTime: horaInicial ?? TimeOfDay.now());
                    if (horaSeleccionada != null) {
                      setDialogState(() {
                        horaCtrl.text = _formatearHora(horaSeleccionada);
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: clientes.any((c) => c['nombre'].toString() == clienteCtrl.text) ? clienteCtrl.text : null,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  hint: const Text('Selecciona un cliente'),
                  items: clientes.map((c) => DropdownMenuItem<String>(value: c['nombre'].toString(), child: Text(c['nombre'].toString()))).toList(),
                  onChanged: (v) => setDialogState(() => clienteCtrl.text = v ?? ''),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: asesores.any((a) => a['nombre'].toString() == asesorCtrl.text) ? asesorCtrl.text : null,
                  decoration: const InputDecoration(labelText: 'Asesor'),
                  hint: const Text('Selecciona un asesor'),
                  items: asesores.map((a) => DropdownMenuItem<String>(value: a['nombre'].toString(), child: Text(a['nombre'].toString()))).toList(),
                  onChanged: (v) => setDialogState(() => asesorCtrl.text = v ?? ''),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prioridadCtrl.text,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: ['Alta', 'Media', 'Baja'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => prioridadCtrl.text = v ?? ''),
                ),
                const SizedBox(height: 12),
                TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: 'Notas'), maxLines: 3),
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
                  'asesor': asesorCtrl.text,
                  'prioridad': prioridadCtrl.text,
                  'completada': actividad?['completada'] ?? false,
                  'notas': notasCtrl.text,
                };
                if (esEditar) {
                  LocalStorageService.actualizarActividad(actividad['id'].toString(), {...datos, 'id': actividad['id'].toString()});
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

  void _toggleCompletada(Map<String, dynamic> actividad) {
    LocalStorageService.actualizarActividad(
      actividad['id'].toString(),
      {...actividad, 'completada': !(actividad['completada'] ?? false)},
    );
    _cargarActividades();
  }

  void _confirmarEliminar(Map<String, dynamic> actividad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: Text('¿Estás seguro de eliminar "${actividad['titulo']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              LocalStorageService.eliminarActividad(actividad['id'].toString());
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatearHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime? _parsearFecha(String fechaStr) {
    if (fechaStr.isEmpty) return null;
    final partes = fechaStr.split('/');
    if (partes.length != 3) return null;
    try {
      return DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
    } catch (e) {
      return null;
    }
  }

  String _getNombreMes(int mes) {
    const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return meses[mes - 1];
  }

  String _getNombreDiaSemana(int dia) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[dia - 1];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    final eventosHoy = _eventosDelDia(DateTime.now());
    final eventosSeleccionados = _eventosDelDia(_selectedDate);
    final totalMes = _eventosDelMes.length;
    final completadosMes = _eventosDelMes.where((a) => a['completada'] == true).length;
    final pendientesMes = totalMes - completadosMes;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // ✅ HEADER FIJO: Título + KPIs + Controles
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 320,
              backgroundColor: AppTheme.getBackgroundColor(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila 1: Título + Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Calendario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))),
                              const SizedBox(height: 4),
                              Text('Próximos eventos y citas', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _mostrarFormularioEvento(),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Nuevo Evento'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Fila 2: KPIs del mes
                    Row(
                      children: [
                        _buildKpiCard(icon: Icons.event, value: '$totalMes', label: 'Eventos', subtitle: 'este mes', color: const Color(0xFF0D1B4C)),
                        const SizedBox(width: 8),
                        _buildKpiCard(icon: Icons.check_circle, value: '$completadosMes', label: 'Completados', subtitle: 'realizados', color: AppTheme.success),
                        const SizedBox(width: 8),
                        _buildKpiCard(icon: Icons.pending_actions, value: '$pendientesMes', label: 'Pendientes', subtitle: 'por hacer', color: AppTheme.warning),
                        const SizedBox(width: 8),
                        _buildKpiCard(icon: Icons.today, value: '${eventosHoy.length}', label: 'Hoy', subtitle: 'programados', color: AppTheme.primary),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Fila 3: Navegación de mes + Vistas
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            '${_getNombreMes(_currentMonth.month)} ${_currentMonth.year}',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.getTextPrimaryColor(context)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime.now();
                              _selectedDate = DateTime.now();
                            });
                          },
                          icon: const Icon(Icons.today, size: 16),
                          label: const Text('Hoy', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Fila 4: Selector de vistas
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'mes', label: Text('Mes'), icon: Icon(Icons.calendar_month, size: 16)),
                              ButtonSegment(value: 'dia', label: Text('Día'), icon: Icon(Icons.view_day, size: 16)),
                              ButtonSegment(value: 'agenda', label: Text('Agenda'), icon: Icon(Icons.view_list, size: 16)),
                            ],
                            selected: {_vistaActual},
                            onSelectionChanged: (values) {
                              setState(() {
                                _vistaActual = values.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ✅ CONTENIDO SCROLLEABLE
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ✅ Filtros
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filtroTipo,
                            decoration: const InputDecoration(labelText: 'Tipo', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: ['Todos', 'Llamada', 'Reunión', 'Visita', 'Email', 'Seguimiento', 'WhatsApp']
                                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                                .toList(),
                            onChanged: (v) => setState(() => _filtroTipo = v ?? 'Todos'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filtroAsesor,
                            decoration: const InputDecoration(labelText: 'Asesor', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: ['Todos', ..._getAsesoresUnicos()]
                                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                                .toList(),
                            onChanged: (v) => setState(() => _filtroAsesor = v ?? 'Todos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ VISTA MES: Calendario completo
                if (_vistaActual == 'mes') ...[
                  _buildCalendarioMensual(),
                  const SizedBox(height: 24),
                  _buildSeccionEventosDia('Eventos del día seleccionado', _selectedDate, eventosSeleccionados),
                ],

                // ✅ VISTA DÍA: Solo el día seleccionado
                if (_vistaActual == 'dia') ...[
                  _buildVistaDia(),
                ],

                // ✅ VISTA AGENDA: Lista cronológica
                if (_vistaActual == 'agenda') ...[
                  _buildVistaAgenda(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Calendario mensual con indicadores
  Widget _buildCalendarioMensual() {
    final primerDia = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final diasEnMes = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final diaSemana = primerDia.weekday; // 1=Lunes, 7=Domingo

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Días de la semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [1, 2, 3, 4, 5, 6, 7].map((d) => Expanded(
                child: Center(
                  child: Text(
                    _getNombreDiaSemana(d),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.getTextSecondaryColor(context)),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            // Días del mes
            ...List.generate(6, (semanaIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (diaIndex) {
                  final diaNumero = (semanaIndex * 7) + diaIndex - diaSemana + 2;
                  if (diaNumero < 1 || diaNumero > diasEnMes) {
                    return const Expanded(child: SizedBox(height: 70));
                  }
                  final fecha = DateTime(_currentMonth.year, _currentMonth.month, diaNumero);
                  final esHoy = fecha.day == DateTime.now().day &&
                               fecha.month == DateTime.now().month &&
                               fecha.year == DateTime.now().year;
                  final esSeleccionado = fecha.day == _selectedDate.day &&
                                        fecha.month == _selectedDate.month &&
                                        fecha.year == _selectedDate.year;
                  final tieneEventos = _diaTieneEventos(fecha);
                  final numEventos = _contarEventosDia(fecha);
                  final tipos = _tiposDelDia(fecha);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = fecha;
                        });
                      },
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: esSeleccionado ? AppTheme.primary : (esHoy ? AppTheme.primary.withOpacity(0.1) : null),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: esSeleccionado ? AppTheme.primary : (esHoy ? AppTheme.primary : Colors.transparent),
                            width: esSeleccionado ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$diaNumero',
                              style: TextStyle(
                                color: esSeleccionado ? Colors.white : (esHoy ? AppTheme.primary : AppTheme.getTextPrimaryColor(context)),
                                fontWeight: esHoy || esSeleccionado ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (tieneEventos)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...tipos.take(3).map((tipo) => Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: _colorTipo(tipo),
                                      shape: BoxShape.circle,
                                    ),
                                  )),
                                  if (numEventos > 3)
                                    Text(
                                      '+${numEventos - 3}',
                                      style: TextStyle(fontSize: 8, color: AppTheme.getTextSecondaryColor(context)),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ✅ Vista de día completo
  Widget _buildVistaDia() {
    final eventos = _eventosDelDia(_selectedDate);
    final esHoy = _selectedDate.day == DateTime.now().day &&
                 _selectedDate.month == DateTime.now().month &&
                 _selectedDate.year == DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.1), AppTheme.primary.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${_selectedDate.day}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(_getNombreMes(_selectedDate.month).substring(0, 3), style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esHoy ? 'HOY' : _getNombreDiaSemana(_selectedDate.weekday).toUpperCase(),
                      style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedDate.day} de ${_getNombreMes(_selectedDate.month)} de ${_selectedDate.year}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context)),
                    ),
                    const SizedBox(height: 4),
                    Text('${eventos.length} eventos programados', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 32),
                onPressed: () => _mostrarFormularioEvento(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (eventos.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No hay eventos para este día', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarFormularioEvento(),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar evento'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...eventos.map((a) => _buildEventoCard(a)),
      ],
    );
  }

  // ✅ Vista Agenda: Lista cronológica
  Widget _buildVistaAgenda() {
    // Agrupar eventos por fecha
    final eventosAgrupados = <String, List<Map<String, dynamic>>>{};
    for (var a in _proximosEventos) {
      final fecha = a['fecha'] ?? '';
      if (!eventosAgrupados.containsKey(fecha)) {
        eventosAgrupados[fecha] = [];
      }
      eventosAgrupados[fecha]!.add(a);
    }

    if (eventosAgrupados.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                const Text('No hay próximos eventos', style: const TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: eventosAgrupados.entries.map((entry) {
        final fechaStr = entry.key;
        final eventos = entry.value;
        DateTime? fecha;
        try {
          final partes = fechaStr.split('/');
          fecha = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
        } catch (e) {}

        final esHoy = fecha != null && fecha.day == DateTime.now().day &&
                     fecha.month == DateTime.now().month &&
                     fecha.year == DateTime.now().year;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: esHoy ? AppTheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (esHoy) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    esHoy ? 'HOY' : fechaStr,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: esHoy ? AppTheme.primary : AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${eventos.length} evento${eventos.length == 1 ? '' : 's'}', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...eventos.map((a) => _buildEventoCard(a)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  // ✅ Sección de eventos de un día
  Widget _buildSeccionEventosDia(String titulo, DateTime dia, List<Map<String, dynamic>> eventos) {
    final esHoy = dia.day == DateTime.now().day &&
                 dia.month == DateTime.now().month &&
                 dia.year == DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_note, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
            const Spacer(),
            Text(
              _formatearFecha(dia),
              style: TextStyle(color: esHoy ? AppTheme.primary : AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (eventos.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    const Text('Sin eventos', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          )
        else
          ...eventos.map((a) => _buildEventoCard(a)),
      ],
    );
  }

  // ✅ Tarjeta de evento
  Widget _buildEventoCard(Map<String, dynamic> a) {
    final completada = a['completada'] ?? false;
    final color = _colorTipo(a['tipo'] ?? 'Reunión');
    final icono = _iconoTipo(a['tipo'] ?? 'Reunión');
    final vencida = _estaVencida(a);
    final notas = a['notas'] ?? '';
    final asesor = a['asesor'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: vencida ? AppTheme.danger.withOpacity(0.5) : color.withOpacity(0.3)),
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
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 24),
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
                      fontSize: 16,
                      color: AppTheme.getTextPrimaryColor(context),
                      decoration: completada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: vencida ? AppTheme.danger : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${a['fecha'] ?? ''} • ${a['hora'] ?? ''}',
                        style: TextStyle(
                          color: vencida ? AppTheme.danger : Colors.grey,
                          fontSize: 12,
                          fontWeight: vencida ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (vencida) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('VENCIDO', style: TextStyle(color: AppTheme.danger, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  if (a['cliente']?.toString().isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Cliente: ${a['cliente']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                  if (asesor.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.business, size: 12, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text('Asesor: $asesor', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  if (notas.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.note, size: 12, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notas,
                            style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 11, fontStyle: FontStyle.italic),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                a['tipo'] ?? 'Reunión',
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20), onPressed: () => _mostrarFormularioEvento(actividad: a)),
            IconButton(icon: const Icon(Icons.delete, color: AppTheme.danger, size: 20), onPressed: () => _confirmarEliminar(a)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({required IconData icon, required String value, required String label, required String subtitle, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
            Text(subtitle, style: TextStyle(fontSize: 9, color: AppTheme.getTextSecondaryColor(context))),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  final Color backgroundColor;
  _StickyHeaderDelegate({required this.height, required this.child, required this.backgroundColor});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}