import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/actividades_service.dart';
import '../../services/clientes_service.dart';
import '../../services/asesores_service.dart';
import '../../widgets/searchable_dropdown.dart';

class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({super.key});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  List<Map<String, dynamic>> _actividades = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _asesores = [];
  Map<String, dynamic> _stats = {};
  String _filtroTipo = 'Todas';
  bool _mostrarCompletadas = false;
  String _busqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _actividades = await ActividadesService.getActividades();
      _clientes = await ClientesService.getClientes();
      _asesores = await AsesoresService.getAsesores();
      _stats = await ActividadesService.getEstadisticas();
    } catch (e) {
      print('Error al cargar: $e');
    }
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final actividadesFiltradas = _getActividadesFiltradas();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.task, color: Colors.white), SizedBox(width: 8), Text('Actividades')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _abrirFormulario(),
                tooltip: 'Nueva actividad',
              ),
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildKPICard('Total', '${_stats['total'] ?? 0}', const Color(0xFF3B82F6))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard('Pendientes', '${_stats['pendientes'] ?? 0}', const Color(0xFFF59E0B))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard('Completadas', '${_stats['completadas'] ?? 0}', const Color(0xFF10B981))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (value) => setState(() => _busqueda = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar por título, cliente o asesor...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.getTextSecondaryColor(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filtroTipo,
                          decoration: InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                          ),
                          items: ['Todas', 'Llamada', 'Reunión', 'Visita', 'Seguimiento', 'Otra'].map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                          onChanged: (value) => setState(() => _filtroTipo = value ?? 'Todas'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(_mostrarCompletadas ? Icons.visibility : Icons.visibility_off, color: AppTheme.primary),
                        onPressed: () => setState(() => _mostrarCompletadas = !_mostrarCompletadas),
                        tooltip: _mostrarCompletadas ? 'Ocultar completadas' : 'Mostrar completadas',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: actividadesFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task_alt, size: 80, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                              const SizedBox(height: 16),
                              const Text('No hay actividades', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              const Text('Crea tu primera actividad', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => _abrirFormulario(),
                                icon: const Icon(Icons.add),
                                label: const Text('Nueva actividad'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: actividadesFiltradas.length,
                          itemBuilder: (context, index) => _buildActividadCard(actividadesFiltradas[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildKPICard(String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
      ]),
    );
  }

  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    final titulo = actividad['titulo'] ?? 'Sin título';
    final descripcion = actividad['descripcion'] ?? '';
    final tipo = actividad['tipo'] ?? 'Otra';
    final fecha = actividad['fecha'] ?? '';
    final hora = actividad['hora'] ?? '';
    final cliente = actividad['cliente'] ?? '';
    final asesor = actividad['asesor'] ?? '';
    final completada = actividad['completada'] ?? false;
    final prioridad = actividad['prioridad'] ?? 'Normal';

    final colorTipo = _getColorPorTipo(tipo);
    final colorPrioridad = _getColorPorPrioridad(prioridad);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => ActividadesService.toggleCompletada(actividad['id']).then((_) => _cargarDatos()),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: completada ? const Color(0xFF10B981) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981), width: 2),
                  ),
                  child: completada ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: completada ? AppTheme.getTextSecondaryColor(context) : AppTheme.getTextColor(context),
                        decoration: completada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(descripcion, style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: colorTipo.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(tipo, style: TextStyle(fontSize: 10, color: colorTipo, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              if (fecha.isNotEmpty) ...[
                Icon(Icons.calendar_today, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                const SizedBox(width: 4),
                Text(fecha, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                const SizedBox(width: 12),
              ],
              if (hora.isNotEmpty) ...[
                Icon(Icons.access_time, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                const SizedBox(width: 4),
                Text(hora, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                const SizedBox(width: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorPrioridad.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(prioridad, style: TextStyle(fontSize: 10, color: colorPrioridad, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (cliente.isNotEmpty || asesor.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (cliente.isNotEmpty) ...[
                  Icon(Icons.person, size: 14, color: const Color(0xFF3B82F6)),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Cliente: $cliente', style: TextStyle(fontSize: 11, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                ],
                if (asesor.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.badge, size: 14, color: const Color(0xFF8B5CF6)),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Asesor: $asesor', style: TextStyle(fontSize: 11, color: const Color(0xFF8B5CF6), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(icon: Icons.edit, label: 'Editar', color: const Color(0xFF3B82F6), onPressed: () => _abrirFormulario(actividad: actividad)),
              const SizedBox(width: 8),
              _buildActionButton(icon: Icons.delete, label: 'Eliminar', color: const Color(0xFFEF4444), onPressed: () => _confirmarEliminar(actividad['id'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))]),
      ),
    );
  }

  void _abrirFormulario({Map<String, dynamic>? actividad}) {
    final esEdicion = actividad != null;
    final tituloCtrl = TextEditingController(text: actividad?['titulo'] ?? '');
    final descripcionCtrl = TextEditingController(text: actividad?['descripcion'] ?? '');
    final fechaCtrl = TextEditingController(text: actividad?['fecha'] ?? DateTime.now().toIso8601String().split('T')[0]);
    final horaCtrl = TextEditingController(text: actividad?['hora'] ?? '');
    final clienteCtrl = TextEditingController(text: actividad?['cliente'] ?? '');
    final asesorCtrl = TextEditingController(text: actividad?['asesor'] ?? '');
    String tipo = actividad?['tipo'] ?? 'Llamada';
    String prioridad = actividad?['prioridad'] ?? 'Normal';
    bool completada = actividad?['completada'] ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(esEdicion ? Icons.edit : Icons.add_task, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        esEdicion ? 'Editar Actividad' : 'Nueva Actividad',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextColor(context)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(tituloCtrl, 'Título *', Icons.title),
                  const SizedBox(height: 16),
                  _buildTextField(descripcionCtrl, 'Descripción', Icons.description, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    tipo,
                    'Tipo de actividad',
                    Icons.category,
                    ['Llamada', 'Reunión', 'Visita', 'Seguimiento', 'Otra'],
                    (val) => setDialogState(() => tipo = val ?? 'Llamada'),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    prioridad,
                    'Prioridad',
                    Icons.flag,
                    ['Baja', 'Normal', 'Alta', 'Urgente'],
                    (val) => setDialogState(() => prioridad = val ?? 'Normal'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(fechaCtrl, 'Fecha', Icons.calendar_today)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(horaCtrl, 'Hora', Icons.access_time)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdown(
                    value: clienteCtrl.text.isEmpty ? 'Sin cliente' : clienteCtrl.text,
                    hint: 'Cliente',
                    icon: Icons.person,
                    items: ['Sin cliente', ..._clientes.map((c) => c['nombre'].toString()).toList()],
                    showAvatars: true,
                    avatarLetters: Map.fromEntries(
                      _clientes.map((c) => MapEntry(
                        c['nombre'].toString(),
                        c['nombre'].toString().isNotEmpty ? c['nombre'].toString().substring(0, 1).toUpperCase() : '?',
                      )),
                    ),
                    onChanged: (val) => setDialogState(() {
                      clienteCtrl.text = val == 'Sin cliente' ? '' : val;
                    }),
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdown(
                    value: asesorCtrl.text.isEmpty ? 'Sin asesor asignado' : asesorCtrl.text,
                    hint: 'Asesor',
                    icon: Icons.badge,
                    items: ['Sin asesor asignado', ..._asesores.map((a) => a['nombre'].toString()).toList()],
                    showAvatars: true,
                    avatarLetters: Map.fromEntries(
                      _asesores.map((a) => MapEntry(
                        a['nombre'].toString(),
                        a['nombre'].toString().isNotEmpty ? a['nombre'].toString().substring(0, 1).toUpperCase() : '?',
                      )),
                    ),
                    onChanged: (val) => setDialogState(() {
                      asesorCtrl.text = val == 'Sin asesor asignado' ? '' : val;
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(completada ? Icons.check_circle : Icons.radio_button_unchecked, 
                           color: completada ? const Color(0xFF10B981) : AppTheme.getTextSecondaryColor(context), size: 20),
                      const SizedBox(width: 8),
                      Text('Marcar como completada', style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Switch(
                        value: completada,
                        onChanged: (value) => setDialogState(() => completada = value),
                        activeColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: AppTheme.getDividerColor(context)),
                          ),
                          child: Text('Cancelar', style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (tituloCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El título es obligatorio'), backgroundColor: Color(0xFFF59E0B)));
                              return;
                            }
                            final datos = {
                              'titulo': tituloCtrl.text,
                              'descripcion': descripcionCtrl.text,
                              'tipo': tipo,
                              'prioridad': prioridad,
                              'fecha': fechaCtrl.text,
                              'hora': horaCtrl.text,
                              'cliente': clienteCtrl.text,
                              'asesor': asesorCtrl.text,
                              'completada': completada,
                            };
                            try {
                              if (esEdicion && actividad != null) {
                                await ActividadesService.actualizarActividad(actividad['id'], datos);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Actividad actualizada'), backgroundColor: Color(0xFF10B981)));
                              } else {
                                await ActividadesService.agregarActividad(datos);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Actividad creada'), backgroundColor: Color(0xFF10B981)));
                              }
                              Navigator.pop(dialogContext);
                              await _cargarDatos();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(esEdicion ? 'Actualizar' : 'Guardar Actividad', style: const TextStyle(fontWeight: FontWeight.w700)),
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
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.getTextSecondaryColor(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppTheme.getBackgroundColor(context),
      ),
    );
  }

  Widget _buildDropdownField(String value, String label, IconData icon, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.getTextSecondaryColor(context)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppTheme.getBackgroundColor(context),
      ),
      items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar actividad?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await ActividadesService.eliminarActividad(id);
              Navigator.pop(ctx);
              await _cargarDatos();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getActividadesFiltradas() {
    var actividades = _actividades;
    if (_filtroTipo != 'Todas') {
      actividades = actividades.where((a) => a['tipo'] == _filtroTipo).toList();
    }
    if (!_mostrarCompletadas) {
      actividades = actividades.where((a) => !(a['completada'] ?? false)).toList();
    }
    if (_busqueda.isNotEmpty) {
      final busq = _busqueda.toLowerCase();
      actividades = actividades.where((a) {
        final titulo = (a['titulo'] ?? '').toString().toLowerCase();
        final descripcion = (a['descripcion'] ?? '').toString().toLowerCase();
        final cliente = (a['cliente'] ?? '').toString().toLowerCase();
        final asesor = (a['asesor'] ?? '').toString().toLowerCase();
        return titulo.contains(busq) || descripcion.contains(busq) || cliente.contains(busq) || asesor.contains(busq);
      }).toList();
    }
    actividades.sort((a, b) {
      final fechaA = a['fecha'] ?? '';
      final fechaB = b['fecha'] ?? '';
      return fechaB.compareTo(fechaA);
    });
    return actividades;
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo) {
      case 'Llamada': return const Color(0xFF3B82F6);
      case 'Reunión': return const Color(0xFF8B5CF6);
      case 'Visita': return const Color(0xFF10B981);
      case 'Seguimiento': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getColorPorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Baja': return const Color(0xFF10B981);
      case 'Normal': return const Color(0xFF3B82F6);
      case 'Alta': return const Color(0xFFF59E0B);
      case 'Urgente': return const Color(0xFFEF4444);
      default: return const Color(0xFF3B82F6);
    }
  }
}