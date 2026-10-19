import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/cliente.dart';
import '../services/local_storage_service.dart';

class NuevoClienteForm extends StatefulWidget {
  final Function(Cliente) onClienteCreado;
  const NuevoClienteForm({super.key, required this.onClienteCreado});

  @override
  State<NuevoClienteForm> createState() => _NuevoClienteFormState();
}

class _NuevoClienteFormState extends State<NuevoClienteForm> {
  final _formKey = GlobalKey<FormState>();
  bool _guardando = false;

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _tipoController = TextEditingController(text: 'Comprador');
  final _interesController = TextEditingController(text: 'Terreno');
  final _presupuestoController = TextEditingController();
  final _paisController = TextEditingController(text: 'México');
  final _estadoController = TextEditingController();
  final _notasController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _tipoController.dispose();
    _interesController.dispose();
    _presupuestoController.dispose();
    _paisController.dispose();
    _estadoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      // Generar nuevo ID
      final nuevoId =
          LocalStorageService.generarId('app_inmobiliaria_clientes');
      final fechaActual =
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

      // Crear mapa del cliente
      final clienteMap = <String, dynamic>{
        'id': nuevoId,
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        'tipo': _tipoController.text.trim(),
        'interes': _interesController.text.trim(),
        'estado': 'Prospecto',
        'pais': _paisController.text.trim(),
        'estadoUbicacion': _estadoController.text.trim(),
        'presupuesto': _presupuestoController.text.trim(),
        'notas': _notasController.text.trim(),
        'fotoUrl':
            'https://ui-avatars.com/api/?name=${_nombreController.text}+${_apellidoController.text}&background=0D1B4C&color=E8D44D',
        'fechaAlta': fechaActual,
      };

      // Guardar en localStorage
      LocalStorageService.agregarCliente(clienteMap);

      // Crear objeto Cliente
      final nuevoCliente = Cliente(
        id: nuevoId,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim(),
        tipo: _tipoController.text.trim(),
        interes: _interesController.text.trim(),
        estado: 'Prospecto',
        pais: _paisController.text.trim(),
        estadoUbicacion: _estadoController.text.trim(),
        presupuesto: _presupuestoController.text.trim(),
        notas: _notasController.text.trim(),
        fotoUrl:
            'https://ui-avatars.com/api/?name=${_nombreController.text}+${_apellidoController.text}&background=0D1B4C&color=E8D44D',
        fechaAlta: fechaActual,
      );

      // Notificar al padre
      widget.onClienteCreado(nuevoCliente);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cliente guardado localmente'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Nuevo Cliente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información Personal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(_nombreController, 'Nombre', Icons.person,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 12),
              _buildTextField(
                  _apellidoController, 'Apellido', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_telefonoController, 'Teléfono', Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              const Text('Información de Negocio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildDropdownField(
                  _tipoController,
                  'Tipo de Cliente',
                  Icons.category,
                  ['Comprador', 'Vendedor', 'Inversionista', 'Prospecto']),
              const SizedBox(height: 12),
              _buildDropdownField(
                  _interesController, 'Interés', Icons.favorite, [
                'Casa',
                'Departamento',
                'Terreno',
                'Gasolinera',
                'Hotel',
                'Mina',
                'Local'
              ]),
              const SizedBox(height: 12),
              _buildTextField(
                  _presupuestoController, 'Presupuesto', Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              const Text('Ubicación',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(_paisController, 'País', Icons.flag),
              const SizedBox(height: 12),
              _buildTextField(_estadoController, 'Estado', Icons.location_on),
              const SizedBox(height: 24),
              const Text('Notas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTextField(_notasController, 'Notas adicionales', Icons.note,
                  maxLines: 4),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _guardando
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Guardando...',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        )
                      : const Text('GUARDAR CLIENTE',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
      ),
    );
  }

  Widget _buildDropdownField(TextEditingController controller, String label,
      IconData icon, List<String> opciones) {
    return DropdownButtonFormField<String>(
      initialValue: controller.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: opciones
          .map((opcion) => DropdownMenuItem(value: opcion, child: Text(opcion)))
          .toList(),
      onChanged: (valor) {
        if (valor != null) controller.text = valor;
      },
    );
  }
}
