import 'dart:html' as html; // ✅ IMPORT AGREGADO
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/calculadora_service.dart';

class CalculadoraClienteScreen extends StatefulWidget {
  const CalculadoraClienteScreen({super.key});

  @override
  State<CalculadoraClienteScreen> createState() => _CalculadoraClienteScreenState();
}

class _CalculadoraClienteScreenState extends State<CalculadoraClienteScreen> {
  final TextEditingController _precioCtrl = TextEditingController(text: '2500000');
  final TextEditingController _engancheCtrl = TextEditingController(text: '500000');
  final TextEditingController _tasaCtrl = TextEditingController(text: '10.5');
  final TextEditingController _plazoCtrl = TextEditingController(text: '20');
  
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  Map<String, dynamic>? _resultado;
  bool _mostrarFormularioLead = false;

  @override
  void initState() {
    super.initState();
    _calcular();
  }

  @override
  void dispose() {
    _precioCtrl.dispose();
    _engancheCtrl.dispose();
    _tasaCtrl.dispose();
    _plazoCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _calcular() {
    final precio = double.tryParse(_precioCtrl.text.replaceAll(',', '')) ?? 0;
    final enganche = double.tryParse(_engancheCtrl.text.replaceAll(',', '')) ?? 0;
    final tasa = double.tryParse(_tasaCtrl.text) ?? 0;
    final plazo = int.tryParse(_plazoCtrl.text) ?? 0;

    setState(() {
      _resultado = CalculadoraService.calcular(
        precioPropiedad: precio,
        enganche: enganche,
        tasaAnual: tasa,
        plazoAnios: plazo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.calculate, color: Colors.white), SizedBox(width: 8), Text('Calculadora de Crédito')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Simula tu crédito hipotecario', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Ajusta los valores y conoce tu mensualidad estimada al instante.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inputs
            _buildInputField('Precio de la propiedad', _precioCtrl, Icons.home, onChanged: (_) => _calcular()),
            const SizedBox(height: 16),
            _buildInputField('Pago inicial (Enganche)', _engancheCtrl, Icons.account_balance_wallet, onChanged: (_) => _calcular()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField('Tasa anual (%)', _tasaCtrl, Icons.percent, onChanged: (_) => _calcular())),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('Plazo (años)', _plazoCtrl, Icons.calendar_today, onChanged: (_) => _calcular())),
              ],
            ),
            const SizedBox(height: 32),

            // Resultados
            if (_resultado != null && _resultado!['error'] == null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.getBorderColor(context)),
                  boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    const Text('Tu mensualidad estimada', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    Text(
                      CalculadoraService.formatearMoneda(_resultado!['mensualidad']),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildResumenItem('Monto del préstamo', CalculadoraService.formatearMoneda(_resultado!['montoPrestamo']))),
                        Expanded(child: _buildResumenItem('Intereses totales', CalculadoraService.formatearMoneda(_resultado!['totalIntereses']))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildResumenItem('Monto total a pagar', CalculadoraService.formatearMoneda(_resultado!['montoTotal']))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _mostrarFormularioLead = !_mostrarFormularioLead),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Solicitar Asesoría'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _compartirWhatsApp,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Compartir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Formulario de Lead (Opcional)
              if (_mostrarFormularioLead) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('¿Te interesa esta propiedad? Déjanos tus datos y un asesor te contactará hoy mismo.', 
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 12),
                      TextField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _guardarYContactar,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Enviar mis datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (_resultado != null && _resultado!['error'] != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Color(0xFFEF4444)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_resultado!['error'], style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, IconData icon, {ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextSecondaryColor(context))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
            filled: true,
            fillColor: AppTheme.getSurfaceColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenItem(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        const SizedBox(height: 4),
        Text(valor, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
      ],
    );
  }

  void _compartirWhatsApp() {
    if (_resultado == null || _resultado!['error'] != null) return;
    
    final precio = CalculadoraService.formatearMoneda(double.tryParse(_precioCtrl.text.replaceAll(',', '')) ?? 0);
    final mensualidad = CalculadoraService.formatearMoneda(_resultado!['mensualidad']);
    final enganche = CalculadoraService.formatearMoneda(double.tryParse(_engancheCtrl.text.replaceAll(',', '')) ?? 0);
    
    final mensaje = '🏡 *Simulación de Crédito Hipotecario*\n\n'
        '💰 Precio: $precio\n'
        '💵 Enganche: $enganche\n'
        '📅 Mensualidad estimada: *$mensualidad*\n\n'
        '¿Te interesa esta propiedad? ¡Contáctame para más detalles!';
    
    // ✅ CORREGIDO: html.window.open ahora funciona porque importamos dart:html
    final url = 'https://wa.me/?text=${Uri.encodeComponent(mensaje)}';
    html.window.open(url, '_blank');
  }

  void _guardarYContactar() {
    if (_nombreCtrl.text.isEmpty || _telefonoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Por favor ingresa al menos tu nombre y teléfono'), backgroundColor: Color(0xFFF59E0B)),
      );
      return;
    }

    final precio = double.tryParse(_precioCtrl.text.replaceAll(',', '')) ?? 0;
    final mensualidad = _resultado!['mensualidad'];

    CalculadoraService.guardarLead(
      nombre: _nombreCtrl.text,
      telefono: _telefonoCtrl.text,
      email: _emailCtrl.text,
      precioPropiedad: precio,
      mensualidad: mensualidad,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ ¡Datos enviados! Un asesor te contactará pronto.'), backgroundColor: Color(0xFF10B981)),
    );

    setState(() => _mostrarFormularioLead = false);
    _nombreCtrl.clear();
    _telefonoCtrl.clear();
    _emailCtrl.clear();
  }
}