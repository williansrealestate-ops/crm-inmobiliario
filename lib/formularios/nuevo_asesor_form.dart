import 'package:flutter/material.dart';
import '../../config/theme.dart';

class NuevoAsesorForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onAsesorCreado;
  const NuevoAsesorForm({super.key, required this.onAsesorCreado});

  @override
  State<NuevoAsesorForm> createState() => _NuevoAsesorFormState();
}

class _NuevoAsesorFormState extends State<NuevoAsesorForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _oficinaController = TextEditingController();
  final _fechaIngresoController = TextEditingController();

  String _pais = 'México';
  String _estado = 'Campeche';

  final List<String> _paises = [
    'México',
    'Estados Unidos',
    'Canadá',
    'Guatemala',
    'Belice',
    'Costa Rica',
    'Panamá',
    'Colombia',
    'España'
  ];
  final List<String> _estadosMexico = [
    'Campeche',
    'Yucatán',
    'Quintana Roo',
    'Tabasco',
    'Chiapas',
    'Veracruz',
    'Querétaro',
    'CDMX',
    'Jalisco',
    'Sonora',
    'Nuevo León',
    'Puebla'
  ];
  final List<String> _estadosUSA = [
    'Florida',
    'Texas',
    'California',
    'New York',
    'Nevada',
    'Arizona'
  ];

  List<String> _estadosDisponibles = [
    'Campeche',
    'Yucatán',
    'Quintana Roo',
    'Tabasco',
    'Chiapas',
    'Veracruz',
    'Querétaro',
    'CDMX',
    'Jalisco',
    'Sonora',
    'Nuevo León',
    'Puebla'
  ];

  @override
  void initState() {
    super.initState();
    _fechaIngresoController.text =
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _oficinaController.dispose();
    _fechaIngresoController.dispose();
    super.dispose();
  }

  void _guardarAsesor() {
    if (_formKey.currentState!.validate()) {
      final nuevoAsesor = {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        'oficina': _oficinaController.text.trim(),
        'pais': _pais,
        'estado': _estado,
        'fechaIngreso': _fechaIngresoController.text.trim(),
        'ventas': 0,
        'comision': 0.0,
        'inmuebles': [],
      };

      widget.onAsesorCreado(nuevoAsesor);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Asesor "${nuevoAsesor['nombre']}" creado exitosamente'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Nuevo Asesor'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _guardarAsesor,
            icon: const Icon(Icons.check, color: AppTheme.accent),
            label: const Text('Guardar',
                style: TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFORMACIÓN PERSONAL
              const Text('Información personal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre completo',
                icon: Icons.person,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa el teléfono' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa el email' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // UBICACIÓN
              const Text('Ubicación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _oficinaController,
                label: 'Oficina / Ciudad',
                icon: Icons.business,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa la oficina' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDropdown('País', _pais, _paises, (v) {
                    setState(() {
                      _pais = v!;
                      if (_pais == 'México') {
                        _estadosDisponibles = _estadosMexico;
                        _estado = 'Campeche';
                      } else if (_pais == 'Estados Unidos') {
                        _estadosDisponibles = _estadosUSA;
                        _estado = 'Florida';
                      } else {
                        _estadosDisponibles = ['General'];
                        _estado = 'General';
                      }
                    });
                  })),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDropdown(
                          'Estado',
                          _estado,
                          _estadosDisponibles,
                          (v) => setState(() => _estado = v!))),
                ],
              ),
              const SizedBox(height: 32),

              // FECHA DE INGRESO
              const Text('Fecha de ingreso',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fechaIngresoController,
                label: 'Fecha de ingreso',
                icon: Icons.calendar_today,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa la fecha' : null,
              ),
              const SizedBox(height: 32),

              // INFO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El nuevo asesor se agregará al ranking con 0 ventas. Podrás asignarle inmuebles posteriormente.',
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _guardarAsesor,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text('GUARDAR ASESOR',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
