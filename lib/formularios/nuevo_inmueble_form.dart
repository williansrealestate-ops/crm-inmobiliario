import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/inmueble.dart';
import '../../models/mock_inmuebles.dart';

class NuevoInmuebleForm extends StatefulWidget {
  final Function(Inmueble) onInmuebleCreado;
  const NuevoInmuebleForm({super.key, required this.onInmuebleCreado});

  @override
  State<NuevoInmuebleForm> createState() => _NuevoInmuebleFormState();
}

class _NuevoInmuebleFormState extends State<NuevoInmuebleForm> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _direccionController = TextEditingController();
  final _precioController = TextEditingController();
  final _areaTerrenoController = TextEditingController();
  final _areaConstruccionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _comisionController = TextEditingController();
  final _porcentajeController = TextEditingController(text: '6');

  String _tipo = 'Casa';
  String _moneda = 'MXN';
  String _pais = 'México';
  String _estado = 'Campeche';
  String _municipio = '';
  String _estadoVenta = 'Disponible';

  int _habitaciones = 0;
  int _banos = 0;
  int _estacionamientos = 0;

  final Map<String, bool> _caracteristicas = {
    'Alberca': false,
    'Jardín': false,
    'Seguridad 24/7': false,
    'Aire acondicionado': false,
    'Cocina integral': false,
    'Estacionamiento techado': false,
    'Cuarto de servicio': false,
    'Vista panorámica': false,
  };

  final List<String> _tipos = [
    'Casa',
    'Departamento',
    'Terreno',
    'Gasolinera',
    'Hotel',
    'Mina',
    'Local',
    'Oficina',
    'Bodega'
  ];
  final List<String> _monedas = ['MXN', 'USD'];
  final List<String> _paises = [
    'México',
    'Estados Unidos',
    'Canadá',
    'Guatemala',
    'Belice'
  ];
  final List<String> _estados = [
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
  final List<String> _estadosVenta = [
    'Disponible',
    'Reservado',
    'Vendido',
    'Rentado'
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _direccionController.dispose();
    _precioController.dispose();
    _areaTerrenoController.dispose();
    _areaConstruccionController.dispose();
    _descripcionController.dispose();
    _comisionController.dispose();
    _porcentajeController.dispose();
    super.dispose();
  }

  void _guardarInmueble() {
    if (_formKey.currentState!.validate()) {
      final nuevasCaracteristicas = _caracteristicas.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final nuevoInmueble = Inmueble(
        id: MockInmuebles.lista.length + 1,
        titulo: _tituloController.text.trim(),
        tipo: _tipo,
        precio:
            double.tryParse(_precioController.text.replaceAll(',', '')) ?? 0,
        moneda: _moneda,
        pais: _pais,
        estado: _estado,
        municipio: _municipio.isEmpty ? _estado : _municipio,
        direccion: _direccionController.text.trim(),
        areaTerreno: double.tryParse(_areaTerrenoController.text) ?? 0,
        unidadArea: _tipo == 'Terreno' ? 'm2' : 'm2',
        areaConstruccion:
            double.tryParse(_areaConstruccionController.text) ?? 0,
        habitaciones: _habitaciones,
        banos: _banos,
        estacionamientos: _estacionamientos,
        estadoVenta: _estadoVenta,
        descripcion: _descripcionController.text.trim(),
        caracteristicas: nuevasCaracteristicas,
        fotos: [
          'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800'
        ],
        fechaAlta: DateTime.now()
            .toString()
            .split(' ')[0]
            .split('-')
            .reversed
            .join('/'),
        propietario: 'Sin asignar',
        asesor: 'Williams Carrillo',
        comision:
            double.tryParse(_comisionController.text.replaceAll(',', '')) ?? 0,
        porcentajeComision: double.tryParse(_porcentajeController.text) ?? 6,
      );

      widget.onInmuebleCreado(nuevoInmueble);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Inmueble "${nuevoInmueble.titulo}" creado exitosamente'),
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
        title: const Text('Nuevo Inmueble'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _guardarInmueble,
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
              // INFORMACIÓN GENERAL
              const Text('Información general',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tituloController,
                label: 'Título del inmueble',
                icon: Icons.title,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDropdown('Tipo', _tipo, _tipos,
                          (v) => setState(() => _tipo = v!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDropdown('Moneda', _moneda, _monedas,
                          (v) => setState(() => _moneda = v!))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _precioController,
                      label: 'Precio',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa el precio' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                        'Estado venta',
                        _estadoVenta,
                        _estadosVenta,
                        (v) => setState(() => _estadoVenta = v!)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // UBICACIÓN
              const Text('Ubicación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildDropdown('País', _pais, _paises,
                          (v) => setState(() => _pais = v!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDropdown('Estado', _estado, _estados,
                          (v) => setState(() => _estado = v!))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: TextEditingController(text: _municipio),
                label: 'Municipio',
                icon: Icons.location_city,
                onChanged: (v) => _municipio = v ?? '',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionController,
                label: 'Dirección completa',
                icon: Icons.place,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // ÁREAS
              const Text('Áreas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _areaTerrenoController,
                      label: 'Área terreno (m²)',
                      icon: Icons.square_foot,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _areaConstruccionController,
                      label: 'Área construcción (m²)',
                      icon: Icons.home_work,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildContador('Habitaciones', _habitaciones,
                          Icons.bed, (v) => setState(() => _habitaciones = v))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildContador('Baños', _banos, Icons.bathtub,
                          (v) => setState(() => _banos = v))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildContador(
                          'Estacionamientos',
                          _estacionamientos,
                          Icons.local_parking,
                          (v) => setState(() => _estacionamientos = v))),
                ],
              ),
              const SizedBox(height: 32),

              // COMISIÓN (CAPTURA MANUAL)
              const Text('Comisión',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
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
                        'Captura la comisión que recibirás por esta venta. Se sumará a los Ingresos Totales en Reportes.',
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _comisionController,
                      label: 'Comisión (MXN)',
                      icon: Icons.account_balance_wallet,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa la comisión' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _porcentajeController,
                      label: 'Porcentaje (%)',
                      icon: Icons.percent,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa el %' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // DESCRIPCIÓN
              const Text('Descripción',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe el inmueble...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // CARACTERÍSTICAS ADICIONALES
              const Text('Características adicionales',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _caracteristicas.keys.map((caract) {
                    return FilterChip(
                      label: Text(caract),
                      selected: _caracteristicas[caract] ?? false,
                      onSelected: (valor) {
                        setState(() => _caracteristicas[caract] = valor);
                      },
                      backgroundColor: AppTheme.background,
                      selectedColor: AppTheme.primary.withValues(alpha: 0.1),
                      checkmarkColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: (_caracteristicas[caract] ?? false)
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontWeight: (_caracteristicas[caract] ?? false)
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: (_caracteristicas[caract] ?? false)
                            ? AppTheme.primary
                            : AppTheme.border,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _guardarInmueble,
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text('GUARDAR INMUEBLE',
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
    int? maxLines,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
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
        maxLines: maxLines ?? 1,
        validator: validator,
        onChanged: onChanged,
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

  Widget _buildContador(
      String label, int valor, IconData icon, void Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: valor > 0 ? () => onChanged(valor - 1) : null,
                icon: const Icon(Icons.remove_circle_outline, size: 24),
                color: valor > 0 ? AppTheme.primary : Colors.grey,
              ),
              const SizedBox(width: 12),
              Text('$valor',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => onChanged(valor + 1),
                icon: const Icon(Icons.add_circle_outline, size: 24),
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
