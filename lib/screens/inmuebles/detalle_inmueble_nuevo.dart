import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';
import '../extras/detalle_asesor.dart';
import '../clientes/detalle_cliente.dart';

class DetalleInmuebleNuevo extends StatelessWidget {
  final Map<String, dynamic> inmueble;
  const DetalleInmuebleNuevo({super.key, required this.inmueble});

  void _copiarTexto(BuildContext context, String texto, String label) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ $label copiado'), backgroundColor: AppTheme.success, duration: const Duration(seconds: 2)),
    );
  }

  String _formatearPrecio(String precio) {
    final valor = double.tryParse(precio?.replaceAll(',', '') ?? '0') ?? 0;
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)}K';
    return '\$${valor.toStringAsFixed(0)}';
  }

  void _irADetalleAsesor(BuildContext context, String nombreAsesor) {
    final asesores = LocalStorageService.getAsesores();
    final asesor = asesores.firstWhere((a) => a['nombre'] == nombreAsesor, orElse: () => {});
    if (asesor.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleAsesor(asesor: asesor)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se encontró: $nombreAsesor'), backgroundColor: AppTheme.warning));
    }
  }

  void _irADetalleCliente(BuildContext context, String nombreCliente) {
    final clientes = LocalStorageService.getClientes();
    final cliente = clientes.firstWhere((c) => c['nombre'] == nombreCliente, orElse: () => {});
    if (cliente.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DetalleCliente(cliente: cliente)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se encontró: $nombreCliente'), backgroundColor: AppTheme.warning));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = inmueble['titulo'] ?? '';
    final tipo = inmueble['tipo'] ?? 'Casa';
    final precio = _formatearPrecio(inmueble['precio'] ?? '0');
    final estado = inmueble['estado'] ?? '';
    final municipio = inmueble['municipio'] ?? '';
    final direccion = inmueble['direccion'] ?? '';
    final areaTerreno = inmueble['areaTerreno'] ?? '';
    final areaConstruccion = inmueble['areaConstruccion'] ?? '';
    final habitaciones = inmueble['habitaciones'] ?? '';
    final banos = inmueble['banos'] ?? '';
    final estacionamientos = inmueble['estacionamientos'] ?? '';
    final estadoVenta = inmueble['estadoVenta'] ?? 'Disponible';
    final descripcion = inmueble['descripcion'] ?? '';
    final propietario = inmueble['propietario'] ?? '';
    final asesor = inmueble['asesor'] ?? '';
    final fechaIngreso = inmueble['fechaIngreso'] ?? '';
    final fechaVenta = inmueble['fechaVenta'] ?? '';
    final notas = inmueble['notas'] ?? '';
    final archivo = inmueble['archivo'] ?? '';
    final fotoBase64 = inmueble['fotoBase64'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Detalle del Inmueble'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primary, width: 3)),
                  child: ClipOval(
                    child: fotoBase64.isNotEmpty
                        ? Image.network(fotoBase64, fit: BoxFit.cover)
                        : Container(color: AppTheme.primary.withOpacity(0.2), child: Center(child: Icon(Icons.home, color: AppTheme.primary, size: 40))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))),
                      const SizedBox(height: 4),
                      Text('$tipo • $estadoVenta', style: TextStyle(fontSize: 14, color: AppTheme.getTextSecondaryColor(context))),
                      const SizedBox(height: 4),
                      Text(precio, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.success)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(context, 'Información General', [
              _buildInfoRow(context, Icons.location_on, 'Ubicación', '$direccion, $municipio, $estado', null),
              _buildInfoRow(context, Icons.square_foot, 'Área Terreno', '$areaTerreno m²', null),
              _buildInfoRow(context, Icons.home, 'Área Construcción', '$areaConstruccion m²', null),
              _buildInfoRow(context, Icons.bed, 'Habitaciones', habitaciones, null),
              _buildInfoRow(context, Icons.bathtub, 'Baños', banos, null),
              _buildInfoRow(context, Icons.local_parking, 'Estacionamientos', estacionamientos, null),
            ]),
            const SizedBox(height: 24),
            if (descripcion.isNotEmpty) ...[
              _buildSection(context, 'Descripción', [], customContent: _buildCajaTexto(context, descripcion)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _copiarTexto(context, descripcion, 'Descripción'),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar descripción'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              ),
              const SizedBox(height: 24),
            ],
            if (archivo.isNotEmpty) ...[
              _buildSection(context, 'Archivo', [], customContent: _buildCajaTexto(context, archivo)),
              const SizedBox(height: 24),
            ],
            if (notas.isNotEmpty) ...[
              _buildSection(context, 'Notas', [], customContent: _buildCajaTexto(context, notas)),
              const SizedBox(height: 24),
            ],
            _buildSection(context, 'Información de Venta', [
              _buildInfoRow(context, Icons.calendar_today, 'Fecha de Ingreso', fechaIngreso, null),
              if (fechaVenta.isNotEmpty) _buildInfoRow(context, Icons.check_circle, 'Fecha de Venta', fechaVenta, null),
              _buildInfoRowClickable(context, Icons.person, 'Propietario', propietario, () => _irADetalleCliente(context, propietario)),
              _buildInfoRowClickable(context, Icons.business, 'Asesor', asesor, () => _irADetalleAsesor(context, asesor)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCajaTexto(BuildContext context, String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Text(texto, style: TextStyle(fontSize: 14, color: AppTheme.getTextPrimaryColor(context), height: 1.5)),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> rows, {Widget? customContent}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
        const SizedBox(height: 12),
        if (customContent != null) customContent
        else Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, VoidCallback? onCopy) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.getBorderColor(context)))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.getTextSecondaryColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
              ],
            ),
          ),
          if (onCopy != null) IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: onCopy),
        ],
      ),
    );
  }

  Widget _buildInfoRowClickable(BuildContext context, IconData icon, String label, String value, VoidCallback onTap) {
    if (value.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.getBorderColor(context))),
          color: AppTheme.primary.withOpacity(0.02),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary, decoration: TextDecoration.underline)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}