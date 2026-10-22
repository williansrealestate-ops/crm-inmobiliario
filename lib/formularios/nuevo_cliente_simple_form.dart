import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NuevoClienteSimpleForm extends StatefulWidget {
  final Map<String, dynamic>? cliente;
  final VoidCallback? onClienteCreado;

  const NuevoClienteSimpleForm({
    super.key,
    this.cliente,
    this.onClienteCreado,
  });

  @override
  State<NuevoClienteSimpleForm> createState() => _NuevoClienteSimpleFormState();
}

class _NuevoClienteSimpleFormState extends State<NuevoClienteSimpleForm> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _presupuestoController = TextEditingController();
  final _catalogoController = TextEditingController();
  final _asesorController = TextEditingController();
  final _estadoNegociacionController = TextEditingController();
  final _notasController = TextEditingController();

  String _tipo = 'Comprador';
  bool _activo = true;

  bool get _esEditar => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (_esEditar) {
      _nombreController.text = widget.cliente?['nombre'] ?? '';
      _emailController.text = widget.cliente?['email'] ?? '';
      _telefonoController.text = widget.cliente?['telefono'] ?? '';
      _ubicacionController.text = widget.cliente?['ubicacion'] ?? '';
      _presupuestoController.text = widget.cliente?['presupuesto']?.toString() ?? '0';
      _catalogoController.text = widget.cliente?['catalogo_interes'] ?? '';
      _asesorController.text = widget.cliente?['asesor'] ?? '';
      _estadoNegociacionController.text = widget.cliente?['estado_negociacion'] ?? 'Inicial';
      _notasController.text = widget.cliente?['notas'] ?? '';
      _tipo = widget.cliente?['tipo'] ?? 'Comprador';
      _activo = widget.cliente?['activo'] ?? true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    _presupuestoController.dispose();
    _catalogoController.dispose();
    _asesorController.dispose();
    _estadoNegociacionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'presupuesto': double.tryParse(_presupuestoController.text) ?? 0,
        'catalogo_interes': _catalogoController.text.trim(),
        'asesor': _asesorController.text.trim(),
        'estado_negociacion': _estadoNegociacionController.text.trim(),
        'notas': _notasController.text.trim(),
        'tipo': _tipo,
        'activo': _activo,
      };

      if (_esEditar) {
        await _supabase
            .from('clientes')
            .update(data)
            .eq('id', widget.cliente!['id']);
      } else {
        await _supabase.from('clientes').insert(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_esEditar ? 'Cliente actualizado' : 'Cliente creado'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClienteCreado?.call();
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
        title: Text(_esEditar ? 'Editar Cliente' : 'Nuevo Cliente',
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
                    _buildTextField(_nombreController, 'Nombre *', Icons.person, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_telefonoController, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Tipo',
                      _tipo,
                      ['Comprador', 'Vendedor', 'Inversionista', 'Rentador'],
                      (v) => setState(() => _tipo = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_ubicacionController, 'Ubicación', Icons.location_on),
                    const SizedBox(height: 16),
                    _buildTextField(_presupuestoController, 'Presupuesto (MXN)', Icons.attach_money, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField(_catalogoController, 'Catálogo de interés', Icons.folder),
                    const SizedBox(height: 16),
                    _buildTextField(_asesorController, 'Asesor', Icons.person),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Estado de negociación',
                      _estadoNegociacionController.text.isEmpty ? 'Inicial' : _estadoNegociacionController.text,
                      ['Inicial', 'Contactado', 'Negociación', 'Cerrado', 'Perdido'],
                      (v) => _estadoNegociacionController.text = v!,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_notasController, 'Notas', Icons.note, maxLines: 4),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Cliente activo', style: TextStyle(color: Colors.white)),
                      value: _activo,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _activo = v),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_esEditar ? 'Actualizar Cliente' : 'Crear Cliente',
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