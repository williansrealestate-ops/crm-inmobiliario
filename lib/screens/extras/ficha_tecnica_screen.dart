import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/theme.dart';
import '../../services/fichas_service.dart';
import '../../services/local_storage_service.dart';

class FichaTecnicaScreen extends StatefulWidget {
  final Map<String, dynamic> propiedad;
  const FichaTecnicaScreen({super.key, required this.propiedad});

  @override
  State<FichaTecnicaScreen> createState() => _FichaTecnicaScreenState();
}

class _FichaTecnicaScreenState extends State<FichaTecnicaScreen> {
  bool _generando = false;

  @override
  Widget build(BuildContext context) {
    final prop = widget.propiedad;
    final titulo = prop['titulo'] ?? 'Sin título';
    final precio = prop['precio'] ?? 0;
    final ubicacion = prop['ubicacion'] ?? 'Sin ubicación';
    final tipo = prop['tipo'] ?? 'Casa';
    final recamaras = _toInt(prop['recamaras']);
    final banos = _toInt(prop['banos']);
    final area = _toDouble(prop['area']);
    final descripcion = prop['descripcion'] ?? 'Sin descripción disponible.';
    final caracteristicas = List<String>.from(prop['caracteristicas'] ?? []);
    final colorTipo = _getColorPorTipo(tipo);
    final precioFormateado = _formatearMoneda(precio);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.description, color: Colors.white), SizedBox(width: 8), Text('Ficha Técnica')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _generando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.picture_as_pdf),
            onPressed: _generando ? null : _generarYDescargarPDF,
            tooltip: 'Descargar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirFicha,
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con tipo y título
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorTipo, colorTipo.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: colorTipo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(tipo.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 16),
                  Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(ubicacion, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(precioFormateado, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Características principales
            Text('Características Principales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCaracteristicaCard('Recámaras', '$recamaras', Icons.bed, colorTipo)),
                const SizedBox(width: 12),
                Expanded(child: _buildCaracteristicaCard('Baños', '$banos', Icons.bathtub, colorTipo)),
                const SizedBox(width: 12),
                Expanded(child: _buildCaracteristicaCard('Área', '${area.toInt()} m²', Icons.square_foot, colorTipo)),
              ],
            ),
            const SizedBox(height: 24),

            // Descripción
            Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Text(descripcion, style: TextStyle(fontSize: 14, color: AppTheme.getTextSecondaryColor(context), height: 1.6)),
            ),
            const SizedBox(height: 24),

            // Características adicionales
            if (caracteristicas.isNotEmpty) ...[
              Text('Características Adicionales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: caracteristicas.map((c) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorTipo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorTipo.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: colorTipo),
                      const SizedBox(width: 4),
                      Text(c, style: TextStyle(fontSize: 12, color: colorTipo, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Código QR
            Text('Código QR para Compartir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: QrImageView(
                      data: 'https://realestate-crm.com/propiedad/${prop['id']}',
                      version: QrVersions.auto,
                      size: 120,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Escanea para ver la propiedad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
                        const SizedBox(height: 4),
                        Text('Comparte este código QR con tus clientes para que accedan a la ficha completa.', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón de descarga
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generando ? null : _generarYDescargarPDF,
                icon: _generando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf),
                label: Text(_generando ? 'Generando PDF...' : 'Descargar Ficha en PDF', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCaracteristicaCard(String label, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.getTextColor(context))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  Future<void> _generarYDescargarPDF() async {
    setState(() => _generando = true);
    try {
      final pdfBytes = await FichasService.generarFichaPDF(propiedad: widget.propiedad);
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'ficha_${widget.propiedad['id']}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Ficha PDF descargada exitosamente'), backgroundColor: Color(0xFF10B981)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Error al generar PDF: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
    setState(() => _generando = false);
  }

  void _compartirFicha() {
    final titulo = widget.propiedad['titulo'] ?? 'Propiedad';
    final precio = _formatearMoneda(widget.propiedad['precio'] ?? 0);
    final ubicacion = widget.propiedad['ubicacion'] ?? 'Sin ubicación';
    final mensaje = '🏠 *$titulo*\n\n💰 Precio: $precio\n📍 Ubicación: $ubicacion\n\n¡Contáctame para más información!';
    final url = 'https://wa.me/?text=${Uri.encodeComponent(mensaje)}';
    html.window.open(url, '_blank');
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

  String _formatearMoneda(dynamic valor) {
    if (valor == null) return '\$0';
    final num n = valor is String ? double.tryParse(valor.replaceAll(',', '')) ?? 0 : valor as num;
    if (n >= 1000000) return '\$${(n / 1000000).toStringAsFixed(2)} MDP';
    if (n >= 1000) return '\$${(n / 1000).toStringAsFixed(0)} K';
    return '\$${n.toStringAsFixed(0)}';
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return const Color(0xFF3B82F6);
      case 'departamento': return const Color(0xFF8B5CF6);
      case 'terreno': return const Color(0xFFF59E0B);
      case 'local': return const Color(0xFF10B981);
      case 'oficina': return const Color(0xFFEC4899);
      default: return const Color(0xFF64748B);
    }
  }
}