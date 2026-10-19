import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/photo_carousel.dart';

// ✅ ASEGÚRATE DE QUE ESTA LÍNEA DIGA Map<String, dynamic>
class DetalleInmueble extends StatefulWidget {
  final Map<String, dynamic> inmueble;

  const DetalleInmueble({
    super.key,
    required this.inmueble,
  });

  @override
  State<DetalleInmueble> createState() => _DetalleInmuebleState();
}

class _DetalleInmuebleState extends State<DetalleInmueble> {
  late Map<String, dynamic> _inmueble;

  @override
  void initState() {
    super.initState();
    _inmueble = Map<String, dynamic>.from(widget.inmueble);
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

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'Casa': return AppTheme.success;
      case 'Departamento': return const Color(0xFF3B82F6);
      case 'Terreno': return AppTheme.warning;
      case 'Gasolinera': return AppTheme.danger;
      default: return AppTheme.primary;
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Inmueble'),
        content: Text('¿Estás seguro de eliminar "${_inmueble['titulo']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              LocalStorageService.eliminarInmueble(_inmueble['id']);
              Navigator.pop(ctx); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inmueble eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final color = _colorTipo(_inmueble['tipo'] ?? 'Casa');
    final fotos = List<String>.from(_inmueble['fotosBase64'] ?? []);
    final precio = _formatearPrecio(_inmueble['precio'] ?? '0');

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getSurfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getTextPrimaryColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.danger),
            onPressed: _confirmarEliminar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoCarousel(photos: fotos, height: isMobile ? 250 : 400),
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Icon(_getIconoTipo(_inmueble['tipo'] ?? 'Casa'), color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_inmueble['titulo'] ?? '', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                                const SizedBox(width: 4),
                                Text('${_inmueble['estado']}, ${_inmueble['municipio']}', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                              const SizedBox(height: 4),
                              Text('$precio ${_inmueble['moneda']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
                        child: Column(
                          children: [
                            Text('Estado', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                            const SizedBox(height: 4),
                            Text(_inmueble['estadoVenta'] ?? 'Disponible', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Características', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
                    child: Column(
                      children: [
                        _buildCaracteristica(Icons.square_foot, 'Área Terreno', '${_inmueble['areaTerreno']} m²'),
                        const Divider(),
                        _buildCaracteristica(Icons.home, 'Área Construcción', '${_inmueble['areaConstruccion']} m²'),
                        const Divider(),
                        _buildCaracteristica(Icons.bed, 'Habitaciones', _inmueble['habitaciones'] ?? '0'),
                        const Divider(),
                        _buildCaracteristica(Icons.bathtub, 'Baños', _inmueble['banos'] ?? '0'),
                        const Divider(),
                        _buildCaracteristica(Icons.local_parking, 'Estacionamientos', _inmueble['estacionamientos'] ?? '0'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if ((_inmueble['descripcion'] ?? '').isNotEmpty) ...[
                    Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
                      child: Text(_inmueble['descripcion'] ?? '', style: TextStyle(fontSize: 14, color: AppTheme.getTextPrimaryColor(context), height: 1.5)),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text('Información Adicional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person, 'Propietario', _inmueble['propietario'] ?? 'No especificado'),
                        const Divider(),
                        _buildInfoRow(Icons.person_outline, 'Asesor', _inmueble['asesor'] ?? 'No asignado'),
                        const Divider(),
                        _buildInfoRow(Icons.calendar_today, 'Fecha de alta', _inmueble['fechaAlta'] ?? ''),
                        const Divider(),
                        _buildInfoRow(Icons.attach_money, 'Comisión', '${_inmueble['comision']} (${_inmueble['porcentajeComision']}%)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_inmueble['direccion'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
                              const SizedBox(height: 4),
                              Text('${_inmueble['municipio']}, ${_inmueble['estado']}, ${_inmueble['pais']}', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaracteristica(IconData icono, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14))),
          Text(valor, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.getTextPrimaryColor(context))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icono, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: AppTheme.getTextSecondaryColor(context), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14))),
          Text(valor, style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
        ],
      ),
    );
  }
}