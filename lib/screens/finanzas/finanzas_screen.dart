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
  String _negocioFiltro = 'Todos';
  bool _soloPendientes = false;
  bool _soloReconciliadas = false;
  int _vistaActual = 0;
  String? _cuentaSeleccionada; // Para mostrar subcuentas
  List<DocumentSnapshot> _transaccionesDesglose = []; // Para el desglose de gráfica

  final List<Map<String, dynamic>> _cuentas = [
    {'nombre': 'Efectivo', 'icon': Icons.money, 'color': Colors.green},
    {'nombre': 'Banco', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'nombre': 'Tarjeta', 'icon': Icons.credit_card, 'color': Colors.orange},
    {'nombre': 'Inversión', 'icon': Icons.trending_up, 'color': Colors.purple},
  ];

  final List<String> _negocios = ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'];

  final List<Map<String, dynamic>> _categoriasGasto = [
    {'nombre': 'Préstamos', 'icon': Icons.account_balance_wallet, 'presupuesto': 30000.0},
    {'nombre': 'Personal', 'icon': Icons.people, 'presupuesto': 20000.0},
    {'nombre': 'Adair', 'icon': Icons.business, 'presupuesto': 10000.0},
    {'nombre': 'Capacitación', 'icon': Icons.school, 'presupuesto': 5000.0},
    {'nombre': 'Deudas', 'icon': Icons.warning, 'presupuesto': 5000.0},
    {'nombre': 'Mobiliario', 'icon': Icons.chair, 'presupuesto': 3000.0},
    {'nombre': 'Alquiler', 'icon': Icons.home, 'presupuesto': 2000.0},
    {'nombre': 'Transporte', 'icon': Icons.directions_car, 'presupuesto': 2000.0},
    {'nombre': 'Insumos de Oficina', 'icon': Icons.print, 'presupuesto': 1000.0},
    {'nombre': 'Recarga', 'icon': Icons.phone_android, 'presupuesto': 500.0},
    {'nombre': 'Uber', 'icon': Icons.local_taxi, 'presupuesto': 500.0},
    {'nombre': 'Propina', 'icon': Icons.card_giftcard, 'presupuesto': 200.0},
    {'nombre': 'Otros', 'icon': Icons.more_horiz, 'presupuesto': 1000.0},
  ];

  final List<Map<String, dynamic>> _categoriasIngreso = [
    {'nombre': 'Proyecto', 'icon': Icons.business_center},
    {'nombre': 'Deslinde', 'icon': Icons.map},
    {'nombre': 'Comisiones', 'icon': Icons.handshake},
    {'nombre': 'Renta', 'icon': Icons.home},
    {'nombre': 'Servicios', 'icon': Icons.build},
    {'nombre': 'Otros', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
          Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _mostrarFormularioTransaccion()),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: () => _cargarDatosEjemplo(), tooltip: 'Cargar datos ejemplo'),
          IconButton(icon: const Icon(Icons.upload_file, color: Colors.white), onPressed: () => _importarCSV(), tooltip: 'Importar CSV'),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'exportar') _exportarCSV();
              if (value == 'presupuestos') _mostrarPresupuestosEditables();
              if (value == 'metas') _mostrarMetasEditables();
              if (value == 'recurrentes') _mostrarRecurrentesEditables();
              if (value == 'calendario') _mostrarCalendario();
              if (value == 'hoy') _mostrarVistaHoy();
              if (value == 'reconciliar') _mostrarReconciliacionEditable();
              if (value == 'informes') _mostrarInformesEditables();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hoy', child: Row(children: [Icon(Icons.today, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Vista de Hoy')])),
              const PopupMenuItem(value: 'calendario', child: Row(children: [Icon(Icons.calendar_month, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Calendario')])),
              const PopupMenuItem(value: 'presupuestos', child: Row(children: [Icon(Icons.pie_chart, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Presupuestos (Editable)')])),
              const PopupMenuItem(value: 'metas', child: Row(children: [Icon(Icons.flag, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Metas (Editable)')])),
              const PopupMenuItem(value: 'recurrentes', child: Row(children: [Icon(Icons.repeat, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Recurrentes (Editable)')])),
              const PopupMenuItem(value: 'reconciliar', child: Row(children: [Icon(Icons.check_circle, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Reconciliar (Editable)')])),
              const PopupMenuItem(value: 'informes', child: Row(children: [Icon(Icons.analytics, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Informes (Editable)')])),
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
            Tab(icon: Icon(Icons.today), text: 'Hoy'),
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ingresos'),
            Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'),
            Tab(icon: Icon(Icons.credit_card), text: 'Cuentas'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            Tab(icon: Icon(Icons.show_chart), text: 'Reportes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVistaHoy(),
          _buildResumen(),
          _buildListaTransacciones('Ingreso'),
          _buildListaTransacciones('Gasto'),
          _buildCuentas(),
          _buildCalendarioCompleto(),
          _buildReportes(),
        ],
      ),
    );
  }

  // ============================================
  // CUENTAS CON SUBCUENTAS POR NEGOCIO
  // ============================================
  Widget _buildCuentas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('💳 Mis Cuentas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              if (_cuentaSeleccionada != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _cuentaSeleccionada = null),
                  tooltip: 'Volver',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _cuentaSeleccionada == null
                ? _buildListaCuentasPrincipales()
                : _buildSubcuentasPorNegocio(_cuentaSeleccionada!),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCuentasPrincipales() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: _cuentas.length,
          itemBuilder: (context, index) {
            final cuenta = _cuentas[index];
            double balance = 0;
            int numTransacciones = 0;
            
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['cuenta'] == cuenta['nombre']) {
                final monto = (data['monto'] ?? 0).toDouble();
                if (data['tipo'] == 'Ingreso') {
                  balance += monto;
                } else {
                  balance -= monto;
                }
                numTransacciones++;
              }
            }
            
            return GestureDetector(
              onTap: () => setState(() => _cuentaSeleccionada = cuenta['nombre']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF222222)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (cuenta['color'] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cuenta['icon'] as IconData, color: cuenta['color'] as Color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cuenta['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 14)),
                          Text('$numTransacciones transacciones • Toca para ver detalle', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubcuentasPorNegocio(String cuentaNombre) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: _negocios.length,
          itemBuilder: (context, index) {
            final negocio = _negocios[index];
            double balance = 0;
            int numTransacciones = 0;
            
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['cuenta'] == cuentaNombre && data['negocio'] == negocio) {
                final monto = (data['monto'] ?? 0).toDouble();
                if (data['tipo'] == 'Ingreso') {
                  balance += monto;
                } else {
                  balance -= monto;
                }
                numTransacciones++;
              }
            }
            
            return GestureDetector(
              onTap: () => _mostrarDesgloseTransacciones(cuentaNombre, negocio),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF222222)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.business, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(negocio, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 14)),
                          Text('$numTransacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDesgloseTransacciones(String cuenta, String negocio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF0066FF), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$cuenta - $negocio',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones')
                    .where('cuenta', isEqualTo: cuenta)
                    .where('negocio', isEqualTo: negocio)
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  
                  if (docs.isEmpty) {
                    return const Center(child: Text('No hay transacciones', style: TextStyle(color: Colors.grey)));
                  }
                  
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final esIngreso = data['tipo'] == 'Ingreso';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('${data['categoria'] ?? ''} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              '${esIngreso ? "+" : "-"}\$${(data['monto'] ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                            ),
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

  // ============================================
  // GRÁFICA CIRCULAR INTERACTIVA CON DESGLOSE
  // ============================================
  Widget _buildGraficaCircularMoneyPro() {
    final colors = [Colors.green, Colors.teal, Colors.amber, Colors.red.shade700, Colors.red, Colors.cyan, Colors.blue.shade300, Colors.indigo, Colors.lightGreen, Colors.teal.shade700, Colors.amber.shade700, Colors.red.shade900];
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        double totalIngresos = 0, totalGastos = 0;
        Map<String, double> ingresosPorCategoria = {}, gastosPorCategoria = {}, porCuenta = {};
        
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final monto = (data['monto'] ?? 0).toDouble();
          final tipo = data['tipo'] ?? '';
          final categoria = data['categoria'] ?? 'Otros';
          final cuenta = data['cuenta'] ?? 'Efectivo';
          
          if (tipo == 'Ingreso') {
            totalIngresos += monto;
            ingresosPorCategoria[categoria] = (ingresosPorCategoria[categoria] ?? 0) + monto;
            porCuenta[cuenta] = (porCuenta[cuenta] ?? 0) + monto;
          } else if (tipo == 'Gasto') {
            totalGastos += monto;
            gastosPorCategoria[categoria] = (gastosPorCategoria[categoria] ?? 0) + monto;
            porCuenta[cuenta] = (porCuenta[cuenta] ?? 0) - monto;
          }
        }
        
        final beneficio = totalIngresos - totalGastos;
        final totalActivos = porCuenta.values.fold(0.0, (sum, v) => sum + (v > 0 ? v : 0));
        
        List<PieChartSectionData> sections;
        switch (_vistaActual) {
          case 0:
            sections = [
              PieChartSectionData(
                value: totalIngresos,
                title: totalIngresos + totalGastos > 0 ? '${((totalIngresos / (totalIngresos + totalGastos)) * 100).toStringAsFixed(0)}%' : '0%',
                color: Colors.green,
                radius: 110,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              PieChartSectionData(
                value: totalGastos,
                title: totalIngresos + totalGastos > 0 ? '${((totalGastos / (totalIngresos + totalGastos)) * 100).toStringAsFixed(0)}%' : '0%',
                color: Colors.red,
                radius: 110,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ];
            break;
          case 1:
            sections = ingresosPorCategoria.entries.map((e) {
              final idx = ingresosPorCategoria.keys.toList().indexOf(e.key);
              return PieChartSectionData(
                value: e.value,
                title: totalIngresos > 0 ? '${((e.value / totalIngresos) * 100).toStringAsFixed(0)}%' : '0%',
                color: colors[idx % colors.length],
                radius: 110,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              );
            }).toList();
            break;
          case 2:
            sections = gastosPorCategoria.entries.map((e) {
              final idx = gastosPorCategoria.keys.toList().indexOf(e.key);
              return PieChartSectionData(
                value: e.value,
                title: totalGastos > 0 ? '${((e.value / totalGastos) * 100).toStringAsFixed(0)}%' : '0%',
                color: colors[idx % colors.length],
                radius: 110,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              );
            }).toList();
            break;
          case 3:
            sections = [PieChartSectionData(value: totalActivos, title: '100%', color: Colors.green, radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))];
            break;
          case 4:
            sections = porCuenta.entries.map((e) {
              final idx = porCuenta.keys.toList().indexOf(e.key);
              return PieChartSectionData(
                value: e.value.abs(),
                title: totalActivos > 0 ? '${((e.value.abs() / totalActivos) * 100).toStringAsFixed(0)}%' : '0%',
                color: colors[idx % colors.length],
                radius: 110,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              );
            }).toList();
            break;
          default:
            sections = [];
        }
        
        List<Map<String, dynamic>> items;
        Map<String, double> datosDesglose;
        String tituloDesglose;
        
        switch (_vistaActual) {
          case 0:
            items = [
              {'label': 'Ingresos', 'value': '\$${totalIngresos.toStringAsFixed(2)}', 'color': Colors.green},
              {'label': 'Gastos', 'value': '\$${totalGastos.toStringAsFixed(2)}', 'color': Colors.red},
            ];
            datosDesglose = {'Ingresos': totalIngresos, 'Gastos': totalGastos};
            tituloDesglose = 'Ingresos vs Gastos';
            break;
          case 1:
            items = ingresosPorCategoria.entries.map((e) {
              final idx = ingresosPorCategoria.keys.toList().indexOf(e.key);
              return {'label': e.key.toUpperCase(), 'value': '\$${e.value.toStringAsFixed(2)}', 'color': colors[idx % colors.length]};
            }).toList();
            datosDesglose = ingresosPorCategoria;
            tituloDesglose = 'Ingresos por Categoría';
            break;
          case 2:
            items = gastosPorCategoria.entries.map((e) {
              final idx = gastosPorCategoria.keys.toList().indexOf(e.key);
              return {'label': e.key.toUpperCase(), 'value': '\$${e.value.toStringAsFixed(2)}', 'color': colors[idx % colors.length]};
            }).toList();
            datosDesglose = gastosPorCategoria;
            tituloDesglose = 'Gastos por Categoría';
            break;
          case 3:
            items = [{'label': 'Total Activos', 'value': '\$${totalActivos.toStringAsFixed(2)}', 'color': Colors.green}];
            datosDesglose = {'Activos': totalActivos};
            tituloDesglose = 'Activos';
            break;
          case 4:
            items = porCuenta.entries.map((e) {
              final idx = porCuenta.keys.toList().indexOf(e.key);
              return {'label': e.key.toUpperCase(), 'value': '\$${e.value.toStringAsFixed(2)}', 'color': colors[idx % colors.length]};
            }).toList();
            datosDesglose = porCuenta.map((k, v) => MapEntry(k, v.abs()));
            tituloDesglose = 'Cuentas';
            break;
          default:
            items = [];
            datosDesglose = {};
            tituloDesglose = '';
        }
        
        final titulos = ['Ingresos vs Gastos', 'Ingresos', 'Gastos', 'Activos', 'Cuentas'];
        final labelsCentro = ['BENEFICIO', 'INGRESOS', 'GASTOS', 'ACTIVOS', 'CUENTAS'];
        String totalCentro;
        switch (_vistaActual) {
          case 0: totalCentro = '\$${beneficio.toStringAsFixed(2)}'; break;
          case 1: totalCentro = '\$${totalIngresos.toStringAsFixed(2)}'; break;
          case 2: totalCentro = '\$${totalGastos.toStringAsFixed(2)}'; break;
          case 3: totalCentro = '\$${totalActivos.toStringAsFixed(2)}'; break;
          case 4: totalCentro = '\$${totalActivos.toStringAsFixed(2)}'; break;
          default: totalCentro = '\$0';
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => setState(() => _vistaActual = (_vistaActual - 1 + 5) % 5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                    child: Text(titulos[_vistaActual], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => setState(() => _vistaActual = (_vistaActual + 1) % 5)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    sections.isEmpty
                        ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)))
                        : PieChart(
                            PieChartData(
                              sections: sections,
                              sectionsSpace: 2,
                              centerSpaceRadius: 80,
                              startDegreeOffset: 270,
                              touchingCallback: (pieTouch) {
                                if (pieTouch != null && pieTouch.touchedSection != null) {
                                  final touchedIndex = pieTouch.touchedSection!.touchedSectionIndex;
                                  if (touchedIndex >= 0 && touchedIndex < items.length) {
                                    _mostrarDesgloseCategoria(items[touchedIndex]['label'], datosDesglose[items[touchedIndex]['label']] ?? 0, tituloDesglose);
                                  }
                                }
                              },
                            ),
                          ),
                    GestureDetector(
                      onTap: () => setState(() => _vistaActual = (_vistaActual + 1) % 5),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade700, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(totalCentro, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(labelsCentro[_vistaActual], style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            const Icon(Icons.touch_app, color: Colors.grey, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => _mostrarDesgloseCategoria(item['label'], datosDesglose[item['label']] ?? 0, tituloDesglose),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(width: 14, height: 14, decoration: BoxDecoration(color: item['color'] as Color, borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item['label'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
                            Text(item['value'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDesgloseCategoria(String categoria, double monto, String titulo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Color(0xFF0066FF), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$titulo - $categoria',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total: \$${monto.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Transacciones detalladas:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _vistaActual == 0
                    ? _firestore.collection('transacciones')
                        .where('tipo', isEqualTo: categoria == 'Ingresos' ? 'Ingreso' : 'Gasto')
                        .orderBy('created_at', descending: true)
                        .snapshots()
                    : _firestore.collection('transacciones')
                        .where('categoria', isEqualTo: categoria)
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  
                  if (docs.isEmpty) {
                    return const Center(child: Text('No hay transacciones', style: TextStyle(color: Colors.grey)));
                  }
                  
                  // Calcular total para porcentaje
                  double totalCategoria = 0;
                  for (var doc in docs) {
                    totalCategoria += (doc.data() as Map<String, dynamic>)['monto'] ?? 0;
                  }
                  
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final esIngreso = data['tipo'] == 'Ingreso';
                      final montoTransaccion = (data['monto'] ?? 0).toDouble();
                      final porcentaje = totalCategoria > 0 ? (montoTransaccion / totalCategoria * 100) : 0;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text('${data['categoria'] ?? ''} • ${data['cuenta'] ?? ''} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${montoTransaccion.toStringAsFixed(2)}',
                                      style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${porcentaje.toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (porcentaje > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: LinearProgressIndicator(
                                  value: porcentaje / 100,
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(esIngreso ? Colors.green : Colors.red),
                                  minHeight: 4,
                                ),
                              ),
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

  // ... (resto de los métodos existentes como _buildVistaHoy, _buildResumen, etc. se mantienen igual)
  
  // Métodos placeholder para no romper el código - mantener los existentes
  Widget _buildVistaHoy() { return Container(); }
  Widget _buildResumen() { return Container(); }
  Widget _buildListaTransacciones(String tipo) { return Container(); }
  Future<void> _cargarDatosEjemplo() async {}
  Future<void> _aprobarTransaccion(String id) async {}
  Widget _buildMiniCard(String titulo, IconData icon, Color color) { return Container(); }
  Widget _buildTarjetaBalance() { return Container(); }
  Widget _buildTarjetaResumen(String titulo, Color color, IconData icon) { return Container(); }
  Widget _buildGraficoLineas() { return Container(); }
  Widget _buildUltimasTransacciones() { return Container(); }
  Future<void> _toggleReconciliar(String id, bool actual) async {}
  Future<void> _dividirTransaccion(String id, Map<String, dynamic> data) async {}
  Future<void> _duplicarTransaccion(Map<String, dynamic> data) async {}
  Widget _buildCalendarioCompleto() { return Container(); }
  Widget _buildFlujoDeCaja() { return Container(); }
  Widget _buildGraficoBarras() { return Container(); }
  void _mostrarPresupuestosEditables() {}
  Future<void> _editarPresupuesto(BuildContext ctx, String categoria, double actual) async {}
  void _mostrarMetasEditables() {}
  Future<void> _editarMeta(String id, String nombre, double objetivo, double actual) async {}
  void _mostrarRecurrentesEditables() {}
  Future<void> _editarRecurrente(String id, Map<String, dynamic> data) async {}
  void _mostrarVistaHoy() {}
  void _mostrarReconciliacionEditable() {}
  void _mostrarInformesEditables() {}
  Widget _buildInformeItemEditable(String titulo, String descripcion, IconData icon, VoidCallback onTap) { return Container(); }
  void _verInformeIngresosGastos(BuildContext ctx) {}
  void _verInformeFlujoCaja(BuildContext ctx) {}
  void _verInformeTransacciones(BuildContext ctx) {}
  void _verInformeActivos(BuildContext ctx) {}
  void _verInformeProyeccion(BuildContext ctx) {}
  void _verInformeTendencia(BuildContext ctx) {}
  void _mostrarCalendario() {}
  Future<void> _importarCSV() async {}
  Future<void> _exportarCSV() async {}
  void _mostrarFormularioTransaccion({Map<String, dynamic>? transaccion, String? docId}) {}
  Widget _buildDropdownCategoria(TextEditingController ctrl, String tipo) { return Container(); }
  Widget _buildSeccion(String titulo) { return Container(); }
  Widget _buildCampo(String label, TextEditingController ctrl, {IconData? icon, TextInputType? tipo}) { return Container(); }
  Widget _buildCampoMultilinea(String label, TextEditingController ctrl) { return Container(); }
  Future<void> _guardarTransaccion(BuildContext ctx, TextEditingController concepto, TextEditingController monto, TextEditingController categoria, TextEditingController subcategoria, TextEditingController fecha, TextEditingController descripcion, TextEditingController metodoPago, TextEditingController referencia, TextEditingController acreedor, TextEditingController beneficiario, TextEditingController numCheque, String tipo, String cuenta, String negocio, bool reconciliada, String? docId) async {}
  Future<void> _eliminarTransaccion(String id, String concepto) async {}
}