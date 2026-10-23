import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NuevoAsesorSimpleForm extends StatefulWidget {
  final Map<String, dynamic>? asesor;
  final VoidCallback? onAsesorCreado;

  const NuevoAsesorSimpleForm({
    super.key,
    this.asesor,
    this.onAsesorCreado,
  });

  @override
  State<NuevoAsesorSimpleForm> createState() => _NuevoAsesorSimpleFormState();
}

class _NuevoAsesorSimpleFormState extends State<NuevoAsesorSimpleForm> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _paisController = TextEditingController();
  final _estadoController = TextEditingController();
  final _grupoController = TextEditingController();
  final _comisionController = TextEditingController();
  final _notasController = TextEditingController();

  String _interes = 'Casa';
  bool _activo = true;

  final List<String> _tiposInteres = [
    'Casa', 'Departamento', 'Terreno', 'Local', 'Oficina',
    'Hotel', 'Hacienda', 'Gasolinera', 'Combustible', 'Refinería', 'Mina', 'Minerales',
  ];

  bool get _esEditar => widget.asesor != null;

  @override
  void initState() {
    super.initState();
    if (_esEditar) {
      _nombreController.text = widget.asesor?['nombre'] ?? '';
      _telefonoController.text = widget.asesor?['telefono'] ?? '';
      _ubicacionController.text = widget.asesor?['ubicacion'] ?? '';
      _paisController.text = widget.asesor?['pais'] ?? 'México';
      _estadoController.text = widget.asesor?['estado'] ?? '';
      _grupoController.text = widget.asesor?['grupo'] ?? '';
      _comisionController.text = widget.asesor?['comision']?.toString() ?? '0';
      _notasController.text = widget.asesor?['notas'] ?? '';
      _interes = widget.asesor?['catalogo'] ?? 'Casa';
      _activo = widget.asesor?['activo'] ?? true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    _paisController.dispose();
    _estadoController.dispose();
    _grupoController.dispose();
    _comisionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'pais': _paisController.text.trim(),
        'estado': _estadoController.text.trim(),
        'grupo': _grupoController.text.trim(),
        'catalogo': _interes,
        'comision': double.tryParse(_comisionController.text) ?? 0,
        'notas': _notasController.text.trim(),
        'activo': _activo,
      };

      if (_esEditar) {
        await _supabase.from('asesores').update(data).eq('id', widget.asesor!['id']);
      } else {
        await _supabase.from('asesores').insert(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_esEditar ? '✅ Asesor actualizado' : '✅ Asesor creado'), backgroundColor: Colors.green),
        );
        widget.onAsesorCreado?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
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
        title: Text(_esEditar ? 'Editar Asesor' : 'Nuevo Asesor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    _buildTextField(_nombreController, 'Nombre *', Icons.person, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    _buildTextField(_telefonoController, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField(_ubicacionController, 'Ubicación', Icons.location_on),
                    const SizedBox(height: 16),
                    _buildTextField(_paisController, 'País', Icons.flag),
                    const SizedBox(height: 16),
                    _buildTextField(_estadoController, 'Estado', Icons.map),
                    const SizedBox(height: 16),
                    _buildTextField(_grupoController, 'Grupo', Icons.group),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Interés',
                      _interes,
                      _tiposInteres,
                      (v) => setState(() => _interes = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_comisionController, 'Comisión (%)', Icons.percent, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(_notasController, 'Notas', Icons.note, maxLines: 4),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Asesor activo', style: TextStyle(color: Colors.white)),
                      value: _activo,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _activo = v),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(_esEditar ? 'Actualizar Asesor' : 'Crear Asesor', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
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