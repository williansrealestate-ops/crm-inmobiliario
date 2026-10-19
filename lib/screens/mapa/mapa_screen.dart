import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../services/mapa_service.dart';
import '../../services/inmuebles_supabase_service.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> _inmuebles = [];
  Map<String, dynamic> _stats = {};
  bool _cargando = true;
  String _filtroTipo = 'Todos';
  Map<String, dynamic>? _inmuebleSeleccionado;

  // Centro del mapa (México)
  static const LatLng _centroMexico = LatLng(23.6345, -102.5528);
  static const double _zoomInicial = 5.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _inmuebles = await MapaService.getInmueblesConCoordenadas();
      _stats = await MapaService.getEstadisticas();
    } catch (e) {
      print('Error al cargar mapa: $e');
    }
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.map, color: Colors.white),
            SizedBox(width: 8),
            Text('Mapa de Inmuebles'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Estadísticas rápidas
                _buildStatsBar(),
                const SizedBox(height: 8),
                
                // Mapa
                Expanded(
                  child: _buildMapa(),
                ),
                
                // Panel de detalles del inmueble seleccionado
                if (_inmuebleSeleccionado != null)
                  _buildPanelDetalles(),
              ],
            ),
    );
  }

  Widget _buildStatsBar() {
    final total = _stats['total'] ?? 0;
    final valorTotal = _stats['valorTotal'] ?? 0.0;
    final tipos = _stats['tipos'] as Map<String, int>? ?? {};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.getSurfaceColor(context),
      child: Row(
        children: [
          _buildStatItem('Total', '$total', Icons.home, const Color(0xFF3B82F6)),
          const SizedBox(width: 16),
          _buildStatItem(
            'Valor Total',
            '\$${_formatearMonto(valorTotal)}',
            Icons.attach_money,
            const Color(0xFF10B981),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tipos.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getColorPorTipo(entry.key).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category, size: 14, color: _getColorPorTipo(entry.key)),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.value} ${entry.key}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _getColorPorTipo(entry.key),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String valor, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMapa() {
    // Filtrar inmuebles por tipo
    final inmueblesFiltrados = _filtroTipo == 'Todos'
        ? _inmuebles
        : _inmuebles.where((i) => i['tipo'] == _filtroTipo).toList();

    if (inmueblesFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppTheme.getTextSecondaryColor(context)),
            const SizedBox(height: 16),
            Text(
              'No hay inmuebles con coordenadas',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _centroMexico,
        initialZoom: _zoomInicial,
        onTap: (tapPosition, point) {
          setState(() {
            _inmuebleSeleccionado = null;
          });
        },
      ),
      children: [
        // Capa de tiles (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.realestate.app',
        ),
        
        // Capa de marcadores
        MarkerLayer(
          markers: inmueblesFiltrados.map((inmueble) {
            final lat = _toDouble(inmueble['latitud']);
            final lng = _toDouble(inmueble['longitud']);
            final color = _getColorPorTipo(inmueble['tipo'] ?? 'Casa');

            return Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _inmuebleSeleccionado = inmueble;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconoPorTipo(inmueble['tipo']),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPanelDetalles() {
    final inmueble = _inmuebleSeleccionado!;
    final precio = _toDouble(inmueble['precio']);
    final color = _getColorPorTipo(inmueble['tipo'] ?? 'Casa');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  inmueble['titulo'] ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _inmuebleSeleccionado = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  inmueble['tipo'] ?? 'Sin tipo',
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (inmueble['ubicacion'] != null && inmueble['ubicacion'].toString().isNotEmpty)
                Expanded(
                  child: Text(
                    inmueble['ubicacion'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (precio > 0)
            Text(
              '\$${_formatearMonto(precio)} MXN',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10B981),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (inmueble['area'] != null && _toDouble(inmueble['area']) > 0) ...[
                const Icon(Icons.square_foot, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '${_toDouble(inmueble['area']).toStringAsFixed(0)} m²',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
              ],
              if (inmueble['recamaras'] != null && inmueble['recamaras'] > 0) ...[
                const Icon(Icons.bed, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '${inmueble['recamaras']} Rec.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
              ],
              if (inmueble['banos'] != null && inmueble['banos'] > 0) ...[
                const Icon(Icons.bathtub, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '${inmueble['banos']} Baños',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ],
          ),
          if (inmueble['asesor'] != null && inmueble['asesor'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 4),
                Text(
                  'Asesor: ${inmueble['asesor']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8B5CF6)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final tipos = ['Todos', ...(_stats['tipos'] as Map<String, int>?)?.keys.toList() ?? []];
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por tipo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ...tipos.map((tipo) {
                final isSelected = _filtroTipo == tipo;
                return ListTile(
                  leading: Icon(
                    tipo == 'Todos' ? Icons.all_inclusive : Icons.category,
                    color: isSelected ? AppTheme.primary : AppTheme.getTextSecondaryColor(context),
                  ),
                  title: Text(tipo),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                      : null,
                  onTap: () {
                    setState(() {
                      _filtroTipo = tipo;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return const Color(0xFF3B82F6);
      case 'departamento': return const Color(0xFF8B5CF6);
      case 'terreno': return const Color(0xFFF59E0B);
      case 'local': return const Color(0xFF06B6D4);
      case 'oficina': return const Color(0xFF14B8A6);
      case 'hacienda': return const Color(0xFFEC4899);
      case 'gasolinera': return const Color(0xFFEF4444);
      case 'mina': return const Color(0xFF64748B);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return Icons.home;
      case 'departamento': return Icons.apartment;
      case 'terreno': return Icons.terrain;
      case 'local': return Icons.store;
      case 'oficina': return Icons.business;
      case 'hacienda': return Icons.landscape;
      case 'gasolinera': return Icons.local_gas_station;
      case 'mina': return Icons.how_to_vote;
      default: return Icons.location_on;
    }
  }

  String _formatearMonto(double monto) {
    if (monto >= 1000000) {
      return '${(monto / 1000000).toStringAsFixed(2)} M';
    } else if (monto >= 1000) {
      return '${(monto / 1000).toStringAsFixed(0)} K';
    }
    return monto.toStringAsFixed(0);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}