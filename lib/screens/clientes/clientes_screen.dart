import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/clientes_supabase_service.dart';
import '../../services/asesores_service.dart';
import '../../widgets/ios_widgets.dart';
import '../../widgets/searchable_dropdown.dart';
import 'package:image_picker/image_picker.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String _busqueda = '';
  String _tipoFiltro = 'Todos';
  String _asesorFiltro = 'Todos';
  String _etapaFiltro = 'Todas';
  
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _asesores = [];
  List<String> _tipos = [];
  Map<String, dynamic> _stats = {'total': 0, 'activos': 0, 'compradores': 0, 'inversionistas': 0};
  bool _cargando = true;

  final List<String> _tiposNegocio = [
    'Inmobiliario',
    'Minerales',
    'Combustible',
    'Agropecuario',
    'Proyectos',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _clientes = await ClientesSupabaseService.getClientes();
      _asesores = await AsesoresService.getAsesores();
      _tipos = await ClientesSupabaseService.getTipos();
      _stats = await ClientesSupabaseService.getEstadisticas();
    } catch (e) {
      print('Error al cargar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = _getClientesFiltrados();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.people, color: Colors.white), SizedBox(width: 8), Text('Clientes')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.upload), onPressed: _importarClientes, tooltip: 'Importar'),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _abrirFormulario(),
              tooltip: 'Agregar nuevo cliente',
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context)))),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) => setState(() => _busqueda = value),
                        decoration: InputDecoration(
                          hintText: 'Buscar clientes...',
                          prefixIcon: Icon(Icons.search, color: AppTheme.getTextSecondaryColor(context)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: AppTheme.getBackgroundColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _tipoFiltro,
                              decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppTheme.getBackgroundColor(context)),
                              items: ['Todos', ..._tipos].map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                              onChanged: (value) => setState(() => _tipoFiltro = value ?? 'Todos'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _etapaFiltro,
                              decoration: InputDecoration(labelText: 'Etapa', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppTheme.getBackgroundColor(context)),
                              items: ['Todas', 'Nuevo', 'Contactado', 'Propuesta', 'Negociación', 'Cerrado', 'Perdido'].map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                              onChanged: (value) => setState(() => _etapaFiltro = value ?? 'Todas'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_asesores.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: _asesorFiltro,
                          decoration: InputDecoration(labelText: 'Asesor', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppTheme.getBackgroundColor(context)),
                          items: ['Todos', ..._asesores.map((a) => a['nombre'].toString())].map((a) => DropdownMenuItem<String>(value: a, child: Text(a))).toList(),
                          onChanged: (value) => setState(() => _asesorFiltro = value ?? 'Todos'),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildKPICard('Total', '${_stats['total']}', const Color(0xFF3B82F6))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard('Activos', '${_stats['activos']}', const Color(0xFF10B981))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard('Compradores', '${_stats['compradores']}', const Color(0xFFF59E0B))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildKPICard('Inversionistas', '${_stats['inversionistas']}', const Color(0xFF8B5CF6))),
                    ],
                  ),
                ),
                Expanded(
                  child: clientes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              const Text('No hay clientes registrados', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(onPressed: () => _abrirFormulario(), icon: const Icon(Icons.add), label: const Text('Agregar cliente')),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: clientes.length,
                          itemBuilder: (context, index) => _buildClienteCard(clientes[index]),
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

  Widget _buildClienteCard(Map<String, dynamic> cliente) {
    final nombre = cliente['nombre'] ?? 'Sin nombre';
    final tipo = cliente['tipo'] ?? 'Comprador';
    final tipoNegocio = cliente['tipo_negocio'] ?? 'Inmobiliario';
    final ubicacion = cliente['ubicacion'] ?? '';
    final presupuesto = _toDouble(cliente['presupuesto']);
    final catalogo = cliente['catalogo'] ?? '';
    final notas = cliente['notas'] ?? '';
    final estadoNegociacion = cliente['estado_negociacion'] ?? '';
    final asesor = cliente['asesor'] ?? '';
    final etapa = cliente['etapa'] ?? 'Nuevo';
    final telefono = cliente['telefono'] ?? '';
    final pais = cliente['pais'] ?? '';
    final estado = cliente['estado'] ?? '';
    final fotoUrl = cliente['foto_url'] ?? '';

    final colorTipo = tipo == 'Inversionista' ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B);
    final colorEtapa = _getColorPorEtapa(etapa);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context)), boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colorTipo, colorTipo.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(12),
              image: fotoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(fotoUrl), fit: BoxFit.cover) : null,
            ),
            child: fotoUrl.isEmpty ? Center(child: Text(nombre.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nombre, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
            const SizedBox(height: 4),
            if (ubicacion.isNotEmpty || pais.isNotEmpty || estado.isNotEmpty) 
              Row(children: [
                Icon(Icons.location_on, size: 14, color: AppTheme.getTextSecondaryColor(context)), 
                const SizedBox(width: 4), 
                Expanded(child: Text(
                  [pais, estado, ubicacion].where((e) => e.isNotEmpty).join(', '),
                  style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)), 
                  overflow: TextOverflow.ellipsis
                )),
              ]),
            if (telefono.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.phone, size: 14, color: const Color(0xFF10B981)), 
                const SizedBox(width: 4), 
                Text('Tel: $telefono', style: TextStyle(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ]),
            ],
            if (asesor.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [Icon(Icons.person, size: 14, color: const Color(0xFF3B82F6)), const SizedBox(width: 4), Expanded(child: Text('Asesor: $asesor', style: TextStyle(fontSize: 12, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))]),
            ],
          ])),
          Column(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: colorTipo.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(tipo, style: TextStyle(fontSize: 10, color: colorTipo, fontWeight: FontWeight.w700))),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: colorEtapa.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(etapa, style: TextStyle(fontSize: 10, color: colorEtapa, fontWeight: FontWeight.w700))),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        if (presupuesto > 0) Row(children: [Icon(Icons.attach_money, size: 16, color: const Color(0xFF10B981)), const SizedBox(width: 4), Text('Presupuesto: \$${presupuesto.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w600))]),
        if (catalogo.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inventory_2, size: 14, color: const Color(0xFFF59E0B)), const SizedBox(width: 4), Expanded(child: Text('Catálogo: $catalogo', style: TextStyle(fontSize: 11, color: const Color(0xFFF59E0B), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))])),
        ],
        if (estadoNegociacion.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.handshake, size: 14, color: const Color(0xFF3B82F6)), const SizedBox(width: 4), Text('Estado: $estadoNegociacion', style: TextStyle(fontSize: 11, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600))])),
        ],
        if (tipoNegocio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.business, size: 14, color: const Color(0xFF3B82F6)), const SizedBox(width: 4), Text('Negocio: $tipoNegocio', style: TextStyle(fontSize: 11, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600))])),
        ],
        if (notas.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.getBackgroundColor(context), borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: const Color(0xFF3B82F6), width: 3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.note, size: 14, color: const Color(0xFF3B82F6)), const SizedBox(width: 4), Text('Notas', style: TextStyle(fontSize: 11, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w700))]), const SizedBox(height: 4), Text(notas, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)))])),
        ],
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.primary.withOpacity(0.3))), child: IconButton(icon: const Icon(Icons.edit, size: 20, color: Color(0xFF3B82F6)), onPressed: () => _abrirFormulario(cliente: cliente), tooltip: 'Editar', padding: const EdgeInsets.all(10))),
          const SizedBox(width: 12),
          Container(decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3))), child: IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)), onPressed: () => _confirmarEliminar(cliente['id']), tooltip: 'Eliminar', padding: const EdgeInsets.all(10))),
        ]),
      ]),
    );
  }

  void _abrirFormulario({Map<String, dynamic>? cliente}) {
    final esEdicion = cliente != null;
    final nombreCtrl = TextEditingController(text: cliente?['nombre'] ?? '');
    final tipoCtrl = TextEditingController(text: cliente?['tipo'] ?? 'Comprador');
    final ubicacionCtrl = TextEditingController(text: cliente?['ubicacion'] ?? '');
    final presupuestoCtrl = TextEditingController(text: cliente?['presupuesto']?.toString() ?? '0');
    final catalogoCtrl = TextEditingController(text: cliente?['catalogo'] ?? '');
    final estadoNegociacionCtrl = TextEditingController(text: cliente?['estado_negociacion'] ?? '');
    final notasCtrl = TextEditingController(text: cliente?['notas'] ?? '');
    
    final telefonoCtrl = TextEditingController(text: cliente?['telefono'] ?? '');
    final paisCtrl = TextEditingController(text: cliente?['pais'] ?? 'México');
    final estadoCtrl = TextEditingController(text: cliente?['estado'] ?? '');
    String tipoNegocio = cliente?['tipo_negocio'] ?? 'Inmobiliario';
    
    String asesorSeleccionado = cliente?['asesor'] ?? '';
    String etapaSeleccionada = cliente?['etapa'] ?? 'Nuevo';
    bool activo = cliente?['activo'] ?? true;
    String fotoUrl = cliente?['foto_url'] ?? '';

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
                      Icon(esEdicion ? Icons.edit : Icons.person_add, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        esEdicion ? 'Editar Cliente' : 'Nuevo Cliente',
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
                  
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final imagen = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (imagen != null) {
                          final bytes = await imagen.readAsBytes();
                          final extension = imagen.path.split('.').last;
                          final clienteId = esEdicion ? cliente!['id'] : DateTime.now().millisecondsSinceEpoch.toString();
                          try {
                            final nuevaUrl = await ClientesSupabaseService.subirFoto(bytes, clienteId, '.$extension');
                            setDialogState(() => fotoUrl = nuevaUrl);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: const Color(0xFFEF4444)));
                          }
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                          image: fotoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(fotoUrl), fit: BoxFit.cover) : null,
                        ),
                        child: fotoUrl.isEmpty ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.white54, size: 32),
                            SizedBox(height: 4),
                            Text('Agregar foto', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ) : null,
                      ),
                    ),
                  ),
                  if (fotoUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setDialogState(() => fotoUrl = ''),
                        icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 16),
                        label: const Text('Eliminar foto', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  _buildTextField(nombreCtrl, 'Nombre completo *', Icons.person),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(paisCtrl, 'País', Icons.public)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(estadoCtrl, 'Estado', Icons.location_city)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(telefonoCtrl, 'Número de teléfono', Icons.phone),
                  const SizedBox(height: 16),
                  
                  _buildDropdownField(
                    tipoCtrl.text,
                    'Tipo de cliente',
                    Icons.category,
                    _tipos.isEmpty ? ['Comprador', 'Inversionista', 'Vendedor'] : _tipos,
                    (val) => setDialogState(() => tipoCtrl.text = val ?? 'Comprador'),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdownField(
                    tipoNegocio,
                    'Tipo de Negocio',
                    Icons.business,
                    _tiposNegocio,
                    (val) => setDialogState(() => tipoNegocio = val ?? 'Inmobiliario'),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDropdownField(
                    etapaSeleccionada,
                    'Etapa del Pipeline',
                    Icons.trending_up,
                    ['Nuevo', 'Contactado', 'Propuesta', 'Negociación', 'Cerrado', 'Perdido'],
                    (val) => setDialogState(() => etapaSeleccionada = val ?? 'Nuevo'),
                    isEtapa: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(ubicacionCtrl, 'Ubicación', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildTextField(presupuestoCtrl, 'Presupuesto (MXN)', Icons.attach_money, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(catalogoCtrl, 'Catálogo de interés', Icons.inventory_2),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SearchableDropdown(
                      value: asesorSeleccionado.isEmpty ? 'Sin asesor asignado' : asesorSeleccionado,
                      hint: 'Asesor asignado',
                      icon: Icons.person_outline,
                      items: ['Sin asesor asignado', ..._asesores.map((a) => a['nombre'].toString()).toList()],
                      showAvatars: true,
                      avatarLetters: Map.fromEntries(
                        _asesores.map((a) => MapEntry(
                          a['nombre'].toString(),
                          a['nombre'].toString().isNotEmpty ? a['nombre'].toString().substring(0, 1).toUpperCase() : '?',
                        )),
                      ),
                      onChanged: (val) => setDialogState(() {
                        asesorSeleccionado = val == 'Sin asesor asignado' ? '' : val;
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildTextField(estadoNegociacionCtrl, 'Estado de Negociación', Icons.handshake),
                  const SizedBox(height: 16),
                  _buildTextField(notasCtrl, 'Notas adicionales', Icons.note, maxLines: 3),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(activo ? Icons.check_circle : Icons.cancel, color: activo ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 20),
                      const SizedBox(width: 8),
                      Text('Cliente activo', style: TextStyle(color: AppTheme.getTextColor(context), fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Switch(
                        value: activo,
                        onChanged: (value) => setDialogState(() => activo = value),
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
                            if (nombreCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El nombre es obligatorio'), backgroundColor: Color(0xFFF59E0B)));
                              return;
                            }
                            final datos = {
                              'nombre': nombreCtrl.text,
                              'tipo': tipoCtrl.text,
                              'ubicacion': ubicacionCtrl.text,
                              'presupuesto': double.tryParse(presupuestoCtrl.text.replaceAll(',', '')) ?? 0.0,
                              'catalogo': catalogoCtrl.text,
                              'estado_negociacion': estadoNegociacionCtrl.text,
                              'notas': notasCtrl.text,
                              'asesor': asesorSeleccionado,
                              'activo': activo,
                              'etapa': etapaSeleccionada,
                              'telefono': telefonoCtrl.text,
                              'pais': paisCtrl.text,
                              'estado': estadoCtrl.text,
                              'tipo_negocio': tipoNegocio,
                              'foto_url': fotoUrl,
                            };
                            try {
                              if (esEdicion && cliente != null) {
                                await ClientesSupabaseService.actualizarCliente(cliente['id'], datos);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cliente actualizado'), backgroundColor: Color(0xFF10B981)));
                              } else {
                                await ClientesSupabaseService.agregarCliente(datos);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cliente creado'), backgroundColor: Color(0xFF10B981)));
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
                          child: Text(esEdicion ? 'Actualizar' : 'Guardar Cliente', style: const TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value, String label, IconData icon, List<String> items, ValueChanged<String?> onChanged, {bool isEtapa = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2C2C2E),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: isEtapa 
                ? Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: _getColorPorEtapa(item), shape: BoxShape.circle)), const SizedBox(width: 8), Text(item, style: const TextStyle(color: Colors.white))])
                : Text(item, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar cliente?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ClientesSupabaseService.eliminarCliente(id);
                Navigator.pop(ctx);
                await _cargarDatos();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cliente eliminado'), backgroundColor: Color(0xFF10B981)));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' Error: $e'), backgroundColor: const Color(0xFFEF4444)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _importarClientes() {
    final fileInput = html.FileUploadInputElement()..accept = '.json'..click();
    fileInput.onChange.listen((e) async {
      final files = fileInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) async {
          try {
            final contenido = jsonDecode(reader.result as String);
            List<Map<String, dynamic>> clientesArray = [];
            
            if (contenido is List) {
              clientesArray = contenido.map((c) => Map<String, dynamic>.from(c as Map)).toList();
            } else if (contenido is Map) {
              final clavesPosibles = ['clientes', 'clientes_datos', 'clientes_data', 'lista_clientes', 'data'];
              bool encontrado = false;
              for (var clave in clavesPosibles) {
                if (contenido.containsKey(clave) && contenido[clave] is List) {
                  clientesArray = (contenido[clave] as List).map((c) => Map<String, dynamic>.from(c as Map)).toList();
                  encontrado = true;
                  break;
                }
              }
              if (!encontrado) {
                for (var valor in contenido.values) {
                  if (valor is List) {
                    clientesArray = valor.map((c) => Map<String, dynamic>.from(c as Map)).toList();
                    break;
                  }
                }
              }
            }
            
            if (clientesArray.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ No se encontraron clientes en el archivo'),
                  backgroundColor: Color(0xFFF59E0B),
                ),
              );
              return;
            }
            
            final clientes = clientesArray.map((c) {
              return {
                'nombre': c['nombre'] ?? c['name'] ?? 'Sin nombre',
                'tipo': c['tipo'] ?? c['type'] ?? 'Comprador',
                'tipo_negocio': c['tipo_negocio'] ?? c['tipoNegocio'] ?? 'Inmobiliario',
                'ubicacion': c['ubicacion'] ?? c['location'] ?? '',
                'pais': c['pais'] ?? c['country'] ?? 'México',
                'estado': c['estado'] ?? c['state'] ?? '',
                'telefono': c['telefono'] ?? c['phone'] ?? '',
                'presupuesto': _toDouble(c['presupuesto'] ?? c['budget'] ?? 0),
                'catalogo': c['catalogo'] ?? c['catalog'] ?? '',
                'estado_negociacion': c['estado_negociacion'] ?? c['estadoNegociacion'] ?? '',
                'notas': c['notas'] ?? c['notes'] ?? '',
                'asesor': c['asesor'] ?? c['asesor_nombre'] ?? c['asesorId'] ?? '',
                'etapa': c['etapa'] ?? c['stage'] ?? 'Nuevo',
                'activo': c['activo'] ?? c['active'] ?? true,
                'foto_url': c['foto_url'] ?? c['fotoUrl'] ?? c['foto'] ?? '',
              };
            }).toList();
            
            final confirmado = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.getSurfaceColor(context),
                title: const Text('Confirmar importación', style: TextStyle(color: Colors.white)),
                content: Text(
                  'Se importarán ${clientes.length} clientes. ¿Deseas continuar?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    child: const Text('Importar'),
                  ),
                ],
              ),
            );
            
            if (confirmado != true) return;
            
            int exitosos = 0;
            int errores = 0;
            
            for (var cliente in clientes) {
              try {
                await ClientesSupabaseService.agregarCliente(cliente);
                exitosos++;
              } catch (e) {
                print('Error al importar cliente ${cliente['nombre']}: $e');
                errores++;
              }
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ $exitosos clientes importados' + (errores > 0 ? ' ($errores errores)' : '')),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
            
            await _cargarDatos();
            
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error al importar: $e'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        });
        reader.readAsText(file);
      }
    });
  }

  List<Map<String, dynamic>> _getClientesFiltrados() {
    var clientes = _clientes;
    if (_tipoFiltro != 'Todos') clientes = clientes.where((c) => (c['tipo'] ?? '') == _tipoFiltro).toList();
    if (_etapaFiltro != 'Todas') clientes = clientes.where((c) => (c['etapa'] ?? '') == _etapaFiltro).toList();
    if (_asesorFiltro != 'Todos') clientes = clientes.where((c) => (c['asesor'] ?? '') == _asesorFiltro).toList();
    if (_busqueda.isNotEmpty) clientes = clientes.where((c) => 
      (c['nombre'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) || 
      (c['ubicacion'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) || 
      (c['asesor'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
      (c['telefono'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
      (c['pais'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
      (c['estado'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
      (c['tipo_negocio'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase())
    ).toList();
    return clientes;
  }

  Color _getColorPorEtapa(String etapa) {
    switch (etapa) {
      case 'Nuevo': return IOSColors.blue;
      case 'Contactado': return IOSColors.purple;
      case 'Propuesta': return IOSColors.orange;
      case 'Negociación': return IOSColors.yellow;
      case 'Cerrado': return IOSColors.green;
      case 'Perdido': return IOSColors.red;
      default: return IOSColors.textSecondary;
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }
}