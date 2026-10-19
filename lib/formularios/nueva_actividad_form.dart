import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/mock_data.dart';

class NuevaActividadForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onActividadCreada;
  const NuevaActividadForm({super.key, required this.onActividadCreada});

  @override
  State<NuevaActividadForm> createState() => _NuevaActividadFormState();
}

class _NuevaActividadFormState extends State<NuevaActividadForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _clienteController = TextEditingController();

  // Campos seleccionables
  String _tipo = 'Llamada';
  String _prioridad = 'Media';
  String _clienteSeleccionado = '';
  DateTime _fecha = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 10, minute: 0);
  bool _recordatorio = true;
  Duration _tiempoRecordatorio = const Duration(hours: 1);

  final List<String> _tipos = [
    'Llamada',
    'Reunión',
    'Visita',
    'Firma',
    'Presentación',
    'Seguimiento',
    'Email',
    'Otro'
  ];
  final List<String> _prioridades = ['Alta', 'Media', 'Baja'];
  final List<Duration> _tiemposRecordatorio = [
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 2),
    const Duration(hours: 24),
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _clienteController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fecha) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _hora,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _hora) {
      setState(() => _hora = picked);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  void _guardarActividad() {
    if (_formKey.currentState!.validate()) {
      final nuevaActividad = {
        'titulo': _tituloController.text.trim(),
        'tipo': _tipo,
        'fecha':
            '${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
        'hora':
            '${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}',
        'cliente':
            _clienteSeleccionado.isEmpty ? 'General' : _clienteSeleccionado,
        'descripcion': _descripcionController.text.trim(),
        'prioridad': _prioridad,
        'recordatorio': _recordatorio,
        'tiempoRecordatorio': _tiempoRecordatorio.inHours > 0
            ? '${_tiempoRecordatorio.inHours}h antes'
            : '${_tiempoRecordatorio.inMinutes}min antes',
        'completada': false,
      };

      widget.onActividadCreada(nuevaActividad);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Actividad "${nuevaActividad['titulo']}" creada exitosamente'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  Color _colorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return AppTheme.danger;
      case 'Media':
        return AppTheme.accent;
      case 'Baja':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'Llamada':
        return Icons.phone;
      case 'Reunión':
        return Icons.people;
      case 'Visita':
        return Icons.location_on;
      case 'Firma':
        return Icons.edit_note;
      case 'Presentación':
        return Icons.slideshow;
      case 'Seguimiento':
        return Icons.track_changes;
      case 'Email':
        return Icons.email;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Nueva Actividad'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _guardarActividad,
            icon: const Icon(Icons.check, color: AppTheme.accent),
            label: const Text('Guardar',
                style: TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFORMACIÓN BÁSICA
              const Text('Información básica',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tituloController,
                label: 'Título de la actividad',
                icon: Icons.title,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDropdown('Tipo', _tipo, _tipos,
                          (v) => setState(() => _tipo = v!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDropdown(
                          'Prioridad',
                          _prioridad,
                          _prioridades,
                          (v) => setState(() => _prioridad = v!))),
                ],
              ),
              const SizedBox(height: 32),

              // FECHA Y HORA
              const Text('Fecha y hora',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCampoSeleccionable(
                      label: 'Fecha',
                      valor: _formatearFecha(_fecha),
                      icon: Icons.calendar_today,
                      onTap: _seleccionarFecha,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCampoSeleccionable(
                      label: 'Hora',
                      valor: _hora.format(context),
                      icon: Icons.access_time,
                      onTap: _seleccionarHora,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recordatorio',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            _recordatorio
                                ? '${_tiempoRecordatorio.inHours > 0 ? "${_tiempoRecordatorio.inHours}h" : "${_tiempoRecordatorio.inMinutes}min"} antes'
                                : 'Sin recordatorio',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _recordatorio,
                      onChanged: (valor) =>
                          setState(() => _recordatorio = valor),
                      activeThumbColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              if (_recordatorio) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tiemposRecordatorio.map((tiempo) {
                    final isSelected = _tiempoRecordatorio == tiempo;
                    return FilterChip(
                      label: Text(
                        tiempo.inHours > 0
                            ? '${tiempo.inHours}h antes'
                            : '${tiempo.inMinutes}min antes',
                      ),
                      selected: isSelected,
                      onSelected: (valor) {
                        if (valor) setState(() => _tiempoRecordatorio = tiempo);
                      },
                      backgroundColor: AppTheme.surface,
                      selectedColor: AppTheme.primary.withValues(alpha: 0.1),
                      checkmarkColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                          color:
                              isSelected ? AppTheme.primary : AppTheme.border),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),

              // CLIENTE RELACIONADO
              const Text('Cliente relacionado',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildDropdownCliente(),
              const SizedBox(height: 32),

              // DESCRIPCIÓN
              const Text('Descripción',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe los detalles de la actividad...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // VISTA PREVIA
              const Text('Vista previa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _colorPrioridad(_prioridad).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconoTipo(_tipo),
                          color: _colorPrioridad(_prioridad), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tituloController.text.isEmpty
                                ? 'Título de la actividad'
                                : _tituloController.text,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatearFecha(_fecha)} • ${_hora.format(context)}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _clienteSeleccionado.isEmpty
                                ? 'General'
                                : _clienteSeleccionado,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            _colorPrioridad(_prioridad).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _prioridad,
                        style: TextStyle(
                            color: _colorPrioridad(_prioridad),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _guardarActividad,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text('GUARDAR ACTIVIDAD',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCampoSeleccionable({
    required String label,
    required String valor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(valor,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCliente() {
    final clientes = MockData.clientes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _clienteSeleccionado.isEmpty ? null : _clienteSeleccionado,
          isExpanded: true,
          hint: const Text('Selecciona un cliente (opcional)',
              style: TextStyle(color: AppTheme.textSecondary)),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          items: [
            const DropdownMenuItem(
                value: '', child: Text('General (sin cliente específico)')),
            ...clientes.map((cliente) => DropdownMenuItem(
                  value: cliente.nombreCompleto,
                  child: Text(cliente.nombreCompleto),
                )),
          ],
          onChanged: (valor) {
            setState(() => _clienteSeleccionado = valor ?? '');
          },
        ),
      ),
    );
  }
}
