import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AsesoresScreen extends StatefulWidget {
  const AsesoresScreen({super.key});

  @override
  State<AsesoresScreen> createState() => _AsesoresScreenState();
}

class _AsesoresScreenState extends State<AsesoresScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 8),
          Text('Asesores', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _mostrarFormularioAsesor()),
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
                decoration: InputDecoration(hintText: 'Buscar asesores...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('asesores').orderBy('nombre').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    final asesores = snapshot.data?.docs ?? [];
                    final filtrados = asesores.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = (data['nombre'] ?? '').toString().toLowerCase();
                      final email = (data['email'] ?? '').toString().toLowerCase();
                      return _search.isEmpty || nombre.contains(_search) || email.contains(_search);
                    }).toList();

                    if (filtrados.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, color: Colors.grey, size: 64), SizedBox(height: 16), Text('No hay asesores registrados', style: TextStyle(color: Colors.grey, fontSize: 16))]));

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5),
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final doc = filtrados[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF222222))),
                          child: Row(children: [
                            Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle), child: Center(child: Text((data['nombre'] ?? '?').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(data['nombre'] ?? 'Sin nombre', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), Text(data['email'] ?? 'Sin email', style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)])),
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _mostrarFormularioAsesor(asesor: data, docId: doc.id)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _eliminarAsesor(doc.id, data['nombre'])),
                          ]),
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

  void _mostrarFormularioAsesor({Map<String, dynamic>? asesor, String? docId}) {
    final nombreCtrl = TextEditingController(text: asesor?['nombre'] ?? '');
    final emailCtrl = TextEditingController(text: asesor?['email'] ?? '');
    final telefonoCtrl = TextEditingController(text: asesor?['telefono'] ?? '');
    final facebookCtrl = TextEditingController(text: asesor?['facebook'] ?? '');
    final linkedinCtrl = TextEditingController(text: asesor?['linkedin'] ?? '');
    final paisCtrl = TextEditingController(text: asesor?['pais'] ?? 'México');
    final estadoCtrl = TextEditingController(text: asesor?['estado'] ?? '');
    final zonaCoberturaCtrl = TextEditingController(text: asesor?['zona_cobertura'] ?? '');
    final especialidadCtrl = TextEditingController(text: asesor?['especialidad'] ?? '');
    final comisionCtrl = TextEditingController(text: asesor?['comision']?.toString() ?? '5');
    final fechaIngresoCtrl = TextEditingController(text: asesor?['fecha_ingreso'] ?? '');
    final notasCtrl = TextEditingController(text: asesor?['notas'] ?? '');
    bool activo = asesor?['activo'] ?? true;

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
                  Icon(asesor == null ? Icons.person_add : Icons.edit, color: const Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(asesor == null ? 'Nuevo Asesor' : 'Editar Asesor', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 20),
                
                // Sección: Información Personal
                _buildSeccion('👤 Información Personal'),
                _buildCampo('Nombre completo *', nombreCtrl, icon: Icons.person),
                _buildCampo('Email', emailCtrl, icon: Icons.email, tipo: TextInputType.emailAddress),
                _buildCampo('Teléfono', telefonoCtrl, icon: Icons.phone, tipo: TextInputType.phone),
                _buildCampo('Facebook', facebookCtrl, icon: Icons.facebook),
                _buildCampo('LinkedIn', linkedinCtrl, icon: Icons.link),
                
                const SizedBox(height: 12),
                // Sección: Ubicación
                _buildSeccion('📍 Ubicación'),
                _buildCampo('Ubicación', paisCtrl, icon: Icons.location_on),
                Row(children: [
                  Expanded(child: _buildCampo('País', paisCtrl, icon: Icons.flag)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCampo('Estado', estadoCtrl, icon: Icons.map)),
                ]),
                _buildCampo('Zona de Cobertura', zonaCoberturaCtrl, icon: Icons.public),
                
                const SizedBox(height: 12),
                // Sección: Información Profesional
                _buildSeccion('💼 Información Profesional'),
                _buildCampo('Especialidad', especialidadCtrl, icon: Icons.star),
                _buildCampo('Comisión (%)', comisionCtrl, icon: Icons.percent, tipo: TextInputType.number),
                
                // Campo de Fecha con calendario
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: ctx,
                        initialDate: fechaIngresoCtrl.text.isNotEmpty ? DateTime.tryParse(fechaIngresoCtrl.text) ?? DateTime.now() : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF0066FF),
                                onPrimary: Colors.white,
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: const Color(0xFF1A1A1A),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (fecha != null) {
                        setSheetState(() {
                          fechaIngresoCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF0066FF), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Fecha de Ingreso', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(
                                  fechaIngresoCtrl.text.isNotEmpty ? fechaIngresoCtrl.text : 'Seleccionar fecha',
                                  style: TextStyle(color: fechaIngresoCtrl.text.isNotEmpty ? Colors.white : Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                // Sección: Estado y Notas
                _buildSeccion('📝 Estado y Notas'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activo', style: TextStyle(color: Colors.white)),
                  subtitle: Text(activo ? 'Asesor activo' : 'Asesor inactivo', style: const TextStyle(color: Colors.grey)),
                  value: activo,
                  activeColor: const Color(0xFF0066FF),
                  onChanged: (v) => setSheetState(() => activo = v),
                ),
                _buildCampoMultilinea('Notas / Observaciones', notasCtrl),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _guardarAsesor(ctx, nombreCtrl, emailCtrl, telefonoCtrl, facebookCtrl, linkedinCtrl, paisCtrl, estadoCtrl, zonaCoberturaCtrl, especialidadCtrl, comisionCtrl, fechaIngresoCtrl, notasCtrl, activo, docId),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(asesor == null ? 'Crear Asesor' : 'Guardar Cambios', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(titulo, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCampo(String label, TextEditingController ctrl, {IconData? icon, TextInputType? tipo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: ctrl, keyboardType: tipo, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0066FF)) : null, filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
    );
  }

  Widget _buildCampoMultilinea(String label, TextEditingController ctrl) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.notes, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Future<void> _guardarAsesor(BuildContext ctx, TextEditingController nombre, TextEditingController email, TextEditingController telefono, TextEditingController facebook, TextEditingController linkedin, TextEditingController pais, TextEditingController estado, TextEditingController zonaCobertura, TextEditingController especialidad, TextEditingController comision, TextEditingController fechaIngreso, TextEditingController notas, bool activo, String? docId) async {
    if (nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El nombre es obligatorio'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final data = {
        'nombre': nombre.text.trim(),
        'email': email.text.trim(),
        'telefono': telefono.text.trim(),
        'facebook': facebook.text.trim(),
        'linkedin': linkedin.text.trim(),
        'pais': pais.text.trim(),
        'estado': estado.text.trim(),
        'zona_cobertura': zonaCobertura.text.trim(),
        'especialidad': especialidad.text.trim(),
        'comision': double.tryParse(comision.text) ?? 5,
        'fecha_ingreso': fechaIngreso.text.trim(),
        'notas': notas.text.trim(),
        'activo': activo,
      };
      if (docId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('asesores').add(data);
      } else {
        await _firestore.collection('asesores').doc(docId).update(data);
      }
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? '✅ Asesor creado' : '✅ Asesor actualizado'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminarAsesor(String id, String nombre) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Eliminar Asesor', style: TextStyle(color: Colors.white)), content: Text('¿Eliminar a $nombre?', style: const TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red)))]));
    if (confirm == true) {
      await _firestore.collection('asesores').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }
}
// Versión actualizada: 2026-10-25