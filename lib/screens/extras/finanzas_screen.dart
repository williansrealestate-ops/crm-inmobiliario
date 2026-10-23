import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../services/finanzas_service.dart';
import '../../services/integraciones_service.dart';
import '../../services/pipeline_service.dart';
import '../../widgets/money_pro_donut_chart.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _resumen = {};
  List<Map<String, dynamic>> _negocios = [];
  List<Map<String, dynamic>> _ingresos = [];
  List<Map<String, dynamic>> _gastos = [];
  Map<String, double> _ingresosPorNegocio = {};
  Map<String, double> _gastosPorCategoria = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    _resumen = await FinanzasService.getResumenFinanciero();
    _negocios = await FinanzasService.getNegocios();
    _ingresos = await FinanzasService.getIngresos();
    _gastos = await FinanzasService.getGastos();
    _ingresosPorNegocio = await FinanzasService.getIngresosPorNegocio();
    _gastosPorCategoria = await FinanzasService.getGastosPorCategoria();
    setState(() => _isLoading = false);
  }

  String _formatearMoneda(double valor) {
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcono(String nombreIcono) {
    switch (nombreIcono) {
      case 'home': return Icons.home;
      case 'mineral': return Icons.landscape;
      case 'local_gas_station': return Icons.local_gas_station;
      case 'agriculture': return Icons.agriculture;
      case 'engineering': return Icons.engineering;
      default: return Icons.more_horiz;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.account_balance_wallet, color: Colors.white),
          SizedBox(width: 8),
          Text('Finanzas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        backgroundColor: const Color(0xFF0066FF),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Negocios'),
            Tab(text: 'Transacciones'),
            Tab(text: 'Presupuestos'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTabDashboard(),
                _buildTabNegocios(),
                _buildTabTransacciones(),
                _buildTabPresupuestos(),
              ],
            ),
    );
  }

  Widget _buildTabDashboard() {
    final ingresos = (_resumen['ingresosMes'] ?? 0).toDouble();
    final gastos = (_resumen['gastosMes'] ?? 0).toDouble();
    final utilidad = ingresos - gastos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildKpiCard('Ingresos', ingresos, const Color(0xFF10B981), Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Gastos', gastos, const Color(0xFFEF4444), Icons.trending_down)),
              const SizedBox(width: 12),
              Expanded(child: _buildKpiCard('Balance', utilidad, utilidad >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444), Icons.account_balance_wallet)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF222222))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingresos / Gastos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                MoneyProDonutChart(
                  segments: [
                    DonutSegment(label: 'Ingresos', value: ingresos, color: const Color(0xFF10B981)),
                    DonutSegment(label: 'Gastos', value: gastos, color: const Color(0xFFEF4444)),
                  ],
                  centerTitle: 'Beneficio',
                  centerValue: utilidad,
                  size: 280,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF222222))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingresos por Negocio', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                MoneyProDonutChart(
                  segments: _negocios.map((n) => DonutSegment(
                    label: n['nombre'],
                    value: _ingresosPorNegocio[n['id']] ?? 0.0,
                    color: _getColorFromHex(n['color']),
                  )).toList(),
                  centerTitle: 'Ingresos',
                  centerValue: ingresos,
                  size: 280,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_gastosPorCategoria.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF222222))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gastos por Categoría', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  MoneyProDonutChart(
                    segments: _gastosPorCategoria.entries.map((e) => DonutSegment(
                      label: e.key,
                      value: e.value,
                      color: _getColorParaCategoria(e.key),
                    )).toList(),
                    centerTitle: 'Gastos',
                    centerValue: gastos,
                    size: 280,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getColorParaCategoria(String categoria) {
    final colores = {
      'Marketing': const Color(0xFF10B981), 'Transporte': const Color(0xFF3B82F6), 'Oficina': const Color(0xFFF59E0B),
      'Comidas': const Color(0xFFEF4444), 'Préstamos': const Color(0xFF10B981), 'Personal': const Color(0xFF14B8A6),
      'Capacitación': const Color(0xFFEF4444), 'Deudas': const Color(0xFFDC2626), 'Mobiliario': const Color(0xFF06B6D4),
      'Alquiler': const Color(0xFF3B82F6), 'Insumos': const Color(0xFF22C55E), 'Otros': const Color(0xFF6366F1),
    };
    return colores[categoria] ?? const Color(0xFF6366F1);
  }

  Widget _buildKpiCard(String titulo, double valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icono, color: color, size: 24),
        const SizedBox(height: 8),
        Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(_formatearMoneda(valor), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  Widget _buildTabNegocios() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mis Negocios', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._negocios.map((negocio) {
          final color = _getColorFromHex(negocio['color']);
          final ingresoNegocio = _ingresosPorNegocio[negocio['id']] ?? 0.0;
          final gastosNegocio = _gastos.where((g) => g['negocioId'] == negocio['id']).fold<double>(0, (s, g) => s + (g['monto'] ?? 0).toDouble());
          final balance = ingresoNegocio - gastosNegocio;
          final transacciones = _ingresos.where((i) => i['negocioId'] == negocio['id']).length + _gastos.where((g) => g['negocioId'] == negocio['id']).length;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
            child: Column(children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Icon(_getIcono(negocio['icono']), color: Colors.white, size: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(negocio['nombre'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('$transacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ])),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: () => _mostrarMenuNegocio(negocio)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _buildMiniCard('Ingresos', ingresoNegocio, const Color(0xFF10B981), Icons.trending_up)),
                const SizedBox(width: 8),
                Expanded(child: _buildMiniCard('Gastos', gastosNegocio, const Color(0xFFEF4444), Icons.trending_down)),
                const SizedBox(width: 8),
                Expanded(child: _buildMiniCard('Balance', balance, balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444), Icons.account_balance_wallet)),
              ]),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildMiniCard(String label, double valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Icon(icono, color: color, size: 18),
        const SizedBox(height: 4),
        Text(_formatearMoneda(valor), style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
      ]),
    );
  }

  void _mostrarMenuNegocio(Map<String, dynamic> negocio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.edit, color: Colors.white), title: const Text('Editar Negocio', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _editarNegocio(negocio); }),
        ListTile(leading: const Icon(Icons.visibility, color: Colors.white), title: const Text('Ver Gráfica', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(ctx); _verGraficaNegocio(negocio); }),
      ]),
    );
  }

  void _editarNegocio(Map<String, dynamic> negocio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar ${negocio['nombre']} (Función en desarrollo)'), backgroundColor: const Color(0xFF0066FF)),
    );
  }

  void _verGraficaNegocio(Map<String, dynamic> negocio) {
    final ingresosNeg = _ingresos.where((i) => i['negocioId'] == negocio['id']).fold<double>(0, (s, i) => s + (i['monto'] ?? 0).toDouble());
    final gastosNeg = _gastos.where((g) => g['negocioId'] == negocio['id']).fold<double>(0, (s, g) => s + (g['monto'] ?? 0).toDouble());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0A0A0A),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(negocio['nombre'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            MoneyProDonutChart(
              segments: [
                DonutSegment(label: 'Ingresos', value: ingresosNeg, color: const Color(0xFF10B981)),
                DonutSegment(label: 'Gastos', value: gastosNeg, color: const Color(0xFFEF4444)),
              ],
              centerTitle: 'Balance',
              centerValue: ingresosNeg - gastosNeg,
              size: 260,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar', style: TextStyle(color: Colors.grey))),
          ]),
        ),
      ),
    );
  }

  Widget _buildTabTransacciones() {
    final todasTransacciones = [
      ..._ingresos.map((i) => {...i, 'tipo': 'ingreso'}),
      ..._gastos.map((g) => {...g, 'tipo': 'gasto'}),
    ]..sort((a, b) => (b['fecha'] ?? '').compareTo(a['fecha'] ?? ''));

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _mostrarDialogoTransaccion(tipo: 'ingreso'), icon: const Icon(Icons.add), label: const Text('Ingreso'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(onPressed: () => _mostrarDialogoTransaccion(tipo: 'gasto'), icon: const Icon(Icons.add), label: const Text('Gasto'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)))),
        ]),
      ),
      Expanded(
        child: todasTransacciones.isEmpty
            ? const Center(child: Text('No hay transacciones', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: todasTransacciones.length,
                itemBuilder: (context, index) {
                  final t = todasTransacciones[index];
                  final esIngreso = t['tipo'] == 'ingreso';
                  final color = esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                  final icono = esIngreso ? Icons.add : Icons.remove;
                  final negocio = _negocios.firstWhere((n) => n['id'] == t['negocioId'], orElse: () => {'nombre': 'Otros', 'color': '0xFF6366F1', 'icono': 'more_horiz'});
                  final colorNegocio = _getColorFromHex(negocio['color']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icono, color: color)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: colorNegocio, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(negocio['nombre'] ?? 'Otros', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text(t['categoria'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(_formatearMoneda(t['monto'] ?? 0), style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                        Text(_formatearFecha(t['fecha'] ?? ''), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                        color: const Color(0xFF1A1A1A),
                        onSelected: (value) {
                          if (value == 'editar') _mostrarDialogoTransaccion(tipo: t['tipo'], transaccion: t);
                          if (value == 'eliminar') _eliminarTransaccion(t);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit, color: Colors.white, size: 18), SizedBox(width: 8), Text('Editar', style: TextStyle(color: Colors.white))])),
                          const PopupMenuItem(value: 'eliminar', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  void _eliminarTransaccion(Map<String, dynamic> t) async {
    if (t['tipo'] == 'ingreso') {
      await FinanzasService.eliminarIngreso(t['id']);
    } else {
      await FinanzasService.eliminarGasto(t['id']);
    }
    _cargarDatos();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transacción eliminada'), backgroundColor: Color(0xFFEF4444)));
  }

  void _mostrarDialogoTransaccion({required String tipo, Map<String, dynamic>? transaccion}) {
    final esEditar = transaccion != null;
    final conceptoCtrl = TextEditingController(text: transaccion?['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: transaccion != null ? _formatearMoneda((transaccion['monto'] ?? 0).toDouble()) : '');
    final categoriaCtrl = TextEditingController(text: transaccion?['categoria'] ?? '');
    String negocioId = transaccion?['negocioId'] ?? (_negocios.isNotEmpty ? _negocios.first['id'] : 'otros');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(esEditar ? 'Editar ${tipo == 'ingreso' ? 'Ingreso' : 'Gasto'}' : 'Nuevo ${tipo == 'ingreso' ? 'Ingreso' : 'Gasto'}', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: conceptoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Concepto',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto (MXN)',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: negocioId,
                  decoration: const InputDecoration(
                    labelText: 'Negocio',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF0A0A0A),
                  ),
                  dropdownColor: const Color(0xFF0A0A0A),
                  style: const TextStyle(color: Colors.white),
                  items: _negocios.map((n) => DropdownMenuItem<String>(
                    value: n['id'] as String,
                    child: Text(n['nombre'], style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (v) => setState(() => negocioId = v ?? negocioId),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoriaCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Categoría ${tipo == 'gasto' ? '(opcional)' : ''}',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: const Color(0xFF0A0A0A),
                    prefixIcon: const Icon(Icons.category, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final montoTexto = montoCtrl.text.replaceAll(RegExp(r'[^\d.]'), '');
                final monto = double.tryParse(montoTexto) ?? 0;
                if (conceptoCtrl.text.isEmpty || monto <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa concepto y monto'), backgroundColor: Color(0xFFEF4444)));
                  return;
                }
                final data = {
                  'concepto': conceptoCtrl.text,
                  'monto': monto,
                  'negocioId': negocioId,
                  'categoria': categoriaCtrl.text,
                };
                if (esEditar) {
                  data['id'] = transaccion['id'];
                  data['fecha'] = transaccion['fecha'];
                  if (tipo == 'ingreso') {
                    await FinanzasService.actualizarIngreso(data);
                  } else {
                    await FinanzasService.actualizarGasto(data);
                  }
                } else {
                  if (tipo == 'ingreso') {
                    await FinanzasService.agregarIngreso(data);
                  } else {
                    await FinanzasService.agregarGasto(data);
                  }
                }
                Navigator.pop(ctx);
                _cargarDatos();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(esEditar ? 'Transacción actualizada' : 'Transacción registrada'),
                    backgroundColor: const Color(0xFF10B981),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: tipo == 'ingreso' ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
              child: Text(esEditar ? 'Actualizar' : 'Guardar', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPresupuestos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Presupuestos por Negocio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)), onPressed: () => _editarTodosLosPresupuestos()),
        ]),
        const SizedBox(height: 16),
        ..._negocios.map((negocio) {
          final color = _getColorFromHex(negocio['color']);
          final gastoNegocio = _gastos.where((g) => g['negocioId'] == negocio['id']).fold<double>(0, (s, g) => s + (g['monto'] ?? 0).toDouble());
          final presupuesto = (negocio['presupuesto'] ?? 0).toDouble();
          final progreso = presupuesto > 0 ? (gastoNegocio / presupuesto).clamp(0.0, 1.0) : 0.0;
          final excedido = progreso >= 1.0 && gastoNegocio > 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: excedido ? const Color(0xFFEF4444) : color.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(_getIcono(negocio['icono']), color: color, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text(negocio['nombre'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                Text(excedido ? '¡Excedido!' : '${(progreso * 100).toStringAsFixed(0)}%', style: TextStyle(color: excedido ? const Color(0xFFEF4444) : color, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: progreso, backgroundColor: color.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(excedido ? const Color(0xFFEF4444) : color), minHeight: 10),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Gastado: ${_formatearMoneda(gastoNegocio)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Presupuesto: ${_formatearMoneda(presupuesto)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _editarPresupuesto(negocio), style: OutlinedButton.styleFrom(side: BorderSide(color: color), foregroundColor: color), child: const Text('Editar Presupuesto'))),
            ]),
          );
        }),
      ]),
    );
  }

  void _editarPresupuesto(Map<String, dynamic> negocio) {
    final controller = TextEditingController(text: negocio['presupuesto'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Presupuesto: ${negocio['nombre']}', style: const TextStyle(color: Colors.white)),
        content: TextField(controller: controller, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto (MXN)', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final nuevo = double.tryParse(controller.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
              await FinanzasService.actualizarPresupuestoNegocio(negocio['id'], nuevo);
              Navigator.pop(ctx);
              _cargarDatos();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarTodosLosPresupuestos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar Presupuestos', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, children: _negocios.map((n) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(child: Text(n['nombre'], style: const TextStyle(color: Colors.white))),
              SizedBox(
                width: 120,
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  controller: TextEditingController(text: n['presupuesto'].toString()),
                  decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                  onChanged: (v) async {
                    final nuevo = double.tryParse(v.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
                    await FinanzasService.actualizarPresupuestoNegocio(n['id'], nuevo);
                  },
                ),
              ),
            ]),
          )).toList()),
        ),
        actions: [ElevatedButton(onPressed: () { Navigator.pop(ctx); _cargarDatos(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)), child: const Text('Cerrar', style: TextStyle(color: Colors.white)))],
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