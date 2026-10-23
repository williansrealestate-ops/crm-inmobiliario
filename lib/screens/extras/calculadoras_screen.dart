import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class CalculadorasScreen extends StatefulWidget {
  const CalculadorasScreen({super.key});

  @override
  State<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends State<CalculadorasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores Hipotecaria
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _engancheController = TextEditingController(text: '20');
  final TextEditingController _tasaController = TextEditingController(text: '9.5');
  final TextEditingController _plazoController = TextEditingController(text: '20');

  // Controladores Comisión
  final TextEditingController _precioVentaController = TextEditingController();
  final TextEditingController _porcComisionController = TextEditingController(text: '6');
  final TextEditingController _gastosOpController = TextEditingController(text: '0');

  // Controladores Plusvalía
  final TextEditingController _valorActualController = TextEditingController();
  final TextEditingController _tasaPlusvaliaController = TextEditingController(text: '8');
  final TextEditingController _aniosPlusvaliaController = TextEditingController(text: '5');

  // Controladores ROI
  final TextEditingController _precioCompraController = TextEditingController();
  final TextEditingController _gastosEscrituracionController = TextEditingController(text: '7');
  final TextEditingController _rentaMensualController = TextEditingController();
  final TextEditingController _gastosAnualesController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _precioController.dispose();
    _engancheController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _precioVentaController.dispose();
    _porcComisionController.dispose();
    _gastosOpController.dispose();
    _valorActualController.dispose();
    _tasaPlusvaliaController.dispose();
    _aniosPlusvaliaController.dispose();
    _precioCompraController.dispose();
    _gastosEscrituracionController.dispose();
    _rentaMensualController.dispose();
    _gastosAnualesController.dispose();
    super.dispose();
  }

  String _formatearMonedaCompleto(double valor) {
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // --- LÓGICA DE CÁLCULO ---
  
  Map<String, double> calcularHipotecaria() {
    final precio = double.tryParse(_precioController.text.replaceAll(',', '')) ?? 0;
    final enganchePorc = double.tryParse(_engancheController.text) ?? 0;
    final tasaAnual = double.tryParse(_tasaController.text) ?? 0;
    final plazoAnios = double.tryParse(_plazoController.text) ?? 0;

    final enganche = precio * (enganchePorc / 100);
    final montoCredito = precio - enganche;
    final tasaMensual = (tasaAnual / 100) / 12;
    final numPagos = plazoAnios * 12;

    double pagoMensual = 0;
    if (montoCredito > 0 && tasaMensual > 0 && numPagos > 0) {
      pagoMensual = montoCredito * (tasaMensual * pow(1 + tasaMensual, numPagos)) / (pow(1 + tasaMensual, numPagos) - 1);
    }

    final totalPagar = pagoMensual * numPagos;
    final totalIntereses = totalPagar - montoCredito;

    return {
      'enganche': enganche,
      'montoCredito': montoCredito,
      'pagoMensual': pagoMensual,
      'totalPagar': totalPagar,
      'totalIntereses': totalIntereses,
    };
  }

  Map<String, double> calcularComision() {
    final precio = double.tryParse(_precioVentaController.text.replaceAll(',', '')) ?? 0;
    final porcComision = double.tryParse(_porcComisionController.text) ?? 0;
    final gastosOp = double.tryParse(_gastosOpController.text.replaceAll(',', '')) ?? 0;

    final comisionBruta = precio * (porcComision / 100);
    final isrEstimado = comisionBruta * 0.10;
    final comisionFinal = comisionBruta - gastosOp - isrEstimado;

    return {
      'comisionBruta': comisionBruta,
      'gastosOp': gastosOp,
      'isrEstimado': isrEstimado,
      'comisionFinal': comisionFinal,
    };
  }

  Map<String, double> calcularPlusvalia() {
    final valorActual = double.tryParse(_valorActualController.text.replaceAll(',', '')) ?? 0;
    final tasa = double.tryParse(_tasaPlusvaliaController.text) ?? 0;
    final anios = double.tryParse(_aniosPlusvaliaController.text) ?? 0;

    final valorFuturo = valorActual * pow(1 + (tasa / 100), anios);
    final ganancia = valorFuturo - valorActual;

    return {
      'valorFuturo': valorFuturo,
      'ganancia': ganancia,
    };
  }

  // ✅ CORREGIDO: ROI y Payback con .toDouble() explícito
  Map<String, double> calcularROI() {
    final precioCompra = double.tryParse(_precioCompraController.text.replaceAll(',', '')) ?? 0;
    final porcGastos = double.tryParse(_gastosEscrituracionController.text) ?? 0;
    final rentaMensual = double.tryParse(_rentaMensualController.text.replaceAll(',', '')) ?? 0;
    final porcGastosAnuales = double.tryParse(_gastosAnualesController.text) ?? 0;

    final gastosEscrituracion = precioCompra * (porcGastos / 100);
    final inversionTotal = precioCompra + gastosEscrituracion;
    final rentaAnual = rentaMensual * 12;
    final gastosAnuales = rentaAnual * (porcGastosAnuales / 100);
    final ingresoNetoAnual = rentaAnual - gastosAnuales;
    
    // ✅ CORRECCIÓN: forzar conversión a double con .toDouble()
    final roi = inversionTotal > 0 ? ((ingresoNetoAnual / inversionTotal) * 100).toDouble() : 0.0;
    final payback = ingresoNetoAnual > 0 ? (inversionTotal / ingresoNetoAnual).toDouble() : 0.0;

    return {
      'inversionTotal': inversionTotal,
      'ingresoNetoAnual': ingresoNetoAnual,
      'roi': roi,
      'payback': payback,
    };
  }

  // --- WIDGETS DE UI ---

  Widget _buildInput(String label, TextEditingController controller, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildResultado(String label, double valor, {Color color = const Color(0xFF0F172A), bool esMoneda = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          Text(
            esMoneda ? _formatearMonedaCompleto(valor) : '${valor.toStringAsFixed(2)}${label.contains('%') ? '%' : ''}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.calculate, color: Colors.white), SizedBox(width: 8), Text('Centro de Calculadoras')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Hipotecaria'),
            Tab(text: 'Comisión'),
            Tab(text: 'Plusvalía'),
            Tab(text: 'ROI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabHipotecaria(),
          _buildTabComision(),
          _buildTabPlusvalia(),
          _buildTabROI(),
        ],
      ),
    );
  }

  Widget _buildTabHipotecaria() {
    final resultados = calcularHipotecaria();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏠 Calculadora Hipotecaria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildInput('Precio del inmueble', _precioController, suffix: 'MXN'),
          _buildInput('Porcentaje de enganche', _engancheController, suffix: '%'),
          _buildInput('Tasa de interés anual', _tasaController, suffix: '%'),
          _buildInput('Plazo del crédito', _plazoController, suffix: 'años'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resultados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Divider(),
                _buildResultado('Enganche requerido', resultados['enganche']!),
                _buildResultado('Monto del crédito', resultados['montoCredito']!),
                const Divider(),
                _buildResultado('Pago mensual estimado', resultados['pagoMensual']!, color: AppTheme.primary),
                _buildResultado('Total a pagar', resultados['totalPagar']!),
                _buildResultado('Total de intereses', resultados['totalIntereses']!, color: AppTheme.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabComision() {
    final resultados = calcularComision();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Calculadora de Comisiones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildInput('Precio de venta', _precioVentaController, suffix: 'MXN'),
          _buildInput('Porcentaje de comisión', _porcComisionController, suffix: '%'),
          _buildInput('Gastos de operación/marketing', _gastosOpController, suffix: 'MXN'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Desglose de Comisión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Divider(),
                _buildResultado('Comisión bruta', resultados['comisionBruta']!),
                _buildResultado('(-) Gastos de operación', resultados['gastosOp']!, color: AppTheme.danger),
                _buildResultado('(-) ISR estimado (10%)', resultados['isrEstimado']!, color: AppTheme.danger),
                const Divider(),
                _buildResultado('Comisión neta estimada', resultados['comisionFinal']!, color: AppTheme.success),
                const Text('Nota: El ISR es un estimado del 10%. Ajusta según tu régimen fiscal.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPlusvalia() {
    final resultados = calcularPlusvalia();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📈 Calculadora de Plusvalía', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildInput('Valor actual del inmueble', _valorActualController, suffix: 'MXN'),
          _buildInput('Tasa de plusvalía anual', _tasaPlusvaliaController, suffix: '%'),
          _buildInput('Período de proyección', _aniosPlusvaliaController, suffix: 'años'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Proyección a Futuro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Divider(),
                _buildResultado('Valor futuro estimado', resultados['valorFuturo']!, color: AppTheme.primary),
                _buildResultado('Ganancia por plusvalía', resultados['ganancia']!, color: AppTheme.success),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabROI() {
    final resultados = calcularROI();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Calculadora de ROI (Rentabilidad)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildInput('Precio de compra', _precioCompraController, suffix: 'MXN'),
          _buildInput('Gastos de escrituración', _gastosEscrituracionController, suffix: '%'),
          _buildInput('Renta mensual proyectada', _rentaMensualController, suffix: 'MXN'),
          _buildInput('Gastos anuales estimados', _gastosAnualesController, suffix: '% de la renta'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Análisis de Inversión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Divider(),
                _buildResultado('Inversión total (Compra + Gastos)', resultados['inversionTotal']!),
                _buildResultado('Ingreso neto anual', resultados['ingresoNetoAnual']!, color: AppTheme.success),
                const Divider(),
                _buildResultado('ROI Anual (%)', resultados['roi']!, esMoneda: false, color: AppTheme.primary),
                _buildResultado('Recuperación de inversión (años)', resultados['payback']!, esMoneda: false, color: AppTheme.warning),
                const Text('Nota: No incluye plusvalía del inmueble, solo flujo de efectivo por renta.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}