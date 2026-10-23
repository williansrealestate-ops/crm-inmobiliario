import 'dart:math';
import 'package:flutter/material.dart';

class SimuladorCreditoScreen extends StatefulWidget {
  final double precioPropiedad;

  const SimuladorCreditoScreen({
    super.key,
    required this.precioPropiedad,
  });

  @override
  State<SimuladorCreditoScreen> createState() => _SimuladorCreditoScreenState();
}

class _SimuladorCreditoScreenState extends State<SimuladorCreditoScreen> {
  double _precio = 0;
  double _enganche = 20;
  int _plazo = 20;
  double _tasaAnual = 10.5;

  double get _montoFinanciar {
    return _precio * (1 - _enganche / 100);
  }

  double get _pagoMensual {
    if (_montoFinanciar <= 0) return 0;
    final tasaMensual = _tasaAnual / 100 / 12;
    final meses = _plazo * 12;
    if (tasaMensual == 0) return _montoFinanciar / meses;
    // ✅ CORRECCIÓN: usar pow() de dart:math
    final factor = pow(1 + tasaMensual, meses).toDouble();
    return _montoFinanciar * (tasaMensual * factor) / (factor - 1);
  }

  double get _totalPagar => _pagoMensual * _plazo * 12;
  double get _totalIntereses => _totalPagar - _montoFinanciar;

  String _formatearMonto(double monto) {
    if (monto >= 1000000) {
      return '\$${(monto / 1000000).toStringAsFixed(2)}M';
    } else if (monto >= 1000) {
      return '\$${(monto / 1000).toStringAsFixed(0)}K';
    }
    return '\$${monto.toStringAsFixed(0)}';
  }

  @override
  void initState() {
    super.initState();
    _precio = widget.precioPropiedad > 0 ? widget.precioPropiedad : 4500000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Simulador de Crédito Hipotecario',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calcula tu mensualidad',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simula tu crédito hipotecario en segundos',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Datos del crédito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                        const SizedBox(height: 24),
                        _buildSlider(label: 'Precio de la propiedad', valor: _precio, minimo: 100000, maximo: 500000000, formato: _formatearMonto, onChanged: (v) => setState(() => _precio = v)),
                        _buildSlider(label: 'Enganche', valor: _enganche, minimo: 10, maximo: 50, formato: (v) => '${v.toStringAsFixed(0)}%', onChanged: (v) => setState(() => _enganche = v)),
                        _buildSlider(label: 'Plazo (años)', valor: _plazo.toDouble(), minimo: 5, maximo: 30, formato: (v) => '${v.toInt()} años', onChanged: (v) => setState(() => _plazo = v.toInt())),
                        _buildSlider(label: 'Tasa de interés anual', valor: _tasaAnual, minimo: 5, maximo: 20, formato: (v) => '${v.toStringAsFixed(1)}%', onChanged: (v) => setState(() => _tasaAnual = v)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 380,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF1E40AF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF0066FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resultado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 24),
                        _buildResultado(label: 'Pago mensual estimado', valor: _formatearMonto(_pagoMensual), destacado: true),
                        const Divider(color: Colors.white24, height: 32),
                        _buildResultado(label: 'Monto a financiar', valor: _formatearMonto(_montoFinanciar)),
                        _buildResultado(label: 'Enganche', valor: _formatearMonto(_precio * _enganche / 100)),
                        _buildResultado(label: 'Total a pagar', valor: _formatearMonto(_totalPagar)),
                        _buildResultado(label: 'Total de intereses', valor: _formatearMonto(_totalIntereses)),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(' Contacta a un asesor para más detalles'), backgroundColor: Color(0xFF10B981)));
                            },
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('Contactar asesor'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0066FF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({required String label, required double valor, required double minimo, required double maximo, required String Function(double) formato, required ValueChanged<double> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))), Text(formato(valor), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0066FF)))]),
          const SizedBox(height: 12),
          SliderTheme(data: SliderThemeData(activeTrackColor: const Color(0xFF0066FF), inactiveTrackColor: const Color(0xFFE5E7EB), thumbColor: const Color(0xFF0066FF), overlayColor: const Color(0xFF0066FF).withOpacity(0.1), trackHeight: 6), child: Slider(value: valor, min: minimo, max: maximo, onChanged: onChanged)),
        ],
      ),
    );
  }

  Widget _buildResultado({required String label, required String valor, bool destacado = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: destacado ? FontWeight.w600 : FontWeight.w400)), const SizedBox(height: 4), Text(valor, style: TextStyle(fontSize: destacado ? 28 : 20, fontWeight: FontWeight.w800, color: Colors.white))]));
  }
}