import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/photo_picker.dart';
import 'detalle_cliente.dart';

class ListaClientes extends StatefulWidget {
  final String? busqueda;
  const ListaClientes({super.key, this.busqueda});

  @override
  State<ListaClientes> createState() => _ListaClientesState();
}

class _ListaClientesState extends State<ListaClientes> {
  List<Map<String, dynamic>> _clientes = [];
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  void _cargarClientes() {
    setState(() {
      _clientes = LocalStorageService.getClientes();
    });
  }

  String _limpiarNombre(String nombre) {
    if (nombre.isEmpty) return '';
    return nombre.replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}]', unicode: true), '').trim();
  }

  List<Map<String, dynamic>> get _clientesFiltrados {
    final busquedaActiva = widget.busqueda ?? '';
    return _clientes.where((c) {
      final coincideFiltro = _filtro == 'Todos' || c['tipo'] == _filtro;
      final texto = '${c['nombre']} ${c['email'] ?? ''} ${c['telefono'] ?? ''} ${c['catalogo'] ?? ''} ${c['notas'] ?? ''}'.toLowerCase();
      return coincideFiltro && (busquedaActiva.isEmpty || texto.contains(busquedaActiva.toLowerCase()));
    }).toList();
  }

  double _calcularAvanceCliente(Map<String, dynamic> c) {
    double avance = 0;
    if ((c['telefono'] ?? '').toString().trim().isNotEmpty && (c['email'] ?? '').toString().trim().isNotEmpty) {
      avance += 0.30;
    } else if ((c['telefono'] ?? '').toString().trim().isNotEmpty || (c['email'] ?? '').toString().trim().isNotEmpty) avance += 0.15;
    if ((c['interes'] ?? '').toString().trim().isNotEmpty) avance += 0.20;
    final presupuesto = double.tryParse(c['presupuesto']?.toString().replaceAll(',', '').replaceAll('\$', '') ?? '0') ?? 0;
    if (presupuesto > 0) avance += 0.20;
    if ((c['notas'] ?? '').toString().trim().isNotEmpty) avance += 0.15;
    if ((c['fotoBase64'] ?? '').toString().trim().isNotEmpty) avance += 0.15;
    return avance.clamp(0.0, 1.0);
  }

  String _etapaProceso(double avance) {
    if (avance >= 0.8) return 'Cierre';
    if (avance >= 0.6) return 'Negociación';
    if (avance >= 0.4) return 'Propuesta';
    if (avance >= 0.2) return 'Interés';
    return 'Contacto';
  }

  String _formatearDinero(String texto) {
    String limpio = texto.replaceAll(RegExp(r'[^\d]'), '');
    if (limpio.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < limpio.length; i++) {
      if (i > 0 && (limpio.length - i) % 3 == 0) buffer.write(',');
      buffer.write(limpio[i]);
    }
    return buffer.toString();
  }

  Image? _decodificarImagen(String? fotoBase64, double width, double height, Color color, String iniciales) {
    if (fotoBase64 == null || fotoBase64.isEmpty) return null;
    try {
      String base64String = fotoBase64;
      if (base64String.contains(',')) base64String = base64String.split(',').last;
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: color.withOpacity(0.2),
            child: Center(child: Text(iniciales, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18))),
          );
        },
      );
    } catch (e) {
      return null;
    }
  }

  void _mostrarFormularioCliente({Map<String, dynamic>? cliente}) {
    final esEditar = cliente != null;
    final nombreCtrl = TextEditingController(text: cliente?['nombre'] ?? '');
    final telefonoCtrl = TextEditingController(text: cliente?['telefono'] ?? '');
    final emailCtrl = TextEditingController(text: cliente?['email'] ?? '');
    final tipoCtrl = TextEditingController(text: cliente?['tipo'] ?? 'Comprador');
    final interesCtrl = TextEditingController(text: cliente?['interes'] ?? '');
    final presupuestoRaw = cliente?['presupuesto']?.toString().replaceAll(',', '').replaceAll('\$', '') ?? '';
    final presupuestoCtrl = TextEditingController(text: presupuestoRaw.isNotEmpty ? _formatearDinero(presupuestoRaw) : '');
    final monedaCtrl = TextEditingController(text: cliente?['moneda'] ?? 'MXN');
    final paisCtrl = TextEditingController(text: cliente?['pais'] ?? 'México');
    final estadoCtrl = TextEditingController(text: cliente?['estadoUbicacion'] ?? '');
    final catalogoCtrl = TextEditingController(text: cliente?['catalogo'] ?? '');
    final notasCtrl = TextEditingController(text: cliente?['notas'] ?? '');
    String? fotoBase64 = cliente?['fotoBase64'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(esEditar ? 'Editar Cliente' : 'Nuevo Cliente'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo *')),
                  const SizedBox(height: 12),
                  TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tipoCtrl.text,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: ['Comprador', 'Vendedor', 'Inversionista', 'Prospecto'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setDialogState(() => tipoCtrl.text = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: interesCtrl, decoration: const InputDecoration(labelText: 'Interés (tipo de propiedad)')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: presupuestoCtrl,
                          decoration: const InputDecoration(labelText: 'Presupuesto', prefixText: '\$ '),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            final formateado = _formatearDinero(value);
                            presupuestoCtrl.value = TextEditingValue(text: formateado, selection: TextSelection.collapsed(offset: formateado.length));
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: monedaCtrl.text,
                          decoration: const InputDecoration(labelText: 'Moneda'),
                          items: ['MXN', 'USD', 'EUR'].map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                          onChanged: (v) => setDialogState(() => monedaCtrl.text = v ?? 'MXN'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: paisCtrl, decoration: const InputDecoration(labelText: 'País')),
                  const SizedBox(height: 12),
                  TextField(controller: estadoCtrl, decoration: const InputDecoration(labelText: 'Estado / Ubicación')),
                  const SizedBox(height: 12),
                  TextField(controller: catalogoCtrl, decoration: const InputDecoration(labelText: 'Catálogo', helperText: 'Productos o servicios que busca/ofrece')),
                  const SizedBox(height: 12),
                  TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: 'Notas'), maxLines: 3),
                  const SizedBox(height: 16),
                  PhotoPicker(currentPhoto: fotoBase64, onPhotoSelected: (base64) => setDialogState(() => fotoBase64 = base64), onPhotoRemoved: () => setDialogState(() => fotoBase64 = null)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El nombre es obligatorio')));
                  return;
                }
                final presupuestoLimpio = presupuestoCtrl.text.replaceAll(',', '').replaceAll('\$', '');
                final datos = {
                  'nombre': nombreCtrl.text.trim(),
                  'telefono': telefonoCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'tipo': tipoCtrl.text,
                  'interes': interesCtrl.text,
                  'presupuesto': presupuestoLimpio,
                  'moneda': monedaCtrl.text,
                  'pais': paisCtrl.text,
                  'estadoUbicacion': estadoCtrl.text,
                  'catalogo': catalogoCtrl.text,
                  'notas': notasCtrl.text,
                  'estado': 'Activo',
                  'fotoUrl': '',
                  'fotoBase64': fotoBase64 ?? '',
                  'fechaAlta': DateTime.now().toIso8601String().split('T')[0],
                };
                if (esEditar) {
                  LocalStorageService.actualizarCliente(cliente['id'].toString(), {...datos, 'id': cliente['id'].toString()});
                } else {
                  LocalStorageService.agregarCliente(datos);
                }
                Navigator.pop(ctx);
                _cargarClientes();
              },
              child: Text(esEditar ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> cliente) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a ${cliente['nombre']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              LocalStorageService.eliminarCliente(cliente['id'].toString());
              Navigator.pop(ctx);
              _cargarClientes();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'Comprador': return const Color(0xFF0D1B4C);
      case 'Vendedor': return AppTheme.warning;
      case 'Inversionista': return AppTheme.success;
      case 'Prospecto': return const Color(0xFF3B82F6);
      default: return const Color(0xFF6B7280);
    }
  }

  Widget _buildNumeroConsecutivo(int posicion, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Center(child: Text('${posicion + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
    );
  }

  Widget _buildAvatarConProgreso(String? fotoBase64, String nombre, double avance, Color color) {
    final nombreLimpio = _limpiarNombre(nombre);
    final palabras = nombreLimpio.trim().split(' ');
    final inicial1 = palabras.isNotEmpty ? palabras[0][0] : '';
    final inicial2 = palabras.length > 1 ? palabras[1][0] : '';
    final iniciales = '$inicial1$inicial2'.toUpperCase();
    final imagen = _decodificarImagen(fotoBase64, 52, 52, color, iniciales);

    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(value: avance, strokeWidth: 4, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation<Color>(color)),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: ClipOval(
              child: imagen ?? Container(
                color: color.withOpacity(0.2),
                child: Center(child: Text(iniciales, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearPresupuesto(Map<String, dynamic> c) {
    final raw = c['presupuesto']?.toString().replaceAll(',', '') ?? '0';
    final valor = double.tryParse(raw) ?? 0;
    final moneda = c['moneda'] ?? 'MXN';
    if (valor == 0) return 'Sin definir';
    String formateado;
    if (valor >= 1000000) {
      formateado = '\$${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      formateado = '\$${(valor / 1000).toStringAsFixed(0)}K';
    } else {
      formateado = '\$${valor.toStringAsFixed(0)}';
    }
    return '$formateado $moneda';
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
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
            Text(subtitle, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              height: 230,
              backgroundColor: AppTheme.getBackgroundColor(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Clientes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))),
                              const SizedBox(height: 2),
                              Text('Gestiona tu cartera de clientes', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _mostrarFormularioCliente(),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Nuevo Cliente', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildKpiCard(icon: Icons.people, value: '${_clientes.length}', label: 'Total', subtitle: 'clientes registrados', color: const Color(0xFF0D1B4C)),
                        const SizedBox(width: 8),
                        _buildKpiCard(icon: Icons.check_circle, value: '${_clientes.where((c) => c['estado'] == 'Activo').length}', label: 'Activos', subtitle: 'en seguimiento', color: AppTheme.success),
                        const SizedBox(width: 8),
                        _buildKpiCard(icon: Icons.shopping_cart, value: '${_clientes.where((c) => c['tipo'] == 'Comprador').length}', label: 'Compradores', subtitle: 'buscando propiedad', color: AppTheme.warning),
                        const SizedBox(width: 8),
                        _buildKpiCard(icon: Icons.trending_up, value: '${_clientes.where((c) => c['tipo'] == 'Inversionista').length}', label: 'Inversionistas', subtitle: 'alto potencial', color: const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Text('Filtrar por tipo: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _filtro,
                          items: ['Todos', 'Comprador', 'Vendedor', 'Inversionista', 'Prospecto'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                          onChanged: (v) => setState(() => _filtro = v ?? 'Todos'),
                        ),
                        const Spacer(),
                        if (widget.busqueda != null && widget.busqueda!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search, size: 14, color: AppTheme.primary),
                                const SizedBox(width: 6),
                                Text('Buscando: "${widget.busqueda}"', style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_clientesFiltrados.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No hay clientes', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ..._clientesFiltrados.asMap().entries.map((entry) {
                    final index = entry.key;
                    final c = entry.value;
                    final fotoBase64 = c['fotoBase64'] ?? '';
                    final color = _colorTipo(c['tipo'] ?? 'Prospecto');
                    final avance = _calcularAvanceCliente(c);
                    final etapa = _etapaProceso(avance);
                    final presupuestoFormateado = _formatearPresupuesto(c);
                    final nombreLimpio = _limpiarNombre(c['nombre'] ?? '');
                    final estado = c['estadoUbicacion'] ?? '';
                    final catalogo = c['catalogo'] ?? '';
                    final notas = c['notas'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleCliente(cliente: c))).then((editar) {
                          if (editar == true) _mostrarFormularioCliente(cliente: c);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildNumeroConsecutivo(index, color),
                              const SizedBox(width: 16),
                              _buildAvatarConProgreso(fotoBase64, c['nombre'] ?? '', avance, color),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nombreLimpio, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.getTextPrimaryColor(context))),
                                    const SizedBox(height: 4),
                                    if (estado.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(estado, style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13)),
                                        ],
                                      ),
                                    if (catalogo.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.inventory_2, size: 12, color: AppTheme.primary),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text('Catálogo: $catalogo', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ],
                                    if (notas.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.note, size: 12, color: AppTheme.warning),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text('Notas: $notas', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 12, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
                                    child: Text(c['tipo'] ?? '', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(height: 6),
                                  if (presupuestoFormateado != 'Sin definir')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.success.withOpacity(0.3))),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.account_balance_wallet, size: 12, color: AppTheme.success),
                                          const SizedBox(width: 4),
                                          Text(presupuestoFormateado, style: const TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: avance >= 0.8 ? AppTheme.success.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: Text('🎯 $etapa', style: TextStyle(color: avance >= 0.8 ? AppTheme.success : AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20), onPressed: () => _mostrarFormularioCliente(cliente: c)),
                              IconButton(icon: const Icon(Icons.delete, color: AppTheme.danger, size: 20), onPressed: () => _confirmarEliminar(c)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ]),
            ),
          ),
        ],
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