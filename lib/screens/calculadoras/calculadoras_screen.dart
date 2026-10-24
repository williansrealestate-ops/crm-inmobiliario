import 'dart:math' as Math;
import 'package:flutter/material.dart';

class CalculadorasScreen extends StatefulWidget {
  const CalculadorasScreen({super.key});

  @override
  State<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends State<CalculadorasScreen> {
  final List<Map<String, dynamic>> _calculadoras = [
    {'icon': Icons.calculate, 'nombre': 'Comisión', 'color': Colors.green, 'descripcion': 'Calcula comisiones de venta'},
    {'icon': Icons.percent, 'nombre': 'ROI', 'color': Colors.blue, 'descripcion': 'Retorno de inversión'},
    {'icon': Icons.account_balance, 'nombre': 'Mensualidad', 'color': Colors.orange, 'descripcion': 'Pagos mensuales de crédito'},
    {'icon': Icons.trending_up, 'nombre': 'Plusvalía', 'color': Colors.purple, 'descripcion': 'Crecimiento de valor'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.calculate, color: Colors.white),
          SizedBox(width: 8),
          Text('Calculadoras', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona una calculadora',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _calculadoras.length,
                itemBuilder: (context, index) {
                  final calc = _calculadoras[index];
                  return GestureDetector(
                    onTap: () => _abrirCalculadora(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF222222)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: (calc['color'] as Color).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(calc['icon'] as IconData, color: calc['color'] as Color, size: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            calc['nombre'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              calc['descripcion'] as String,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirCalculadora(int index) {
    switch (index) {
      case 0: _mostrarCalculadoraComision(); break;
      case 1: _mostrarCalculadoraROI(); break;
      case 2: _mostrarCalculadoraMensualidad(); break;
      case 3: _mostrarCalculadoraPlusvalia(); break;
    }
  }

  void _mostrarCalculadoraComision() {
    final precioCtrl = TextEditingController();
    final porcentajeCtrl = TextEditingController(text: '5');
    String resultado = '';

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
                  const Icon(Icons.calculate, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Calculadora de Comisión', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 20),
                _buildSeccion(' Datos de la Venta'),
                _buildCampo('Precio de Venta', precioCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
                _buildCampo('Porcentaje (%)', porcentajeCtrl, icon: Icons.percent, tipo: TextInputType.number),
                const SizedBox(height: 16),
                if (resultado.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
                    child: Column(children: [
                      const Text('Comisión Calculada', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(resultado, style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final precio = double.tryParse(precioCtrl.text) ?? 0;
                      final porcentaje = double.tryParse(porcentajeCtrl.text) ?? 0;
                      final comision = precio * (porcentaje / 100);
                      setSheetState(() => resultado = '\$${comision.toStringAsFixed(2)}');
                    },
                    icon: const Icon(Icons.calculate, color: Colors.white),
                    label: const Text('Calcular', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _mostrarCalculadoraROI() {
    final inversionCtrl = TextEditingController();
    final gananciaCtrl = TextEditingController();
    String resultado = '';

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
                  const Icon(Icons.percent, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Calculadora ROI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 20),
                _buildSeccion('📊 Datos de Inversión'),
                _buildCampo('Inversión Inicial', inversionCtrl, icon: Icons.account_balance_wallet, tipo: TextInputType.number),
                _buildCampo('Ganancia Obtenida', gananciaCtrl, icon: Icons.trending_up, tipo: TextInputType.number),
                const SizedBox(height: 16),
                if (resultado.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue)),
                    child: Column(children: [
                      const Text('ROI Calculado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(resultado, style: const TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final inversion = double.tryParse(inversionCtrl.text) ?? 0;
                      final ganancia = double.tryParse(gananciaCtrl.text) ?? 0;
                      if (inversion > 0) {
                        final roi = ((ganancia - inversion) / inversion) * 100;
                        setSheetState(() => resultado = '${roi.toStringAsFixed(2)}%');
                      }
                    },
                    icon: const Icon(Icons.calculate, color: Colors.white),
                    label: const Text('Calcular', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _mostrarCalculadoraMensualidad() {
    final montoCtrl = TextEditingController();
    final tasaCtrl = TextEditingController();
    final plazoCtrl = TextEditingController();
    String resultado = '';

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
                  const Icon(Icons.account_balance, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Calculadora de Mensualidad', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 20),
                _buildSeccion('🏦 Datos del Crédito'),
                _buildCampo('Monto del Préstamo', montoCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
                _buildCampo('Tasa Anual (%)', tasaCtrl, icon: Icons.percent, tipo: TextInputType.number),
                _buildCampo('Plazo (meses)', plazoCtrl, icon: Icons.calendar_today, tipo: TextInputType.number),
                const SizedBox(height: 16),
                if (resultado.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                    child: Column(children: [
                      const Text('Pago Mensual', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(resultado, style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final monto = double.tryParse(montoCtrl.text) ?? 0;
                      final tasa = double.tryParse(tasaCtrl.text) ?? 0;
                      final plazo = int.tryParse(plazoCtrl.text) ?? 0;
                      if (monto > 0 && tasa > 0 && plazo > 0) {
                        final tasaMensual = (tasa / 100) / 12;
                        final mensualidad = monto * (tasaMensual * Math.pow(1 + tasaMensual, plazo)) / (Math.pow(1 + tasaMensual, plazo) - 1);
                        setSheetState(() => resultado = '\$${mensualidad.toStringAsFixed(2)}');
                      }
                    },
                    icon: const Icon(Icons.calculate, color: Colors.white),
                    label: const Text('Calcular', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _mostrarCalculadoraPlusvalia() {
    final valorActualCtrl = TextEditingController();
    final tasaPlusvaliaCtrl = TextEditingController();
    final aniosCtrl = TextEditingController();
    String resultado = '';

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
                  const Icon(Icons.trending_up, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Calculadora de Plusvalía', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 20),
                _buildSeccion('📈 Datos de la Propiedad'),
                _buildCampo('Valor Actual', valorActualCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
                _buildCampo('Tasa de Plusvalía Anual (%)', tasaPlusvaliaCtrl, icon: Icons.percent, tipo: TextInputType.number),
                _buildCampo('Años', aniosCtrl, icon: Icons.calendar_today, tipo: TextInputType.number),
                const SizedBox(height: 16),
                if (resultado.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.purple)),
                    child: Column(children: [
                      const Text('Valor Futuro Estimado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(resultado, style: const TextStyle(color: Colors.purple, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final valor = double.tryParse(valorActualCtrl.text) ?? 0;
                      final tasa = double.tryParse(tasaPlusvaliaCtrl.text) ?? 0;
                      final anios = int.tryParse(aniosCtrl.text) ?? 0;
                      if (valor > 0 && tasa > 0 && anios > 0) {
                        final valorFuturo = valor * Math.pow(1 + (tasa / 100), anios);
                        setSheetState(() => resultado = '\$${valorFuturo.toStringAsFixed(2)}');
                      }
                    },
                    icon: const Icon(Icons.calculate, color: Colors.white),
                    label: const Text('Calcular', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      child: TextField(
        controller: ctrl,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0066FF)) : null,
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}