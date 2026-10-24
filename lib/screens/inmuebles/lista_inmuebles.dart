import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaInmuebles extends StatefulWidget {
  const ListaInmuebles({super.key});

  @override
  State<ListaInmuebles> createState() => _ListaInmueblesState();
}

class _ListaInmueblesState extends State<ListaInmuebles> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _search = '';
  String _tipoFiltro = 'Todos';
  String _asesorFiltro = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [Icon(Icons.home, color: Colors.white), SizedBox(width: 8), Text('Inmuebles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        actions: [IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _mostrarFormularioInmueble())],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF111111),
              child: Column(children: [
                TextField(decoration: InputDecoration(hintText: 'Buscar por título, ubicación o asesor...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), style: const TextStyle(color: Colors.white), onChanged: (v) => setState(() => _search = v.toLowerCase())),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(value: _tipoFiltro, decoration: InputDecoration(labelText: 'Tipo', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todos', 'Casa', 'Departamento', 'Terreno', 'Local', 'Oficina'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _tipoFiltro = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(value: _asesorFiltro, decoration: InputDecoration(labelText: 'Asesor', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todos', 'Williams'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => _asesorFiltro = v!))),
                ]),
              ]),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('inmuebles').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    final inmuebles = snapshot.data?.docs ?? [];
                    final filtrados = inmuebles.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final titulo = (data['titulo'] ?? '').toString().toLowerCase();
                      final ubicacion = (data['ubicacion'] ?? '').toString().toLowerCase();
                      final asesor = (data['asesor'] ?? '').toString();
                      final tipo = data['tipo'] ?? 'Todos';
                      final matchSearch = _search.isEmpty || titulo.contains(_search) || ubicacion.contains(_search) || asesor.contains(_search);
                      final matchTipo = _tipoFiltro == 'Todos' || tipo == _tipoFiltro;
                      final matchAsesor = _asesorFiltro == 'Todos' || asesor == _asesorFiltro;
                      return matchSearch && matchTipo && matchAsesor;
                    }).toList();

                    if (filtrados.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.home_outlined, color: Colors.grey, size: 64), SizedBox(height: 16), Text('No hay inmuebles registrados', style: TextStyle(color: Colors.grey, fontSize: 16))]));

                    return ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final doc = filtrados[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF222222))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.home, color: Colors.white, size: 40)),
                            title: Text(data['titulo'] ?? 'Sin título', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('${data['tipo'] ?? 'Casa'} - ${data['ubicacion'] ?? 'Sin ubicación'}', style: const TextStyle(color: Colors.grey)), Text('\$${data['precio'] ?? '0'}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _verDetalle(data)),
                              IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _mostrarFormularioInmueble(inmueble: data, docId: doc.id)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminarInmueble(doc.id, data['titulo'])),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioInmueble({Map<String, dynamic>? inmueble, String? docId}) {
    final tituloCtrl = TextEditingController(text: inmueble?['titulo'] ?? '');
    final tipoCtrl = TextEditingController(text: inmueble?['tipo'] ?? 'Casa');
    final ubicacionCtrl = TextEditingController(text: inmueble?['ubicacion'] ?? '');
    final paisCtrl = TextEditingController(text: inmueble?['pais'] ?? 'México');
    final estadoCtrl = TextEditingController(text: inmueble?['estado'] ?? '');
    final precioCtrl = TextEditingController(text: inmueble?['precio']?.toString() ?? '0');
    final superficieCtrl = TextEditingController(text: inmueble?['superficie']?.toString() ?? '0');
    final recamarasCtrl = TextEditingController(text: inmueble?['recamaras']?.toString() ?? '0');
    final banosCtrl = TextEditingController(text: inmueble?['banos']?.toString() ?? '0');
    final asesorCtrl = TextEditingController(text: inmueble?['asesor'] ?? 'Williams');
    final descripcionCtrl = TextEditingController(text: inmueble?['descripcion'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(inmueble == null ? Icons.add_home : Icons.edit, color: const Color(0xFF0066FF), size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(inmueble == null ? 'Nuevo Inmueble' : 'Editar Inmueble', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 20),
              _buildCampo('Título', tituloCtrl, icon: Icons.title),
              _buildCampo('Tipo', tipoCtrl, icon: Icons.category),
              _buildCampo('Ubicación', ubicacionCtrl, icon: Icons.location_on),
              Row(children: [Expanded(child: _buildCampo('País', paisCtrl, icon: Icons.flag)), const SizedBox(width: 12), Expanded(child: _buildCampo('Estado', estadoCtrl, icon: Icons.map))]),
              _buildCampo('Precio', precioCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
              _buildCampo('Superficie (m²)', superficieCtrl, icon: Icons.square_foot, tipo: TextInputType.number),
              Row(children: [Expanded(child: _buildCampo('Recámaras', recamarasCtrl, icon: Icons.bed, tipo: TextInputType.number)), const SizedBox(width: 12), Expanded(child: _buildCampo('Baños', banosCtrl, icon: Icons.bathtub, tipo: TextInputType.number))]),
              _buildCampo('Asesor', asesorCtrl, icon: Icons.person),
              _buildCampoMultilinea('Descripción', descripcionCtrl),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _guardarInmueble(ctx, tituloCtrl, tipoCtrl, ubicacionCtrl, paisCtrl, estadoCtrl, precioCtrl, superficieCtrl, recamarasCtrl, banosCtrl, asesorCtrl, descripcionCtrl, docId),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(inmueble == null ? 'Crear Inmueble' : 'Guardar Cambios', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController ctrl, {IconData? icon, TextInputType? tipo}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, keyboardType: tipo, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0066FF)) : null, filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Widget _buildCampoMultilinea(String label, TextEditingController ctrl) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.notes, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Future<void> _guardarInmueble(BuildContext ctx, TextEditingController titulo, TextEditingController tipo, TextEditingController ubicacion, TextEditingController pais, TextEditingController estado, TextEditingController precio, TextEditingController superficie, TextEditingController recamaras, TextEditingController banos, TextEditingController asesor, TextEditingController descripcion, String? docId) async {
    if (titulo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El título es obligatorio'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final data = {
        'titulo': titulo.text.trim(),
        'tipo': tipo.text.trim(),
        'ubicacion': ubicacion.text.trim(),
        'pais': pais.text.trim(),
        'estado': estado.text.trim(),
        'precio': double.tryParse(precio.text) ?? 0,
        'superficie': double.tryParse(superficie.text) ?? 0,
        'recamaras': int.tryParse(recamaras.text) ?? 0,
        'banos': int.tryParse(banos.text) ?? 0,
        'asesor': asesor.text.trim(),
        'descripcion': descripcion.text.trim(),
        'activo': true,
      };
      if (docId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('inmuebles').add(data);
      } else {
        await _firestore.collection('inmuebles').doc(docId).update(data);
      }
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? '✅ Inmueble creado' : '✅ Inmueble actualizado'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminarInmueble(String id, String titulo) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Eliminar Inmueble', style: TextStyle(color: Colors.white)), content: Text('¿Eliminar "$titulo"?', style: const TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red)))]));
    if (confirm == true) {
      await _firestore.collection('inmuebles').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }

  void _verDetalle(Map<String, dynamic> data) {
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: Text(data['titulo'] ?? 'Detalle', style: const TextStyle(color: Colors.white)), content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: data.entries.where((e) => e.key != 'created_at').map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 120, child: Text(e.key.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))), Expanded(child: Text('${e.value}', style: const TextStyle(color: Colors.white, fontSize: 14)))]))).toList()))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar', style: TextStyle(color: Colors.white)))]));
  }
}