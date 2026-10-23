import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class DetallePropiedadScreen extends StatefulWidget {
  final Map<String, dynamic> inmueble;
  final Map<String, dynamic> config;

  const DetallePropiedadScreen({
    super.key,
    required this.inmueble,
    required this.config,
  });

  @override
  State<DetallePropiedadScreen> createState() => _DetallePropiedadScreenState();
}

class _DetallePropiedadScreenState extends State<DetallePropiedadScreen> {
  int _fotoActual = 0;
  late List<String> _fotos;

  @override
  void initState() {
    super.initState();
    _fotos = widget.inmueble['fotos'] is List
        ? List<String>.from(widget.inmueble['fotos'] as List)
        : [];
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return Icons.home;
      case 'departamento': return Icons.apartment;
      case 'terreno': return Icons.landscape;
      case 'local': return Icons.store;
      case 'oficina': return Icons.business;
      case 'hacienda': return Icons.agriculture;
      default: return Icons.home_work;
    }
  }

  Color _getColorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return const Color(0xFF3B82F6);
      case 'departamento': return const Color(0xFF8B5CF6);
      case 'terreno': return const Color(0xFFF59E0B);
      case 'local': return const Color(0xFF10B981);
      case 'oficina': return const Color(0xFF06B6D4);
      case 'hacienda': return const Color(0xFFEF4444);
      default: return const Color(0xFF64748B);
    }
  }

  String _formatearPrecio(dynamic precio) {
    if (precio == null) return '\$0';
    final valor = precio is int ? precio.toDouble() : (precio is double ? precio : double.tryParse(precio.toString()) ?? 0);
    if (valor >= 1000000) {
      return '\$${(valor / 1000000).toStringAsFixed(2)}M MXN';
    } else if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(0)}K MXN';
    }
    return '\$${valor.toStringAsFixed(0)} MXN';
  }

  String _formatearArea(dynamic area) {
    if (area == null) return '0';
    final valor = area is int ? area : (area is double ? area.toInt() : int.tryParse(area.toString()) ?? 0);
    if (valor >= 1000000) {
      return '${(valor / 1000000).toStringAsFixed(2)}M';
    } else if (valor >= 1000) {
      return '${(valor / 1000).toStringAsFixed(1)}K';
    }
    return '$valor';
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.inmueble['titulo'] ?? 'Sin título';
    final tipo = widget.inmueble['tipo'] ?? 'Otro';
    final ubicacion = widget.inmueble['ubicacion'] ?? '';
    final precio = widget.inmueble['precio'] ?? 0;
    final descripcion = widget.inmueble['descripcion'] ?? 'Sin descripción disponible.';
    final recamaras = widget.inmueble['recamaras'] ?? 0;
    final banos = widget.inmueble['banos'] ?? 0;
    final area = widget.inmueble['area'] ?? 0;
    final latitud = widget.inmueble['latitud'];
    final longitud = widget.inmueble['longitud'];
    final colorTipo = _getColorTipo(tipo);
    final iconoTipo = _getIconoTipo(tipo);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF1F2937)),
            onPressed: () {
              final url = html.window.location.href;
              final mensaje = 'Mira esta propiedad: $titulo en $ubicacion por ${_formatearPrecio(precio)}. Más info: $url';
              html.window.open('https://wa.me/?text=${Uri.encodeComponent(mensaje)}', '_blank');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGaleria(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorTipo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(iconoTipo, size: 16, color: colorTipo),
                              const SizedBox(width: 6),
                              Text(tipo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colorTipo)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          titulo,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1F2937), height: 1.2),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20, color: Color(0xFF6B7280)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(ubicacion, style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (recamaras > 0) _buildCaracteristicaGrande(Icons.bed, '$recamaras', 'Recámaras'),
                              if (recamaras > 0) _buildDivider(),
                              if (banos > 0) _buildCaracteristicaGrande(Icons.bathtub, '$banos', 'Baños'),
                              if (banos > 0) _buildDivider(),
                              if (area > 0) _buildCaracteristicaGrande(Icons.square_foot, '${_formatearArea(area)} m²', 'Área total'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('Descripción', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(descripcion, style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.7)),
                        ),
                        const SizedBox(height: 32),
                        // ✅ VIDEO TOUR DINÁMICO
                        _buildVideoTour(),
                        const SizedBox(height: 32),
                        if (latitud != null && longitud != null) _buildMapa(latitud, longitud, ubicacion),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  SizedBox(width: 360, child: _buildPanelContacto(titulo, precio, tipo)),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGaleria() {
    if (_fotos.isEmpty) {
      return Container(
        height: 500,
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF1E40AF)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.home, size: 100, color: Colors.white), SizedBox(height: 16), Text('Sin fotos disponibles', style: TextStyle(color: Colors.white, fontSize: 18))])),
      );
    }
    return Column(
      children: [
        Container(
          height: 500,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(_fotos[_fotoActual], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0066FF), child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.white)))),
              ),
              if (_fotoActual > 0)
                Positioned(
                  left: 20, top: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]),
                      child: IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => setState(() => _fotoActual--)),
                    ),
                  ),
                ),
              if (_fotoActual < _fotos.length - 1)
                Positioned(
                  right: 20, top: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)]),
                      child: IconButton(icon: const Icon(Icons.chevron_right, size: 28), onPressed: () => setState(() => _fotoActual++)),
                    ),
                  ),
                ),
              Positioned(
                bottom: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_fotoActual + 1} / ${_fotos.length}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        if (_fotos.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _fotos.length,
                itemBuilder: (context, index) {
                  final isSelected = _fotoActual == index;
                  return GestureDetector(
                    onTap: () => setState(() => _fotoActual = index),
                    child: Container(
                      width: 120, margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: isSelected ? const Color(0xFF0066FF) : Colors.transparent, width: 3)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(_fotos[index], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE5E7EB), child: const Icon(Icons.broken_image, color: Colors.grey))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaracteristicaGrande(IconData icono, String valor, String label) {
    return Column(children: [Icon(icono, size: 32, color: const Color(0xFF0066FF)), const SizedBox(height: 8), Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))), Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))]);
  }

  Widget _buildDivider() {
    return Container(height: 50, width: 1, color: const Color(0xFFE5E7EB));
  }

  // ✅ VIDEO TOUR DINÁMICO: Lee videoUrl de cada propiedad
  Widget _buildVideoTour() {
    final videoUrl = widget.inmueble['videoUrl']?.toString() ?? '';
    final tieneVideo = videoUrl.isNotEmpty;
    
    String embedUrl = '';
    if (tieneVideo) {
      if (videoUrl.contains('youtube.com/watch?v=')) {
        final videoId = videoUrl.split('v=')[1].split('&')[0];
        embedUrl = 'https://www.youtube.com/embed/$videoId';
      } else if (videoUrl.contains('youtu.be/')) {
        final videoId = videoUrl.split('youtu.be/')[1].split('?')[0];
        embedUrl = 'https://www.youtube.com/embed/$videoId';
      } else if (videoUrl.contains('youtube.com/embed/')) {
        embedUrl = videoUrl;
      } else {
        embedUrl = 'https://www.youtube.com/embed/$videoUrl';
      }
    } else {
      embedUrl = 'https://www.youtube.com/embed/dQw4w9WgXcQ'; // Video por defecto
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Video Tour', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
        const SizedBox(height: 12),
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1F2937),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (_fotos.isNotEmpty)
                  Positioned.fill(child: Image.network(_fotos.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1F2937))))
                else
                  const Positioned.fill(child: Icon(Icons.videocam, size: 100, color: Colors.white24)),
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),
                Center(
                  child: GestureDetector(
                    onTap: () => html.window.open(embedUrl, '_blank'),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFFFF0000), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)]),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle, color: Color(0xFFFF0000), size: 16),
                        const SizedBox(width: 6),
                        Text(tieneVideo ? 'Ver video tour' : 'Video de ejemplo', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFF0000), borderRadius: BorderRadius.circular(8)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.youtube_searched_for, color: Colors.white, size: 14), SizedBox(width: 4), Text('YouTube', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))]),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          tieneVideo ? 'Haz clic para ver el recorrido virtual completo en YouTube' : 'Video de ejemplo. Agrega un video real desde el panel de administración.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildMapa(double lat, double lng, String ubicacion) {
    final bboxLngMin = lng - 0.05;
    final bboxLatMin = lat - 0.03;
    final bboxLngMax = lng + 0.05;
    final bboxLatMax = lat + 0.03;
    final mapaUrl = 'https://www.openstreetmap.org/export/embed.html?bbox=$bboxLngMin%2C$bboxLatMin%2C$bboxLngMax%2C$bboxLatMax&layer=mapnik&marker=$lat%2C$lng';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ubicación', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
        const SizedBox(height: 12),
        Container(
          height: 400,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: const HtmlElementView(viewType: 'mapa-detalle')),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Expanded(child: Text('Coordenadas: $lat, $lng', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
            TextButton.icon(onPressed: () => html.window.open('https://www.google.com/maps?q=$lat,$lng', '_blank'), icon: const Icon(Icons.open_in_new, size: 16), label: const Text('Ver en Google Maps')),
            const SizedBox(width: 8),
            TextButton.icon(onPressed: () => html.window.open(mapaUrl, '_blank'), icon: const Icon(Icons.map, size: 16), label: const Text('Ver en OpenStreetMap')),
          ],
        ),
      ],
    );
  }

  Widget _buildPanelContacto(String titulo, dynamic precio, String tipo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Precio', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_formatearPrecio(precio), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0066FF))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(_getIconoTipo(tipo), size: 20, color: _getColorTipo(tipo)), const SizedBox(width: 8), Text(tipo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))]),
                const SizedBox(height: 12),
                const Row(children: [Icon(Icons.verified, size: 16, color: Color(0xFF10B981)), SizedBox(width: 8), Text('Propiedad verificada', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))]),
                const SizedBox(height: 8),
                const Row(children: [Icon(Icons.calendar_today, size: 16, color: Color(0xFF6B7280)), SizedBox(width: 8), Text('Disponible ahora', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final mensaje = 'Hola, me interesa la propiedad: $titulo por ${_formatearPrecio(precio)}. ¿Podrían darme más información y agendar una visita?';
                final whatsapp = widget.config['whatsapp'] ?? '529932149996';
                html.window.open('https://wa.me/$whatsapp?text=${Uri.encodeComponent(mensaje)}', '_blank');
              },
              icon: const Icon(Icons.chat, size: 20),
              label: const Text('Contactar por WhatsApp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => html.window.open('tel:${widget.config['telefono'] ?? '9932149996'}', '_self'),
              icon: const Icon(Icons.phone, size: 20),
              label: const Text('Llamar ahora', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final email = widget.config['email'] ?? 'willians.realestate@gmail.com';
                final asunto = Uri.encodeComponent('Interés en: $titulo');
                final cuerpo = Uri.encodeComponent('Hola, me interesa la propiedad: $titulo por ${_formatearPrecio(precio)}.');
                html.window.open('mailto:$email?subject=$asunto&body=$cuerpo', '_blank');
              },
              icon: const Icon(Icons.email, size: 20),
              label: const Text('Enviar email', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1F2937), side: const BorderSide(color: Color(0xFFE5E7EB)), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Asesor asignado', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF0066FF), borderRadius: BorderRadius.circular(24)), child: const Center(child: Text('W', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)))),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Williams', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))), Text('Asesor certificado', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}