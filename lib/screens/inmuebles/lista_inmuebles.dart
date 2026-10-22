import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../formularios/nuevo_inmueble_simple_form.dart';

class ListaInmuebles extends StatefulWidget {
  const ListaInmuebles({super.key});

  @override
  State<ListaInmuebles> createState() => _ListaInmueblesState();
}

class _ListaInmueblesState extends State<ListaInmuebles> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _inmuebles = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _tipoFilter = 'Todos';
  String _asesorFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _supabase.from('inmuebles').select('*').order('created_at', ascending: false);
      final data = List<Map<String, dynamic>>.from(res);
      setState(() {
        _inmuebles = data;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    _filtered = _inmuebles.where((i) {
      final s = _search.toLowerCase();
      final matchSearch = s.isEmpty ||
          (i['titulo']?.toString().toLowerCase().contains(s) ?? false) ||
          (i['ubicacion']?.toString().toLowerCase().contains(s) ?? false);
      final matchTipo = _tipoFilter == 'Todos' || i['tipo'] == _tipoFilter;
      final matchAsesor = _asesorFilter == 'Todos' || i['asesor'] == _asesorFilter;
      return matchSearch && matchTipo && matchAsesor;
    }).toList();
    if (mounted) setState(() {});
  }

  void _openForm({Map<String, dynamic>? inmueble}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevoInmuebleSimpleForm(
          inmueble: inmueble,
          onInmuebleCreado: _load,
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
          Icon(Icons.home, color: Colors.white),
          SizedBox(width: 8),
          Text('Inmuebles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => _openForm()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por título, ubicación o asesor...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
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
                    decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.grey, fontSize: 11), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: ['Todos', 'Casa', 'Departamento', 'Terreno', 'Local', 'Oficina', 'Hacienda', 'Gasolinera', 'Mina'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) { _tipoFilter = v ?? 'Todos'; _applyFilters(); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _asesorFilter,
                    decoration: const InputDecoration(labelText: 'Asesor', labelStyle: TextStyle(color: Colors.grey, fontSize: 11), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: ['Todos'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                    onChanged: (v) { _asesorFilter = v ?? 'Todos'; _applyFilters(); },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No hay inmuebles', style: TextStyle(color: Colors.grey)))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: 1500,
                          child: Column(
                            children: [
                              _buildHeader(),
                              ..._filtered.map((i) => _buildRow(i)),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFF111111),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text('', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 200, child: Text('TÍTULO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 100, child: Text('TIPO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 150, child: Text('UBICACIÓN', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 120, child: Text('PRECIO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 100, child: Text('SUPERFICIE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text('REC.', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 60, child: Text('BAÑOS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 150, child: Text('ASESOR', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
          SizedBox(width: 100, child: Text('ESTADO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> i) {
    final titulo = i['titulo'] ?? 'Sin título';
    final tipo = i['tipo'] ?? 'Casa';
    final ubicacion = i['ubicacion'] ?? '---';
    final precio = i['precio'] ?? 0;
    final superficie = i['superficie'] ?? 0;
    final recamaras = i['recamaras'] ?? 0;
    final banos = i['banos'] ?? 0;
    final asesor = i['asesor'] ?? '---';
    final activo = i['activo'] ?? true;
    final inicial = titulo.toString().isNotEmpty ? titulo.toString().substring(0, 1).toUpperCase() : 'I';

    Color tipoColor;
    switch (tipo) {
      case 'Casa': tipoColor = Colors.blue; break;
      case 'Departamento': tipoColor = Colors.purple; break;
      case 'Terreno': tipoColor = Colors.green; break;
      case 'Local': tipoColor = Colors.orange; break;
      case 'Oficina': tipoColor = Colors.teal; break;
      case 'Hacienda': tipoColor = Colors.brown; break;
      case 'Gasolinera': tipoColor = Colors.cyan; break;
      case 'Mina': tipoColor = Colors.grey; break;
      default: tipoColor = Colors.blue;
    }

    return InkWell(
      onTap: () => _showDetails(i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(width: 50, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: tipoColor.withOpacity(0.8), borderRadius: BorderRadius.circular(4)), child: Center(child: Text(inicial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))))),
            SizedBox(width: 200, child: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 100, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: tipoColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text(tipo, style: TextStyle(color: tipoColor, fontSize: 10)))),
            SizedBox(width: 150, child: Text(ubicacion, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 120, child: Text('\$${(precio / 1000000).toStringAsFixed(2)} MDP', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold))),
            SizedBox(width: 100, child: Text(superficie > 0 ? '$superficie m²' : '---', style: const TextStyle(color: Colors.grey, fontSize: 11))),
            SizedBox(width: 60, child: Text(recamaras > 0 ? '$recamaras' : '-', style: const TextStyle(color: Colors.grey, fontSize: 11))),
            SizedBox(width: 60, child: Text(banos > 0 ? '$banos' : '-', style: const TextStyle(color: Colors.grey, fontSize: 11))),
            SizedBox(width: 150, child: Text(asesor, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 100, child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: activo ? Colors.green : Colors.red, shape: BoxShape.circle)), const SizedBox(width: 4), Text(activo ? 'Activo' : 'Inactivo', style: TextStyle(color: activo ? Colors.green : Colors.red, fontSize: 10))])),
          ],
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> i) {
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
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.home, color: Colors.white, size: 24))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(i['titulo'] ?? 'Sin título', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(i['tipo'] ?? 'Casa', style: TextStyle(color: Colors.blue.shade300, fontSize: 14)),
                  ])),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () { Navigator.pop(ctx); _openForm(inmueble: i); }),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF333333)),
              const SizedBox(height: 16),
              _detailRow(Icons.location_on, 'Ubicación', i['ubicacion'] ?? '---'),
              _detailRow(Icons.attach_money, 'Precio', '\$${i['precio'] ?? 0} MXN'),
              _detailRow(Icons.square_foot, 'Superficie', '${i['superficie'] ?? 0} m²'),
              _detailRow(Icons.bed, 'Recámaras', '${i['recamaras'] ?? 0}'),
              _detailRow(Icons.bathtub, 'Baños', '${i['banos'] ?? 0}'),
              _detailRow(Icons.person, 'Asesor', i['asesor'] ?? '---'),
              _detailRow(Icons.folder, 'Catálogo', i['catalogo'] ?? '---'),
              const SizedBox(height: 16),
              const Text('Descripción', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(8)), child: Text(i['descripcion'] ?? 'Sin descripción', style: const TextStyle(color: Colors.white, fontSize: 13))),
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