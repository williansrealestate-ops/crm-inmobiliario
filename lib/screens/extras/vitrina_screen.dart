import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class VitrinaScreen extends StatefulWidget {
  const VitrinaScreen({super.key});

  @override
  State<VitrinaScreen> createState() => _VitrinaScreenState();
}

class _VitrinaScreenState extends State<VitrinaScreen> {
  String _tipoFiltro = 'Todos';
  String _ubicacionFiltro = 'Todas';
  String _busqueda = '';
  bool _vistaGrid = true;

  @override
  Widget build(BuildContext context) {
    final inmuebles = _getInmueblesFiltrados();
    final tipos = _getTiposDisponibles();
    final ubicaciones = _getUbicacionesDisponibles();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.storefront, color: Colors.white), SizedBox(width: 8), Text('Vitrina de Propiedades')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(tipos, ubicaciones),
          _buildToolbar(inmuebles.length),
          Expanded(
            child: inmuebles.isEmpty ? _buildEmptyState() : _vistaGrid ? _buildGrid(inmuebles) : _buildLista(inmuebles),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<String> tipos, List<String> ubicaciones) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceElevatedColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppTheme.getTextSecondaryColor(context), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _busqueda = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar propiedades...',
                      hintStyle: TextStyle(color: AppTheme.getTextTertiaryColor(context)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                  ),
                ),
                if (_busqueda.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, size: 18, color: AppTheme.getTextSecondaryColor(context)),
                    onPressed: () => setState(() => _busqueda = ''),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter('Tipo de propiedad', _tipoFiltro, tipos, (value) {
                  setState(() => _tipoFiltro = value);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownFilter('Ubicación', _ubicacionFiltro, ubicaciones, (value) {
                  setState(() => _ubicacionFiltro = value);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 20, color: AppTheme.getTextSecondaryColor(context)),
              style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 13),
              items: options.map((opt) => DropdownMenuItem<String>(value: opt, child: Text(opt, style: TextStyle(fontSize: 13, color: AppTheme.getTextColor(context))))).toList(),
              onChanged: (val) => onChanged(val ?? value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context))),
      ),
      child: Row(
        children: [
          Text('$total propiedades', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _vistaGrid ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: Icon(Icons.grid_view, size: 18, color: _vistaGrid ? Colors.white : AppTheme.getTextSecondaryColor(context)),
              onPressed: () => setState(() => _vistaGrid = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: !_vistaGrid ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              icon: Icon(Icons.view_list, size: 18, color: !_vistaGrid ? Colors.white : AppTheme.getTextSecondaryColor(context)),
              onPressed: () => setState(() => _vistaGrid = false),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> inmuebles) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: inmuebles.length,
      itemBuilder: (context, index) {
        return _buildPropertyCard(inmuebles[index]);
      },
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> inmueble) {
    final precioRaw = inmueble['precio'];
    double precio = 0;
    if (precioRaw is num) {
      precio = precioRaw.toDouble();
    } else if (precioRaw is String) {
      precio = double.tryParse(precioRaw.replaceAll(',', '')) ?? 0;
    }

    final tipo = (inmueble['tipo'] ?? 'Casa').toString();
    final ubicacion = (inmueble['ubicacion'] ?? 'Sin ubicación').toString();
    final titulo = (inmueble['titulo'] ?? 'Sin título').toString();
    
    final recamaras = _toInt(inmueble['recamaras']);
    final banos = _toInt(inmueble['banos']);
    final area = _toDouble(inmueble['area']);
    
    final esNuevo = inmueble['nuevo'] == true;
    final esDestacado = inmueble['destacado'] == true;
    final tieneReduccion = inmueble['reduccion'] == true;

    final colorTipo = _getColorPorTipo(tipo);
    final iconoTipo = _getIconoPorTipo(tipo);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorTipo.withOpacity(0.15), colorTipo.withOpacity(0.05)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(iconoTipo, size: 40, color: colorTipo.withOpacity(0.6)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorTipo,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: colorTipo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Text(tipo, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
                if (esNuevo)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(12)),
                      child: const Text('NUEVO', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                    ),
                  ),
                if (esDestacado)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 8, color: Colors.white),
                          SizedBox(width: 2),
                          Text('TOP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.favorite_border, size: 14, color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${_formatearPrecio(precio)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colorTipo),
                  ),
                  if (tieneReduccion)
                    const Text('Reducción', style: TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 11, color: AppTheme.getTextSecondaryColor(context)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(ubicacion, style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (recamaras > 0 || banos > 0 || area > 0)
                    Row(
                      children: [
                        if (recamaras > 0) ...[_buildCaracteristica(Icons.bed, '$recamaras'), const SizedBox(width: 8)],
                        if (banos > 0) ...[_buildCaracteristica(Icons.bathtub, '$banos'), const SizedBox(width: 8)],
                        if (area > 0) _buildCaracteristica(Icons.square_foot, '${area.toInt()}m²'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristica(IconData icono, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 12, color: AppTheme.getTextSecondaryColor(context)),
        const SizedBox(width: 3),
        Text(texto, style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLista(List<Map<String, dynamic>> inmuebles) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: inmuebles.length,
      itemBuilder: (context, index) {
        final inmueble = inmuebles[index];
        final precioRaw = inmueble['precio'];
        double precio = 0;
        if (precioRaw is num) {
          precio = precioRaw.toDouble();
        } else if (precioRaw is String) {
          precio = double.tryParse(precioRaw.replaceAll(',', '')) ?? 0;
        }
        final tipo = (inmueble['tipo'] ?? 'Casa').toString();
        final colorTipo = _getColorPorTipo(tipo);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorTipo.withOpacity(0.15), colorTipo.withOpacity(0.05)]),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: Center(child: Icon(_getIconoPorTipo(tipo), size: 48, color: colorTipo.withOpacity(0.6))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: colorTipo, borderRadius: BorderRadius.circular(20)),
                            child: Text(tipo, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                          const Spacer(),
                          Text('\$${_formatearPrecio(precio)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorTipo)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text((inmueble['titulo'] ?? 'Sin título').toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                          const SizedBox(width: 4),
                          Text((inmueble['ubicacion'] ?? 'Sin ubicación').toString(), style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No hay propiedades disponibles', style: TextStyle(fontSize: 18, color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Intenta cambiar los filtros', style: TextStyle(fontSize: 14, color: AppTheme.getTextTertiaryColor(context))),
        ],
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  List<Map<String, dynamic>> _getInmueblesFiltrados() {
    var inmuebles = LocalStorageService.getInmuebles();
    if (_tipoFiltro != 'Todos') {
      inmuebles = inmuebles.where((i) => (i['tipo'] ?? '') == _tipoFiltro).toList();
    }
    if (_ubicacionFiltro != 'Todas') {
      inmuebles = inmuebles.where((i) => (i['ubicacion'] ?? '').toString().contains(_ubicacionFiltro)).toList();
    }
    if (_busqueda.isNotEmpty) {
      inmuebles = inmuebles.where((i) => 
        (i['titulo'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
        (i['ubicacion'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase())
      ).toList();
    }
    return inmuebles;
  }

  List<String> _getTiposDisponibles() {
    final inmuebles = LocalStorageService.getInmuebles();
    final tipos = inmuebles.map((i) => (i['tipo'] ?? 'Casa').toString()).toSet().toList();
    return ['Todos', ...tipos];
  }

  List<String> _getUbicacionesDisponibles() {
    final inmuebles = LocalStorageService.getInmuebles();
    final ubicaciones = inmuebles.map((i) => (i['ubicacion'] ?? 'Sin ubicación').toString()).toSet().toList();
    return ['Todas', ...ubicaciones];
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return const Color(0xFF3B82F6);
      case 'departamento': return const Color(0xFF8B5CF6);
      case 'terreno': return const Color(0xFFF59E0B);
      case 'local': return const Color(0xFF10B981);
      case 'oficina': return const Color(0xFFEC4899);
      case 'bodega': return const Color(0xFF6366F1);
      case 'hacienda': return const Color(0xFFEF4444);
      case 'gasolinera': return const Color(0xFFDC2626);
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
      case 'bodega': return Icons.warehouse;
      case 'hacienda': return Icons.agriculture;
      case 'gasolinera': return Icons.local_gas_station;
      default: return Icons.home_work;
    }
  }

  String _formatearPrecio(double precio) {
    if (precio >= 1000000) return '${(precio / 1000000).toStringAsFixed(1)}M';
    if (precio >= 1000) return '${(precio / 1000).toStringAsFixed(0)}K';
    return precio.toStringAsFixed(0);
  }
}