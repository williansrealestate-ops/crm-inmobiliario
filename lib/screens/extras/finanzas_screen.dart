import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../services/finanzas_service.dart';
import '../../services/integraciones_service.dart';
import '../../services/pipeline_service.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatearMoneda(double valor) {
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)}K';
    return '\$${valor.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Finanzas y Comisiones')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
            Tab(text: 'Metas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabResumen(),
          _buildTabIngresos(),
          _buildTabGastos(),
          _buildTabMetas(),
        ],
      ),
    );
  }

  Widget _buildTabResumen() {
    final resumen = FinanzasService.getResumenFinanciero();
    final historial = FinanzasService.getHistorialMensual();
    final proyeccion = FinanzasService.getProyeccion();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildKpiCard('Ingresos del Mes', resumen['ingresosMes'], const Color(0xFF10B981), Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Gastos del Mes', resumen['gastosMes'], const Color(0xFFEF4444), Icons.trending_down)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKpiCard('Utilidad Neta', resumen['utilidadMes'], const Color(0xFF3B82F6), Icons.account_balance_wallet)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Impuestos Est.', resumen['impuestosMes'], const Color(0xFFF59E0B), Icons.receipt_long)),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 Progreso de Metas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _buildBarraProgreso('Meta Mensual', resumen['ingresosMes'], resumen['metaMensual'], const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildBarraProgreso('Meta Anual', resumen['ingresosAnio'], resumen['metaAnual'], const Color(0xFF3B82F6)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📈 Evolución Mensual (Últimos 6 meses)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < historial.length) {
                                return Text(historial[index]['mes'], style: const TextStyle(fontSize: 10));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: historial.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(toY: data['ingresos'], color: const Color(0xFF10B981), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                            BarChartRodData(toY: data['gastos'], color: const Color(0xFFEF4444), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLeyenda('Ingresos', const Color(0xFF10B981)),
                    const SizedBox(width: 16),
                    _buildLeyenda('Gastos', const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔮 Proyección Anual', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildProyeccionItem('Promedio Mensual', proyeccion['promedioMensual'])),
                    const SizedBox(width: 12),
                    Expanded(child: _buildProyeccionItem('Proyección Anual', proyeccion['proyeccionAnual'])),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProyeccionItem('Utilidad Proyectada', proyeccion['utilidadProyectada']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String titulo, double valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(_formatearMoneda(valor), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildBarraProgreso(String label, double actual, double meta, Color color) {
    final progreso = meta > 0 ? (actual / meta).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${(progreso * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progreso,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text('${_formatearMoneda(actual)} de ${_formatearMoneda(meta)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildLeyenda(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildProyeccionItem(String label, double valor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(_formatearMoneda(valor), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildTabIngresos() {
    final ingresos = FinanzasService.getIngresos();
    return Column(
      children: [
        Expanded(
          child: ingresos.isEmpty
              ? const Center(child: Text('No hay ingresos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ingresos.length,
                  itemBuilder: (context, index) {
                    final ingreso = ingresos[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Color(0xFF10B981)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ingreso['concepto'] ?? 'Sin concepto', style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(ingreso['cliente'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_formatearMoneda(ingreso['monto'] ?? 0), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                              Text(_formatearFecha(ingreso['fecha'] ?? ''), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                            onPressed: () => FinanzasService.eliminarIngreso(ingreso['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(top: BorderSide(color: AppTheme.getBorderColor(context)))),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarDialogoIngreso(),
              icon: const Icon(Icons.add),
              label: const Text('Registrar Ingreso'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabGastos() {
    final gastos = FinanzasService.getGastos();
    final categorias = FinanzasService.getGastosPorCategoria();
    return Column(
      children: [
        if (categorias.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppTheme.getBorderColor(context)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gastos por Categoría (Mes Actual)', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...categorias.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key),
                          Text(_formatearMoneda(e.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        Expanded(
          child: gastos.isEmpty
              ? const Center(child: Text('No hay gastos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: gastos.length,
                  itemBuilder: (context, index) {
                    final gasto = gastos[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.remove, color: Color(0xFFEF4444)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(gasto['concepto'] ?? 'Sin concepto', style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(gasto['categoria'] ?? 'Otros', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_formatearMoneda(gasto['monto'] ?? 0), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                              Text(_formatearFecha(gasto['fecha'] ?? ''), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                            onPressed: () => FinanzasService.eliminarGasto(gasto['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(top: BorderSide(color: AppTheme.getBorderColor(context)))),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarDialogoGasto(),
              icon: const Icon(Icons.add),
              label: const Text('Registrar Gasto'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabMetas() {
    final metas = FinanzasService.getMetas();
    final resumen = FinanzasService.getResumenFinanciero();
    final metaMensualCtrl = TextEditingController(text: metas['metaMensual'].toString());
    final metaAnualCtrl = TextEditingController(text: metas['metaAnual'].toString());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Configuración de Metas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: metaMensualCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Meta Mensual (MXN)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: metaAnualCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Meta Anual (MXN)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                FinanzasService.guardarMetas({
                  'metaMensual': double.tryParse(metaMensualCtrl.text) ?? 50000,
                  'metaAnual': double.tryParse(metaAnualCtrl.text) ?? 600000,
                });
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Metas actualizadas'), backgroundColor: Color(0xFF10B981)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Guardar Metas'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('📊 Progreso Actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                _buildBarraProgreso('Meta Mensual', resumen['ingresosMes'], resumen['metaMensual'], const Color(0xFF10B981)),
                const SizedBox(height: 16),
                _buildBarraProgreso('Meta Anual', resumen['ingresosAnio'], resumen['metaAnual'], const Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ACTUALIZADO: Diálogo de ingreso con calculadora integrada
  void _mostrarDialogoIngreso() {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    final clienteCtrl = TextEditingController();
    double porcentajeComision = 6.0;
    double comisionNeta = 0;
    bool usarCalculadora = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Registrar Ingreso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: conceptoCtrl,
                  decoration: const InputDecoration(labelText: 'Concepto', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: montoCtrl,
                  decoration: const InputDecoration(labelText: 'Monto (MXN)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: clienteCtrl,
                  decoration: const InputDecoration(labelText: 'Cliente (opcional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: usarCalculadora,
                      onChanged: (value) => setState(() => usarCalculadora = value ?? false),
                    ),
                    const Expanded(
                      child: Text('🧮 Usar calculadora de comisión', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                if (usarCalculadora) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('% Comisión:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final pct = double.tryParse(value);
                            if (pct != null) {
                              setState(() {
                                porcentajeComision = pct;
                                final monto = double.tryParse(montoCtrl.text.replaceAll(',', ''));
                                if (monto != null) {
                                  comisionNeta = IntegracionesService.calcularComisionParaFinanzas(monto, porcentajeComision)['comisionNeta'] ?? 0;
                                }
                              });
                            }
                          },
                          controller: TextEditingController(text: porcentajeComision.toString()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Comisión neta: ${PipelineService.formatearMoneda(comisionNeta)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                double montoFinal;
                if (usarCalculadora) {
                  montoFinal = comisionNeta;
                } else {
                  montoFinal = double.tryParse(montoCtrl.text.replaceAll(',', '')) ?? 0;
                }
                
                if (conceptoCtrl.text.isNotEmpty && montoFinal > 0) {
                  FinanzasService.agregarIngreso({
                    'concepto': conceptoCtrl.text,
                    'monto': montoFinal,
                    'cliente': clienteCtrl.text,
                    'tipo': usarCalculadora ? 'Comisión calculada' : 'Ingreso manual',
                  });
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoGasto() {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    String categoria = 'Marketing';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Registrar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: conceptoCtrl, decoration: const InputDecoration(labelText: 'Concepto', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: montoCtrl, decoration: const InputDecoration(labelText: 'Monto (MXN)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: categoria,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Oficina', child: Text('Oficina')),
                  DropdownMenuItem(value: 'Comidas', child: Text('Comidas')),
                  DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                ],
                onChanged: (value) => setState(() => categoria = value ?? 'Marketing'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final monto = double.tryParse(montoCtrl.text.replaceAll(',', ''));
                if (monto != null && monto > 0) {
                  FinanzasService.agregarGasto({
                    'concepto': conceptoCtrl.text,
                    'monto': monto,
                    'categoria': categoria,
                  });
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (e) {
      return fechaIso;
    }
  }
}