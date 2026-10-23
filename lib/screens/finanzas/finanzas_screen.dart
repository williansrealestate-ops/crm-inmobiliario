import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/finanzas_service.dart';
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
  List<Map<String, dynamic>> _operaciones = [];
  List<Map<String, dynamic>> _ingresos = [];
  List<Map<String, dynamic>> _gastos = [];
  Map<String, double> _ingresosPorNegocio = {};
  Map<String, double> _gastosPorCategoria = {};
  Map<String, double> _ingresosPorOperacion = {};
  Map<String, double> _gastosPorOperacion = {};
  List<Map<String, dynamic>> _resumenOperaciones = [];
  
  String _operacionFiltro = 'todas';
  int _graficaModo = 0;
  
  // Nuevos: búsqueda y filtro por negocio en transacciones
  String _busquedaTransacciones = '';
  String _filtroNegocioTransacciones = 'todos';
  String _filtroTipoTransacciones = 'todos'; // todos, ingreso, gasto

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    _resumen = await FinanzasService.getResumenFinanciero(
      operacionId: _operacionFiltro == 'todas' ? null : _operacionFiltro,
    );
    _negocios = await FinanzasService.getNegocios();
    _operaciones = await FinanzasService.getOperaciones();
    _ingresos = await FinanzasService.getIngresos();
    _gastos = await FinanzasService.getGastos();
    _ingresosPorNegocio = await FinanzasService.getIngresosPorNegocio(
      operacionId: _operacionFiltro == 'todas' ? null : _operacionFiltro,
    );
    _gastosPorCategoria = await FinanzasService.getGastosPorCategoria(
      operacionId: _operacionFiltro == 'todas' ? null : _operacionFiltro,
    );
    _ingresosPorOperacion = await FinanzasService.getIngresosPorOperacion();
    _gastosPorOperacion = await FinanzasService.getGastosPorOperacion();
    _resumenOperaciones = await FinanzasService.getResumenPorOperacion();
    setState(() => _isLoading = false);
  }

  String _formatearMoneda(double valor) {
    return '\$${valor.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return DateFormat('dd/MM/yyyy').format(fecha);
    } catch (e) {
      return fechaIso;
    }
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
      case 'swap_horiz': return Icons.swap_horiz;
      case 'construction': return Icons.construction;
      case 'psychology': return Icons.psychology;
      case 'admin_panel_settings': return Icons.admin_panel_settings;
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
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Operaciones'),
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
                _buildTabOperaciones(),
                _buildTabNegocios(),
                _buildTabTransacciones(),
                _buildTabPresupuestos(),
              ],
            ),
    );
  }

  // ==================== DASHBOARD ====================
  Widget _buildTabDashboard() {
    final ingresos = (_resumen['ingresosMes'] ?? 0).toDouble();
    final gastos = (_resumen['gastosMes'] ?? 0).toDouble();
    final utilidad = ingresos - gastos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro de Operaciones
          _buildFiltroOperaciones(),
          const SizedBox(height: 12),

          // ✅ KPIs COMPACTOS (más pequeños para dar espacio a la gráfica)
          Row(
            children: [
              Expanded(child: _buildKpiCardCompacto('Ingresos', ingresos, const Color(0xFF10B981), Icons.trending_up)),
              const SizedBox(width: 8),
              Expanded(child: _buildKpiCardCompacto('Gastos', gastos, const Color(0xFFEF4444), Icons.trending_down)),
              const SizedBox(width: 8),
              Expanded(child: _buildKpiCardCompacto('Balance', utilidad, utilidad >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444), Icons.account_balance_wallet)),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ GRÁFICA GRANDE INTERACTIVA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222222)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getTituloGrafica(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                MoneyProDonutChart(
                  segments: _getSegmentosGrafica(),
                  centerTitle: _getCentroTitulo(),
                  centerValue: _getCentroValor(),
                  size: 320,
                  outerRingWidth: 70,
                  innerRingWidth: 25,
                  centerCircleRadius: 80,
                  viewModes: const ['Ingresos/Gastos', 'Ingresos por Negocio', 'Gastos por Categoría'],
                  currentViewMode: _graficaModo,
                  onViewModeChanged: (modo) => setState(() => _graficaModo = modo),
                  onCenterTap: () {
                    setState(() {
                      _graficaModo = (_graficaModo + 1) % 3;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Resumen de Operaciones en Dashboard
          const Text('Operaciones del Mes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._resumenOperaciones.map((op) {
            final color = _getColorFromHex(op['color']);
            final ingresosOp = (op['ingresos'] ?? 0).toDouble();
            final gastosOp = (op['gastos'] ?? 0).toDouble();
            final balance = ingresosOp - gastosOp;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(_getIcono(op['icono']), color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(op['nombre'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Ingresos: ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(_formatearMoneda(ingresosOp), style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('Gastos: ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(_formatearMoneda(gastosOp), style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatearMoneda(balance), style: TextStyle(
                        color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                      const Text('Balance', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ KPI CARD COMPACTO (más pequeño)
  Widget _buildKpiCardCompacto(String titulo, double valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 4),
          Text(titulo, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
        ]),
        const SizedBox(height: 4),
        Text(_formatearMoneda(valor), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  Widget _buildFiltroOperaciones() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Text('Operación: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _operacionFiltro,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: [
                const DropdownMenuItem(value: 'todas', child: Text('Todas las operaciones')),
                ..._operaciones.map((op) => DropdownMenuItem(
                  value: op['id'],
                  child: Text(op['nombre']),
                )),
              ],
              onChanged: (v) {
                setState(() => _operacionFiltro = v ?? 'todas');
                _cargarDatos();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTituloGrafica() {
    switch (_graficaModo) {
      case 0: return 'Ingresos / Gastos';
      case 1: return 'Ingresos por Negocio';
      case 2: return 'Gastos por Categoría';
      default: return '';
    }
  }

  String _getCentroTitulo() {
    switch (_graficaModo) {
      case 0: return 'Beneficio';
      case 1: return 'Ingresos';
      case 2: return 'Gastos';
      default: return '';
    }
  }

  double _getCentroValor() {
    final ingresos = (_resumen['ingresosMes'] ?? 0).toDouble();
    final gastos = (_resumen['gastosMes'] ?? 0).toDouble();
    switch (_graficaModo) {
      case 0: return ingresos - gastos;
      case 1: return ingresos;
      case 2: return gastos;
      default: return 0;
    }
  }

  List<DonutSegment> _getSegmentosGrafica() {
    final ingresos = (_resumen['ingresosMes'] ?? 0).toDouble();
    final gastos = (_resumen['gastosMes'] ?? 0).toDouble();

    switch (_graficaModo) {
      case 0:
        return [
          DonutSegment(label: 'Ingresos', value: ingresos, color: const Color(0xFF10B981)),
          DonutSegment(label: 'Gastos', value: gastos, color: const Color(0xFFEF4444)),
        ];
      case 1:
        return _negocios.map((n) => DonutSegment(
          label: n['nombre'],
          value: _ingresosPorNegocio[n['id']] ?? 0.0,
          color: _getColorFromHex(n['color']),
        )).toList();
      case 2:
        return _gastosPorCategoria.entries.map((e) => DonutSegment(
          label: e.key,
          value: e.value,
          color: _getColorParaCategoria(e.key),
        )).toList();
      default:
        return [];
    }
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

  // ==================== OPERACIONES ====================
  Widget _buildTabOperaciones() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarDialogoOperacion(),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Operación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: _operaciones.isEmpty
              ? const Center(child: Text('No hay operaciones', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _operaciones.length,
                  itemBuilder: (context, index) {
                    final op = _operaciones[index];
                    final color = _getColorFromHex(op['color']);
                    final resumenOp = _resumenOperaciones.firstWhere(
                      (r) => r['id'] == op['id'],
                      orElse: () => {'ingresos': 0.0, 'gastos': 0.0, 'balance': 0.0},
                    );
                    final ingresosOp = (resumenOp['ingresos'] ?? 0).toDouble();
                    final gastosOp = (resumenOp['gastos'] ?? 0).toDouble();
                    final balance = ingresosOp - gastosOp;
                    final presupuesto = (op['presupuesto'] ?? 0).toDouble();
                    final progreso = presupuesto > 0 ? ((ingresosOp + gastosOp) / presupuesto).clamp(0.0, 1.0) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                                child: Icon(_getIcono(op['icono']), color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(op['nombre'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('Presupuesto: ${_formatearMoneda(presupuesto)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                color: const Color(0xFF1A1A1A),
                                onSelected: (v) {
                                  if (v == 'editar') _mostrarDialogoOperacion(operacion: op);
                                  if (v == 'eliminar') _eliminarOperacion(op['id']);
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit, color: Colors.white, size: 18), SizedBox(width: 8), Text('Editar', style: TextStyle(color: Colors.white))])),
                                  const PopupMenuItem(value: 'eliminar', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progreso,
                              backgroundColor: color.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ingresos: ${_formatearMoneda(ingresosOp)}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('Gastos: ${_formatearMoneda(gastosOp)}', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('Balance: ${_formatearMoneda(balance)}', style: TextStyle(
                                color: balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _mostrarDialogoOperacion({Map<String, dynamic>? operacion}) {
    final esEditar = operacion != null;
    final nombreCtrl = TextEditingController(text: operacion?['nombre'] ?? '');
    final presupuestoCtrl = TextEditingController(text: operacion != null ? operacion['presupuesto'].toString() : '');
    String iconoSel = operacion?['icono'] ?? 'swap_horiz';
    String colorSel = operacion?['color'] ?? '0xFF3B82F6';

    final iconos = ['swap_horiz', 'home', 'construction', 'psychology', 'admin_panel_settings', 'business', 'handshake', 'store'];
    final colores = ['0xFF3B82F6', '0xFF10B981', '0xFFF59E0B', '0xFF8B5CF6', '0xFF06B6D4', '0xFFEF4444', '0xFF22C55E', '0xFFEC4899'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(esEditar ? 'Editar Operación' : 'Nueva Operación', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: presupuestoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Presupuesto (MXN)', labelStyle: TextStyle(color: Colors.grey), prefixText: '\$ ', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A)),
                ),
                const SizedBox(height: 12),
                const Text('Icono:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: iconos.map((ic) => GestureDetector(
                    onTap: () => setState(() => iconoSel = ic),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconoSel == ic ? const Color(0xFF0066FF) : const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: iconoSel == ic ? const Color(0xFF0066FF) : Colors.grey),
                      ),
                      child: Icon(_getIcono(ic), color: Colors.white, size: 20),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Color:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colores.map((c) => GestureDetector(
                    onTap: () => setState(() => colorSel = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getColorFromHex(c),
                        shape: BoxShape.circle,
                        border: Border.all(color: colorSel == c ? Colors.white : Colors.transparent, width: 3),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final presupuesto = double.tryParse(presupuestoCtrl.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
                if (nombreCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es requerido'), backgroundColor: Color(0xFFEF4444)));
                  return;
                }
                final data = {
                  'nombre': nombreCtrl.text,
                  'presupuesto': presupuesto,
                  'icono': iconoSel,
                  'color': colorSel,
                };
                if (esEditar) {
                  data['id'] = operacion!['id'];
                  await FinanzasService.actualizarOperacion(data);
                } else {
                  await FinanzasService.agregarOperacion(data);
                }
                Navigator.pop(ctx);
                _cargarDatos();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(esEditar ? 'Operación actualizada' : 'Operación creada'),
                    backgroundColor: const Color(0xFF10B981),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
              child: Text(esEditar ? 'Actualizar' : 'Crear', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarOperacion(String id) async {
    await FinanzasService.eliminarOperacion(id);
    _cargarDatos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operación eliminada'), backgroundColor: Color(0xFFEF4444)));
    }
  }

  // ==================== NEGOCIOS ====================
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
        }).toList(),
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

  // ==================== TRANSACCIONES (con búsqueda y filtros) ====================
  Widget _buildTabTransacciones() {
    final todasTransacciones = [
      ..._ingresos.map((i) => {...i, 'tipo': 'ingreso'}),
      ..._gastos.map((g) => {...g, 'tipo': 'gasto'}),
    ];

    // Aplicar filtros
    final transaccionesFiltradas = todasTransacciones.where((t) {
      final matchBusqueda = _busquedaTransacciones.isEmpty || 
          (t['concepto']?.toString().toLowerCase().contains(_busquedaTransacciones.toLowerCase()) ?? false) ||
          (t['categoria']?.toString().toLowerCase().contains(_busquedaTransacciones.toLowerCase()) ?? false);
      final matchNegocio = _filtroNegocioTransacciones == 'todos' || t['negocioId'] == _filtroNegocioTransacciones;
      final matchTipo = _filtroTipoTransacciones == 'todos' || t['tipo'] == _filtroTipoTransacciones;
      return matchBusqueda && matchNegocio && matchTipo;
    }).toList()..sort((a, b) => (b['fecha'] ?? '').compareTo(a['fecha'] ?? ''));

    return Column(children: [
      // ✅ BARRA DE BÚSQUEDA Y FILTROS
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar transacciones...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onChanged: (v) => setState(() => _busquedaTransacciones = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Filtro por Negocio
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroNegocioTransacciones,
                    decoration: const InputDecoration(
                      labelText: 'Negocio',
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 11),
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: [
                      const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      ..._negocios.map((n) => DropdownMenuItem(value: n['id'], child: Text(n['nombre']))),
                    ],
                    onChanged: (v) => setState(() => _filtroNegocioTransacciones = v ?? 'todos'),
                  ),
                ),
                const SizedBox(width: 8),
                // Filtro por Tipo
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroTipoTransacciones,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 11),
                      filled: true,
                      fillColor: Color(0xFF1A1A1A),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'ingreso', child: Text('Ingresos')),
                      DropdownMenuItem(value: 'gasto', child: Text('Gastos')),
                    ],
                    onChanged: (v) => setState(() => _filtroTipoTransacciones = v ?? 'todos'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Botones de acción
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => _mostrarDialogoTransaccion(tipo: 'ingreso'), icon: const Icon(Icons.add), label: const Text('Ingreso'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(onPressed: () => _mostrarDialogoTransaccion(tipo: 'gasto'), icon: const Icon(Icons.add), label: const Text('Gasto'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)))),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: transaccionesFiltradas.isEmpty
            ? const Center(child: Text('No hay transacciones', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: transaccionesFiltradas.length,
                itemBuilder: (context, index) {
                  final t = transaccionesFiltradas[index];
                  final esIngreso = t['tipo'] == 'ingreso';
                  final color = esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                  final icono = esIngreso ? Icons.add : Icons.remove;
                  final negocio = _negocios.firstWhere((n) => n['id'] == t['negocioId'], orElse: () => {'nombre': 'Otros', 'color': '0xFF6366F1', 'icono': 'more_horiz'});
                  final operacion = _operaciones.firstWhere((o) => o['id'] == t['operacionId'], orElse: () => {'nombre': 'Sin operación', 'color': '0xFF6366F1'});
                  final colorNegocio = _getColorFromHex(negocio['color']);
                  final colorOperacion = _getColorFromHex(operacion['color']);

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
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: colorOperacion, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(operacion['nombre'] ?? 'Sin operación', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                        const SizedBox(height: 2),
                        Text(_formatearFecha(t['fecha'] ?? ''), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        // ✅ MOSTRAR ASUNTO SI EXISTE
                        if (t['asunto'] != null && t['asunto'].toString().isNotEmpty)
                          Text('Asunto: ${t['asunto']}', style: const TextStyle(fontSize: 11, color: Colors.amber)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(_formatearMoneda(t['monto'] ?? 0), style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                        Text(t['categoria'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                        color: const Color(0xFF1A1A1A),
                        onSelected: (value) {
                          if (value == 'editar') _mostrarDialogoTransaccion(tipo: t['tipo'], transaccion: t);
                          if (value == 'eliminar') _eliminarTransaccion(t);
                          if (value == 'duplicar') _duplicarTransaccion(t);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit, color: Colors.white, size: 18), SizedBox(width: 8), Text('Editar', style: TextStyle(color: Colors.white))])),
                          const PopupMenuItem(value: 'duplicar', child: Row(children: [Icon(Icons.copy, color: Colors.blue, size: 18), SizedBox(width: 8), Text('Duplicar', style: TextStyle(color: Colors.blue))])),
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

  // ✅ FUNCIÓN PARA DUPLICAR TRANSACCIÓN
  void _duplicarTransaccion(Map<String, dynamic> t) {
    final nuevaTransaccion = {
      ...t,
      'id': null,
      'concepto': '${t['concepto']} (copia)',
      'fecha': DateTime.now().toIso8601String(),
    };
    nuevaTransaccion.remove('id');
    
    if (t['tipo'] == 'ingreso') {
      FinanzasService.agregarIngreso(nuevaTransaccion);
    } else {
      FinanzasService.agregarGasto(nuevaTransaccion);
    }
    
    _cargarDatos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transacción duplicada'), backgroundColor: Color(0xFF3B82F6)),
      );
    }
  }

  void _eliminarTransaccion(Map<String, dynamic> t) async {
    if (t['tipo'] == 'ingreso') await FinanzasService.eliminarIngreso(t['id']);
    else await FinanzasService.eliminarGasto(t['id']);
    _cargarDatos();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transacción eliminada'), backgroundColor: Color(0xFFEF4444)));
  }

  void _mostrarDialogoTransaccion({required String tipo, Map<String, dynamic>? transaccion}) {
    final esEditar = transaccion != null;
    final conceptoCtrl = TextEditingController(text: transaccion?['concepto'] ?? '');
    final asuntoCtrl = TextEditingController(text: transaccion?['asunto'] ?? ''); // ✅ NUEVO CAMPO ASUNTO
    final montoCtrl = TextEditingController(text: transaccion != null ? _formatearMoneda((transaccion['monto'] ?? 0).toDouble()) : '');
    final categoriaCtrl = TextEditingController(text: transaccion?['categoria'] ?? '');
    String negocioId = transaccion?['negocioId'] ?? (_negocios.isNotEmpty ? _negocios.first['id'] : 'otros');
    String operacionId = transaccion?['operacionId'] ?? (_operaciones.isNotEmpty ? _operaciones.first['id'] : '');
    DateTime fechaSel = transaccion != null ? DateTime.parse(transaccion['fecha']) : DateTime.now();

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
                  decoration: const InputDecoration(labelText: 'Concepto', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A)),
                ),
                const SizedBox(height: 12),
                // ✅ NUEVO CAMPO ASUNTO
                TextField(
                  controller: asuntoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Asunto', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A), prefixIcon: Icon(Icons.subject, color: Colors.grey)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Monto (MXN)', labelStyle: TextStyle(color: Colors.grey), prefixText: '\$ ', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A)),
                ),
                const SizedBox(height: 12),
                // Selector de fecha con mini calendario
                InkWell(
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaSel,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(primary: Color(0xFF0066FF), onPrimary: Colors.white, surface: Color(0xFF1A1A1A)),
                        ),
                        child: child!,
                      ),
                    );
                    if (fecha != null) setState(() => fechaSel = fecha);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Text(DateFormat('dd/MM/yyyy').format(fechaSel), style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const Spacer(),
                        const Text('Cambiar fecha', style: TextStyle(color: Color(0xFF0066FF), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: negocioId,
                  decoration: const InputDecoration(labelText: 'Negocio', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A)),
                  dropdownColor: const Color(0xFF0A0A0A),
                  style: const TextStyle(color: Colors.white),
                  items: _negocios.map((n) => DropdownMenuItem<String>(value: n['id'] as String, child: Text(n['nombre'], style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (v) => setState(() => negocioId = v ?? negocioId),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: operacionId.isNotEmpty ? operacionId : null,
                  decoration: const InputDecoration(labelText: 'Operación', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A)),
                  dropdownColor: const Color(0xFF0A0A0A),
                  style: const TextStyle(color: Colors.white),
                  items: _operaciones.map((o) => DropdownMenuItem<String>(value: o['id'] as String, child: Text(o['nombre'], style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (v) => setState(() => operacionId = v ?? ''),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoriaCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Categoría ${tipo == 'gasto' ? '(opcional)' : ''}', labelStyle: const TextStyle(color: Colors.grey), border: const OutlineInputBorder(), filled: true, fillColor: const Color(0xFF0A0A0A), prefixIcon: const Icon(Icons.category, color: Colors.grey)),
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
                  'asunto': asuntoCtrl.text, // ✅ GUARDAR ASUNTO
                  'monto': monto,
                  'negocioId': negocioId,
                  'operacionId': operacionId,
                  'categoria': categoriaCtrl.text,
                  'fecha': fechaSel.toIso8601String(),
                };
                if (esEditar) {
                  data['id'] = transaccion!['id'];
                  if (tipo == 'ingreso') await FinanzasService.actualizarIngreso(data);
                  else await FinanzasService.actualizarGasto(data);
                } else {
                  if (tipo == 'ingreso') await FinanzasService.agregarIngreso(data);
                  else await FinanzasService.agregarGasto(data);
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

  // ==================== PRESUPUESTOS ====================
  Widget _buildTabPresupuestos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Presupuestos por Negocio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._negocios.map((negocio) => _buildPresupuestoCard(negocio, 'negocio')),
        const SizedBox(height: 24),
        const Text('Presupuestos por Operación', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._operaciones.map((op) => _buildPresupuestoCard(op, 'operacion')),
      ]),
    );
  }

  Widget _buildPresupuestoCard(Map<String, dynamic> item, String tipo) {
    final color = _getColorFromHex(item['color']);
    double gastado = 0;
    
    if (tipo == 'negocio') {
      gastado = _gastos.where((g) => g['negocioId'] == item['id']).fold<double>(0, (s, g) => s + (g['monto'] ?? 0).toDouble());
    } else {
      gastado = _gastos.where((g) => g['operacionId'] == item['id']).fold<double>(0, (s, g) => s + (g['monto'] ?? 0).toDouble());
    }
    
    final presupuesto = (item['presupuesto'] ?? 0).toDouble();
    final progreso = presupuesto > 0 ? (gastado / presupuesto).clamp(0.0, 1.0) : 0.0;
    final excedido = progreso >= 1.0 && gastado > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: excedido ? const Color(0xFFEF4444) : color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(_getIcono(item['icono']), color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(item['nombre'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
          Text(excedido ? '¡Excedido!' : '${(progreso * 100).toStringAsFixed(0)}%', style: TextStyle(color: excedido ? const Color(0xFFEF4444) : color, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progreso, backgroundColor: color.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(excedido ? const Color(0xFFEF4444) : color), minHeight: 10),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Gastado: ${_formatearMoneda(gastado)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text('Presupuesto: ${_formatearMoneda(presupuesto)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => _editarPresupuesto(item, tipo),
          style: OutlinedButton.styleFrom(side: BorderSide(color: color), foregroundColor: color),
          child: const Text('Editar Presupuesto'),
        )),
      ]),
    );
  }

  void _editarPresupuesto(Map<String, dynamic> item, String tipo) {
    final controller = TextEditingController(text: item['presupuesto'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Presupuesto: ${item['nombre']}', style: const TextStyle(color: Colors.white)),
        content: TextField(controller: controller, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto (MXN)', labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), filled: true, fillColor: Color(0xFF0A0A0A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final nuevo = double.tryParse(controller.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
              if (tipo == 'negocio') {
                await FinanzasService.actualizarPresupuestoNegocio(item['id'], nuevo);
              } else {
                await FinanzasService.actualizarPresupuestoOperacion(item['id'], nuevo);
              }
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
}