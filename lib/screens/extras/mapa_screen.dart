import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';
import '../../services/google_maps_service.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  List<Map<String, dynamic>> _inmuebles = [];
  Map<String, dynamic>? _inmuebleSeleccionado;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Map<String, LatLng> _coordenadasInmuebles = {};

  @override
  void initState() {
    super.initState();
    _cargarInmuebles();
  }

  Future<void> _cargarInmuebles() async {
    final inmuebles = LocalStorageService.getInmuebles();
    final markers = <Marker>{};
    final coordenadas = <String, LatLng>{};

    for (var inmueble in inmuebles) {
      final coords = await GoogleMapsService.geocodificarDireccion(
        direccion: inmueble['direccion'] ?? '',
        municipio: inmueble['municipio'] ?? '',
        estado: inmueble['estado'] ?? '',
        pais: inmueble['pais'] ?? 'México',
      );

      if (coords != null) {
        final latLng = LatLng(coords['lat']!, coords['lng']!);
        coordenadas[inmueble['id'].toString()] = latLng;

        final marker = Marker(
          markerId: MarkerId(inmueble['id'].toString()),
          position: latLng,
          infoWindow: InfoWindow(
            title: inmueble['titulo'] ?? 'Sin título',
            snippet: '${inmueble['estado']}, ${inmueble['municipio']}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getHueColor(inmueble['tipo'] ?? 'Casa'),
          ),
          onTap: () => _seleccionarInmueble(inmueble),
        );
        markers.add(marker);
      }
    }

    setState(() {
      _inmuebles = inmuebles;
      _markers = markers;
      _coordenadasInmuebles = coordenadas;
    });
  }

  double _getHueColor(String tipo) {
    switch (tipo) {
      case 'Casa': return BitmapDescriptor.hueGreen;
      case 'Departamento': return BitmapDescriptor.hueBlue;
      case 'Terreno': return BitmapDescriptor.hueYellow;
      case 'Gasolinera': return BitmapDescriptor.hueRed;
      default: return BitmapDescriptor.hueViolet;
    }
  }

  void _seleccionarInmueble(Map<String, dynamic> inmueble) {
    setState(() {
      _inmuebleSeleccionado = inmueble;
    });

    final id = inmueble['id'].toString();
    final coords = _coordenadasInmuebles[id];

    if (coords != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(coords, 15),
      );
    }

    _mostrarDetalleInmueble(inmueble, coords);
  }

  void _mostrarDetalleInmueble(Map<String, dynamic> inmueble, LatLng? coords) {
    final precio = _formatearPrecio(inmueble['precio'] ?? '0');
    final fotos = List<String>.from(inmueble['fotosBase64'] ?? []);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(inmueble['titulo'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getIconoTipo(inmueble['tipo'] ?? 'Casa'), size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      inmueble['tipo'] ?? '',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                precio,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.location_on, 'Ubicación', '${inmueble['estado']}, ${inmueble['municipio']}'),
              _buildInfoRow(Icons.square_foot, 'Área Terreno', '${inmueble['areaTerreno']} m²'),
              _buildInfoRow(Icons.home, 'Área Construcción', '${inmueble['areaConstruccion']} m²'),
              if ((inmueble['habitaciones'] ?? '0') != '0')
                _buildInfoRow(Icons.bed, 'Habitaciones', inmueble['habitaciones']),
              if ((inmueble['banos'] ?? '0') != '0')
                _buildInfoRow(Icons.bathtub, 'Baños', inmueble['banos']),
              const SizedBox(height: 12),
              Text(
                inmueble['descripcion'] ?? '',
                style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          if (coords != null) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _abrirNavegacion(coords, inmueble['titulo'] ?? '');
              },
              icon: const Icon(Icons.navigation, color: AppTheme.success),
              label: const Text('Navegar'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _compartirUbicacion(coords, inmueble['titulo'] ?? '');
              },
              icon: const Icon(Icons.share, color: AppTheme.primary),
              label: const Text('Compartir'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirNavegacion(LatLng coords, String nombre) async {
    final url = GoogleMapsService.generarUrlNavegacion(
      lat: coords.latitude,
      lng: coords.longitude,
      nombre: nombre,
    );
    await _launchUrl(url);
  }

  Future<void> _compartirUbicacion(LatLng coords, String nombre) async {
    final url = GoogleMapsService.generarUrlCompartir(
      lat: coords.latitude,
      lng: coords.longitude,
      nombre: nombre,
    );
    await _launchUrl(url);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la URL')),
        );
      }
    }
  }

  String _formatearPrecio(String precio) {
    final valor = double.tryParse(precio) ?? 0;
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)}K';
    return '\$${valor.toStringAsFixed(0)}';
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'Casa': return Icons.house;
      case 'Departamento': return Icons.apartment;
      case 'Terreno': return Icons.landscape;
      case 'Gasolinera': return Icons.local_gas_station;
      default: return Icons.business;
    }
  }

  Widget _buildInfoRow(IconData icono, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppTheme.getTextSecondaryColor(context)),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapa de Propiedades',
              style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ubicación de tus inmuebles en México',
              style: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
            ),
            const SizedBox(height: 20),
            Container(
              height: isMobile ? 400 : 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(23.6345, -102.5528), // Centro de México
                    zoom: 5,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Leyenda
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leyenda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildLeyendaItem(BitmapDescriptor.hueGreen, 'Casa'),
                        _buildLeyendaItem(BitmapDescriptor.hueBlue, 'Departamento'),
                        _buildLeyendaItem(BitmapDescriptor.hueYellow, 'Terreno'),
                        _buildLeyendaItem(BitmapDescriptor.hueRed, 'Gasolinera'),
                        _buildLeyendaItem(BitmapDescriptor.hueViolet, 'Otro'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Lista de inmuebles
            Text(
              'Inmuebles (${_inmuebles.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 12),
            if (_inmuebles.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No hay inmuebles',
                      style: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                    ),
                  ),
                ),
              )
            else
              ..._inmuebles.map((inmueble) {
                final color = _colorTipo(inmueble['tipo'] ?? 'Casa');
                final coords = _coordenadasInmuebles[inmueble['id'].toString()];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getIconoTipo(inmueble['tipo'] ?? 'Casa'), color: color),
                    ),
                    title: Text(
                      inmueble['titulo'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${inmueble['estado']}, ${inmueble['municipio']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatearPrecio(inmueble['precio'] ?? '0'),
                          style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700),
                        ),
                        if (coords != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.navigation, color: AppTheme.success, size: 20),
                            onPressed: () => _abrirNavegacion(coords, inmueble['titulo'] ?? ''),
                            tooltip: 'Navegar',
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      if (coords != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(coords, 15),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyendaItem(double hue, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _hueToColor(hue),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Color _hueToColor(double hue) {
    if (hue == BitmapDescriptor.hueGreen) return AppTheme.success;
    if (hue == BitmapDescriptor.hueBlue) return const Color(0xFF3B82F6);
    if (hue == BitmapDescriptor.hueYellow) return AppTheme.warning;
    if (hue == BitmapDescriptor.hueRed) return AppTheme.danger;
    if (hue == BitmapDescriptor.hueViolet) return const Color(0xFF8B5CF6);
    return AppTheme.primary;
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'Casa': return AppTheme.success;
      case 'Departamento': return const Color(0xFF3B82F6);
      case 'Terreno': return AppTheme.warning;
      case 'Gasolinera': return AppTheme.danger;
      default: return AppTheme.primary;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}