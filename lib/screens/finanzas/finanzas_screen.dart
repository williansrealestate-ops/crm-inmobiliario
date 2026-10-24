import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:html' as html;

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  String _search = '';
  String _categoriaFiltro = 'Todas';
  String _cuentaFiltro = 'Todas';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // Cuentas predefinidas (estilo Money Pro)
  final List<Map<String, dynamic>> _cuentas = [
    {'nombre': 'Efectivo', 'icon': Icons.money, 'color': Colors.green},
    {'nombre': 'Banco', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'nombre': 'Tarjeta', 'icon': Icons.credit_card, 'color': Colors.orange},
    {'nombre': 'Inversión', 'icon': Icons.trending_up, 'color': Colors.purple},
  ];

  // Categorías con presupuestos
  final List<Map<String, dynamic>> _categoriasGasto = [
    {'nombre': 'Operación', 'icon': Icons.settings, 'presupuesto': 50000.0},
    {'nombre': 'Marketing', 'icon': Icons.campaign, 'presupuesto': 30000.0},
    {'nombre': 'Oficina', 'icon': Icons.business, 'presupuesto': 20000.0},
    {'nombre': 'Comisiones', 'icon': Icons.handshake, 'presupuesto': 100000.0},
    {'nombre': 'Servicios', 'icon': Icons.bolt, 'presupuesto': 15000.0},
    {'nombre': 'Otros', 'icon': Icons.more_horiz, 'presupuesto': 10000.0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.account_balance_wallet, color: Colors.white),
          SizedBox(width: 8),
          Text('Finanzas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _mostrarFormularioTransaccion()),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'exportar') _exportarCSV();
              if (value == 'presupuestos') _mostrarPresupuestos();
              if (value == 'metas') _mostrarMetas();
              if (value == 'recurrentes') _mostrarRecurrentes();
              if (value == 'calendario') _mostrarCalendario();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'presupuestos', child: Row(children: [Icon(Icons.pie_chart, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Presupuestos')])),
              const PopupMenuItem(value: 'metas', child: Row(children: [Icon(Icons.flag, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Metas de Ahorro')])),
              const PopupMenuItem(value: 'recurrentes', child: Row(children: [Icon(Icons.repeat, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Transacciones Recurrentes')])),
              const PopupMenuItem(value: 'calendario', child: Row(children: [Icon(Icons.calendar_month, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Calendario')])),
              const PopupMenuItem(value: 'exportar', child: Row(children: [Icon(Icons.download, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Exportar CSV')])),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ingresos'),
            Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'),
            Tab(icon: Icon(Icons.credit_card), text: 'Cuentas'),
            Tab(icon: Icon(Icons.show_chart), text: 'Reportes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResumen(),
          _buildListaTransacciones('Ingreso'),
          _buildListaTransacciones('Gasto'),
          _buildCuentas(),
          _buildReportes(),
        ],
      ),
    );
  }

  // ============================================
  // PESTAÑA 1: RESUMEN
  // ============================================
  Widget _buildResumen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Total
            _buildTarjetaBalance(),
            const SizedBox(height: 16),
            
            // Ingresos vs Gastos
            Row(
              children: [
                Expanded(child: _buildTarjetaResumen('Ingresos', Colors.green, Icons.arrow_upward)),
                const SizedBox(width: 12),
                Expanded(child: _buildTarjetaResumen('Gastos', Colors.red, Icons.arrow_downward)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Gráfico de tendencia
            const Text('📈 Tendencia Mensual', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
              child: _buildGraficoLineas(),
            ),
            const SizedBox(height: 24),
            
            // Últimas transacciones
            const Text(' Últimas Transacciones', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildUltimasTransacciones(),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaBalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
            SizedBox(width: 8),
            Text('Balance Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('transacciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
              final docs = snapshot.data!.docs;
              final ingresos = docs.where((d) => (d.data() as Map)['tipo'] == 'Ingreso').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
              final gastos = docs.where((d) => (d.data() as Map)['tipo'] == 'Gasto').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
              final balance = ingresos - gastos;
              return Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('transacciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('0 transacciones', style: TextStyle(color: Colors.white70, fontSize: 12));
              return Text('${snapshot.data!.docs.length} transacciones', style: const TextStyle(color: Colors.white70, fontSize: 12));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaResumen(String titulo, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(titulo, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('transacciones').where('tipo', isEqualTo: titulo).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('\$0', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
              final total = snapshot.data!.docs.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());
              return Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoLineas() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        // Agrupar por mes
        Map<String, double> ingresosPorMes = {};
        Map<String, double> gastosPorMes = {};
        
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fecha = data['fecha'] as String? ?? '';
          final monto = (data['monto'] ?? 0).toDouble();
          final tipo = data['tipo'] ?? '';
          
          if (fecha.length >= 7) {
            final mes = fecha.substring(0, 7); // YYYY-MM
            if (tipo == 'Ingreso') {
              ingresosPorMes[mes] = (ingresosPorMes[mes] ?? 0) + monto;
            } else {
              gastosPorMes[mes] = (gastosPorMes[mes] ?? 0) + monto;
            }
          }
        }
        
        final meses = ingresosPorMes.keys.toList()..sort();
        if (meses.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
        
        final spotsIngresos = <FlSpot>[];
        final spotsGastos = <FlSpot>[];
        
        for (int i = 0; i < meses.length; i++) {
          spotsIngresos.add(FlSpot(i.toDouble(), ingresosPorMes[meses[i]] ?? 0));
          spotsGastos.add(FlSpot(i.toDouble(), gastosPorMes[meses[i]] ?? 0));
        }
        
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < meses.length) {
                  return Text(meses[idx].substring(5), style: const TextStyle(color: Colors.grey, fontSize: 10));
                }
                return const Text('');
              })),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(spots: spotsIngresos, isCurved: true, color: Colors.green, barWidth: 3, dotData: const FlDotData(show: false)),
              LineChartBarData(spots: spotsGastos, isCurved: true, color: Colors.red, barWidth: 3, dotData: const FlDotData(show: false)),
            ],
            minX: 0,
            maxX: (meses.length - 1).toDouble(),
          ),
        );
      },
    );
  }

  Widget _buildUltimasTransacciones() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text('No hay transacciones', style: TextStyle(color: Colors.grey));
        
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final esIngreso = data['tipo'] == 'Ingreso';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF222222))),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('${data['categoria'] ?? 'General'} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ])),
                  Text('${esIngreso ? "+" : "-"}\$${data['monto'] ?? '0'}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================
  // PESTAÑAS 2 y 3: INGRESOS Y GASTOS
  // ============================================
  Widget _buildListaTransacciones(String tipo) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF111111),
            child: Column(children: [
              TextField(decoration: InputDecoration(hintText: 'Buscar transacciones...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), style: const TextStyle(color: Colors.white), onChanged: (v) => setState(() => _search = v.toLowerCase())),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(value: _categoriaFiltro, decoration: InputDecoration(labelText: 'Categoría', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todas', 'General', 'Ventas', 'Comisiones', 'Operación', 'Marketing', 'Oficina', 'Servicios', 'Otros'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(), onChanged: (v) => setState(() => _categoriaFiltro = v!))),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(value: _cuentaFiltro, decoration: InputDecoration(labelText: 'Cuenta', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todas', 'Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _cuentaFiltro = v!))),
              ]),
            ]),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones').where('tipo', isEqualTo: tipo).orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  final transacciones = snapshot.data?.docs ?? [];
                  final filtrados = transacciones.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final concepto = (data['concepto'] ?? '').toString().toLowerCase();
                    final categoria = data['categoria'] ?? 'General';
                    final cuenta = data['cuenta'] ?? 'Efectivo';
                    final matchSearch = _search.isEmpty || concepto.contains(_search);
                    final matchCategoria = _categoriaFiltro == 'Todas' || categoria == _categoriaFiltro;
                    final matchCuenta = _cuentaFiltro == 'Todas' || cuenta == _cuentaFiltro;
                    return matchSearch && matchCategoria && matchCuenta;
                  }).toList();

                  if (filtrados.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.grey, size: 64), const SizedBox(height: 16), Text('No hay ${tipo.toLowerCase()}s registrados', style: const TextStyle(color: Colors.grey, fontSize: 16))]));

                  final total = filtrados.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());

                  return Column(children: [
                    Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: tipo == 'Ingreso' ? Colors.green : Colors.red)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total:', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)), Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 20, fontWeight: FontWeight.bold))])),
                    Expanded(child: ListView.builder(itemCount: filtrados.length, itemBuilder: (context, index) {
                      final doc = filtrados[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF222222))), child: ListTile(contentPadding: const EdgeInsets.all(16), leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: tipo == 'Ingreso' ? Colors.green : Colors.red, size: 24)), title: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'}', style: const TextStyle(color: Colors.grey)), Text('${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12))]), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('\$${data['monto'] ?? '0'}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _mostrarFormularioTransaccion(transaccion: data, docId: doc.id)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _eliminarTransaccion(doc.id, data['concepto']))])])),
                    );
                  })),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PESTAÑA 4: CUENTAS (estilo Money Pro)
  // ============================================
  Widget _buildCuentas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' Mis Cuentas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _cuentas.length,
              itemBuilder: (context, index) {
                final cuenta = _cuentas[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
                  child: Row(
                    children: [
                      Container(width: 50, height: 50, decoration: BoxDecoration(color: (cuenta['color'] as Color).withOpacity(0.2), shape: BoxShape.circle), child: Icon(cuenta['icon'] as IconData, color: cuenta['color'] as Color, size: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cuenta['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore.collection('transacciones').where('cuenta', isEqualTo: cuenta['nombre']).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const Text('\$0.00', style: TextStyle(color: Colors.grey, fontSize: 14));
                                final docs = snapshot.data!.docs;
                                final ingresos = docs.where((d) => (d.data() as Map)['tipo'] == 'Ingreso').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
                                final gastos = docs.where((d) => (d.data() as Map)['tipo'] == 'Gasto').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
                                final balance = ingresos - gastos;
                                return Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 14));
                              },
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PESTAÑA 5: REPORTES
  // ============================================
  Widget _buildReportes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(' Reporte por Categoría', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
              child: _buildGraficoCategorias(),
            ),
            const SizedBox(height: 24),
            const Text(' Comparativo Mensual', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
              child: _buildGraficoBarras(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoCategorias() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').where('tipo', isEqualTo: 'Gasto').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        Map<String, double> porCategoria = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final cat = data['categoria'] ?? 'Otros';
          porCategoria[cat] = (porCategoria[cat] ?? 0) + (data['monto'] ?? 0).toDouble();
        }
        if (porCategoria.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
        
        final sections = <PieChartSectionData>[];
        final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple];
        int i = 0;
        porCategoria.forEach((cat, monto) {
          sections.add(PieChartSectionData(title: cat, value: monto, color: colors[i % colors.length], radius: 60, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)));
          i++;
        });
        
        return PieChart(PieChartData(sections: sections, centerSpaceRadius: 40));
      },
    );
  }

  Widget _buildGraficoBarras() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        Map<String, double> ingresosPorMes = {};
        Map<String, double> gastosPorMes = {};
        
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fecha = data['fecha'] as String? ?? '';
          final monto = (data['monto'] ?? 0).toDouble();
          final tipo = data['tipo'] ?? '';
          if (fecha.length >= 7) {
            final mes = fecha.substring(0, 7);
            if (tipo == 'Ingreso') {
              ingresosPorMes[mes] = (ingresosPorMes[mes] ?? 0) + monto;
            } else {
              gastosPorMes[mes] = (gastosPorMes[mes] ?? 0) + monto;
            }
          }
        }
        
        final meses = ingresosPorMes.keys.toList()..sort();
        if (meses.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
        
        final groups = <BarChartGroupData>[];
        for (int i = 0; i < meses.length; i++) {
          groups.add(BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: ingresosPorMes[meses[i]] ?? 0, color: Colors.green, width: 16),
            BarChartRodData(toY: gastosPorMes[meses[i]] ?? 0, color: Colors.red, width: 16),
          ]));
        }
        
        return BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, barGroups: groups, titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
          final idx = value.toInt();
          if (idx >= 0 && idx < meses.length) return Text(meses[idx].substring(5), style: const TextStyle(color: Colors.grey, fontSize: 10));
          return const Text('');
        }))), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false)));
      },
    );
  }

  // ============================================
  // FUNCIONALIDADES AVANZADAS
  // ============================================
  
  void _mostrarPresupuestos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.pie_chart, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('Presupuestos por Categoría', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones').where('tipo', isEqualTo: 'Gasto').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  Map<String, double> gastado = {};
                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final cat = data['categoria'] ?? 'Otros';
                    gastado[cat] = (gastado[cat] ?? 0) + (data['monto'] ?? 0).toDouble();
                  }
                  
                  return ListView.builder(
                    itemCount: _categoriasGasto.length,
                    itemBuilder: (context, index) {
                      final cat = _categoriasGasto[index];
                      final gastadoCat = gastado[cat['nombre']] ?? 0.0;
                      final presupuesto = cat['presupuesto'] as double;
                      final porcentaje = (gastadoCat / presupuesto * 100).clamp(0, 100);
                      final excedido = gastadoCat > presupuesto;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Icon(cat['icon'] as IconData, color: const Color(0xFF0066FF)), const SizedBox(width: 8), Expanded(child: Text(cat['nombre'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), Text('\$${gastadoCat.toStringAsFixed(0)} / \$${presupuesto.toStringAsFixed(0)}', style: TextStyle(color: excedido ? Colors.red : Colors.green, fontSize: 12))]),
                            const SizedBox(height: 8),
                            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: porcentaje / 100, backgroundColor: Colors.grey.shade800, valueColor: AlwaysStoppedAnimation<Color>(excedido ? Colors.red : const Color(0xFF0066FF)), minHeight: 8)),
                            const SizedBox(height: 4),
                            Text('${porcentaje.toStringAsFixed(1)}% utilizado', style: TextStyle(color: excedido ? Colors.red : Colors.grey, fontSize: 11)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMetas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.flag, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('🏆 Metas de Ahorro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
            const SizedBox(height: 20),
            const Text('Próximamente: Configura metas de ahorro y sigue tu progreso.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _mostrarRecurrentes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.repeat, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('🔄 Transacciones Recurrentes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
            const SizedBox(height: 20),
            const Text('Próximamente: Configura pagos automáticos mensuales (renta, servicios, etc.).', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _mostrarCalendario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.calendar_month, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('📅 Calendario', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
            const SizedBox(height: 20),
            const Text('Próximamente: Vista calendario de todas tus transacciones.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _exportarCSV() async {
    try {
      final snapshot = await _firestore.collection('transacciones').orderBy('created_at', descending: true).get();
      final docs = snapshot.docs;
      
      final buffer = StringBuffer();
      buffer.writeln('Fecha,Tipo,Concepto,Categoría,Cuenta,Monto,Método de Pago,Referencia,Descripción');
      
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        buffer.writeln('${data['fecha'] ?? ''},${data['tipo'] ?? ''},"${data['concepto'] ?? ''}","${data['categoria'] ?? ''}","${data['cuenta'] ?? ''}",${data['monto'] ?? 0},"${data['metodo_pago'] ?? ''}","${data['referencia'] ?? ''}","${data['descripcion'] ?? ''}"');
      }
      
      final bytes = utf8.encode(buffer.toString());
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute("download", "finanzas_${DateTime.now().millisecondsSinceEpoch}.csv")..click();
      html.Url.revokeObjectUrl(url);
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ CSV exportado exitosamente'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _mostrarFormularioTransaccion({Map<String, dynamic>? transaccion, String? docId}) {
    final conceptoCtrl = TextEditingController(text: transaccion?['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: transaccion?['monto']?.toString() ?? '0');
    final categoriaCtrl = TextEditingController(text: transaccion?['categoria'] ?? 'General');
    final fechaCtrl = TextEditingController(text: transaccion?['fecha'] ?? DateTime.now().toIso8601String().split('T')[0]);
    final descripcionCtrl = TextEditingController(text: transaccion?['descripcion'] ?? '');
    final metodoPagoCtrl = TextEditingController(text: transaccion?['metodo_pago'] ?? 'Efectivo');
    final referenciaCtrl = TextEditingController(text: transaccion?['referencia'] ?? '');
    String tipo = transaccion?['tipo'] ?? 'Ingreso';
    String cuenta = transaccion?['cuenta'] ?? 'Efectivo';

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
                Row(children: [Icon(transaccion == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF0066FF), size: 28), const SizedBox(width: 12), Expanded(child: Text(transaccion == null ? 'Nueva Transacción' : 'Editar Transacción', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
                const SizedBox(height: 20),
                _buildSeccion('💰 Información'),
                _buildCampo('Concepto *', conceptoCtrl, icon: Icons.description),
                _buildCampo('Monto', montoCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
                const SizedBox(height: 12),
                _buildSeccion(' Clasificación'),
                Row(children: [Expanded(child: RadioListTile<String>(title: const Text('Ingreso', style: TextStyle(color: Colors.white)), value: 'Ingreso', groupValue: tipo, activeColor: Colors.green, onChanged: (v) => setSheetState(() => tipo = v!))), Expanded(child: RadioListTile<String>(title: const Text('Gasto', style: TextStyle(color: Colors.white)), value: 'Gasto', groupValue: tipo, activeColor: Colors.red, onChanged: (v) => setSheetState(() => tipo = v!)))]),
                _buildCampo('Categoría', categoriaCtrl, icon: Icons.category),
                _buildCampo('Fecha', fechaCtrl, icon: Icons.calendar_today),
                const SizedBox(height: 12),
                _buildSeccion(' Cuenta'),
                DropdownButtonFormField<String>(value: cuenta, decoration: InputDecoration(labelText: 'Cuenta', labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setSheetState(() => cuenta = v!)),
                const SizedBox(height: 12),
                _buildSeccion('💳 Método de Pago'),
                _buildCampo('Método de Pago', metodoPagoCtrl, icon: Icons.credit_card),
                _buildCampo('Referencia / Folio', referenciaCtrl, icon: Icons.receipt),
                const SizedBox(height: 12),
                _buildSeccion('📝 Detalles'),
                _buildCampoMultilinea('Descripción', descripcionCtrl),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: () => _guardarTransaccion(ctx, conceptoCtrl, montoCtrl, categoriaCtrl, fechaCtrl, descripcionCtrl, metodoPagoCtrl, referenciaCtrl, tipo, cuenta, docId), icon: const Icon(Icons.save, color: Colors.white), label: Text(transaccion == null ? 'Crear Transacción' : 'Guardar Cambios', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(titulo, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)));
  }

  Widget _buildCampo(String label, TextEditingController ctrl, {IconData? icon, TextInputType? tipo}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, keyboardType: tipo, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0066FF)) : null, filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Widget _buildCampoMultilinea(String label, TextEditingController ctrl) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.notes, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))));
  }

  Future<void> _guardarTransaccion(BuildContext ctx, TextEditingController concepto, TextEditingController monto, TextEditingController categoria, TextEditingController fecha, TextEditingController descripcion, TextEditingController metodoPago, TextEditingController referencia, String tipo, String cuenta, String? docId) async {
    if (concepto.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El concepto es obligatorio'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final data = {'concepto': concepto.text.trim(), 'monto': double.tryParse(monto.text) ?? 0, 'categoria': categoria.text.trim(), 'fecha': fecha.text.trim(), 'descripcion': descripcion.text.trim(), 'metodo_pago': metodoPago.text.trim(), 'referencia': referencia.text.trim(), 'tipo': tipo, 'cuenta': cuenta};
      if (docId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('transacciones').add(data);
      } else {
        await _firestore.collection('transacciones').doc(docId).update(data);
      }
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? '✅ Transacción creada' : '✅ Transacción actualizada'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminarTransaccion(String id, String concepto) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Eliminar Transacción', style: TextStyle(color: Colors.white)), content: Text('¿Eliminar "$concepto"?', style: const TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red)))]));
    if (confirm == true) {
      await _firestore.collection('transacciones').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }
}