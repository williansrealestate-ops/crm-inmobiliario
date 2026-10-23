import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class VistaMapaScreen extends StatefulWidget {
  final List<Map<String, dynamic>> inmuebles;
  final Map<String, dynamic> config;

  const VistaMapaScreen({
    super.key,
    required this.inmuebles,
    required this.config,
  });

  @override
  State<VistaMapaScreen> createState() => _VistaMapaScreenState();
}

class _VistaMapaScreenState extends State<VistaMapaScreen> {
  Map<String, dynamic>? _inmuebleSeleccionado;

  String _formatearPrecio(dynamic precio) {
    if (precio == null) return '\$0';
    final valor = precio is int ? precio.toDouble() : (precio is double ? precio : double.tryParse(precio.toString()) ?? 0);
    if (valor >= 1000000) {
      return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(0)}K';
    }
    return '\$${valor.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final inmueblesConCoords = widget.inmuebles.where((i) => 
      i['latitud'] != null && i['longitud'] != null
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vista de Mapa',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
        ),
      ),
      body: inmueblesConCoords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay propiedades con ubicación en el mapa',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                // Mapa
                Expanded(
                  flex: 2,
                  child: Container(
                    color: const Color(0xFFE5E7EB),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 100, color: const Color(0xFF0066FF).withOpacity(0.3)),
                          const SizedBox(height: 20),
                          Text(
                            '${inmueblesConCoords.length} propiedades en el mapa',
                            style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Haz clic en una propiedad de la lista para ver detalles',
                            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                          ),
                          const SizedBox(height: 24),
                          ...inmueblesConCoords.map((inmueble) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _inmuebleSeleccionado = inmueble);
                                },
                                icon: const Icon(Icons.location_on, size: 18),
                                label: Text(
                                  inmueble['titulo'] ?? 'Sin título',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _inmuebleSeleccionado?['id'] == inmueble['id']
                                      ? const Color(0xFF0066FF)
                                      : Colors.white,
                                  foregroundColor: _inmuebleSeleccionado?['id'] == inmueble['id']
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                // Panel lateral
                if (_inmuebleSeleccionado != null)
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _inmuebleSeleccionado!['titulo'] ?? 'Sin título',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                              onPressed: () => setState(() => _inmuebleSeleccionado = null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _inmuebleSeleccionado!['ubicacion'] ?? '',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatearPrecio(_inmuebleSeleccionado!['precio']),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0066FF)),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Coordenadas', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                'Lat: ${_inmuebleSeleccionado!['latitud']}, Lng: ${_inmuebleSeleccionado!['longitud']}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final lat = _inmuebleSeleccionado!['latitud'];
                              final lng = _inmuebleSeleccionado!['longitud'];
                              html.window.open(
                                'https://www.google.com/maps?q=$lat,$lng',
                                '_blank',
                              );
                            },
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Ver en Google Maps'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final mensaje = 'Hola, me interesa la propiedad: ${_inmuebleSeleccionado!['titulo']} por ${_formatearPrecio(_inmuebleSeleccionado!['precio'])}';
                              final whatsapp = widget.config['whatsapp'] ?? '529932149996';
                              html.window.open(
                                'https://wa.me/$whatsapp?text=${Uri.encodeComponent(mensaje)}',
                                '_blank',
                              );
                            },
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('Contactar por WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}