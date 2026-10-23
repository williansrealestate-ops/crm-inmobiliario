import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/favoritos_service.dart';
import '../../services/indexed_db_service.dart';
import 'dart:convert';
import 'detalle_propiedad_screen.dart';

class MisFavoritosScreen extends StatefulWidget {
  final Map<String, dynamic> config;

  const MisFavoritosScreen({super.key, required this.config});

  @override
  State<MisFavoritosScreen> createState() => _MisFavoritosScreenState();
}

class _MisFavoritosScreenState extends State<MisFavoritosScreen> {
  List<Map<String, dynamic>> _favoritos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() => _cargando = true);
    try {
      final idsFavoritos = await FavoritosService.obtenerFavoritos();
      final inmueblesJson = await IndexedDBService.get('inmuebles');
      if (inmueblesJson != null) {
        final lista = jsonDecode(inmueblesJson) as List;
        final todosInmuebles = lista.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _favoritos = todosInmuebles.where((i) => idsFavoritos.contains(i['id'])).toList();
      }
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
    setState(() => _cargando = false);
  }

  String _formatearPrecio(dynamic precio) {
    if (precio == null) return '\$0';
    final valor = precio is int ? precio.toDouble() : (precio is double ? precio : double.tryParse(precio.toString()) ?? 0);
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)}K';
    return '\$${valor.toStringAsFixed(0)}';
  }

  String _formatearArea(dynamic area) {
    if (area == null) return '0';
    final valor = area is int ? area : (area is double ? area.toInt() : int.tryParse(area.toString()) ?? 0);
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}K';
    return '$valor';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            const Text('Mis Favoritos', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${_favoritos.length}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _favoritos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No tienes propiedades favoritas', style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
                      const SizedBox(height: 8),
                      const Text('Explora propiedades y guarda las que te gusten', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.search),
                        label: const Text('Explorar propiedades'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: _favoritos.map((inmueble) => _buildCard(inmueble)).toList(),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> inmueble) {
    final titulo = inmueble['titulo'] ?? 'Sin título';
    final tipo = inmueble['tipo'] ?? 'Otro';
    final ubicacion = inmueble['ubicacion'] ?? '';
    final precio = inmueble['precio'] ?? 0;
    final recamaras = inmueble['recamaras'] ?? 0;
    final banos = inmueble['banos'] ?? 0;
    final area = inmueble['area'] ?? 0;
    final fotos = inmueble['fotos'] is List ? List<String>.from(inmueble['fotos'] as List) : [];
    final colorTipo = _getColorTipo(tipo);
    final iconoTipo = _getIconoTipo(tipo);

    return Container(
      width: 380,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [colorTipo, colorTipo.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Stack(
                children: [
                  if (fotos.isNotEmpty)
                    Positioned.fill(child: Image.network(fotos.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(iconoTipo, size: 64, color: Colors.white.withOpacity(0.9)))))
                  else
                    Center(child: Icon(iconoTipo, size: 64, color: Colors.white.withOpacity(0.9))),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(iconoTipo, size: 14, color: colorTipo), const SizedBox(width: 4), Text(tipo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorTipo))]),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        await FavoritosService.toggleFavorito(inmueble['id'] ?? '');
                        await _cargarFavoritos();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💔 Eliminado de favoritos'), backgroundColor: Color(0xFF6B7280)));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatearPrecio(precio), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0066FF))),
                const SizedBox(height: 8),
                Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)), const SizedBox(width: 4), Expanded(child: Text(ubicacion, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                const SizedBox(height: 12),
                if (recamaras > 0 || banos > 0 || area > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (recamaras > 0) Column(children: [const Icon(Icons.bed, size: 18, color: Color(0xFF6B7280)), const SizedBox(height: 4), Text('$recamaras', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))), const Text('Rec', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)))]),
                        if (banos > 0) Column(children: [const Icon(Icons.bathtub, size: 18, color: Color(0xFF6B7280)), const SizedBox(height: 4), Text('$banos', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))), const Text('Baños', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)))]),
                        if (area > 0) Column(children: [const Icon(Icons.square_foot, size: 18, color: Color(0xFF6B7280)), const SizedBox(height: 4), Text(_formatearArea(area), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))), const Text('m²', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)))]),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetallePropiedadScreen(inmueble: inmueble, config: widget.config)));
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Ver detalles'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                        onPressed: () {
                          final mensaje = 'Hola, me interesa la propiedad: $titulo por ${_formatearPrecio(precio)}. ¿Podrían darme más información?';
                          final whatsapp = widget.config['whatsapp'] ?? '529932149996';
                          html.window.open('https://wa.me/$whatsapp?text=${Uri.encodeComponent(mensaje)}', '_blank');
                        },
                      ),
                    ),
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