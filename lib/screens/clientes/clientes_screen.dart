import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../formularios/nuevo_cliente_simple_form.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _tipoFilter = 'Todos';
  String _interesFilter = 'Todos';

  final List<String> _tiposInteres = [
    'Todos', 'Casa', 'Departamento', 'Terreno', 'Local', 'Oficina',
    'Hotel', 'Hacienda', 'Gasolinera', 'Combustible', 'Refinería', 'Mina', 'Minerales',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _supabase.from('clientes').select('*').order('created_at', ascending: false);
      final data = List<Map<String, dynamic>>.from(res);
      setState(() {
        _clientes = data;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _applyFilters() {
    _filtered = _clientes.where((c) {
      final s = _search.toLowerCase();
      final matchSearch = s.isEmpty ||
          (c['nombre']?.toString().toLowerCase().contains(s) ?? false) ||
          (c['telefono']?.toString().contains(s) ?? false);
      final matchTipo = _tipoFilter == 'Todos' || c['tipo'] == _tipoFilter;
      final matchInteres = _interesFilter == 'Todos' || c['catalogo_interes'] == _interesFilter;
      return matchSearch && matchTipo && matchInteres;
    }).toList();
    if (mounted) setState(() {});
  }

  void _openForm({Map<String, dynamic>? cliente}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevoClienteSimpleForm(
          cliente: cliente,
          onClienteCreado: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.people, color: Colors.white),
          SizedBox(width: 8),
          Text('Clientes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _openForm()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.message, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          //  SECCIÓN FIJA: Búsqueda y filtros
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (v) { _search = v; _applyFilters(); },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipoFilter,
                    decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.grey, fontSize: 12), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: ['Todos', 'Comprador', 'Vendedor', 'Inversionista', 'Rentador'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) { _tipoFilter = v ?? 'Todos'; _applyFilters(); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _interesFilter,
                    decoration: const InputDecoration(labelText: 'Interés', labelStyle: TextStyle(color: Colors.grey, fontSize: 12), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: _tiposInteres.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) { _interesFilter = v ?? 'Todos'; _applyFilters(); },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 🔒 HEADER FIJO DE LA TABLA
          Container(
            color: const Color(0xFF111111),
            child: _buildHeader(),
          ),
          // 📜 SOLO LAS FILAS HACEN SCROLL
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No hay clientes', style: TextStyle(color: Colors.grey, fontSize: 14)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                width: totalWidth > 1400 ? totalWidth : 1400,
                                child: Column(
                                  children: _filtered.map((c) => _buildRow(c)).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      color: const Color(0xFF111111),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text('', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 240, child: Text('NOMBRE', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 130, child: Text('TIPO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 150, child: Text('TELÉFONO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 200, child: Text('UBICACIÓN', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 110, child: Text('PAÍS', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 130, child: Text('ESTADO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 140, child: Text('PRESUPUESTO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 140, child: Text('INTERÉS', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 200, child: Text('ASESOR', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 110, child: Text('ESTADO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 200, child: Text('NOTAS', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildAvatar(String nombre, Color color) {
    final inicial = nombre.toString().isNotEmpty ? nombre.toString().substring(0, 1).toUpperCase() : 'S';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          inicial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> c) {
    final nombre = c['nombre'] ?? 'Sin nombre';
    final tipo = c['tipo'] ?? 'Comprador';
    final tel = c['telefono'] ?? '---';
    final ubicacion = c['ubicacion'] ?? '---';
    final pais = c['pais'] ?? 'México';
    final estado = c['estado'] ?? '---';
    final presupuesto = c['presupuesto'] ?? 0;
    final interes = c['catalogo_interes'] ?? '---';
    final asesor = c['asesor'] ?? '---';
    final activo = c['activo'] ?? true;
    final notas = c['notas'] ?? '---';

    Color tipoColor;
    switch (tipo) {
      case 'Comprador': tipoColor = Colors.orange; break;
      case 'Vendedor': tipoColor = Colors.blue; break;
      case 'Inversionista': tipoColor = Colors.purple; break;
      case 'Rentador': tipoColor = Colors.green; break;
      default: tipoColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _showDetails(c),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(width: 80, child: Padding(padding: const EdgeInsets.only(right: 8), child: _buildAvatar(nombre, Colors.orange.shade700))),
            SizedBox(width: 240, child: Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 130, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: tipoColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text(tipo, style: TextStyle(color: tipoColor, fontSize: 12, fontWeight: FontWeight.w500)))),
            SizedBox(width: 150, child: Text(tel, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            SizedBox(width: 200, child: Text(ubicacion, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 110, child: Text(pais, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            SizedBox(width: 130, child: Text(estado, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            SizedBox(width: 140, child: Text(presupuesto > 0 ? '\$${(presupuesto / 1000000).toStringAsFixed(1)} M' : '---', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w500))),
            SizedBox(width: 140, child: Text(interes, style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 200, child: Text(asesor, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 110, child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: activo ? Colors.green : Colors.red, shape: BoxShape.circle)), const SizedBox(width: 6), Text(activo ? 'Activo' : 'Inactivo', style: TextStyle(color: activo ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w500))])),
            SizedBox(width: 200, child: Text(notas, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(8)), child: Center(child: Text((c['nombre'] ?? 'S').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(c['tipo'] ?? 'Comprador', style: TextStyle(color: Colors.orange.shade300, fontSize: 14)),
                  ])),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () { Navigator.pop(ctx); _openForm(cliente: c); }),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF333333)),
              const SizedBox(height: 16),
              _detailRow(Icons.phone, 'Teléfono', c['telefono'] ?? '---'),
              _detailRow(Icons.location_on, 'Ubicación', c['ubicacion'] ?? '---'),
              _detailRow(Icons.flag, 'País', c['pais'] ?? 'México'),
              _detailRow(Icons.map, 'Estado', c['estado'] ?? '---'),
              _detailRow(Icons.attach_money, 'Presupuesto', '\$${c['presupuesto'] ?? 0} MXN'),
              _detailRow(Icons.folder, 'Interés', c['catalogo_interes'] ?? '---'),
              _detailRow(Icons.person, 'Asesor', c['asesor'] ?? '---'),
              _detailRow(Icons.handshake, 'Estado de negociación', c['estado_negociacion'] ?? 'Inicial'),
              const SizedBox(height: 16),
              const Text('Notas', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(8)), child: Text(c['notas'] ?? 'Sin notas', style: const TextStyle(color: Colors.white, fontSize: 13))),
              const SizedBox(height: 20),
              Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)), child: const Text('Cerrar', style: TextStyle(color: Colors.white))))]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}