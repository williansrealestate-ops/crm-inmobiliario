import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../formularios/nuevo_asesor_simple_form.dart';

class AsesoresScreen extends StatefulWidget {
  const AsesoresScreen({super.key});

  @override
  State<AsesoresScreen> createState() => _AsesoresScreenState();
}

class _AsesoresScreenState extends State<AsesoresScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _asesores = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _grupoFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _supabase.from('asesores').select('*').order('nombre');
      final data = List<Map<String, dynamic>>.from(res);
      setState(() {
        _asesores = data;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    _filtered = _asesores.where((a) {
      final s = _search.toLowerCase();
      final matchSearch = s.isEmpty || (a['nombre']?.toString().toLowerCase().contains(s) ?? false);
      final matchGrupo = _grupoFilter == 'Todos' || a['grupo'] == _grupoFilter;
      return matchSearch && matchGrupo;
    }).toList();
    if (mounted) setState(() {});
  }

  void _openForm({Map<String, dynamic>? asesor}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NuevoAsesorSimpleForm(
          asesor: asesor,
          onAsesorCreado: _load,
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
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 8),
          Text('Asesores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar asesores...',
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
            child: DropdownButtonFormField<String>(
              value: _grupoFilter,
              decoration: const InputDecoration(labelText: 'Grupo', labelStyle: TextStyle(color: Colors.grey, fontSize: 12), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: ['Todos'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) { _grupoFilter = v ?? 'Todos'; _applyFilters(); },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No hay asesores', style: TextStyle(color: Colors.grey, fontSize: 14)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                width: totalWidth > 1300 ? totalWidth : 1300,
                                child: Column(
                                  children: [
                                    _buildHeader(),
                                    ..._filtered.map((a) => _buildRow(a)),
                                  ],
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
          SizedBox(width: 60, child: Text('', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 240, child: Text('NOMBRE', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 130, child: Text('GRUPO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 150, child: Text('TELÉFONO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 200, child: Text('UBICACIÓN', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 110, child: Text('PAÍS', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 130, child: Text('ESTADO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 110, child: Text('COMISIÓN', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 140, child: Text('CATÁLOGO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 110, child: Text('ESTADO', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
          SizedBox(width: 200, child: Text('NOTAS', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> a) {
    final nombre = a['nombre'] ?? 'Sin nombre';
    final grupo = a['grupo'] ?? 'Sin grupo';
    final tel = a['telefono'] ?? '---';
    final ubicacion = a['ubicacion'] ?? '---';
    final pais = a['pais'] ?? 'México';
    final estado = a['estado'] ?? '---';
    final comision = a['comision'] ?? 0;
    final catalogo = a['catalogo'] ?? '---';
    final activo = a['activo'] ?? true;
    final notas = a['notas'] ?? '---';
    final inicial = nombre.toString().isNotEmpty ? nombre.toString().substring(0, 1).toUpperCase() : 'A';

    return InkWell(
      onTap: () => _showDetails(a),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade900, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(width: 60, child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)), child: Center(child: Text(inicial, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))))),
            SizedBox(width: 240, child: Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 130, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text(grupo, style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500)))),
            SizedBox(width: 150, child: Text(tel, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            SizedBox(width: 200, child: Text(ubicacion, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 110, child: Text(pais, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            SizedBox(width: 130, child: Text(estado, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            SizedBox(width: 110, child: Text('$comision%', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold))),
            SizedBox(width: 140, child: Text(catalogo, style: const TextStyle(color: Colors.amber, fontSize: 13), overflow: TextOverflow.ellipsis)),
            SizedBox(width: 110, child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: activo ? Colors.green : Colors.red, shape: BoxShape.circle)), const SizedBox(width: 6), Text(activo ? 'Activo' : 'Inactivo', style: TextStyle(color: activo ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w500))])),
            SizedBox(width: 200, child: Text(notas, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> a) {
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
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: Center(child: Text((a['nombre'] ?? 'A').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(a['grupo'] ?? 'Sin grupo', style: TextStyle(color: Colors.blue.shade300, fontSize: 14)),
                  ])),
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () { Navigator.pop(ctx); _openForm(asesor: a); }),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF333333)),
              const SizedBox(height: 16),
              _detailRow(Icons.phone, 'Teléfono', a['telefono'] ?? '---'),
              _detailRow(Icons.location_on, 'Ubicación', a['ubicacion'] ?? '---'),
              _detailRow(Icons.flag, 'País', a['pais'] ?? 'México'),
              _detailRow(Icons.map, 'Estado', a['estado'] ?? '---'),
              _detailRow(Icons.percent, 'Comisión', '${a['comision'] ?? 0}%'),
              _detailRow(Icons.folder, 'Catálogo', a['catalogo'] ?? '---'),
              const SizedBox(height: 16),
              const Text('Notas', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(8)), child: Text(a['notas'] ?? 'Sin notas', style: const TextStyle(color: Colors.white, fontSize: 13))),
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