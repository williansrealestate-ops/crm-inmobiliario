import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/avaluos_service.dart';

class AvaluosScreen extends StatefulWidget {
  const AvaluosScreen({super.key});

  @override
  State<AvaluosScreen> createState() => _AvaluosScreenState();
}

class _AvaluosScreenState extends State<AvaluosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ Variables de estado
  String _tipoPropiedad = 'casa';
  String _metodoValuacion = 'comparativo';
  List<Map<String, dynamic>> _comparables = [];

  // ✅ Controladores de texto
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _coloniaCtrl = TextEditingController();
  final TextEditingController _ciudadCtrl = TextEditingController();
  final TextEditingController _estadoCtrl = TextEditingController();
  final TextEditingController _codigoPostalCtrl = TextEditingController();
  final TextEditingController _areaTerrenoCtrl = TextEditingController();
  final TextEditingController _areaConstruccionCtrl = TextEditingController();
  final TextEditingController _antiguedadCtrl = TextEditingController();
  final TextEditingController _habitacionesCtrl = TextEditingController();
  final TextEditingController _banosCtrl = TextEditingController();
  final TextEditingController _estacionamientosCtrl = TextEditingController();
  final TextEditingController _observacionesCtrl = TextEditingController();
  final TextEditingController _rentaMensualCtrl = TextEditingController();
  final TextEditingController _tasaCapitalizacionCtrl = TextEditingController();
  final TextEditingController _valorTerrenoCtrl = TextEditingController();
  final TextEditingController _costoPorM2Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _direccionCtrl.dispose();
    _coloniaCtrl.dispose();
    _ciudadCtrl.dispose();
    _estadoCtrl.dispose();
    _codigoPostalCtrl.dispose();
    _areaTerrenoCtrl.dispose();
    _areaConstruccionCtrl.dispose();
    _antiguedadCtrl.dispose();
    _habitacionesCtrl.dispose();
    _banosCtrl.dispose();
    _estacionamientosCtrl.dispose();
    _observacionesCtrl.dispose();
    _rentaMensualCtrl.dispose();
    _tasaCapitalizacionCtrl.dispose();
    _valorTerrenoCtrl.dispose();
    _costoPorM2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.analytics, color: Colors.white), SizedBox(width: 8), Text('Avalúos Profesionales')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Nuevo Avalúo'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormularioAvaluo(),
          _buildHistorial(),
        ],
      ),
    );
  }

  Widget _buildFormularioAvaluo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Crear Nuevo Avalúo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _buildSeccionDatosGenerales(),
          const SizedBox(height: 16),
          _buildSeccionUbicacion(),
          const SizedBox(height: 16),
          _buildSeccionCaracteristicas(),
          const SizedBox(height: 16),
          _buildSeccionValuacion(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _guardarAvaluo(),
              icon: const Icon(Icons.save),
              label: const Text('Guardar Avalúo', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionDatosGenerales() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📋 Datos Generales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tipo de propiedad', border: OutlineInputBorder()),
            items: AvaluosService.tiposPropiedad.map((t) => DropdownMenuItem<String>(value: t['id'] as String, child: Text('${t['icono']} ${t['nombre']}'))).toList(),
            onChanged: (value) => setState(() => _tipoPropiedad = value ?? 'casa'),
            value: _tipoPropiedad,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Método de valuación', border: OutlineInputBorder()),
            items: AvaluosService.metodosValuacion.map((m) => DropdownMenuItem<String>(value: m['id'] as String, child: Text(m['nombre']))).toList(),
            onChanged: (value) => setState(() => _metodoValuacion = value ?? 'comparativo'),
            value: _metodoValuacion,
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionUbicacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Ubicación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          TextField(controller: _coloniaCtrl, decoration: const InputDecoration(labelText: 'Colonia', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _ciudadCtrl, decoration: const InputDecoration(labelText: 'Ciudad', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _estadoCtrl, decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: _codigoPostalCtrl, decoration: const InputDecoration(labelText: 'Código Postal', border: OutlineInputBorder()), keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildSeccionCaracteristicas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏗️ Características Físicas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _areaTerrenoCtrl, decoration: const InputDecoration(labelText: 'Área terreno (m²)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _areaConstruccionCtrl, decoration: const InputDecoration(labelText: 'Área construcción (m²)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _antiguedadCtrl, decoration: const InputDecoration(labelText: 'Antigüedad (años)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _habitacionesCtrl, decoration: const InputDecoration(labelText: 'Habitaciones', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _banosCtrl, decoration: const InputDecoration(labelText: 'Baños', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _estacionamientosCtrl, decoration: const InputDecoration(labelText: 'Estacionamientos', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionValuacion() {
    if (_metodoValuacion == 'comparativo') {
      return _buildValuacionComparativo();
    } else if (_metodoValuacion == 'capitalizacion') {
      return _buildValuacionCapitalizacion();
    } else {
      return _buildValuacionCosto();
    }
  }

  Widget _buildValuacionComparativo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊 Valuación Comparativa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _agregarComparable(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar comparable', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._comparables.asMap().entries.map((entry) {
            final index = entry.key;
            final comp = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextField(controller: comp['direccionCtrl'], decoration: const InputDecoration(labelText: 'Dirección', isDense: true, border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEF4444)), onPressed: () => setState(() => _comparables.removeAt(index))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: comp['valorCtrl'], decoration: const InputDecoration(labelText: 'Valor venta', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: comp['areaTerrenoCtrl'], decoration: const InputDecoration(labelText: 'Área terreno', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: comp['areaConstruccionCtrl'], decoration: const InputDecoration(labelText: 'Área construcción', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: comp['antiguedadCtrl'], decoration: const InputDecoration(labelText: 'Antigüedad', isDense: true, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildValuacionCapitalizacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💰 Valuación por Capitalización', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: _rentaMensualCtrl, decoration: const InputDecoration(labelText: 'Renta mensual', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _tasaCapitalizacionCtrl, decoration: const InputDecoration(labelText: 'Tasa de capitalización (%)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('Valor estimado: ${_calcularValorCapitalizacion()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  Widget _buildValuacionCosto() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏗️ Valuación por Costo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: _valorTerrenoCtrl, decoration: const InputDecoration(labelText: 'Valor del terreno', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _costoPorM2Ctrl, decoration: const InputDecoration(labelText: 'Costo por m²', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('Valor estimado: ${_calcularValorCosto()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  String _calcularValorCapitalizacion() {
    final renta = double.tryParse(_rentaMensualCtrl.text) ?? 0;
    final tasa = double.tryParse(_tasaCapitalizacionCtrl.text) ?? 0;
    final valor = AvaluosService.calcularCapitalizacion(rentaMensual: renta, tasaCapitalizacion: tasa);
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _calcularValorCosto() {
    final terreno = double.tryParse(_valorTerrenoCtrl.text) ?? 0;
    final area = double.tryParse(_areaConstruccionCtrl.text) ?? 0;
    final costoM2 = double.tryParse(_costoPorM2Ctrl.text) ?? 0;
    final antiguedad = int.tryParse(_antiguedadCtrl.text) ?? 0;
    final valor = AvaluosService.calcularCosto(valorTerreno: terreno, areaConstruccion: area, costoPorM2: costoM2, antiguedad: antiguedad);
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _agregarComparable() {
    setState(() {
      _comparables.add({
        'direccionCtrl': TextEditingController(),
        'valorCtrl': TextEditingController(),
        'areaTerrenoCtrl': TextEditingController(),
        'areaConstruccionCtrl': TextEditingController(),
        'antiguedadCtrl': TextEditingController(),
      });
    });
  }

  void _guardarAvaluo() {
    final areaTerreno = double.tryParse(_areaTerrenoCtrl.text) ?? 0;
    final areaConstruccion = double.tryParse(_areaConstruccionCtrl.text) ?? 0;
    final antiguedad = int.tryParse(_antiguedadCtrl.text) ?? 0;

    double valorAvaluo = 0;

    if (_metodoValuacion == 'comparativo') {
      final comparables = _comparables.map((c) {
        return {
          'direccion': c['direccionCtrl'].text,
          'valorVenta': double.tryParse(c['valorCtrl'].text) ?? 0,
          'areaTerreno': double.tryParse(c['areaTerrenoCtrl'].text) ?? 0,
          'areaConstruccion': double.tryParse(c['areaConstruccionCtrl'].text) ?? 0,
          'antiguedad': int.tryParse(c['antiguedadCtrl'].text) ?? 0,
          'factorUbicacion': 1.0,
          'factorAcabados': 1.0,
        };
      }).toList();

      valorAvaluo = AvaluosService.calcularComparativo(
        comparables: comparables,
        areaTerreno: areaTerreno,
        areaConstruccion: areaConstruccion,
      );
    } else if (_metodoValuacion == 'capitalizacion') {
      final renta = double.tryParse(_rentaMensualCtrl.text) ?? 0;
      final tasa = double.tryParse(_tasaCapitalizacionCtrl.text) ?? 0;
      valorAvaluo = AvaluosService.calcularCapitalizacion(rentaMensual: renta, tasaCapitalizacion: tasa);
    } else {
      final terreno = double.tryParse(_valorTerrenoCtrl.text) ?? 0;
      final costoM2 = double.tryParse(_costoPorM2Ctrl.text) ?? 0;
      valorAvaluo = AvaluosService.calcularCosto(valorTerreno: terreno, areaConstruccion: areaConstruccion, costoPorM2: costoM2, antiguedad: antiguedad);
    }

    final avaluo = {
      'tipoPropiedad': _tipoPropiedad,
      'metodoValuacion': _metodoValuacion,
      'direccion': _direccionCtrl.text,
      'colonia': _coloniaCtrl.text,
      'ciudad': _ciudadCtrl.text,
      'estado': _estadoCtrl.text,
      'codigoPostal': _codigoPostalCtrl.text,
      'areaTerreno': areaTerreno,
      'areaConstruccion': areaConstruccion,
      'antiguedad': antiguedad,
      'habitaciones': int.tryParse(_habitacionesCtrl.text),
      'banos': int.tryParse(_banosCtrl.text),
      'estacionamientos': int.tryParse(_estacionamientosCtrl.text),
      'valorAvaluo': valorAvaluo,
      'observaciones': _observacionesCtrl.text,
    };

    if (_metodoValuacion == 'comparativo') {
      avaluo['comparables'] = _comparables.map((c) {
        return {
          'direccion': c['direccionCtrl'].text,
          'valorVenta': double.tryParse(c['valorCtrl'].text) ?? 0,
          'areaTerreno': double.tryParse(c['areaTerrenoCtrl'].text) ?? 0,
          'areaConstruccion': double.tryParse(c['areaConstruccionCtrl'].text) ?? 0,
          'antiguedad': int.tryParse(c['antiguedadCtrl'].text) ?? 0,
        };
      }).toList();
    } else if (_metodoValuacion == 'capitalizacion') {
      avaluo['rentaMensual'] = double.tryParse(_rentaMensualCtrl.text) ?? 0;
      avaluo['tasaCapitalizacion'] = double.tryParse(_tasaCapitalizacionCtrl.text) ?? 0;
    } else {
      avaluo['valorTerreno'] = double.tryParse(_valorTerrenoCtrl.text) ?? 0;
      avaluo['costoPorM2'] = double.tryParse(_costoPorM2Ctrl.text) ?? 0;
    }

    AvaluosService.agregarAvaluo(avaluo);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Avalúo guardado: \$${valorAvaluo.toStringAsFixed(0)}'), backgroundColor: const Color(0xFF10B981)),
    );

    _limpiarFormulario();
    setState(() => _tabController.index = 1);
  }

  void _limpiarFormulario() {
    _direccionCtrl.clear();
    _coloniaCtrl.clear();
    _ciudadCtrl.clear();
    _estadoCtrl.clear();
    _codigoPostalCtrl.clear();
    _areaTerrenoCtrl.clear();
    _areaConstruccionCtrl.clear();
    _antiguedadCtrl.clear();
    _habitacionesCtrl.clear();
    _banosCtrl.clear();
    _estacionamientosCtrl.clear();
    _observacionesCtrl.clear();
    _rentaMensualCtrl.clear();
    _tasaCapitalizacionCtrl.clear();
    _valorTerrenoCtrl.clear();
    _costoPorM2Ctrl.clear();
    _comparables.forEach((c) {
      (c['direccionCtrl'] as TextEditingController).dispose();
      (c['valorCtrl'] as TextEditingController).dispose();
      (c['areaTerrenoCtrl'] as TextEditingController).dispose();
      (c['areaConstruccionCtrl'] as TextEditingController).dispose();
      (c['antiguedadCtrl'] as TextEditingController).dispose();
    });
    _comparables.clear();
  }

  Widget _buildHistorial() {
    final avaluos = AvaluosService.getAvaluos();

    if (avaluos.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.analytics, size: 64, color: Color(0xFF64748B)), SizedBox(height: 16), Text('No hay avalúos registrados', style: TextStyle(color: Color(0xFF64748B)))]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: avaluos.length,
      itemBuilder: (context, index) {
        final avaluo = avaluos[index];
        final tipo = AvaluosService.tiposPropiedad.firstWhere((t) => t['id'] == avaluo['tipoPropiedad'], orElse: () => {'nombre': 'No especificado', 'icono': '🏠'});
        final fecha = DateTime.parse(avaluo['fechaAvaluo'] ?? DateTime.now().toIso8601String());

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(tipo['icono'], style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(avaluo['direccion'] ?? 'Sin dirección', style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${tipo['nombre']} • ${fecha.day}/${fecha.month}/${fecha.year}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.visibility, color: Color(0xFF3B82F6)), onPressed: () => _verReporte(avaluo)),
                  IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEF4444)), onPressed: () => _confirmarEliminar(avaluo)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Valor de avalúo:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('\$${(avaluo['valorAvaluo'] ?? 0).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _verReporte(Map<String, dynamic> avaluo) {
    final reporte = AvaluosService.generarReporte(avaluo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(' Reporte de Avalúo'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Text(reporte, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ElevatedButton.icon(
            onPressed: () {
              html.window.navigator.clipboard?.writeText(reporte);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Reporte copiado'), backgroundColor: Color(0xFF10B981)));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> avaluo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar avalúo?'),
        content: Text('¿Estás seguro de eliminar el avalúo de "${avaluo['direccion']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              AvaluosService.eliminarAvaluo(avaluo['id']);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}