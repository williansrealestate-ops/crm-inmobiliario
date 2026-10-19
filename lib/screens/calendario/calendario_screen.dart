import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/calendario_service.dart';
import '../../services/clientes_supabase_service.dart';
import '../../services/asesores_service.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _fechaSeleccionada = DateTime.now();
  DateTime _mesActual = DateTime.now();
  List<Map<String, dynamic>> _eventos = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _asesores = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _eventos = await CalendarioService.getEventosDelMes(
        _mesActual.year,
        _mesActual.month,
      );
      _clientes = await ClientesSupabaseService.getClientes();
      _asesores = await AsesoresService.getAsesores();
    } catch (e) {
      print('Error al cargar calendario: $e');
    }
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white),
            SizedBox(width: 8),
            Text('Calendario'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirFormulario(),
            tooltip: 'Agregar evento',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header del mes
                _buildHeaderMes(),
                const SizedBox(height: 8),
                
                // Calendario mensual (compacto)
                _buildCalendarioMensual(),
                const SizedBox(height: 8),
                
                // Eventos del día seleccionado (ocupa el espacio restante)
                Expanded(
                  child: _buildEventosDelDia(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderMes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.getSurfaceColor(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _mesActual = DateTime(_mesActual.year, _mesActual.month - 1);
              });
              _cargarDatos();
            },
          ),
          Text(
            '${_getNombreMes(_mesActual.month)} ${_mesActual.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _mesActual = DateTime(_mesActual.year, _mesActual.month + 1);
              });
              _cargarDatos();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarioMensual() {
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1).weekday;
    // Ajustar para que lunes sea 0 (en Dart, lunes=1, domingo=7)
    final offset = primerDia - 1;
    final diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: diasSemana.map((dia) => Expanded(
              child: Center(
                child: Text(
                  dia,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextSecondaryColor(context),
                    fontSize: 11,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          // Días del mes (compacto)
          SizedBox(
            height: 240, // Altura fija para evitar overflow
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.2, // Más alto que ancho
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dia = index - offset + 1;
                if (dia < 1 || dia > diasEnMes) {
                  return const SizedBox();
                }

                final fecha = DateTime(_mesActual.year, _mesActual.month, dia);
                final esHoy = _esMismoDia(fecha, DateTime.now());
                final estaSeleccionado = _esMismoDia(fecha, _fechaSeleccionada);
                final tieneEventos = _tieneEventosEnFecha(fecha);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _fechaSeleccionada = fecha;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: estaSeleccionado
                          ? AppTheme.primary
                          : esHoy
                              ? AppTheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dia.toString(),
                            style: TextStyle(
                              color: estaSeleccionado
                                  ? Colors.white
                                  : AppTheme.getTextColor(context),
                              fontWeight: estaSeleccionado || esHoy
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          if (tieneEventos)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventosDelDia() {
    final eventosDelDia = _eventos
        .where((e) {
          try {
            final fechaEvento = DateTime.parse(e['fecha_inicio']);
            return _esMismoDia(fechaEvento, _fechaSeleccionada);
          } catch (e) {
            return false;
          }
        })
        .toList();

    if (eventosDelDia.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: AppTheme.getTextSecondaryColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay eventos para el ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _abrirFormulario(fecha: _fechaSeleccionada),
                icon: const Icon(Icons.add),
                label: const Text('Agregar evento'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: eventosDelDia.length,
      itemBuilder: (context, index) {
        final evento = eventosDelDia[index];
        return _buildEventoCard(evento);
      },
    );
  }

  Widget _buildEventoCard(Map<String, dynamic> evento) {
    final horaInicio = DateTime.parse(evento['fecha_inicio']);
    final horaFin = DateTime.parse(evento['fecha_fin']);
    final color = Color(int.parse(evento['color'].replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  evento['titulo'] ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  evento['tipo'] ?? 'Cita',
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '${_formatearHora(horaInicio)} - ${_formatearHora(horaFin)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          if (evento['ubicacion'] != null && evento['ubicacion'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    evento['ubicacion'],
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (evento['cliente'] != null && evento['cliente'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF3B82F6)),
                const SizedBox(width: 4),
                Text(
                  'Cliente: ${evento['cliente']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
                ),
              ],
            ),
          ],
          if (evento['asesor'] != null && evento['asesor'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.badge, size: 14, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 4),
                Text(
                  'Asesor: ${evento['asesor']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8B5CF6)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF3B82F6)),
                onPressed: () => _abrirFormulario(evento: evento),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                onPressed: () => _confirmarEliminar(evento['id']),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _abrirFormulario({Map<String, dynamic>? evento, DateTime? fecha}) {
    final esEdicion = evento != null;
    final fechaInicio = esEdicion
        ? DateTime.parse(evento['fecha_inicio'])
        : (fecha ?? DateTime.now());
    final fechaFin = esEdicion
        ? DateTime.parse(evento['fecha_fin'])
        : fechaInicio.add(const Duration(hours: 1));

    final tituloCtrl = TextEditingController(text: evento?['titulo'] ?? '');
    final descripcionCtrl = TextEditingController(text: evento?['descripcion'] ?? '');
    final ubicacionCtrl = TextEditingController(text: evento?['ubicacion'] ?? '');
    
    String tipoSeleccionado = evento?['tipo'] ?? 'Cita';
    String estadoSeleccionado = evento?['estado'] ?? 'Programado';
    String colorSeleccionado = evento?['color'] ?? '#3B82F6';
    String clienteSeleccionado = evento?['cliente'] ?? '';
    String asesorSeleccionado = evento?['asesor'] ?? '';
    bool recordatorio = evento?['recordatorio'] ?? true;
    int minutosRecordatorio = evento?['minutos_recordatorio'] ?? 30;

    DateTime fechaInicioSel = fechaInicio;
    DateTime fechaFinSel = fechaFin;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        esEdicion ? Icons.edit : Icons.event,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          esEdicion ? 'Editar Evento' : 'Nuevo Evento',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(tituloCtrl, 'Título *', Icons.title),
                  const SizedBox(height: 12),
                  
                  _buildDropdownField(
                    tipoSeleccionado,
                    'Tipo de evento',
                    Icons.category,
                    CalendarioService.getTiposEvento(),
                    (val) => setDialogState(() => tipoSeleccionado = val ?? 'Cita'),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDateTimeField(
                    'Inicio',
                    Icons.event,
                    fechaInicioSel,
                    (val) => setDialogState(() {
                      if (val != null) fechaInicioSel = val;
                    }),
                  ),
                  const SizedBox(height: 8),
                  _buildDateTimeField(
                    'Fin',
                    Icons.event,
                    fechaFinSel,
                    (val) => setDialogState(() {
                      if (val != null) fechaFinSel = val;
                    }),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildTextField(ubicacionCtrl, 'Ubicación', Icons.location_on),
                  const SizedBox(height: 12),
                  
                  _buildDropdownField(
                    clienteSeleccionado.isEmpty ? 'Sin cliente' : clienteSeleccionado,
                    'Cliente',
                    Icons.person,
                    ['Sin cliente', ..._clientes.map((c) => c['nombre'].toString())],
                    (val) => setDialogState(() {
                      clienteSeleccionado = val == 'Sin cliente' ? '' : val ?? '';
                    }),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDropdownField(
                    asesorSeleccionado.isEmpty ? 'Sin asesor' : asesorSeleccionado,
                    'Asesor',
                    Icons.badge,
                    ['Sin asesor', ..._asesores.map((a) => a['nombre'].toString())],
                    (val) => setDialogState(() {
                      asesorSeleccionado = val == 'Sin asesor' ? '' : val ?? '';
                    }),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDropdownField(
                    estadoSeleccionado,
                    'Estado',
                    Icons.flag,
                    CalendarioService.getEstadosEvento(),
                    (val) => setDialogState(() => estadoSeleccionado = val ?? 'Programado'),
                  ),
                  const SizedBox(height: 12),
                  
                  Text('Color', style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: CalendarioService.getColoresEvento().map((color) {
                      final isSelected = colorSeleccionado == color;
                      return GestureDetector(
                        onTap: () => setDialogState(() => colorSeleccionado = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(
                        recordatorio ? Icons.notifications : Icons.notifications_off,
                        color: recordatorio ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text('Recordatorio', style: TextStyle(fontSize: 12)),
                      const Spacer(),
                      Switch(
                        value: recordatorio,
                        onChanged: (value) => setDialogState(() => recordatorio = value),
                      ),
                    ],
                  ),
                  if (recordatorio) ...[
                    const SizedBox(height: 6),
                    _buildDropdownField(
                      '$minutosRecordatorio',
                      'Minutos antes',
                      Icons.timer,
                      ['15', '30', '60', '120', '1440'],
                      (val) => setDialogState(() {
                        minutosRecordatorio = int.tryParse(val ?? '30') ?? 30;
                      }),
                    ),
                  ],
                  const SizedBox(height: 12),
                  
                  _buildTextField(descripcionCtrl, 'Descripción', Icons.description, maxLines: 3),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (tituloCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('⚠️ El título es obligatorio'),
                                  backgroundColor: Color(0xFFF59E0B),
                                ),
                              );
                              return;
                            }

                            final datos = {
                              'titulo': tituloCtrl.text,
                              'descripcion': descripcionCtrl.text,
                              'tipo': tipoSeleccionado,
                              'fecha_inicio': fechaInicioSel.toIso8601String(),
                              'fecha_fin': fechaFinSel.toIso8601String(),
                              'ubicacion': ubicacionCtrl.text,
                              'cliente': clienteSeleccionado,
                              'asesor': asesorSeleccionado,
                              'estado': estadoSeleccionado,
                              'color': colorSeleccionado,
                              'activo': true,
                              'recordatorio': recordatorio,
                              'minutos_recordatorio': minutosRecordatorio,
                            };

                            try {
                              if (esEdicion) {
                                await CalendarioService.actualizarEvento(evento['id'], datos);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Evento actualizado'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              } else {
                                await CalendarioService.agregarEvento(datos);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Evento creado'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              }
                              Navigator.pop(dialogContext);
                              await _cargarDatos();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(' Error: $e'),
                                  backgroundColor: const Color(0xFFEF4444),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
          prefixIcon: Icon(icon, color: Colors.white54, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value, String label, IconData icon, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        dropdownColor: const Color(0xFF2C2C2E),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
          prefixIcon: Icon(icon, color: Colors.white54, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: items.map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(color: Colors.white)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateTimeField(String label, IconData icon, DateTime value, ValueChanged<DateTime?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (time != null) {
              onChanged(DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              ));
            }
          }
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    _formatearFechaHora(value),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: const Text('¿Eliminar evento?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await CalendarioService.eliminarEvento(id);
                Navigator.pop(ctx);
                await _cargarDatos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Evento eliminado'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _tieneEventosEnFecha(DateTime fecha) {
    return _eventos.any((e) {
      try {
        final fechaEvento = DateTime.parse(e['fecha_inicio']);
        return _esMismoDia(fechaEvento, fecha);
      } catch (e) {
        return false;
      }
    });
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  String _formatearFechaHora(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${_formatearHora(fecha)}';
  }

  String _getNombreMes(int mes) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[mes - 1];
  }
}