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
  String? _cuentaSeleccionada;
  List<Map<String, dynamic>> _presupuestosPersonalizados = [];
  Set<String> _tagsDisponibles = {'#urgente', '#deducible', '#cliente', '#personal', '#negocio', '#importante', '#revisar'};

  final List<Map<String, dynamic>> _cuentas = [
    {'nombre': 'Efectivo', 'icon': Icons.money, 'color': Colors.green},
    {'nombre': 'Banco', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'nombre': 'Tarjeta', 'icon': Icons.credit_card, 'color': Colors.orange},
    {'nombre': 'Inversión', 'icon': Icons.trending_up, 'color': Colors.purple},
  ];

  final List<String> _negocios = ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'];

  final List<Map<String, dynamic>> _categoriasGasto = [
    {'nombre': 'Préstamos', 'icon': Icons.account_balance_wallet},
    {'nombre': 'Personal', 'icon': Icons.people},
    {'nombre': 'Adair', 'icon': Icons.business},
    {'nombre': 'Capacitación', 'icon': Icons.school},
    {'nombre': 'Deudas', 'icon': Icons.warning},
    {'nombre': 'Mobiliario', 'icon': Icons.chair},
    {'nombre': 'Alquiler', 'icon': Icons.home},
    {'nombre': 'Transporte', 'icon': Icons.directions_car},
    {'nombre': 'Insumos de Oficina', 'icon': Icons.print},
    {'nombre': 'Recarga', 'icon': Icons.phone_android},
    {'nombre': 'Uber', 'icon': Icons.local_taxi},
    {'nombre': 'Propina', 'icon': Icons.card_giftcard},
    {'nombre': 'Otros', 'icon': Icons.more_horiz},
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
    _tabController = TabController(length: 10, vsync: this);
    _cargarPresupuestosPersonalizados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarPresupuestosPersonalizados() async {
    try {
      final snap = await _firestore.collection('presupuestos_personalizados').get();
      setState(() {
        _presupuestosPersonalizados = snap.docs.map((doc) {
          final d = doc.data();
          return {
            'id': doc.id,
            'nombre': d['nombre'] ?? '',
            'icon': d['icon'] ?? 'category',
            'presupuesto': (d['presupuesto'] ?? 0).toDouble(),
            'gastado': (d['gastado'] ?? 0).toDouble(),
            'cuenta': d['cuenta'] ?? 'Efectivo',
            'subcuenta': d['subcuenta'] ?? 'Proyectos',
            'aplicado': d['aplicado'] ?? false,
          };
        }).toList();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => _mostrarFormularioTransaccion()),
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: () => _mostrarTransferenciaEntreCuentas()),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: () => _cargarDatosEjemplo()),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'exportar') _exportarCSV();
              else if (v == 'calendario') _mostrarCalendario();
              else if (v == 'hoy') _mostrarVistaHoy();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hoy', child: Row(children: [Icon(Icons.today), SizedBox(width: 8), Text('Vista de Hoy')])),
              const PopupMenuItem(value: 'calendario', child: Row(children: [Icon(Icons.calendar_month), SizedBox(width: 8), Text('Calendario')])),
              const PopupMenuItem(value: 'exportar', child: Row(children: [Icon(Icons.download), SizedBox(width: 8), Text('Exportar CSV')])),
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
            Tab(icon: Icon(Icons.dashboard_customize), text: 'Dashboard'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ingresos'),
            Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'),
            Tab(icon: Icon(Icons.credit_card), text: 'Cuentas'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            Tab(icon: Icon(Icons.show_chart), text: 'Reportes'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Presupuestos'),
            Tab(icon: Icon(Icons.flag), text: 'Metas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVistaHoy(),
          _buildResumen(),
          _buildDashboardKPIs(),
          _buildListaTransacciones('Ingreso'),
          _buildListaTransacciones('Gasto'),
          _buildCuentas(),
          _buildCalendario(),
          _buildReportes(),
          _buildPresupuestos(),
          _buildMetas(),
        ],
      ),
    );
  }

  Widget _buildDashboardKPIs() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Dashboard Ejecutivo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                double ingresos = 0, gastos = 0;
                int numTransacciones = 0;
                Map<String, double> porNegocio = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final monto = (data['monto'] ?? 0).toDouble();
                  final tipo = data['tipo'] ?? '';
                  final negocio = data['negocio'] ?? 'Otros';

                  if (tipo == 'Ingreso') ingresos += monto;
                  if (tipo == 'Gasto') gastos += monto;
                  numTransacciones++;

                  porNegocio[negocio] = (porNegocio[negocio] ?? 0) + (tipo == 'Ingreso' ? monto : -monto);
                }

                final margenGanancia = ingresos > 0 ? ((ingresos - gastos) / ingresos * 100) : 0;
                final ticketPromedio = numTransacciones > 0 ? ingresos / numTransacciones : 0;
                final flujoNeto = ingresos - gastos;

                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        _buildKPICard('Ingresos', '\$${ingresos.toStringAsFixed(0)}', Icons.trending_up, Colors.green),
                        _buildKPICard('Gastos', '\$${gastos.toStringAsFixed(0)}', Icons.trending_down, Colors.red),
                        _buildKPICard('Flujo Neto', '\$${flujoNeto.toStringAsFixed(0)}', Icons.account_balance_wallet, flujoNeto >= 0 ? Colors.green : Colors.red),
                        _buildKPICard('Margen', '${margenGanancia.toStringAsFixed(1)}%', Icons.percent, Colors.blue),
                        _buildKPICard('Ticket Promedio', '\$${ticketPromedio.toStringAsFixed(0)}', Icons.receipt_long, Colors.orange),
                        _buildKPICard('Transacciones', '$numTransacciones', Icons.list_alt, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('📈 Por Negocio', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...porNegocio.entries.map((e) => _buildNegocioRow(e.key, e.value, ingresos)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 9)),
                const SizedBox(height: 2),
                Text(valor, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegocioRow(String negocio, double balance, double totalIngresos) {
    final porcentaje = totalIngresos > 0 ? (balance / totalIngresos * 100).abs() : 0;
    final color = balance >= 0 ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Expanded(child: Text(negocio, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Text('\$${balance.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 6),
          Text('${porcentaje.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildVistaHoy() {
    final hoy = DateTime.now();
    final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['fecha'] == fechaHoy).toList();
          if (docs.isEmpty) return const Center(child: Text('No hay transacciones hoy', style: TextStyle(color: Colors.grey)));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final esIngreso = data['tipo'] == 'Ingreso';
              return ListTile(
                leading: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red),
                title: Text(data['concepto'] ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text('${data['categoria']} • ${data['cuenta']}', style: const TextStyle(color: Colors.grey)),
                trailing: Text('\$${data['monto']}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Balance Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('transacciones').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('\$0', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
                      double ingresos = 0, gastos = 0;
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final monto = (data['monto'] ?? 0).toDouble();
                        if (data['tipo'] == 'Ingreso') ingresos += monto;
                        if (data['tipo'] == 'Gasto') gastos += monto;
                      }
                      return Text('\$${(ingresos - gastos).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTarjetaResumen('Ingresos', Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildTarjetaResumen('Gastos', Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaResumen(String tipo, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(tipo, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('transacciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('\$0', style: TextStyle(color: Colors.white, fontSize: 20));
              double total = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['tipo'] == tipo) total += (data['monto'] ?? 0).toDouble();
              }
              return Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListaTransacciones(String tipo) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['tipo'] == tipo && (_search.isEmpty || (data['concepto'] ?? '').toLowerCase().contains(_search));
                }).toList();
                
                if (docs.isEmpty) return const Center(child: Text('No hay transacciones', style: TextStyle(color: Colors.grey)));
                
                final total = docs.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());
                
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total:', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)), Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: (tipo == 'Ingreso' ? Colors.green : Colors.red).withOpacity(0.2), child: Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: tipo == 'Ingreso' ? Colors.green : Colors.red)),
                            title: Text(data['concepto'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('${data['categoria']} • ${data['cuenta']} • ${data['fecha']}', style: const TextStyle(color: Colors.grey)),
                            trailing: Text('\$${data['monto']}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuentas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _cuentas.length,
        itemBuilder: (context, index) {
          final cuenta = _cuentas[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: (cuenta['color'] as Color).withOpacity(0.2), child: Icon(cuenta['icon'] as IconData, color: cuenta['color'] as Color)),
            title: Text(cuenta['nombre'] as String, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildCalendario() {
    return const Center(child: Text('Calendario - Próximamente', style: TextStyle(color: Colors.grey)));
  }

  Widget _buildReportes() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Reportes - Próximamente', style: TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildPresupuestos() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _mostrarDialogoPresupuesto(),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Presupuesto'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _presupuestosPersonalizados.length,
              itemBuilder: (context, index) {
                final p = _presupuestosPersonalizados[index];
                return ListTile(
                  title: Text(p['nombre'], style: const TextStyle(color: Colors.white)),
                  subtitle: Text('\$${p['gastado']} / \$${p['presupuesto']}', style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarPresupuesto(p['id'])),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetas() {
    return const Center(child: Text('Metas - Próximamente', style: TextStyle(color: Colors.grey)));
  }

  void _mostrarFormularioTransaccion() {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    String tipo = 'Ingreso';
    String categoria = 'General';
    String cuenta = 'Efectivo';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Concepto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: RadioListTile(title: const Text('Ingreso', style: TextStyle(color: Colors.white)), value: 'Ingreso', groupValue: tipo, onChanged: (v) => setState(() => tipo = v!))), Expanded(child: RadioListTile(title: const Text('Gasto', style: TextStyle(color: Colors.white)), value: 'Gasto', groupValue: tipo, onChanged: (v) => setState(() => tipo = v!)))]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: categoria, decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: (tipo == 'Ingreso' ? _categoriasIngreso : _categoriasGasto).map((c) => DropdownMenuItem(value: c['nombre'] as String, child: Text(c['nombre'] as String))).toList(), onChanged: (v) => categoria = v!),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: cuenta, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => cuenta = v!)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
              if (conceptoCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
              await _firestore.collection('transacciones').add({
                'concepto': conceptoCtrl.text,
                'monto': double.tryParse(montoCtrl.text) ?? 0,
                'categoria': categoria,
                'tipo': tipo,
                'cuenta': cuenta,
                'subcuenta': 'Minerales',
                'negocio': 'Minerales',
                'fecha': DateTime.now().toIso8601String().split('T')[0],
                'reconciliada': false,
                'created_at': FieldValue.serverTimestamp(),
              });
              Navigator.pop(ctx);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Transacción guardada'), backgroundColor: Colors.green));
            }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Guardar', style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  void _mostrarTransferenciaEntreCuentas() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transferencias - Próximamente')));
  }

  void _cargarDatosEjemplo() async {
    final ejemplos = [
      {'concepto': 'Comisión venta', 'monto': 25000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso', 'cuenta': 'Banco', 'subcuenta': 'Proyectos', 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'reconciliada': true},
      {'concepto': 'Pago préstamo', 'monto': 8500.0, 'categoria': 'Préstamos', 'tipo': 'Gasto', 'cuenta': 'Banco', 'subcuenta': 'Minerales', 'negocio': 'Minerales', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'reconciliada': true},
    ];
    for (var t in ejemplos) {
      await _firestore.collection('transacciones').add({...t, 'created_at': FieldValue.serverTimestamp()});
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Datos de ejemplo cargados'), backgroundColor: Colors.green));
  }

  void _exportarCSV() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportando...')));
  }

  void _mostrarCalendario() {
    _tabController.animateTo(6);
  }

  void _mostrarVistaHoy() {
    _tabController.animateTo(0);
  }

  void _mostrarDialogoPresupuesto() {
    final nombreCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Nuevo Presupuesto', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()))]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () async {
            if (nombreCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
            await _firestore.collection('presupuestos_personalizados').add({'nombre': nombreCtrl.text, 'presupuesto': double.tryParse(montoCtrl.text) ?? 0, 'gastado': 0, 'cuenta': 'Efectivo', 'subcuenta': 'Proyectos', 'aplicado': false, 'created_at': FieldValue.serverTimestamp()});
            Navigator.pop(ctx);
            _cargarPresupuestosPersonalizados();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Presupuesto creado'), backgroundColor: Colors.green));
          }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)), child: const Text('Crear', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Future<void> _eliminarPresupuesto(String id) async {
    await _firestore.collection('presupuestos_personalizados').doc(id).delete();
    _cargarPresupuestosPersonalizados();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('️ Eliminado'), backgroundColor: Colors.red));
  }
}