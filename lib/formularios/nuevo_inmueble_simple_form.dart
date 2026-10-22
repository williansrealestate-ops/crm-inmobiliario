import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NuevoInmuebleSimpleForm extends StatefulWidget {
  final Map<String, dynamic>? inmueble;
  final VoidCallback? onInmuebleCreado;

  const NuevoInmuebleSimpleForm({
    super.key,
    this.inmueble,
    this.onInmuebleCreado,
  });

  @override
  State<NuevoInmuebleSimpleForm> createState() => _NuevoInmuebleSimpleFormState();
}

class _NuevoInmuebleSimpleFormState extends State<NuevoInmuebleSimpleForm> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _tituloController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _paisController = TextEditingController();
  final _estadoController = TextEditingController();
  final _precioController = TextEditingController();
  final _superficieController = TextEditingController();
  final _recamarasController = TextEditingController();
  final _banosController = TextEditingController();
  final _asesorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _catalogoController = TextEditingController();
  final _notasController = TextEditingController();

  String _tipo = 'Casa';
  bool _activo = true;

  bool get _esEditar => widget.inmueble != null;

  @override
  void initState() {
    super.initState();
    if (_esEditar) {
      _tituloController.text = widget.inmueble?['titulo'] ?? '';
      _ubicacionController.text = widget.inmueble?['ubicacion'] ?? '';
      _paisController.text = widget.inmueble?['pais'] ?? 'México';
      _estadoController.text = widget.inmueble?['estado'] ?? '';
      _precioController.text = widget.inmueble?['precio']?.toString() ?? '0';
      _superficieController.text = widget.inmueble?['superficie']?.toString() ?? '0';
      _recamarasController.text = widget.inmueble?['recamaras']?.toString() ?? '0';
      _banosController.text = widget.inmueble?['banos']?.toString() ?? '0';
      _asesorController.text = widget.inmueble?['asesor'] ?? '';
      _descripcionController.text = widget.inmueble?['descripcion'] ?? '';
      _catalogoController.text = widget.inmueble?['catalogo'] ?? '';
      _notasController.text = widget.inmueble?['notas'] ?? '';
      _tipo = widget.inmueble?['tipo'] ?? 'Casa';
      _activo = widget.inmueble?['activo'] ?? true;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _ubicacionController.dispose();
    _paisController.dispose();
    _estadoController.dispose();
    _precioController.dispose();
    _superficieController.dispose();
    _recamarasController.dispose();
    _banosController.dispose();
    _asesorController.dispose();
    _descripcionController.dispose();
    _catalogoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final data = {
        'titulo': _tituloController.text.trim(),
        'tipo': _tipo,
        'ubicacion': _ubicacionController.text.trim(),
        'pais': _paisController.text.trim(),
        'estado': _estadoController.text.trim(),
        'precio': double.tryParse(_precioController.text) ?? 0,
        'superficie': double.tryParse(_superficieController.text) ?? 0,
        'recamaras': int.tryParse(_recamarasController.text) ?? 0,
        'banos': int.tryParse(_banosController.text) ?? 0,
        'asesor': _asesorController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'catalogo': _catalogoController.text.trim(),
        'notas': _notasController.text.trim(),
        'activo': _activo,
      };

      if (_esEditar) {
        await _supabase.from('inmuebles').update(data).eq('id', widget.inmueble!['id']);
      } else {
        await _supabase.from('inmuebles').insert(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_esEditar ? 'Inmueble actualizado' : 'Inmueble creado'), backgroundColor: Colors.green),
        );
        widget.onInmuebleCreado?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: Text(_esEditar ? 'Editar Inmueble' : 'Nuevo Inmueble',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(_tituloController, 'Título *', Icons.title, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    _buildDropdownField('Tipo', _tipo, ['Casa', 'Departamento', 'Terreno', 'Local', 'Oficina', 'Hacienda', 'Gasolinera', 'Mina'], (v) => setState(() => _tipo = v!)),
                    const SizedBox(height: 16),
                    _buildTextField(_ubicacionController, 'Ubicación', Icons.location_on),
                    const SizedBox(height: 16),
                    _buildTextField(_paisController, 'País', Icons.flag),
                    const SizedBox(height: 16),
                    _buildTextField(_estadoController, 'Estado', Icons.map),
                    const SizedBox(height: 16),
                    _buildTextField(_precioController, 'Precio (MXN)', Icons.attach_money, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(_superficieController, 'Superficie (m²)', Icons.square_foot, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_recamarasController, 'Recámaras', Icons.bed, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_banosController, 'Baños', Icons.bathtub, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_asesorController, 'Asesor', Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(_catalogoController, 'Catálogo', Icons.folder),
                    const SizedBox(height: 16),
                    _buildTextField(_descripcionController, 'Descripción', Icons.description, maxLines: 4),
                    const SizedBox(height: 16),
                    _buildTextField(_notasController, 'Notas', Icons.note, maxLines: 4),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Inmueble activo', style: TextStyle(color: Colors.white)),
                      value: _activo,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _activo = v),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(_esEditar ? 'Actualizar Inmueble' : 'Crear Inmueble',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF333333))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0066FF))),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF333333))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0066FF))),
      ),
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }
}