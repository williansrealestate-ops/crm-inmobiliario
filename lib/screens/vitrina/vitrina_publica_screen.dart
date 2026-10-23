import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';

class VitrinaPublicaScreen extends StatefulWidget {
  const VitrinaPublicaScreen({super.key});

  @override
  State<VitrinaPublicaScreen> createState() => _VitrinaPublicaScreenState();
}

class _VitrinaPublicaScreenState extends State<VitrinaPublicaScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _inmuebles = [];
  List<Map<String, dynamic>> _inmueblesFiltrados = [];
  bool _cargando = true;
  
  String _filtroTipo = 'Todos';
  String _filtroUbicacion = 'Todas';
  RangeValues _rangoPrecio = const RangeValues(0, 50000000);
  double _precioMaximo = 50000000;
  
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarInmuebles();
  }

  Future<void> _cargarInmuebles() async {
    setState(() => _cargando = true);
    try {
      final response = await _client
          .from('inmuebles')
          .select()
          .eq('activo', true)
          .order('precio', ascending: true);

      final inmuebles = response.map((i) => Map<String, dynamic>.from(i)).toList();
      
      setState(() {
        _inmuebles = inmuebles;
        _inmueblesFiltrados = inmuebles;
        if (inmuebles.isNotEmpty) {
          final precios = inmuebles.map((i) => _toDouble(i['precio'])).toList();
          _precioMaximo = precios.reduce((a, b) => a > b ? a : b);
          _rangoPrecio = RangeValues(0, _precioMaximo);
        }
        _cargando = false;
      });
    } catch (e) {
      print('❌ Error al cargar inmuebles: $e');
      setState(() => _cargando = false);
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _inmueblesFiltrados = _inmuebles.where((i) {
        final tipo = i['tipo']?.toString() ?? '';
        final ubicacion = i['ubicacion']?.toString() ?? '';
        final precio = _toDouble(i['precio']);
        final titulo = i['titulo']?.toString().toLowerCase() ?? '';
        final busqueda = _busquedaCtrl.text.toLowerCase();

        final coincideTipo = _filtroTipo == 'Todos' || tipo == _filtroTipo;
        final coincideUbicacion = _filtroUbicacion == 'Todas' || 
            ubicacion.contains(_filtroUbicacion);
        final coincidePrecio = precio >= _rangoPrecio.start && 
            precio <= _rangoPrecio.end;
        final coincideBusqueda = busqueda.isEmpty || 
            titulo.contains(busqueda) || ubicacion.toLowerCase().contains(busqueda);

        return coincideTipo && coincideUbicacion && 
               coincidePrecio && coincideBusqueda;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Willians Real Estate - Vitrina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: Scaffold(
        body: _cargando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
            : Column(
                children: [
                  _buildHeader(),
                  _buildBuscador(),
                  _buildFiltros(),
                  Expanded(child: _buildListaInmuebles()),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.home, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'WILLIANS REAL ESTATE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Encuentra la propiedad de tus sueños',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  '52 993 214 9996',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E293B),
      child: TextField(
        controller: _busquedaCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar por título o ubicación...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF0F172A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.white54),
            onPressed: () {
              _busquedaCtrl.clear();
              _aplicarFiltros();
            },
          ),
        ),
        onChanged: (_) => _aplicarFiltros(),
      ),
    );
  }

  Widget _buildFiltros() {
    final tipos = ['Todos', ..._inmuebles.map((i) => i['tipo']?.toString() ?? '').toSet().where((t) => t.isNotEmpty)];
    final ubicaciones = ['Todas', ..._inmuebles.map((i) => i['ubicacion']?.toString() ?? '').toSet().where((u) => u.isNotEmpty)];

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Tipo', _filtroTipo, tipos, (val) {
                  setState(() => _filtroTipo = val ?? 'Todos');
                  _aplicarFiltros();
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown('Ubicación', _filtroUbicacion, ubicaciones, (val) {
                  setState(() => _filtroUbicacion = val ?? 'Todas');
                  _aplicarFiltros();
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Precio máx:', style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '\$${_formatearMonto(_rangoPrecio.end)}',
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFF10B981),
              overlayColor: const Color(0xFF10B981).withOpacity(0.2),
            ),
            child: RangeSlider(
              values: _rangoPrecio,
              min: 0,
              max: _precioMaximo > 0 ? _precioMaximo : 50000000,
              divisions: 100,
              labels: RangeLabels(
                '\$${_formatearMonto(_rangoPrecio.start)}',
                '\$${_formatearMonto(_rangoPrecio.end)}',
              ),
              onChanged: (val) {
                setState(() => _rangoPrecio = val);
                _aplicarFiltros();
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_inmueblesFiltrados.length} propiedades encontradas',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filtroTipo = 'Todos';
                    _filtroUbicacion = 'Todas';
                    _rangoPrecio = RangeValues(0, _precioMaximo);
                    _busquedaCtrl.clear();
                  });
                  _aplicarFiltros();
                },
                child: const Text('Limpiar', style: TextStyle(color: Color(0xFF3B82F6))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String valor, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: items.contains(valor) ? valor : items.first,
            dropdownColor: const Color(0xFF0F172A),
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildListaInmuebles() {
    if (_inmueblesFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text('No hay propiedades disponibles', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _inmueblesFiltrados.length,
      itemBuilder: (context, index) {
        return _buildInmuebleCard(_inmueblesFiltrados[index]);
      },
    );
  }

  Widget _buildInmuebleCard(Map<String, dynamic> inmueble) {
    final precio = _toDouble(inmueble['precio']);
    final tipo = inmueble['tipo']?.toString() ?? 'Sin tipo';
    final ubicacion = inmueble['ubicacion']?.toString() ?? 'Sin ubicación';
    final titulo = inmueble['titulo']?.toString() ?? 'Sin título';
    final descripcion = inmueble['descripcion']?.toString() ?? '';
    final area = _toDouble(inmueble['area']);
    final recamaras = inmueble['recamaras'] as int? ?? 0;
    final banos = inmueble['banos'] as int? ?? 0;
    final color = _getColorPorTipo(tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con tipo y precio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tipo,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${_formatearMonto(precio)} MXN',
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF64748B), size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ubicacion,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    descripcion,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                
                // Características
                if (area > 0 || recamaras > 0 || banos > 0)
                  Row(
                    children: [
                      if (area > 0) _buildCaracteristica(Icons.square_foot, '${area.toStringAsFixed(0)} m²'),
                      if (recamaras > 0) _buildCaracteristica(Icons.bed, '$recamaras Rec.'),
                      if (banos > 0) _buildCaracteristica(Icons.bathtub, '$banos Baños'),
                    ],
                  ),
                
                const SizedBox(height: 16),
                
                // Botón WhatsApp
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final mensaje = 'Hola Willians, me interesa la propiedad: $titulo ($ubicacion) por \$${_formatearMonto(precio)} MXN';
                      final url = 'https://wa.me/529932149996?text=${Uri.encodeComponent(mensaje)}';
                      // En web, abrir URL
                    },
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('Contactar por WhatsApp', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildCaracteristica(IconData icon, String texto) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
            const SizedBox(width: 4),
            Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
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

  String _formatearMonto(double monto) {
    if (monto >= 1000000) {
      return '${(monto / 1000000).toStringAsFixed(2)}M';
    } else if (monto >= 1000) {
      return '${(monto / 1000).toStringAsFixed(0)}K';
    }
    return monto.toStringAsFixed(0);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }
}