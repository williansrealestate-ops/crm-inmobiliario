import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _search = '';

  // Tipos de propiedades disponibles
  final List<String> _tiposPropiedad = [
    'Casa',
    'Departamento',
    'Terreno',
    'Local Comercial',
    'Hotel',
    'Oficina',
    'ave Industrial',
    'Rancho',
    'Hacienda',
    'Combustible',
    'Gasolinera',
    'Refinería',
    'Mina',
    'Minerales',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.people, color: Colors.white),
          SizedBox(width: 8),
          Text('Clientes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _mostrarFormularioCliente()),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF111111),
              child: TextField(
                decoration: InputDecoration(hintText: 'Buscar clientes...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('clientes').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    final clientes = snapshot.data?.docs ?? [];
                    final filtrados = clientes.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = (data['nombre'] ?? '').toString().toLowerCase();
                      return _search.isEmpty || nombre.contains(_search);
                    }).toList();

                    if (filtrados.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, color: Colors.grey, size: 64), SizedBox(height: 16), Text('No hay clientes registrados', style: TextStyle(color: Colors.grey, fontSize: 16))]));

                    return ListView.builder(
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final doc = filtrados[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF222222))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(backgroundColor: Colors.blue.shade700, radius: 24, child: Text((data['nombre'] ?? '?').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            title: Text(data['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('${data['tipo'] ?? 'Comprador'}', style: const TextStyle(color: Colors.blue)), Text('${data['telefono'] ?? 'Sin teléfono'}', style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _verDetalle(data)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _mostrarFormularioCliente(cliente: data, docId: doc.id)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminarCliente(doc.id, data['nombre']))]),
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

  void _mostrarFormularioCliente({Map<String, dynamic>? cliente, String? docId}) {
    final nombreCtrl = TextEditingController(text: cliente?['nombre'] ?? '');
    final telefonoCtrl = TextEditingController(text: cliente?['telefono'] ?? '');
    final ubicacionCtrl = TextEditingController(text: cliente?['ubicacion'] ?? '');
    final paisCtrl = TextEditingController(text: cliente?['pais'] ?? 'México');
    final estadoCtrl = TextEditingController(text: cliente?['estado'] ?? '');
    final presupuestoCtrl = TextEditingController(text: cliente?['presupuesto']?.toString() ?? '0');
    final notasCtrl = TextEditingController(text: cliente?['notas'] ?? '');
    
    // Valores seleccionados para dropdowns
    String tipoSeleccionado = cliente?['tipo'] ?? 'Casa';
    String interesSeleccionado = cliente?['interes'] ?? 'Casa';
    String asesorSeleccionado = cliente?['asesor'] ?? '';
    String elegioSeleccionado = cliente?['elegio'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(cliente == null ? Icons.person_add : Icons.edit, color: const Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(cliente == null ? 'Nuevo Cliente' : 'Editar Cliente', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 20),
                
                // Sección: Información Personal
                _buildSeccion('👤 Información Personal'),
                _buildCampo('Nombre completo *', nombreCtrl, icon: Icons.person),
                _buildCampo('Teléfono', telefonoCtrl, icon: Icons.phone, tipo: TextInputType.phone),
                
                const SizedBox(height: 12),
                // Sección: Ubicación
                _buildSeccion('📍 Ubicación'),
                _buildCampo('Ubicación', ubicacionCtrl, icon: Icons.location_on),
                Row(children: [
                  Expanded(child: _buildCampo('País', paisCtrl, icon: Icons.flag)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCampo('Estado', estadoCtrl, icon: Icons.map)),
                ]),
                
                const SizedBox(height: 12),
                // Sección: Información del Proyecto
                _buildSeccion('🏠 Información del Proyecto'),
                
                // Dropdown TIPO
                _buildDropdown(
                  label: 'Tipo de Propiedad',
                  value: tipoSeleccionado,
                  icon: Icons.category,
                  items: _tiposPropiedad,
                  onChanged: (v) => setSheetState(() => tipoSeleccionado = v!),
                ),
                
                // Dropdown INTERÉS
                _buildDropdown(
                  label: 'Interés',
                  value: interesSeleccionado,
                  icon: Icons.favorite,
                  items: _tiposPropiedad,
                  onChanged: (v) => setSheetState(() => interesSeleccionado = v!),
                ),
                
                // Dropdown ELEGIO (desde Firebase - colección inmuebles)
                _buildDropdownInmuebles(
                  value: elegioSeleccionado,
                  onChanged: (v) => setSheetState(() => elegioSeleccionado = v ?? ''),
                ),
                
                _buildCampo('Presupuesto (MXN)', presupuestoCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
                
                const SizedBox(height: 12),
                // Sección: Asesor (Dropdown desde Firebase)
                _buildSeccion(' Asesor Asignado'),
                _buildDropdownAsesor(
                  value: asesorSeleccionado,
                  onChanged: (v) => setSheetState(() => asesorSeleccionado = v ?? ''),
                ),
                
                const SizedBox(height: 12),
                // Sección: Notas
                _buildSeccion(' Notas'),
                _buildCampoMultilinea('Notas / Observaciones', notasCtrl),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _guardarCliente(ctx, nombreCtrl, telefonoCtrl, ubicacionCtrl, paisCtrl, estadoCtrl, presupuestoCtrl, notasCtrl, tipoSeleccionado, interesSeleccionado, asesorSeleccionado, elegioSeleccionado, docId),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(cliente == null ? 'Crear Cliente' : 'Guardar Cambios', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para dropdowns de tipo/interés
  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF0066FF)),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        dropdownColor: const Color(0xFF1A1A1A),
        style: const TextStyle(color: Colors.white),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Widget para dropdown de Inmuebles (desde Firebase - colección inmuebles)
  Widget _buildDropdownInmuebles({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('inmuebles').where('activo', isEqualTo: true).orderBy('titulo').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Icon(Icons.home, color: Color(0xFF0066FF)),
                SizedBox(width: 12),
                Text('Cargando inmuebles...', style: TextStyle(color: Colors.grey)),
              ]),
            ),
          );
        }
        
        final inmuebles = snapshot.data!.docs;
        final items = inmuebles.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['titulo'] as String;
        }).toList();
        
        // Si el inmueble seleccionado no está en la lista, agregarlo
        if (value.isNotEmpty && !items.contains(value)) {
          items.insert(0, value);
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            decoration: InputDecoration(
              labelText: 'Elegio (Inmueble)',
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.home, color: Color(0xFF0066FF)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            hint: const Text('Seleccionar inmueble', style: TextStyle(color: Colors.grey)),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }

  // Widget para dropdown de Asesores (desde Firebase)
  Widget _buildDropdownAsesor({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('asesores').where('activo', isEqualTo: true).orderBy('nombre').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Icon(Icons.person, color: Color(0xFF0066FF)),
                SizedBox(width: 12),
                Text('Cargando asesores...', style: TextStyle(color: Colors.grey)),
              ]),
            ),
          );
        }
        
        final asesores = snapshot.data!.docs;
        final items = asesores.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['nombre'] as String;
        }).toList();
        
        // Si el asesor seleccionado no está en la lista, agregarlo
        if (value.isNotEmpty && !items.contains(value)) {
          items.insert(0, value);
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : (items.isNotEmpty ? items.first : null),
            decoration: InputDecoration(
              labelText: 'Asesor',
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF0066FF)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            hint: const Text('Seleccionar asesor', style: TextStyle(color: Colors.grey)),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }

  Widget _buildSeccion(String titulo) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(titulo, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)));
  }

  Widget _buildCampo(String label, TextEditingController ctrl, {IconData? icon, TextInputType? tipo}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, keyboardType: tipo, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0066FF)) : null, filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Widget _buildCampoMultilinea(String label, TextEditingController ctrl) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.notes, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Future<void> _guardarCliente(BuildContext ctx, TextEditingController nombre, TextEditingController telefono, TextEditingController ubicacion, TextEditingController pais, TextEditingController estado, TextEditingController presupuesto, TextEditingController notas, String tipo, String interes, String asesor, String elegio, String? docId) async {
    if (nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El nombre es obligatorio'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final data = {
        'nombre': nombre.text.trim(),
        'telefono': telefono.text.trim(),
        'ubicacion': ubicacion.text.trim(),
        'pais': pais.text.trim(),
        'estado': estado.text.trim(),
        'presupuesto': double.tryParse(presupuesto.text) ?? 0,
        'notas': notas.text.trim(),
        'tipo': tipo,
        'interes': interes,
        'asesor': asesor,
        'elegio': elegio,
        'activo': true,
      };
      if (docId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('clientes').add(data);
      } else {
        await _firestore.collection('clientes').doc(docId).update(data);
      }
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? '✅ Cliente creado' : '✅ Cliente actualizado'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminarCliente(String id, String nombre) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Eliminar Cliente', style: TextStyle(color: Colors.white)), content: Text('¿Eliminar a $nombre?', style: const TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red)))]));
    if (confirm == true) {
      await _firestore.collection('clientes').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }

  void _verDetalle(Map<String, dynamic> data) {
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: Text(data['nombre'] ?? 'Detalle', style: const TextStyle(color: Colors.white)), content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: data.entries.where((e) => e.key != 'created_at').map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 120, child: Text(e.key.toUpperCase(), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))), Expanded(child: Text('${e.value}', style: const TextStyle(color: Colors.white, fontSize: 14)))]))).toList()))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar', style: TextStyle(color: Colors.white)))]));
  }
}