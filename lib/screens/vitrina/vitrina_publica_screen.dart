import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/indexed_db_service.dart';
import '../../services/favoritos_service.dart';
import 'detalle_propiedad_screen.dart';
import 'vista_mapa_screen.dart';
import 'simulador_credito_screen.dart';
import 'mis_favoritos_screen.dart';
import 'contacto_screen.dart';

class VitrinaPublicaScreen extends StatefulWidget {
  const VitrinaPublicaScreen({super.key});

  @override
  State<VitrinaPublicaScreen> createState() => _VitrinaPublicaScreenState();
}

class _VitrinaPublicaScreenState extends State<VitrinaPublicaScreen> {
  List<Map<String, dynamic>> _inmuebles = [];
  List<Map<String, dynamic>> _inmueblesFiltrados = [];
  Map<String, dynamic> _config = {};
  String _busqueda = '';
  String _filtroTipo = 'Todos';
  String _filtroUbicacion = 'Todas';
  RangeValues _rangoPrecio = const RangeValues(0, 500000000);
  int _paginaActual = 0;
  final int _porPagina = 6;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final configJson = await IndexedDBService.get('vitrina_config');
      if (configJson != null) {
        _config = Map<String, dynamic>.from(jsonDecode(configJson) as Map);
      } else {
        _config = {
          'titulo': 'Williams Real Estate',
          'descripcion': 'Encuentra la propiedad de tus sueños en México',
          'telefono': '9932149996',
          'whatsapp': '529932149996',
          'email': 'willians.realestate@gmail.com',
        };
      }
      final inmueblesJson = await IndexedDBService.get('inmuebles');
      if (inmueblesJson != null) {
        final lista = jsonDecode(inmueblesJson) as List;
        _inmuebles = lista
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where((i) => i['activo'] != false)
            .toList();
      }
    } catch (e) {
      print('Error al cargar vitrina: $e');
    }
    _aplicarFiltros();
    setState(() => _cargando = false);
  }

  void _aplicarFiltros() {
    var lista = _inmuebles;
    if (_filtroTipo != 'Todos') {
      lista = lista.where((i) => (i['tipo'] ?? '') == _filtroTipo).toList();
    }
    if (_filtroUbicacion != 'Todas') {
      lista = lista.where((i) {
        final ubi = (i['ubicacion'] ?? '').toString().toLowerCase();
        return ubi.contains(_filtroUbicacion.toLowerCase());
      }).toList();
    }
    lista = lista.where((i) {
      final precio = _parsePrecio(i['precio']);
      return precio >= _rangoPrecio.start && precio <= _rangoPrecio.end;
    }).toList();
    if (_busqueda.isNotEmpty) {
      final busq = _busqueda.toLowerCase();
      lista = lista.where((i) {
        final titulo = (i['titulo'] ?? '').toString().toLowerCase();
        final ubicacion = (i['ubicacion'] ?? '').toString().toLowerCase();
        return titulo.contains(busq) || ubicacion.contains(busq);
      }).toList();
    }
    setState(() {
      _inmueblesFiltrados = lista;
      _paginaActual = 0;
    });
  }

  double _parsePrecio(dynamic precio) {
    if (precio == null) return 0;
    if (precio is int) return precio.toDouble();
    if (precio is double) return precio;
    return double.tryParse(precio.toString()) ?? 0;
  }

  List<String> _getUbicacionesUnicas() {
    final ubicaciones = <String>{};
    for (var inm in _inmuebles) {
      final ubi = inm['ubicacion']?.toString() ?? '';
      if (ubi.isNotEmpty) {
        final partes = ubi.split(',');
        if (partes.length > 1) {
          ubicaciones.add(partes.last.trim());
        } else {
          ubicaciones.add(ubi);
        }
      }
    }
    return ['Todas', ...ubicaciones.toList()];
  }

  List<String> _getTiposUnicos() {
    final tipos = <String>{};
    for (var inm in _inmuebles) {
      final tipo = inm['tipo']?.toString() ?? 'Otro';
      tipos.add(tipo);
    }
    return ['Todos', ...tipos.toList()];
  }

  String _formatearPrecio(dynamic precio) {
    final valor = _parsePrecio(precio);
    if (valor >= 1000000) {
      return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(0)}K';
    }
    return '\$${valor.toStringAsFixed(0)}';
  }

  List<Map<String, dynamic>> get _inmueblesPaginados {
    final inicio = _paginaActual * _porPagina;
    final fin = inicio + _porPagina;
    if (inicio >= _inmueblesFiltrados.length) return [];
    return _inmueblesFiltrados.sublist(inicio, fin > _inmueblesFiltrados.length ? _inmueblesFiltrados.length : fin);
  }

  int get _totalPaginas => (_inmueblesFiltrados.length / _porPagina).ceil();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _config['titulo'] ?? 'Real Estate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0066FF),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroSection(),
                    _buildFiltrosSection(),
                    _buildBotonVistaMapa(),
                    _buildResultadosHeader(),
                    _buildGridPropiedades(),
                    if (_totalPaginas > 1) _buildPaginacion(),
                    _buildFooter(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E40AF).withOpacity(0.9),
            const Color(0xFF0066FF).withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _PatternPainter()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home, color: Color(0xFF0066FF), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _config['titulo'] ?? 'Real Estate',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    if (_config['telefono'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(_config['telefono'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 80),
                const Text(
                  'Encuentra la propiedad\n de tus sueños',
                  style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w800, height: 1.1),
                ),
                const SizedBox(height: 20),
                Text(
                  _config['descripcion'] ?? 'Las mejores propiedades en México',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.search, color: Color(0xFF6B7280), size: 24),
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (valor) {
                            setState(() => _busqueda = valor);
                            _aplicarFiltros();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Buscar por ubicación, tipo o nombre...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Buscar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    _buildStatItem(Icons.home, '${_inmuebles.length}', 'Propiedades'),
                    const SizedBox(width: 40),
                    _buildStatItem(Icons.location_on, '${_getUbicacionesUnicas().length - 1}', 'Ubicaciones'),
                    const SizedBox(width: 40),
                    _buildStatItem(Icons.verified, '100%', 'Confiable'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icono, String valor, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltrosSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtrar propiedades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButton<String>(
                  value: _filtroTipo,
                  underline: const SizedBox(),
                  items: _getTiposUnicos().map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                  onChanged: (valor) {
                    setState(() => _filtroTipo = valor!);
                    _aplicarFiltros();
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButton<String>(
                  value: _filtroUbicacion,
                  underline: const SizedBox(),
                  items: _getUbicacionesUnicas().map((ubi) => DropdownMenuItem(value: ubi, child: Text(ubi))).toList(),
                  onChanged: (valor) {
                    setState(() => _filtroUbicacion = valor!);
                    _aplicarFiltros();
                  },
                ),
              ),
              Container(
                width: 320,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rango de precio: ${_formatearPrecio(_rangoPrecio.start)} - ${_formatearPrecio(_rangoPrecio.end)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: _rangoPrecio,
                      min: 0,
                      max: 500000000,
                      divisions: 50,
                      activeColor: const Color(0xFF0066FF),
                      inactiveColor: const Color(0xFFE5E7EB),
                      labels: RangeLabels(
                        _formatearPrecio(_rangoPrecio.start),
                        _formatearPrecio(_rangoPrecio.end),
                      ),
                      onChanged: (valores) {
                        setState(() => _rangoPrecio = valores);
                        _aplicarFiltros();
                      },
                    ),
                  ],
                ),
              ),
              if (_filtroTipo != 'Todos' || _filtroUbicacion != 'Todas' || _busqueda.isNotEmpty || _rangoPrecio.start > 0 || _rangoPrecio.end < 500000000)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _filtroTipo = 'Todos';
                      _filtroUbicacion = 'Todas';
                      _busqueda = '';
                      _rangoPrecio = const RangeValues(0, 500000000);
                    });
                    _aplicarFiltros();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Limpiar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO CON LOS 4 BOTONES FUNCIONALES
  Widget _buildBotonVistaMapa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VistaMapaScreen(
                    inmuebles: _inmueblesFiltrados,
                    config: _config,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map, size: 18),
            label: const Text('Ver en mapa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SimuladorCreditoScreen(
                    precioPropiedad: 4500000,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calculate, size: 18),
            label: const Text('Simulador de crédito'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0066FF),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFF0066FF)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MisFavoritosScreen(config: _config),
                ),
              );
            },
            icon: const Icon(Icons.favorite, size: 18),
            label: const Text('Mis favoritos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactoScreen(config: _config),
                ),
              );
            },
            icon: const Icon(Icons.email, size: 18),
            label: const Text('Contáctanos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          Text('${_inmueblesFiltrados.length} propiedades encontradas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
          const Spacer(),
          const Text('Ordenar por: Más recientes', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildGridPropiedades() {
    final inmuebles = _inmueblesPaginados;
    if (inmuebles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Icon(Icons.home_work, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text('No hay propiedades que coincidan con tu búsqueda', style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
            const SizedBox(height: 12),
            const Text('Intenta cambiar los filtros o buscar otra ubicación', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: inmuebles.map((inmueble) => _buildPropertyCard(inmueble)).toList(),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> inmueble) {
    final titulo = inmueble['titulo'] ?? 'Sin título';
    final tipo = inmueble['tipo'] ?? 'Otro';
    final ubicacion = inmueble['ubicacion'] ?? '';
    final precio = inmueble['precio'] ?? 0;
    final recamaras = inmueble['recamaras'] ?? 0;
    final banos = inmueble['banos'] ?? 0;
    final area = inmueble['area'] ?? 0;
    final fotos = inmueble['fotos'] is List ? List<String>.from(inmueble['fotos'] as List) : [];

    IconData iconoTipo;
    Color colorTipo;
    switch (tipo.toLowerCase()) {
      case 'casa': iconoTipo = Icons.home; colorTipo = const Color(0xFF3B82F6); break;
      case 'departamento': iconoTipo = Icons.apartment; colorTipo = const Color(0xFF8B5CF6); break;
      case 'terreno': iconoTipo = Icons.landscape; colorTipo = const Color(0xFFF59E0B); break;
      case 'local': iconoTipo = Icons.store; colorTipo = const Color(0xFF10B981); break;
      case 'oficina': iconoTipo = Icons.business; colorTipo = const Color(0xFF06B6D4); break;
      case 'hacienda': iconoTipo = Icons.agriculture; colorTipo = const Color(0xFFEF4444); break;
      default: iconoTipo = Icons.home_work; colorTipo = const Color(0xFF64748B);
    }

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
                    Positioned.fill(child: Image.network(fotos.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderImage(iconoTipo)))
                  else
                    _buildPlaceholderImage(iconoTipo),
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
                    child: FutureBuilder<bool>(
                      future: FavoritosService.esFavorito(inmueble['id'] ?? ''),
                      builder: (context, snapshot) {
                        final esFav = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () async {
                            await FavoritosService.toggleFavorito(inmueble['id'] ?? '');
                            setState(() {});
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(esFav ? ' Eliminado de favoritos' : '❤️ Agregado a favoritos'), backgroundColor: esFav ? const Color(0xFF6B7280) : const Color(0xFFEF4444)),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Icon(esFav ? Icons.favorite : Icons.favorite_border, color: esFav ? const Color(0xFFEF4444) : const Color(0xFF6B7280), size: 20),
                          ),
                        );
                      },
                    ),
                  ),
                  if (fotos.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                        child: Text('${fotos.length} fotos', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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
                        if (recamaras > 0) _buildCaracteristica(Icons.bed, '$recamaras', 'Rec'),
                        if (banos > 0) _buildCaracteristica(Icons.bathtub, '$banos', 'Baños'),
                        if (area > 0) _buildCaracteristica(Icons.square_foot, _formatearArea(area), 'm²'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _mostrarDetalles(inmueble),
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
                          final whatsapp = _config['whatsapp'] ?? '529932149996';
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

  Widget _buildPlaceholderImage(IconData icono) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icono, size: 64, color: Colors.white.withOpacity(0.9)), const SizedBox(height: 8), Text('Sin fotos', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13))]));
  }

  Widget _buildCaracteristica(IconData icono, String valor, String label) {
    return Column(children: [Icon(icono, size: 18, color: const Color(0xFF6B7280)), const SizedBox(height: 4), Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)))]);
  }

  String _formatearArea(dynamic area) {
    if (area == null) return '0';
    final valor = area is int ? area : (area is double ? area.toInt() : int.tryParse(area.toString()) ?? 0);
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}K';
    return '$valor';
  }

  Widget _buildPaginacion() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_paginaActual > 0)
            ElevatedButton.icon(onPressed: () { setState(() => _paginaActual--); _scrollArriba(); }, icon: const Icon(Icons.arrow_back), label: const Text('Anterior'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0066FF), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(width: 16),
          Text('Página ${_paginaActual + 1} de $_totalPaginas', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(width: 16),
          if (_paginaActual < _totalPaginas - 1)
            ElevatedButton.icon(onPressed: () { setState(() => _paginaActual++); _scrollArriba(); }, icon: const Icon(Icons.arrow_forward), label: const Text('Siguiente'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
        ],
      ),
    );
  }

  void _scrollArriba() {
    html.window.scrollTo(0, 0);
  }

  void _mostrarDetalles(Map<String, dynamic> inmueble) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallePropiedadScreen(
          inmueble: inmueble,
          config: _config,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(color: Color(0xFF1F2937)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0066FF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.home, color: Colors.white, size: 24)), const SizedBox(width: 12), Text(_config['titulo'] ?? 'Real Estate', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))]),
                    const SizedBox(height: 16),
                    Text(_config['descripcion'] ?? 'Encuentra la propiedad de tus sueños', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contacto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (_config['telefono'] != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.phone, color: Color(0xFF9CA3AF), size: 16), const SizedBox(width: 8), Text(_config['telefono'], style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14))])),
                  if (_config['email'] != null) Row(children: [const Icon(Icons.email, color: Color(0xFF9CA3AF), size: 16), const SizedBox(width: 8), Text(_config['email'], style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14))]),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enlaces', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildFooterLink('Inicio'),
                  _buildFooterLink('Propiedades'),
                  _buildFooterLink('Contacto'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('© 2026 ${_config['titulo'] ?? 'Real Estate'}. Todos los derechos reservados.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                Row(children: [_buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)), const SizedBox(width: 12), _buildSocialIcon(Icons.chat, const Color(0xFF25D366)), const SizedBox(width: 12), _buildSocialIcon(Icons.email, const Color(0xFFEA4335))]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String texto) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(texto, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)));
  }

  Widget _buildSocialIcon(IconData icono, Color color) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Icon(icono, color: color, size: 18));
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}