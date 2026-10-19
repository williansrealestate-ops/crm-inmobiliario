import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/calculadoras_service.dart';
import '../../widgets/ios_widgets.dart';

class CalculadorasScreen extends StatefulWidget {
  const CalculadorasScreen({super.key});

  @override
  State<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends State<CalculadorasScreen> {
  int _calculadoraSeleccionada = 0;
  final _precioVentaCtrl = TextEditingController();
  final _porcentajeComisionCtrl = TextEditingController(text: '3');
  final _ivaCtrl = TextEditingController(text: '16');
  final _precioPropiedadCtrl = TextEditingController();
  final _engancheCtrl = TextEditingController();
  final _tasaAnualCtrl = TextEditingController(text: '10');
  final _plazoAniosCtrl = TextEditingController(text: '20');
  final _inversionInicialCtrl = TextEditingController();
  final _ingresoAnualCtrl = TextEditingController();
  final _gastosAnualesCtrl = TextEditingController();
  final _periodoAniosCtrl = TextEditingController(text: '1');

  Map<String, dynamic>? _resultado;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.calculate, color: Colors.white), SizedBox(width: 8), Text('Calculadoras')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: IOSSegmentedControl(
              options: ['Comisión', 'Hipoteca', 'ROI'],
              selectedIndex: _calculadoraSeleccionada,
              onSelected: (index) { setState(() { _calculadoraSeleccionada = index; _resultado = null; }); },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_calculadoraSeleccionada == 0) _buildCalculadoraComision(isDark),
                if (_calculadoraSeleccionada == 1) _buildCalculadoraHipoteca(isDark),
                if (_calculadoraSeleccionada == 2) _buildCalculadoraROI(isDark),
                if (_resultado != null) ...[const SizedBox(height: 20), _buildResultado()],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculadoraComision(bool isDark) {
    return Column(children: [
      IOSInput(controller: _precioVentaCtrl, label: 'Precio de Venta (MXN)', icon: Icons.attach_money, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _porcentajeComisionCtrl, label: 'Porcentaje de Comisión (%)', icon: Icons.percent, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _ivaCtrl, label: 'IVA (%)', icon: Icons.receipt, keyboardType: TextInputType.number),
      const SizedBox(height: 20),
      IOSButton(label: 'Calcular Comisión', icon: Icons.calculate, onPressed: _calcularComision),
    ]);
  }

  Widget _buildCalculadoraHipoteca(bool isDark) {
    return Column(children: [
      IOSInput(controller: _precioPropiedadCtrl, label: 'Precio de la Propiedad (MXN)', icon: Icons.home, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _engancheCtrl, label: 'Enganche (MXN)', icon: Icons.account_balance_wallet, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _tasaAnualCtrl, label: 'Tasa de Interés Anual (%)', icon: Icons.percent, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _plazoAniosCtrl, label: 'Plazo (años)', icon: Icons.calendar_today, keyboardType: TextInputType.number),
      const SizedBox(height: 20),
      IOSButton(label: 'Calcular Hipoteca', icon: Icons.calculate, onPressed: _calcularHipoteca),
    ]);
  }

  Widget _buildCalculadoraROI(bool isDark) {
    return Column(children: [
      IOSInput(controller: _inversionInicialCtrl, label: 'Inversión Inicial (MXN)', icon: Icons.account_balance, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _ingresoAnualCtrl, label: 'Ingreso Anual (MXN)', icon: Icons.trending_up, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _gastosAnualesCtrl, label: 'Gastos Anuales (MXN)', icon: Icons.trending_down, keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      IOSInput(controller: _periodoAniosCtrl, label: 'Período (años)', icon: Icons.calendar_today, keyboardType: TextInputType.number),
      const SizedBox(height: 20),
      IOSButton(label: 'Calcular ROI', icon: Icons.calculate, onPressed: _calcularROI),
    ]);
  }

  Widget _buildResultado() {
    return IOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.analytics, color: IOSColors.green, size: 24), const SizedBox(width: 8), Text('Resultado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))]),
          const SizedBox(height: 16),
          ..._resultado!.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            if (key == 'numeroPagos') return const SizedBox.shrink();
            String label = key;
            String valor = value is double ? '\$${value.toStringAsFixed(2)}' : (value is int ? '$value' : value.toString());
            switch (key) {
              case 'precioVenta': label = 'Precio de Venta'; break;
              case 'porcentajeComision': label = 'Porcentaje'; valor = '$value%'; break;
              case 'comisionBruta': label = 'Comisión Bruta'; break;
              case 'iva': label = 'IVA'; break;
              case 'comisionNeta': label = 'Comisión Neta'; break;
              case 'montoPrestamo': label = 'Monto del Préstamo'; break;
              case 'pagoMensual': label = 'Pago Mensual'; break;
              case 'totalPagar': label = 'Total a Pagar'; break;
              case 'totalIntereses': label = 'Total de Intereses'; break;
              case 'inversionInicial': label = 'Inversión Inicial'; break;
              case 'gananciaNeta': label = 'Ganancia Neta'; break;
              case 'roi': label = 'ROI Total'; valor = '${value.toStringAsFixed(2)}%'; break;
              case 'roiAnual': label = 'ROI Anual'; valor = '${value.toStringAsFixed(2)}%'; break;
              case 'paybackPeriod': label = 'Período de Recuperación'; valor = '${value.toStringAsFixed(1)} años'; break;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(label, style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context))),
                Text(valor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
              ]),
            );
          }),
        ],
      ),
    );
  }

  void _calcularComision() {
    final precio = double.tryParse(_precioVentaCtrl.text) ?? 0;
    final porcentaje = double.tryParse(_porcentajeComisionCtrl.text) ?? 0;
    final iva = double.tryParse(_ivaCtrl.text) ?? 16;
    if (precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Ingresa el precio de venta'), backgroundColor: Color(0xFFF59E0B)));
      return;
    }
    setState(() { _resultado = CalculadorasService.calcularComision(precioVenta: precio, porcentajeComision: porcentaje, iva: iva); });
  }

  void _calcularHipoteca() {
    final precio = double.tryParse(_precioPropiedadCtrl.text) ?? 0;
    final enganche = double.tryParse(_engancheCtrl.text) ?? 0;
    final tasa = double.tryParse(_tasaAnualCtrl.text) ?? 0;
    final plazo = int.tryParse(_plazoAniosCtrl.text) ?? 0;
    if (precio <= 0 || plazo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Ingresa precio y plazo válidos'), backgroundColor: Color(0xFFF59E0B)));
      return;
    }
    setState(() { _resultado = CalculadorasService.calcularHipoteca(precioPropiedad: precio, enganche: enganche, tasaAnual: tasa, plazoAnios: plazo); });
  }

  void _calcularROI() {
    final inversion = double.tryParse(_inversionInicialCtrl.text) ?? 0;
    final ingreso = double.tryParse(_ingresoAnualCtrl.text) ?? 0;
    final gastos = double.tryParse(_gastosAnualesCtrl.text) ?? 0;
    final periodo = int.tryParse(_periodoAniosCtrl.text) ?? 1;
    if (inversion <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Ingresa la inversión inicial'), backgroundColor: Color(0xFFF59E0B)));
      return;
    }
    setState(() { _resultado = CalculadorasService.calcularROI(inversionInicial: inversion, ingresoAnual: ingreso, gastosAnuales: gastos, periodoAnios: periodo); });
  }
}