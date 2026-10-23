import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/vitrina_service.dart';
import '../../widgets/ios_widgets.dart';
import '../../widgets/photo_carousel.dart';

class VitrinaScreen extends StatefulWidget {
  final bool modoPublico;
  const VitrinaScreen({super.key, this.modoPublico = false});

  @override
  State<VitrinaScreen> createState() => _VitrinaScreenState();
}

class _VitrinaScreenState extends State<VitrinaScreen> {
  List<Map<String, dynamic>> _inmuebles = [];
  List<Map<String, dynamic>> _inmueblesFiltrados = [];
  Map<String, dynamic> _config = {};
  List<String> _tipos = [];
  bool _cargando = true;

  String _filtroTipo = 'Todos';
  String _filtroUbicacion = '';
  int _recamarasMin = 0;
  int _banosMin = 0;
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _config = await VitrinaService.getConfig();
      _inmuebles = await VitrinaService.getInmueblesPublicos();
      _tipos = await VitrinaService.getTiposDisponibles();
      _aplicarFiltros();
    } catch (e) {
      print('Error al cargar vitrina: $e');
    }
    setState(() => _cargando = false);
  }

  void _aplicarFiltros() {
    setState(() {
      _inmueblesFiltrados = _inmuebles.where((i) {
        if (_filtroTipo != 'Todos' && i['tipo'] != _filtroTipo) return false;
        if (_filtroUbicacion.isNotEmpty && !(i['ubicacion'] ?? '').toString().toLowerCase().contains(_filtroUbicacion.toLowerCase())) return false;
        if (_recamarasMin > 0 && (_toInt(i['recamaras'])) < _recamarasMin) return false;
        if (_banosMin > 0 && (_toInt(i['banos'])) < _banosMin) return false;
        if (_busquedaCtrl.text.isNotEmpty) {
          final busqueda = _busquedaCtrl.text.toLowerCase();
          final titulo = (i['titulo'] ?? '').toString().toLowerCase();
          final ubicacion = (i['ubicacion'] ?? '').toString().toLowerCase();
          if (!titulo.contains(busqueda) && !ubicacion.contains(busqueda)) return false;
        }
        return true;
      }).toList();
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    if (value is num) return value.toDouble();
    return 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si es modo público, no mostrar AppBar
    if (widget.modoPublico) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _buildContenido(isDark),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.storefront, color: Colors.white), SizedBox(width: 8), Text('Vitrina')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarDatos),
        ],
      ),
      body: _cargando ? const Center(child: CircularProgressIndicator()) : _buildContenido(isDark),
    );
  }

  Widget _buildContenido(bool isDark) {
    return Column(
      children: [
        // Header con gradiente
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_config['titulo'] ?? 'Real Estate CRM', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(_config['descripcion'] ?? 'Encuentra la propiedad de tus sueños', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _busquedaCtrl,
                  onChanged: (_) => _aplicarFiltros(),
                  decoration: const InputDecoration(
                    hintText: '🔍 Buscar por título o ubicación...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF8E8E93)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filtros
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context)))),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filtroTipo,
                      decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary),
                      items: ['Todos', ..._tipos].map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                      onChanged: (value) { setState(() => _filtroTipo = value ?? 'Todos'); _aplicarFiltros(); },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _recamarasMin == 0 ? null : _recamarasMin,
                      decoration: InputDecoration(labelText: 'Recámaras', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary),
                      hint: const Text('Mín'),
                      items: [null, 1, 2, 3, 4, 5].map((n) => DropdownMenuItem<int>(value: n, child: Text(n == null ? 'Cualquiera' : '$n+'))).toList(),
                      onChanged: (value) { setState(() => _recamarasMin = value ?? 0); _aplicarFiltros(); },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _banosMin == 0 ? null : _banosMin,
                      decoration: InputDecoration(labelText: 'Baños', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary),
                      hint: const Text('Mín'),
                      items: [null, 1, 2, 3, 4].map((n) => DropdownMenuItem<int>(value: n, child: Text(n == null ? 'Cualquiera' : '$n+'))).toList(),
                      onChanged: (value) { setState(() => _banosMin = value ?? 0); _aplicarFiltros(); },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary, prefixIcon: const Icon(Icons.location_on, size: 20)),
                      onChanged: (value) { setState(() => _filtroUbicacion = value); _aplicarFiltros(); },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('${_inmueblesFiltrados.length} propiedades encontradas', style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600)),
              const Spacer(),
              if (_filtroTipo != 'Todos' || _filtroUbicacion.isNotEmpty || _recamarasMin > 0 || _banosMin > 0)
                TextButton(onPressed: () { setState(() { _filtroTipo = 'Todos'; _filtroUbicacion = ''; _recamarasMin = 0; _banosMin = 0; _busquedaCtrl.clear(); }); _aplicarFiltros(); }, child: const Text('Limpiar', style: TextStyle(color: IOSColors.blue))),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: _inmueblesFiltrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work, size: 80, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textTertiary),
                      const SizedBox(height: 16),
                      const Text('No hay propiedades disponibles', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Intenta cambiar los filtros', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _inmueblesFiltrados.length,
                  itemBuilder: (context, index) => _buildInmuebleCard(_inmueblesFiltrados[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildInmuebleCard(Map<String, dynamic> inmueble) {
    final titulo = inmueble['titulo'] ?? 'Sin título';
    final tipo = inmueble['tipo'] ?? 'Casa';
    final precio = _toDouble(inmueble['precio']);
    final ubicacion = inmueble['ubicacion'] ?? 'Sin ubicación';
    final recamaras = _toInt(inmueble['recamaras']);
    final banos = _toInt(inmueble['banos']);
    final area = _toDouble(inmueble['area']);
    final descripcion = inmueble['descripcion'] ?? '';
    final asesor = inmueble['asesor'] ?? '';
    final fotos = (inmueble['fotos'] as List?)?.cast<String>() ?? [];

    final colorTipo = _getColorPorTipo(tipo);
    final iconoTipo = _getIconoPorTipo(tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: IOSCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CARRUSEL DE FOTOS
            PhotoCarousel(fotos: fotos, height: 240),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: IOSColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(child: Text(ubicacion, style: const TextStyle(fontSize: 13, color: IOSColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ]),
                          ],
                        ),
                      ),
                      IOSBadge(text: tipo, color: colorTipo, filled: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (recamaras > 0) ...[_buildCaracteristica(Icons.bed, '$recamaras Rec.'), const SizedBox(width: 16)],
                      if (banos > 0) ...[_buildCaracteristica(Icons.bathtub, '$banos Baños'), const SizedBox(width: 16)],
                      if (area > 0) _buildCaracteristica(Icons.square_foot, '${area.toInt()} m²'),
                    ],
                  ),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(descripcion, style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context)), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 18, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(_formatearPrecio(precio), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                      const Spacer(),
                      if (asesor.isNotEmpty)
                        Row(children: [const Icon(Icons.person, size: 14, color: IOSColors.purple), const SizedBox(width: 4), Text('Asesor: $asesor', style: const TextStyle(fontSize: 11, color: IOSColors.purple))]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IOSButton(label: 'Ver detalles', icon: Icons.visibility, color: IOSColors.blue, small: true, filled: false, onPressed: () => _verDetalles(inmueble)),
                      const SizedBox(width: 8),
                      IOSButton(label: 'Contactar', icon: Icons.chat, color: IOSColors.green, small: true, filled: true, onPressed: () => _contactar(inmueble)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaracteristica(IconData icono, String texto) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icono, size: 16, color: AppTheme.getTextSecondaryColor(context)), const SizedBox(width: 4), Text(texto, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600))]);
  }

  void _verDetalles(Map<String, dynamic> inmueble) {
    final titulo = inmueble['titulo'] ?? 'Sin título';
    final tipo = inmueble['tipo'] ?? 'Casa';
    final precio = _toDouble(inmueble['precio']);
    final ubicacion = inmueble['ubicacion'] ?? 'Sin ubicación';
    final recamaras = _toInt(inmueble['recamaras']);
    final banos = _toInt(inmueble['banos']);
    final area = _toDouble(inmueble['area']);
    final descripcion = inmueble['descripcion'] ?? 'Sin descripción';
    final asesor = inmueble['asesor'] ?? '';
    final fotos = (inmueble['fotos'] as List?)?.cast<String>() ?? [];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        child: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Galería en detalles
                PhotoCarousel(fotos: fotos, height: 300),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Expanded(child: Text(titulo, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextColor(context)))), IOSBadge(text: tipo, color: _getColorPorTipo(tipo), filled: true)]),
                      const SizedBox(height: 16),
                      Row(children: [const Icon(Icons.attach_money, color: Color(0xFF10B981), size: 24), const SizedBox(width: 8), Text(_formatearPrecio(precio), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF10B981)))]),
                      const SizedBox(height: 16),
                      Row(children: [const Icon(Icons.location_on, color: IOSColors.textSecondary), const SizedBox(width: 8), Expanded(child: Text(ubicacion, style: TextStyle(fontSize: 14, color: AppTheme.getTextSecondaryColor(context))))]),
                      const SizedBox(height: 16),
                      Row(children: [
                        if (recamaras > 0) ...[const Icon(Icons.bed, color: IOSColors.textSecondary), const SizedBox(width: 4), Text('$recamaras Recámaras', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))), const SizedBox(width: 16)],
                        if (banos > 0) ...[const Icon(Icons.bathtub, color: IOSColors.textSecondary), const SizedBox(width: 4), Text('$banos Baños', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))), const SizedBox(width: 16)],
                        if (area > 0) ...[const Icon(Icons.square_foot, color: IOSColors.textSecondary), const SizedBox(width: 4), Text('${area.toInt()} m²', style: TextStyle(color: AppTheme.getTextSecondaryColor(context)))],
                      ]),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                      const SizedBox(height: 8),
                      Text(descripcion, style: TextStyle(fontSize: 14, color: AppTheme.getTextSecondaryColor(context), height: 1.6)),
                      if (asesor.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: IOSColors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.person, color: IOSColors.purple), const SizedBox(width: 8), Text('Asesor: $asesor', style: const TextStyle(color: IOSColors.purple, fontWeight: FontWeight.w600))])),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(onPressed: () { Navigator.pop(ctx); _contactar(inmueble); }, icon: const Icon(Icons.chat), label: const Text('Contactar'), style: ElevatedButton.styleFrom(backgroundColor: IOSColors.green, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _contactar(Map<String, dynamic> inmueble) {
    final titulo = inmueble['titulo'] ?? 'Sin título';
    final precio = _toDouble(inmueble['precio']);
    final whatsapp = _config['whatsapp'] ?? '';
    final telefono = _config['telefono'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: const Text('Contactar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('¿Cómo deseas contactar sobre "$titulo" por ${_formatearPrecio(precio)}?', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
        actions: [
          if (whatsapp.isNotEmpty) ElevatedButton.icon(onPressed: () { final mensaje = Uri.encodeComponent('Hola, me interesa la propiedad: $titulo por ${_formatearPrecio(precio)}'); html.window.open('https://wa.me/$whatsapp?text=$mensaje', '_blank'); Navigator.pop(ctx); }, icon: const Icon(Icons.chat), label: const Text('WhatsApp'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366))),
          if (telefono.isNotEmpty) ElevatedButton.icon(onPressed: () { html.window.open('tel:$telefono', '_self'); Navigator.pop(ctx); }, icon: const Icon(Icons.phone), label: const Text('Llamar'), style: ElevatedButton.styleFrom(backgroundColor: IOSColors.blue)),
          if (_config['email'] != null && (_config['email'] as String).isNotEmpty) ElevatedButton.icon(onPressed: () { final asunto = Uri.encodeComponent('Interés en: $titulo'); final cuerpo = Uri.encodeComponent('Hola, me interesa la propiedad: $titulo por ${_formatearPrecio(precio)}'); html.window.open('mailto:${_config['email']}?subject=$asunto&body=$cuerpo', '_self'); Navigator.pop(ctx); }, icon: const Icon(Icons.email), label: const Text('Email'), style: ElevatedButton.styleFrom(backgroundColor: IOSColors.red)),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  String _formatearPrecio(double precio) {
    if (precio >= 1000000) return '\$${(precio / 1000000).toStringAsFixed(2)} MDP';
    if (precio >= 1000) return '\$${(precio / 1000).toStringAsFixed(0)} K';
    return '\$${precio.toStringAsFixed(0)}';
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return IOSColors.blue;
      case 'departamento': return IOSColors.purple;
      case 'terreno': return IOSColors.orange;
      case 'local': return IOSColors.green;
      case 'oficina': return IOSColors.pink;
      case 'hacienda': return const Color(0xFF64748B);
      case 'gasolinera': return IOSColors.teal;
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return Icons.home;
      case 'departamento': return Icons.apartment;
      case 'terreno': return Icons.landscape;
      case 'local': return Icons.storefront;
      case 'oficina': return Icons.business;
      case 'hacienda': return Icons.agriculture;
      case 'gasolinera': return Icons.local_gas_station;
      default: return Icons.home_work;
    }
  }
}