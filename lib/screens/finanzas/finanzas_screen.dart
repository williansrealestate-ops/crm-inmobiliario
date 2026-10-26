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
  String _search = '', _categoriaFiltro = 'Todas', _cuentaFiltro = 'Todas', _negocioFiltro = 'Todos';
  bool _soloPendientes = false, _soloReconciliadas = false;
  int _vistaActual = 0;
  String? _cuentaSeleccionada;
  List<Map<String, dynamic>> _presupuestosPersonalizados = [];
  
  List<Map<String, dynamic>> _datosIngresosEjemplo = [
    {'categoria': 'SERVICIOS', 'monto': 19000.00, 'color': Colors.green},
    {'categoria': 'COMISIONES', 'monto': 100000.00, 'color': Colors.teal},
    {'categoria': 'TRANSFERENCIA', 'monto': 5000.00, 'color': Colors.amber},
    {'categoria': 'RENTA', 'monto': 8000.00, 'color': Colors.blue},
    {'categoria': 'PROYECTO', 'monto': 15000.00, 'color': Colors.purple},
  ];
  
  List<Map<String, dynamic>> _datosGastosEjemplo = [
    {'categoria': 'TRANSPORTE', 'monto': 13.00, 'color': Colors.green},
    {'categoria': 'PERSONAL', 'monto': 15000.00, 'color': Colors.teal},
    {'categoria': 'ALIMENTOS', 'monto': 5000.00, 'color': Colors.amber},
    {'categoria': 'MOBILIARIO', 'monto': 45000.00, 'color': Colors.red},
    {'categoria': 'ALQUILER', 'monto': 8000.00, 'color': Colors.orange},
  ];

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

  final List<String> _tagsDisponibles = ['#urgente', '#deducible', '#cliente', '#personal', '#negocio', '#importante', '#revisar'];

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
            'id': doc.id, 'nombre': d['nombre'] ?? '', 'icon': d['icon'] ?? 'category',
            'presupuesto': (d['presupuesto'] ?? 0).toDouble(), 'gastado': (d['gastado'] ?? 0).toDouble(),
            'cuenta': d['cuenta'] ?? 'Efectivo', 'subcuenta': d['subcuenta'] ?? 'Proyectos', 'aplicado': d['aplicado'] ?? false,
          };
        }).toList();
      });
    } catch (e) { print('Error: $e'); }
  }

  Future<void> _agregarPresupuestoPersonalizado(String nombre, double monto, double gastado, String icono, String cuenta, String subcuenta) async {
    await _firestore.collection('presupuestos_personalizados').add({
      'nombre': nombre, 'icon': icono, 'presupuesto': monto, 'gastado': gastado, 'cuenta': cuenta, 'subcuenta': subcuenta, 'aplicado': false, 'created_at': FieldValue.serverTimestamp(),
    });
    await _cargarPresupuestosPersonalizados();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Presupuesto creado'), backgroundColor: Colors.green));
  }

  void _editarPresupuestoDialog(Map<String, dynamic> presupuesto) {
    final nombreCtrl = TextEditingController(text: presupuesto['nombre']);
    final montoCtrl = TextEditingController(text: presupuesto['presupuesto'].toString());
    final gastadoCtrl = TextEditingController(text: presupuesto['gastado'].toString());
    String cuenta = presupuesto['cuenta'] ?? 'Efectivo';
    String subcuenta = presupuesto['subcuenta'] ?? 'Proyectos';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar Presupuesto', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: gastadoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Gastado actual', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: cuenta, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => cuenta = v!),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(value: subcuenta, decoration: const InputDecoration(labelText: 'Subcuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => subcuenta = v!),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
              final monto = double.tryParse(montoCtrl.text);
              final gastado = double.tryParse(gastadoCtrl.text) ?? 0;
              if (monto == null) return;
              Navigator.pop(dialogCtx);
              _agregarPresupuestoPersonalizado(nombreCtrl.text.trim(), monto, gastado, 'category', cuenta, subcuenta);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPresupuestoPersonalizado(String id) async {
    await _firestore.collection('presupuestos_personalizados').doc(id).delete();
    await _cargarPresupuestosPersonalizados();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
  }

  Future<void> _toggleAplicarPresupuesto(String id, bool aplicar, String nombre, double monto, String cuenta, String subcuenta) async {
    if (aplicar) {
      await _firestore.collection('transacciones').add({'concepto': 'Presupuesto aplicado: $nombre', 'monto': monto, 'categoria': nombre, 'tipo': 'Gasto', 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'descripcion': 'Presupuesto validado', 'reconciliada': true, 'created_at': FieldValue.serverTimestamp()});
      await _firestore.collection('transacciones').add({'concepto': 'Transferencia: $nombre', 'monto': monto, 'categoria': 'Transferencia', 'tipo': 'Ingreso', 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'descripcion': 'Fondos transferidos', 'reconciliada': true, 'created_at': FieldValue.serverTimestamp()});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Aplicado: \$${monto.toStringAsFixed(2)}'), backgroundColor: Colors.green));
    }
    await _firestore.collection('presupuestos_personalizados').doc(id).update({'aplicado': aplicar});
    await _cargarPresupuestosPersonalizados();
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
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: () => _mostrarTransferenciaEntreCuentas(), tooltip: 'Transferir'),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: () => _cargarDatosEjemplo(), tooltip: 'Ejemplo'),
          IconButton(icon: const Icon(Icons.upload_file, color: Colors.white), onPressed: () => _importarCSV(), tooltip: 'Importar CSV'),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'exportar') _exportarCSV();
              else if (v == 'calendario') _mostrarCalendario();
              else if (v == 'hoy') _mostrarVistaHoy();
              else if (v == 'reconciliar') _mostrarReconciliacionEditable();
              else if (v == 'informes') _mostrarInformesEditables();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hoy', child: Row(children: [Icon(Icons.today, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Vista de Hoy')])),
              const PopupMenuItem(value: 'calendario', child: Row(children: [Icon(Icons.calendar_month, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Calendario')])),
              const PopupMenuItem(value: 'reconciliar', child: Row(children: [Icon(Icons.check_circle, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Reconciliar')])),
              const PopupMenuItem(value: 'informes', child: Row(children: [Icon(Icons.analytics, color: Color(0xFF0066FF)), SizedBox(width: 8), Text('Informes')])),
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
          _buildCalendarioCompleto(),
          _buildReportes(),
          _buildPresupuestosTab(),
          _buildMetasTab(),
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
            const SizedBox(height: 4),
            const Text('Indicadores clave', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.2, mainAxisSpacing: 8, crossAxisSpacing: 8,
                      children: [
                        _buildKPICardCompact('Ingresos', '\$${ingresos.toStringAsFixed(0)}', Icons.trending_up, Colors.green),
                        _buildKPICardCompact('Gastos', '\$${gastos.toStringAsFixed(0)}', Icons.trending_down, Colors.red),
                        _buildKPICardCompact('Flujo Neto', '\$${flujoNeto.toStringAsFixed(0)}', Icons.account_balance_wallet, flujoNeto >= 0 ? Colors.green : Colors.red),
                        _buildKPICardCompact('Margen', '${margenGanancia.toStringAsFixed(1)}%', Icons.percent, Colors.blue),
                        _buildKPICardCompact('Ticket Prom.', '\$${ticketPromedio.toStringAsFixed(0)}', Icons.receipt_long, Colors.orange),
                        _buildKPICardCompact('Transacciones', '$numTransacciones', Icons.list_alt, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('📈 Por Negocio', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...porNegocio.entries.map((e) => _buildNegocioRowCompact(e.key, e.value, ingresos)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICardCompact(String titulo, String valor, IconData icono, Color color) {
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

  Widget _buildNegocioRowCompact(String negocio, double balance, double totalIngresos) {
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📅 Vista del Día', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${hoy.day} de ${['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][hoy.month - 1]} ${hoy.year}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(children: [Expanded(child: _buildMiniCard('Pendientes', Icons.schedule, Colors.orange)), const SizedBox(width: 12), Expanded(child: _buildMiniCard('Completadas', Icons.check_circle, Colors.green))]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('📋 Transacciones de Hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['fecha'] == fechaHoy).toList();
                if (docs.isEmpty) {
                  return Container(width: double.infinity, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: const Column(children: [Icon(Icons.event_busy, color: Colors.grey, size: 64), SizedBox(height: 16), Text('No hay transacciones para hoy', style: TextStyle(color: Colors.grey, fontSize: 16))]));
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final esIngreso = data['tipo'] == 'Ingreso';
                    final reconciliada = data['reconciliada'] ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222))),
                      child: Row(
                        children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16)]),
                                Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${esIngreso ? "+" : "-"}\$${data['monto'] ?? '0'}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              if (!reconciliada) TextButton(onPressed: () { _firestore.collection('transacciones').doc(doc.id).update({'reconciliada': true}); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Aprobada'), backgroundColor: Colors.green)); }, child: const Text('Aprobar', style: TextStyle(color: Color(0xFF0066FF), fontSize: 12))),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(String titulo, IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(titulo, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]));
  }

  Widget _buildResumen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTarjetaBalance(),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _buildTarjetaResumen('Ingresos', Colors.green, Icons.arrow_upward)), const SizedBox(width: 12), Expanded(child: _buildTarjetaResumen('Gastos', Colors.red, Icons.arrow_downward))]),
            const SizedBox(height: 24),
            const Text('📈 Tendencia Mensual', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(height: 250, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))), child: _buildGraficoLineas()),
            const SizedBox(height: 24),
            const Text('🕐 Últimas Transacciones', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20), SizedBox(width: 8), Text('Balance Total', style: TextStyle(color: Colors.white70, fontSize: 14))]),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('transacciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
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
            stream: _firestore.collection('transacciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('\$0', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
              double total = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['tipo'] == titulo) total += (data['monto'] ?? 0).toDouble();
              }
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
        Map<String, double> ingresosPorMes = {}, gastosPorMes = {};
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fecha = data['fecha'] as String? ?? '';
          final monto = (data['monto'] ?? 0).toDouble();
          if (fecha.length >= 7) {
            final mes = fecha.substring(0, 7);
            if (data['tipo'] == 'Ingreso') ingresosPorMes[mes] = (ingresosPorMes[mes] ?? 0) + monto;
            else gastosPorMes[mes] = (gastosPorMes[mes] ?? 0) + monto;
          }
        }
        final meses = ingresosPorMes.keys.toList()..sort();
        if (meses.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < meses.length) return Text(meses[idx].substring(5), style: const TextStyle(color: Colors.grey, fontSize: 10));
                return const Text('');
              })),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(spots: List.generate(meses.length, (i) => FlSpot(i.toDouble(), ingresosPorMes[meses[i]] ?? 0)), isCurved: true, color: Colors.green, barWidth: 3, dotData: const FlDotData(show: false)),
              LineChartBarData(spots: List.generate(meses.length, (i) => FlSpot(i.toDouble(), gastosPorMes[meses[i]] ?? 0)), isCurved: true, color: Colors.red, barWidth: 3, dotData: const FlDotData(show: false)),
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
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('${data['categoria'] ?? 'General'} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12))])),
                  Text('${esIngreso ? "+" : "-"}\$${data['monto'] ?? '0'}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildListaTransacciones(String tipo) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF111111),
            child: Column(
              children: [
                TextField(decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), style: const TextStyle(color: Colors.white), onChanged: (v) => setState(() => _search = v.toLowerCase())),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(value: _categoriaFiltro, decoration: InputDecoration(labelText: 'Categoría', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todas', 'Proyecto', 'Deslinde', 'Comisiones', 'Renta', 'Servicios', 'Préstamos', 'Personal', 'Adair', 'Capacitación', 'Deudas', 'Mobiliario', 'Alquiler', 'Transporte', 'Insumos de Oficina', 'Recarga', 'Uber', 'Propina', 'Otros', 'Transferencia'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(), onChanged: (v) => setState(() => _categoriaFiltro = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(value: _cuentaFiltro, decoration: InputDecoration(labelText: 'Cuenta', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todas', 'Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _cuentaFiltro = v!))),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: _negocioFiltro, decoration: InputDecoration(labelText: 'Negocio', filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Todos', 'Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setState(() => _negocioFiltro = v!)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: CheckboxListTile(title: const Text('Solo pendientes', style: TextStyle(color: Colors.white, fontSize: 12)), value: _soloPendientes, activeColor: const Color(0xFF0066FF), onChanged: (v) => setState(() => _soloPendientes = v ?? false), contentPadding: EdgeInsets.zero)),
                  Expanded(child: CheckboxListTile(title: const Text('Solo reconciliadas', style: TextStyle(color: Colors.white, fontSize: 12)), value: _soloReconciliadas, activeColor: Colors.green, onChanged: (v) => setState(() => _soloReconciliadas = v ?? false), contentPadding: EdgeInsets.zero)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  final transacciones = snapshot.data?.docs ?? [];
                  final filtrados = transacciones.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final concepto = (data['concepto'] ?? '').toString().toLowerCase();
                    final categoria = data['categoria'] ?? 'General';
                    final cuenta = data['cuenta'] ?? 'Efectivo';
                    final negocio = data['negocio'] ?? 'Minerales';
                    final reconciliada = data['reconciliada'] ?? false;
                    return data['tipo'] == tipo && (_search.isEmpty || concepto.contains(_search)) && (_categoriaFiltro == 'Todas' || categoria == _categoriaFiltro) && (_cuentaFiltro == 'Todas' || cuenta == _cuentaFiltro) && (_negocioFiltro == 'Todos' || negocio == _negocioFiltro) && (!_soloPendientes || !reconciliada) && (!_soloReconciliadas || reconciliada);
                  }).toList();
                  
                  if (filtrados.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.grey, size: 64), const SizedBox(height: 16), Text('No hay ${tipo.toLowerCase()}s registrados', style: const TextStyle(color: Colors.grey, fontSize: 16))]));
                  
                  final total = filtrados.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());
                  
                  return Column(
                    children: [
                      Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: tipo == 'Ingreso' ? Colors.green : Colors.red)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total:', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)), Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 20, fontWeight: FontWeight.bold))])),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final doc = filtrados[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final acreedor = data['acreedor'] ?? '';
                            final reconciliada = data['reconciliada'] ?? false;
                            final tags = List<String>.from(data['tags'] ?? []);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222))),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: Stack(children: [Center(child: Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: tipo == 'Ingreso' ? Colors.green : Colors.red, size: 24)), if (reconciliada) Positioned(right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 10))])),
                                title: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'} • ${data['negocio'] ?? 'Minerales'}', style: const TextStyle(color: Colors.grey)), if (acreedor.isNotEmpty) Text('Acreedor: $acreedor', style: const TextStyle(color: Colors.orange, fontSize: 11)), if (tags.isNotEmpty) Wrap(spacing: 4, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)))).toList()), Text('${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('\$${data['monto'] ?? '0'}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.copy, color: Colors.blue, size: 20), onPressed: () => _duplicarTransaccion(data), tooltip: 'Duplicar'), IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _mostrarFormularioTransaccion(transaccion: data, docId: doc.id)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () { showDialog(context: context, builder: (dialogCtx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Eliminar', style: TextStyle(color: Colors.white)), content: Text('¿Eliminar "${data['concepto']}"?', style: const TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () { Navigator.pop(dialogCtx); _firestore.collection('transacciones').doc(doc.id).delete(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red)); }, child: const Text('Eliminar', style: TextStyle(color: Colors.red)))])); })])])),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _duplicarTransaccion(Map<String, dynamic> data) async {
    await _firestore.collection('transacciones').add({'concepto': '${data['concepto']} (copia)', 'monto': data['monto'] ?? 0, 'categoria': data['categoria'] ?? 'General', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'descripcion': data['descripcion'] ?? '', 'metodo_pago': data['metodo_pago'] ?? 'Efectivo', 'referencia': data['referencia'] ?? '', 'tipo': data['tipo'] ?? 'Ingreso', 'cuenta': data['cuenta'] ?? 'Efectivo', 'subcuenta': data['subcuenta'] ?? 'Minerales', 'negocio': data['negocio'] ?? 'Minerales', 'acreedor': data['acreedor'] ?? '', 'tags': data['tags'] ?? [], 'reconciliada': false, 'created_at': FieldValue.serverTimestamp()});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Duplicada'), backgroundColor: Colors.green));
  }

  Widget _buildCuentas() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('💳 Mis Cuentas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), if (_cuentaSeleccionada != null) IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _cuentaSeleccionada = null), tooltip: 'Volver')]), const SizedBox(height: 16), Expanded(child: _cuentaSeleccionada == null ? _buildListaCuentasPrincipales() : _buildSubcuentasPorNegocio(_cuentaSeleccionada!))]));
  }

  Widget _buildListaCuentasPrincipales() {
    return StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final docs = snapshot.data!.docs; return ListView.builder(itemCount: _cuentas.length, itemBuilder: (context, index) { final cuenta = _cuentas[index]; double balance = 0; int numTransacciones = 0; for (var doc in docs) { final data = doc.data() as Map<String, dynamic>; if (data['cuenta'] == cuenta['nombre']) { final monto = (data['monto'] ?? 0).toDouble(); if (data['tipo'] == 'Ingreso') balance += monto; if (data['tipo'] == 'Gasto') balance -= monto; numTransacciones++; } } return GestureDetector(onTap: () => setState(() => _cuentaSeleccionada = cuenta['nombre']), child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: (cuenta['color'] as Color).withOpacity(0.2), shape: BoxShape.circle), child: Icon(cuenta['icon'] as IconData, color: cuenta['color'] as Color, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cuenta['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 14)), Text('$numTransacciones transacciones • Toca para ver detalle', style: const TextStyle(color: Colors.grey, fontSize: 11))])), const Icon(Icons.chevron_right, color: Colors.grey)]))); }); });
  }

  Widget _buildSubcuentasPorNegocio(String cuentaNombre) {
    return StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final docs = snapshot.data!.docs; return ListView.builder(itemCount: _negocios.length, itemBuilder: (context, index) { final negocio = _negocios[index]; double balance = 0; int numTransacciones = 0; for (var doc in docs) { final data = doc.data() as Map<String, dynamic>; if (data['cuenta'] == cuentaNombre && data['negocio'] == negocio) { final monto = (data['monto'] ?? 0).toDouble(); if (data['tipo'] == 'Ingreso') balance += monto; if (data['tipo'] == 'Gasto') balance -= monto; numTransacciones++; } } return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.business, color: Colors.blue, size: 24)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(negocio, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 14)), Text('$numTransacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 11))])), const Icon(Icons.chevron_right, color: Colors.grey)])); }); });
  }

  Widget _buildCalendarioCompleto() {
    DateTime _mesSeleccionado = DateTime.now();
    return StatefulBuilder(builder: (context, setSheetState) => Container(width: double.infinity, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => setSheetState(() => _mesSeleccionado = DateTime(_mesSeleccionado.year, _mesSeleccionado.month - 1))), Text('${_mesSeleccionado.year} - ${['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][_mesSeleccionado.month - 1]}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => setSheetState(() => _mesSeleccionado = DateTime(_mesSeleccionado.year, _mesSeleccionado.month + 1)))]), const SizedBox(height: 16), Expanded(child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final docs = snapshot.data!.docs; final transaccionesDelMes = docs.where((doc) { final data = doc.data() as Map<String, dynamic>; final fechaStr = data['fecha'] as String? ?? ''; if (fechaStr.length >= 7) { final fechaParts = fechaStr.split('-'); if (fechaParts.length >= 2) { final anio = int.tryParse(fechaParts[0]); final mes = int.tryParse(fechaParts[1]); return anio == _mesSeleccionado.year && mes == _mesSeleccionado.month; } } return false; }).toList(); if (transaccionesDelMes.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, color: Colors.grey, size: 64), SizedBox(height: 16), Text('No hay transacciones este mes', style: TextStyle(color: Colors.grey, fontSize: 16))])); Map<String, List<Map<String, dynamic>>> porDia = {}; for (var doc in transaccionesDelMes) { final data = doc.data() as Map<String, dynamic>; final fechaStr = data['fecha'] as String? ?? ''; if (fechaStr.length >= 10) { final dia = fechaStr.substring(8, 10); if (!porDia.containsKey(dia)) porDia[dia] = []; porDia[dia]!.add(data); } } return ListView(children: porDia.entries.map((entry) { final dia = entry.key; final transacciones = entry.value; double totalDia = 0; for (var t in transacciones) { final monto = (t['monto'] ?? 0).toDouble(); if (t['tipo'] == 'Ingreso') totalDia += monto; if (t['tipo'] == 'Gasto') totalDia -= monto; } return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(dia, style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Expanded(child: Text('Día $dia • ${transacciones.length} transacciones', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), Text('\$${totalDia.toStringAsFixed(2)}', style: TextStyle(color: totalDia >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), ...transacciones.map((t) => Padding(padding: const EdgeInsets.only(left: 52, top: 4), child: Row(children: [Icon(t['tipo'] == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: t['tipo'] == 'Ingreso' ? Colors.green : Colors.red, size: 16), const SizedBox(width: 8), Expanded(child: Text(t['concepto'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12))), Text('\$${(t['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: t['tipo'] == 'Ingreso' ? Colors.green : Colors.red, fontSize: 12))])))])); }).toList()); })))]));
  }

  Widget _buildReportes() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('📊 Reportes Editables', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Row(children: [IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => _mostrarDialogoAgregarDatoEjemplo(), tooltip: 'Agregar dato'), IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _resetearDatosEjemplo(), tooltip: 'Restaurar datos')])]),
      const SizedBox(height: 16),
      _buildGraficaCircularEditable(),
      const SizedBox(height: 24),
      const Text('💵 Flujo de Caja', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _buildFlujoDeCajaEditable(),
      const SizedBox(height: 24),
      _buildBenchmarkingSection(),
    ])));
  }

  Widget _buildGraficaCircularEditable() {
    List<Map<String, dynamic>> datosActuales;
    String tituloGrafica;
    double total;
    if (_vistaActual == 0) {
      final totalIngresos = _datosIngresosEjemplo.fold<double>(0, (sum, item) => sum + (item['monto'] as double));
      final totalGastos = _datosGastosEjemplo.fold<double>(0, (sum, item) => sum + (item['monto'] as double));
      datosActuales = [{'categoria': 'INGRESOS', 'monto': totalIngresos, 'color': Colors.green}, {'categoria': 'GASTOS', 'monto': totalGastos, 'color': Colors.red}];
      tituloGrafica = 'INGRESOS VS GASTOS';
      total = totalIngresos + totalGastos;
    } else if (_vistaActual == 1) {
      datosActuales = List.from(_datosIngresosEjemplo);
      tituloGrafica = 'INGRESOS';
      total = _datosIngresosEjemplo.fold<double>(0, (sum, item) => sum + (item['monto'] as double));
    } else {
      datosActuales = List.from(_datosGastosEjemplo);
      tituloGrafica = 'GASTOS';
      total = _datosGastosEjemplo.fold<double>(0, (sum, item) => sum + (item['monto'] as double));
    }

    final sections = datosActuales.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final porcentaje = total > 0 ? ((item['monto'] as double) / total * 100) : 0;
      return PieChartSectionData(value: item['monto'], title: '${porcentaje.toStringAsFixed(0)}%', color: item['color'], radius: 140, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold));
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => setState(() => _vistaActual = (_vistaActual - 1 + 3) % 3)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)), child: Text(['Ingresos vs Gastos', 'Ingresos', 'Gastos'][_vistaActual], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => setState(() => _vistaActual = (_vistaActual + 1) % 3)),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            height: 450,
            child: Stack(
              alignment: Alignment.center,
              children: [
                sections.isEmpty ? const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey))) : PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 100, startDegreeOffset: 270)),
                Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(color: const Color(0xFF111111), shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade700, width: 2)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(tituloGrafica, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    const Text('Toca un color\npara ver detalles', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              itemCount: datosActuales.length,
              itemBuilder: (context, index) {
                final item = datosActuales[index];
                return GestureDetector(
                  onTap: () => _editarDatoEjemplo(index, item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 14, height: 14, decoration: BoxDecoration(color: item['color'] as Color, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item['categoria'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
                        Text('\$${(item['monto'] as double).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 16), onPressed: () => _editarDatoEjemplo(index, item), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 16), onPressed: () => _eliminarDatoEjemplo(index, item), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
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
  }

  void _mostrarDialogoAgregarDatoEjemplo() {
    final categoriaCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    String tipo = _vistaActual == 1 ? 'ingreso' : 'gasto';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Agregar Dato', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(value: tipo, decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: const [DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')), DropdownMenuItem(value: 'gasto', child: Text('Gasto'))], onChanged: (v) => tipo = v!),
          const SizedBox(height: 12),
          TextField(controller: categoriaCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (categoriaCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
              final monto = double.tryParse(montoCtrl.text);
              if (monto == null) return;
              setState(() {
                if (tipo == 'ingreso') {
                  _datosIngresosEjemplo.add({'categoria': categoriaCtrl.text.toUpperCase(), 'monto': monto, 'color': Colors.primaries[_datosIngresosEjemplo.length % Colors.primaries.length]});
                } else {
                  _datosGastosEjemplo.add({'categoria': categoriaCtrl.text.toUpperCase(), 'monto': monto, 'color': Colors.primaries[_datosGastosEjemplo.length % Colors.primaries.length]});
                }
              });
              Navigator.pop(ctx);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Dato agregado'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarDatoEjemplo(int index, Map<String, dynamic> item) {
    final categoriaCtrl = TextEditingController(text: item['categoria']);
    final montoCtrl = TextEditingController(text: item['monto'].toString());
    final esIngreso = _vistaActual == 1 || (_vistaActual == 0 && index == 0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar Dato', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: categoriaCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (categoriaCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
              final monto = double.tryParse(montoCtrl.text);
              if (monto == null) return;
              setState(() {
                if (esIngreso) {
                  _datosIngresosEjemplo[index] = {'categoria': categoriaCtrl.text.toUpperCase(), 'monto': monto, 'color': item['color']};
                } else {
                  _datosGastosEjemplo[index] = {'categoria': categoriaCtrl.text.toUpperCase(), 'monto': monto, 'color': item['color']};
                }
              });
              Navigator.pop(ctx);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Dato actualizado'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _eliminarDatoEjemplo(int index, Map<String, dynamic> item) {
    final esIngreso = _vistaActual == 1 || (_vistaActual == 0 && index == 0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar Dato', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${item['categoria']}"?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                if (esIngreso) _datosIngresosEjemplo.removeAt(index);
                else _datosGastosEjemplo.removeAt(index);
              });
              Navigator.pop(ctx);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetearDatosEjemplo() {
    setState(() {
      _datosIngresosEjemplo = [
        {'categoria': 'SERVICIOS', 'monto': 19000.00, 'color': Colors.green},
        {'categoria': 'COMISIONES', 'monto': 100000.00, 'color': Colors.teal},
        {'categoria': 'TRANSFERENCIA', 'monto': 5000.00, 'color': Colors.amber},
        {'categoria': 'RENTA', 'monto': 8000.00, 'color': Colors.blue},
        {'categoria': 'PROYECTO', 'monto': 15000.00, 'color': Colors.purple},
      ];
      _datosGastosEjemplo = [
        {'categoria': 'TRANSPORTE', 'monto': 13.00, 'color': Colors.green},
        {'categoria': 'PERSONAL', 'monto': 15000.00, 'color': Colors.teal},
        {'categoria': 'ALIMENTOS', 'monto': 5000.00, 'color': Colors.amber},
        {'categoria': 'MOBILIARIO', 'monto': 45000.00, 'color': Colors.red},
        {'categoria': 'ALQUILER', 'monto': 8000.00, 'color': Colors.orange},
      ];
      _vistaActual = 0;
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Datos restaurados'), backgroundColor: Colors.green));
  }

  Widget _buildFlujoDeCajaEditable() {
    final totalIngresos = _datosIngresosEjemplo.fold<double>(0, (sum, item) => sum + (item['monto'] as double));
    final totalGastos = _datosGastosEjemplo.fold<double>(0, (sum, item) => sum + (item['monto'] as double));
    final flujo = totalIngresos - totalGastos;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${totalIngresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold))]),
        Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${totalGastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold))]),
        Column(children: [const Text('Flujo', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${flujo.toStringAsFixed(2)}', style: TextStyle(color: flujo >= 0 ? Colors.green : Colors.red, fontSize: 20, fontWeight: FontWeight.bold))]),
      ]),
    );
  }

  Widget _buildBenchmarkingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        Map<String, Map<String, double>> datosPorNegocio = {};
        for (var negocio in _negocios) datosPorNegocio[negocio] = {'ingresos': 0, 'gastos': 0, 'transacciones': 0};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final negocio = data['negocio'] ?? 'Otros';
          final monto = (data['monto'] ?? 0).toDouble();
          final tipo = data['tipo'] ?? '';
          if (!datosPorNegocio.containsKey(negocio)) datosPorNegocio[negocio] = {'ingresos': 0, 'gastos': 0, 'transacciones': 0};
          if (tipo == 'Ingreso') datosPorNegocio[negocio]!['ingresos'] = (datosPorNegocio[negocio]!['ingresos'] ?? 0) + monto;
          if (tipo == 'Gasto') datosPorNegocio[negocio]!['gastos'] = (datosPorNegocio[negocio]!['gastos'] ?? 0) + monto;
          datosPorNegocio[negocio]!['transacciones'] = (datosPorNegocio[negocio]!['transacciones'] ?? 0) + 1;
        }
        double maxIngreso = 0;
        for (var data in datosPorNegocio.values) if ((data['ingresos'] ?? 0) > maxIngreso) maxIngreso = data['ingresos'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📊 Benchmarking por Negocio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...datosPorNegocio.entries.map((entry) {
              final negocio = entry.key;
              final ingresos = entry.value['ingresos'] ?? 0;
              final gastos = entry.value['gastos'] ?? 0;
              final transacciones = entry.value['transacciones'] ?? 0;
              final utilidad = ingresos - gastos;
              final porcentajeIngreso = maxIngreso > 0 ? (ingresos / maxIngreso * 100) : 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Icon(Icons.business, color: const Color(0xFF0066FF), size: 20), const SizedBox(width: 8), Expanded(child: Text(negocio, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))), Text('$transacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 11))]),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Ingresos', style: TextStyle(color: Colors.grey, fontSize: 10)), Text('\$${ingresos.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold))]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Gastos', style: TextStyle(color: Colors.grey, fontSize: 10)), Text('\$${gastos.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold))]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Utilidad', style: TextStyle(color: Colors.grey, fontSize: 10)), Text('\$${utilidad.toStringAsFixed(0)}', style: TextStyle(color: utilidad >= 0 ? Colors.green : Colors.red, fontSize: 14, fontWeight: FontWeight.bold))]),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: porcentajeIngreso / 100, backgroundColor: Colors.grey.shade800, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)), minHeight: 6)),
                  const SizedBox(height: 4),
                  Text('${porcentajeIngreso.toStringAsFixed(1)}% del mayor ingreso', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ]),
              );
            }),
          ]),
        );
      },
    );
  }

  Widget _buildPresupuestosTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('📊 Mis Presupuestos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () => _mostrarFormularioNuevoPresupuesto(context), icon: const Icon(Icons.add, color: Colors.white), label: const Text('Agregar', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)))]),
          const SizedBox(height: 16),
          Expanded(
            child: _presupuestosPersonalizados.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.pie_chart_outline, color: Colors.grey.shade700, size: 64), const SizedBox(height: 16), const Text('No hay presupuestos', style: TextStyle(color: Colors.grey, fontSize: 16))]))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('transacciones').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      Map<String, double> gastado = {};
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (data['tipo'] == 'Gasto') {
                          final cat = data['categoria'] ?? 'Otros';
                          gastado[cat] = (gastado[cat] ?? 0) + (data['monto'] ?? 0).toDouble();
                        }
                      }
                      return ListView.builder(
                        itemCount: _presupuestosPersonalizados.length,
                        itemBuilder: (context, index) {
                          final cat = _presupuestosPersonalizados[index];
                          final gastadoCat = cat['gastado'] ?? gastado[cat['nombre']] ?? 0.0;
                          final presupuesto = cat['presupuesto'] as double;
                          final porcentaje = presupuesto > 0 ? (gastadoCat / presupuesto * 100).clamp(0, 100) : 0;
                          final excedido = gastadoCat > presupuesto;
                          final aplicado = cat['aplicado'] ?? false;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: aplicado ? Colors.green : const Color(0xFF222222))),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Icon(Icons.category, color: const Color(0xFF0066FF), size: 24),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cat['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('${cat['cuenta']} • ${cat['subcuenta']}', style: const TextStyle(color: Colors.grey, fontSize: 11))])),
                                if (aplicado) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                const SizedBox(width: 8),
                                IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 20), onPressed: () => _editarPresupuestoDialog(cat), tooltip: 'Editar'),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _eliminarPresupuestoPersonalizado(cat['id'])),
                              ]),
                              const SizedBox(height: 12),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\$${gastadoCat.toStringAsFixed(0)} / \$${presupuesto.toStringAsFixed(0)}', style: TextStyle(color: excedido ? Colors.red : Colors.green, fontSize: 14, fontWeight: FontWeight.bold)), Text('${porcentaje.toStringAsFixed(1)}%', style: TextStyle(color: excedido ? Colors.red : Colors.grey, fontSize: 12))]),
                              const SizedBox(height: 8),
                              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: porcentaje / 100, backgroundColor: Colors.grey.shade800, valueColor: AlwaysStoppedAnimation<Color>(excedido ? Colors.red : const Color(0xFF0066FF)), minHeight: 8)),
                              if (excedido) const Padding(padding: EdgeInsets.only(top: 8), child: Text('⚠️ EXCEDIDO', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 12),
                              Row(children: [const Text('Aplicar:', style: TextStyle(color: Colors.grey, fontSize: 12)), const Spacer(), Switch(value: aplicado, activeColor: Colors.green, onChanged: (v) => _toggleAplicarPresupuesto(cat['id'], v, cat['nombre'], presupuesto, cat['cuenta'], cat['subcuenta'])), Text(aplicado ? 'Activo' : 'Inactivo', style: TextStyle(color: aplicado ? Colors.green : Colors.grey, fontSize: 12))]),
                            ]),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioNuevoPresupuesto(BuildContext ctx) {
    final nombreCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    final gastadoCtrl = TextEditingController(text: '0');
    String cuenta = 'Efectivo';
    String subcuenta = 'Proyectos';
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Nuevo Presupuesto', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: gastadoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Gastado actual', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: cuenta, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => cuenta = v!),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: subcuenta, decoration: const InputDecoration(labelText: 'Subcuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => subcuenta = v!),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
              final monto = double.tryParse(montoCtrl.text);
              final gastado = double.tryParse(gastadoCtrl.text) ?? 0;
              if (monto == null) return;
              Navigator.pop(dialogCtx);
              _agregarPresupuestoPersonalizado(nombreCtrl.text.trim(), monto, gastado, 'category', cuenta, subcuenta);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetasTab() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('🏆 Mis Metas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), ElevatedButton.icon(onPressed: () => _mostrarFormularioNuevaMeta(context), icon: const Icon(Icons.add, color: Colors.white), label: const Text('Agregar', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)))]),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('metas').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.flag_outlined, color: Colors.grey.shade700, size: 64), const SizedBox(height: 16), const Text('No hay metas', style: TextStyle(color: Colors.grey, fontSize: 16))]));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final nombre = data['nombre'] ?? 'Sin nombre';
                    final objetivo = (data['objetivo'] ?? 0).toDouble();
                    final actual = (data['actual'] ?? 0).toDouble();
                    final meses = (data['meses'] ?? 12).toInt();
                    final porcentaje = objetivo > 0 ? (actual / objetivo * 100).clamp(0, 100) : 0;
                    final completada = actual >= objetivo;
                    final restante = objetivo - actual;
                    final ahorroMensual = meses > 0 ? restante / meses : 0;
                    final ahorroSemanal = ahorroMensual / 4;
                    final ahorroDiario = ahorroMensual / 30;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: completada ? Colors.green : const Color(0xFF222222))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(completada ? Icons.check_circle : Icons.flag, color: completada ? Colors.green : const Color(0xFF0066FF), size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                          IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 20), onPressed: () => _editarMetaDialog(docs[index]), tooltip: 'Editar'),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () { _firestore.collection('metas').doc(docs[index].id).delete(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Meta eliminada'), backgroundColor: Colors.red)); }),
                        ]),
                        const SizedBox(height: 12),
                        Text('\$${actual.toStringAsFixed(0)} / \$${objetivo.toStringAsFixed(0)}', style: TextStyle(color: completada ? Colors.green : Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: porcentaje / 100, backgroundColor: Colors.grey.shade800, valueColor: AlwaysStoppedAnimation<Color>(completada ? Colors.green : const Color(0xFF0066FF)), minHeight: 8)),
                        const SizedBox(height: 4),
                        Text('${porcentaje.toStringAsFixed(1)}% completado${completada ? ' ✅' : ''}', style: TextStyle(color: completada ? Colors.green : Colors.grey, fontSize: 12)),
                        if (!completada && restante > 0) ...[
                          const SizedBox(height: 12),
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('🎯 Plan de Ahorro Recomendado', style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildPlanItem('Mensual', ahorroMensual), _buildPlanItem('Semanal', ahorroSemanal), _buildPlanItem('Diario', ahorroDiario)]),
                            const SizedBox(height: 8),
                            Text('📅 Fecha estimada: ${DateTime.now().add(Duration(days: meses * 30)).toIso8601String().split('T')[0]}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ])),
                        ],
                      ]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(String periodo, double monto) {
    return Column(children: [Text(periodo, style: const TextStyle(color: Colors.grey, fontSize: 10)), const SizedBox(height: 4), Text('\$${monto.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]);
  }

  void _mostrarFormularioNuevaMeta(BuildContext ctx) {
    final nombreCtrl = TextEditingController();
    final objetivoCtrl = TextEditingController();
    final actualCtrl = TextEditingController(text: '0');
    final mesesCtrl = TextEditingController(text: '12');
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Nueva Meta', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: objetivoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Objetivo', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: actualCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Actual', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: mesesCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Meses', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isEmpty || objetivoCtrl.text.isEmpty) return;
              final objetivo = double.tryParse(objetivoCtrl.text);
              final actual = double.tryParse(actualCtrl.text) ?? 0;
              final meses = int.tryParse(mesesCtrl.text) ?? 12;
              if (objetivo == null) return;
              Navigator.pop(dialogCtx);
              _firestore.collection('metas').add({'nombre': nombreCtrl.text.trim(), 'objetivo': objetivo, 'actual': actual, 'meses': meses, 'created_at': FieldValue.serverTimestamp()});
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Meta creada'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editarMetaDialog(DocumentSnapshot metaDoc) {
    final data = metaDoc.data() as Map<String, dynamic>;
    final nombreCtrl = TextEditingController(text: data['nombre'] ?? '');
    final objetivoCtrl = TextEditingController(text: data['objetivo']?.toString() ?? '0');
    final actualCtrl = TextEditingController(text: data['actual']?.toString() ?? '0');
    final mesesCtrl = TextEditingController(text: (data['meses'] ?? 12).toString());
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Editar Meta', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: objetivoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Objetivo', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: actualCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Actual', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: mesesCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Meses', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.isEmpty || objetivoCtrl.text.isEmpty) return;
              final objetivo = double.tryParse(objetivoCtrl.text);
              final actual = double.tryParse(actualCtrl.text) ?? 0;
              final meses = int.tryParse(mesesCtrl.text) ?? 12;
              if (objetivo == null) return;
              Navigator.pop(dialogCtx);
              _firestore.collection('metas').doc(metaDoc.id).update({'nombre': nombreCtrl.text.trim(), 'objetivo': objetivo, 'actual': actual, 'meses': meses});
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Meta actualizada'), backgroundColor: Colors.green));
            },
            child: const Text('Guardar', style: TextStyle(color: Color(0xFF0066FF))),
          ),
        ],
      ),
    );
  }

  void _mostrarVistaHoy() { _tabController.animateTo(0); }
  void _mostrarCalendario() { _tabController.animateTo(6); }

  void _mostrarReconciliacionEditable() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF111111), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (ctx) => Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('✅ Reconciliar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
      const SizedBox(height: 16),
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(), builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(itemCount: docs.length, itemBuilder: (context, index) {
          final doc = docs[index];
          final data = doc.data() as Map<String, dynamic>;
          final reconciliada = data['reconciliada'] ?? false;
          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222))), child: Row(children: [
            Checkbox(value: reconciliada, activeColor: Colors.green, onChanged: (v) async { await _firestore.collection('transacciones').doc(doc.id).update({'reconciliada': v ?? false}); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v == true ? '✅ Reconciliada' : '↩️ Desmarcada'), backgroundColor: v == true ? Colors.green : Colors.grey)); }),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['concepto'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('${data['categoria'] ?? ''} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            Text('\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: data['tipo'] == 'Ingreso' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ]));
        });
      }))]));
  }

  void _mostrarInformesEditables() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF111111), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (ctx) => Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.analytics, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('📊 Informes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
      const SizedBox(height: 16),
      Expanded(child: ListView(children: [
        GestureDetector(onTap: () { Navigator.pop(ctx); _tabController.animateTo(7); }, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.show_chart, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📈 Ingresos/Gastos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('Resumen por periodo', style: TextStyle(color: Colors.grey, fontSize: 12))])), const Icon(Icons.chevron_right, color: Colors.grey)]))),
        GestureDetector(onTap: () { Navigator.pop(ctx); _tabController.animateTo(2); }, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.dashboard_customize, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📊 Dashboard KPIs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('Indicadores clave', style: TextStyle(color: Colors.grey, fontSize: 12))])), const Icon(Icons.chevron_right, color: Colors.grey)]))),
      ]))]));
  }

  Future<void> _importarCSV() async {
    final input = html.FileUploadInputElement()..accept = '.csv';
    input.click();
    input.onChange.listen((e) async {
      final files = input.files;
      if (files == null || files.isEmpty) return;
      final reader = html.FileReader();
      reader.readAsText(files.first);
      reader.onLoadEnd.listen((e) async {
        final lines = (reader.result as String).split('\n');
        int importados = 0;
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(',');
          if (parts.length >= 8) {
            try {
              await _firestore.collection('transacciones').add({'fecha': parts[0].trim(), 'tipo': parts[1].trim(), 'concepto': parts[2].trim().replaceAll('"', ''), 'categoria': parts[3].trim().replaceAll('"', ''), 'acreedor': parts.length > 4 ? parts[4].trim().replaceAll('"', '') : '', 'cuenta': parts.length > 5 ? parts[5].trim().replaceAll('"', '') : 'Efectivo', 'subcuenta': parts.length > 6 ? parts[6].trim().replaceAll('"', '') : 'Minerales', 'negocio': parts.length > 7 ? parts[7].trim().replaceAll('"', '') : 'Minerales', 'monto': double.tryParse(parts[parts.length - 4]?.trim() ?? '0') ?? 0, 'metodo_pago': parts.length > 8 ? parts[8].trim().replaceAll('"', '') : 'Efectivo', 'referencia': parts.length > 9 ? parts[9].trim().replaceAll('"', '') : '', 'descripcion': parts.length > 10 ? parts[10].trim().replaceAll('"', '') : '', 'tags': [], 'reconciliada': false, 'importada': true, 'created_at': FieldValue.serverTimestamp()});
              importados++;
            } catch (e) { print('Error: $e'); }
          }
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $importados importadas'), backgroundColor: Colors.green));
      });
    });
  }

  Future<void> _exportarCSV() async {
    try {
      final snapshot = await _firestore.collection('transacciones').orderBy('created_at', descending: true).get();
      final buffer = StringBuffer();
      buffer.writeln('Fecha,Tipo,Concepto,Categoría,Acreedor,Cuenta,Subcuenta,Negocio,Monto,Método de Pago,Referencia,Descripción,Reconciliada');
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        buffer.writeln('${data['fecha'] ?? ''},${data['tipo'] ?? ''},"${data['concepto'] ?? ''}","${data['categoria'] ?? ''}","${data['acreedor'] ?? ''}","${data['cuenta'] ?? ''}","${data['subcuenta'] ?? 'Minerales'}","${data['negocio'] ?? 'Minerales'}",${data['monto'] ?? 0},"${data['metodo_pago'] ?? ''}","${data['referencia'] ?? ''}","${data['descripcion'] ?? ''}",${data['reconciliada'] ?? false}');
      }
      final bytes = utf8.encode(buffer.toString());
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)..setAttribute("download", "finanzas_${DateTime.now().millisecondsSinceEpoch}.csv")..click();
      html.Url.revokeObjectUrl(url);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Exportado'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _cargarDatosEjemplo() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Cargar ejemplo', style: TextStyle(color: Colors.white)), content: const Text('¿Agregar transacciones de ejemplo editables?', style: TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cargar', style: TextStyle(color: Color(0xFF0066FF))))]));
    if (confirm != true) return;
    final ejemplos = [
      {'concepto': 'Comisión venta terreno', 'monto': 25000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso', 'cuenta': 'Banco', 'subcuenta': 'Proyectos', 'negocio': 'Proyectos', 'fecha': '2026-10-02', 'reconciliada': true, 'tags': ['#cliente', '#negocio']},
      {'concepto': 'Pago préstamo', 'monto': 8500.0, 'categoria': 'Préstamos', 'tipo': 'Gasto', 'cuenta': 'Banco', 'subcuenta': 'Minerales', 'negocio': 'Minerales', 'fecha': '2026-10-05', 'reconciliada': true, 'tags': ['#urgente']},
      {'concepto': 'Nómina', 'monto': 12000.0, 'categoria': 'Personal', 'tipo': 'Gasto', 'cuenta': 'Banco', 'subcuenta': 'Proyectos', 'negocio': 'Proyectos', 'fecha': '2026-10-15', 'reconciliada': true, 'tags': ['#personal']},
      {'concepto': 'Renta oficina', 'monto': 5000.0, 'categoria': 'Alquiler', 'tipo': 'Gasto', 'cuenta': 'Banco', 'subcuenta': 'Proyectos', 'negocio': 'Proyectos', 'fecha': '2026-10-01', 'reconciliada': true, 'tags': ['#deducible']},
      {'concepto': 'Servicio consultoría', 'monto': 8500.0, 'categoria': 'Servicios', 'tipo': 'Ingreso', 'cuenta': 'Banco', 'subcuenta': 'Proyectos', 'negocio': 'Proyectos', 'fecha': '2026-10-08', 'reconciliada': true, 'tags': ['#cliente', '#negocio']},
    ];
    for (var t in ejemplos) { await _firestore.collection('transacciones').add({...t, 'descripcion': '', 'metodo_pago': 'Transferencia', 'referencia': 'REF-${DateTime.now().millisecondsSinceEpoch}', 'acreedor': '', 'num_cheque': '', 'subcategoria': '', 'importada': false, 'created_at': FieldValue.serverTimestamp()}); }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ejemplo cargado'), backgroundColor: Colors.green));
  }

  void _mostrarFormularioTransaccion({Map<String, dynamic>? transaccion, String? docId}) {
    final conceptoCtrl = TextEditingController(text: transaccion?['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: transaccion?['monto']?.toString() ?? '0');
    final categoriaCtrl = TextEditingController(text: transaccion?['categoria'] ?? 'General');
    final fechaCtrl = TextEditingController(text: transaccion?['fecha'] ?? DateTime.now().toIso8601String().split('T')[0]);
    String tipo = transaccion?['tipo'] ?? 'Ingreso';
    String cuenta = transaccion?['cuenta'] ?? 'Efectivo';
    String subcuenta = transaccion?['subcuenta'] ?? 'Minerales';
    String negocio = transaccion?['negocio'] ?? 'Minerales';
    bool reconciliada = transaccion?['reconciliada'] ?? false;
    Set<String> tagsActuales = Set<String>.from(List<String>.from(transaccion?['tags'] ?? []));

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
                Row(children: [Icon(transaccion == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF0066FF), size: 28), const SizedBox(width: 12), Expanded(child: Text(transaccion == null ? 'Nueva Transacción' : 'Editar', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
                const SizedBox(height: 20),
                TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Concepto *', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: RadioListTile<String>(title: const Text('Ingreso', style: TextStyle(color: Colors.white)), value: 'Ingreso', groupValue: tipo, activeColor: Colors.green, onChanged: (v) => setSheetState(() => tipo = v!))), Expanded(child: RadioListTile<String>(title: const Text('Gasto', style: TextStyle(color: Colors.white)), value: 'Gasto', groupValue: tipo, activeColor: Colors.red, onChanged: (v) => setSheetState(() => tipo = v!)))]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: categoriaCtrl.text, decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: (tipo == 'Ingreso' ? _categoriasIngreso : _categoriasGasto).map((c) => DropdownMenuItem(value: c['nombre'] as String, child: Text(c['nombre'] as String))).toList(), onChanged: (v) => categoriaCtrl.text = v ?? ''),
                const SizedBox(height: 12),
                TextField(controller: fechaCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Fecha', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: cuenta, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setSheetState(() => cuenta = v!)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: subcuenta, decoration: const InputDecoration(labelText: 'Subcuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setSheetState(() => subcuenta = v!)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: negocio, decoration: const InputDecoration(labelText: 'Negocio', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setSheetState(() => negocio = v!)),
                const SizedBox(height: 12),
                const Text('🏷️ Etiquetas', style: TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: _tagsDisponibles.map((tag) { final seleccionado = tagsActuales.contains(tag); return FilterChip(label: Text(tag, style: TextStyle(color: seleccionado ? Colors.white : Colors.grey, fontSize: 12)), selected: seleccionado, backgroundColor: const Color(0xFF1A1A1A), selectedColor: const Color(0xFF0066FF), onSelected: (v) { setSheetState(() { if (v) tagsActuales.add(tag); else tagsActuales.remove(tag); }); }); }).toList()),
                const SizedBox(height: 12),
                CheckboxListTile(title: const Text('Reconciliada', style: TextStyle(color: Colors.white)), value: reconciliada, activeColor: Colors.green, onChanged: (v) => setSheetState(() => reconciliada = v ?? false), contentPadding: EdgeInsets.zero),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (conceptoCtrl.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Concepto obligatorio'), backgroundColor: Colors.orange)); return; }
                      final data = {'concepto': conceptoCtrl.text.trim(), 'monto': double.tryParse(montoCtrl.text) ?? 0, 'categoria': categoriaCtrl.text.trim(), 'fecha': fechaCtrl.text.trim(), 'tipo': tipo, 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': negocio, 'reconciliada': reconciliada, 'tags': tagsActuales.toList(), 'descripcion': '', 'metodo_pago': 'Efectivo', 'referencia': '', 'acreedor': '', 'beneficiario': '', 'num_cheque': ''};
                      if (docId == null) { data['created_at'] = FieldValue.serverTimestamp(); await _firestore.collection('transacciones').add(data); } else { await _firestore.collection('transacciones').doc(docId).update(data); }
                      Navigator.pop(ctx);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? '✅ Creada' : '✅ Actualizada'), backgroundColor: Colors.green));
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(transaccion == null ? 'Crear' : 'Guardar', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _mostrarTransferenciaEntreCuentas() {
    String cuentaOrigen = 'Inversión';
    String cuentaDestino = 'Banco';
    String subcuentaOrigen = 'Proyectos';
    String subcuentaDestino = 'Proyectos';
    final montoCtrl = TextEditingController();
    final conceptoCtrl = TextEditingController(text: 'Transferencia entre cuentas');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Icon(Icons.swap_horiz, color: Color(0xFF0066FF), size: 28), const SizedBox(width: 12), const Expanded(child: Text('💱 Transferir', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
              const SizedBox(height: 16),
              const Text('Cuenta Origen', style: TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: cuentaOrigen, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setSheetState(() => cuentaOrigen = v!)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: subcuentaOrigen, decoration: const InputDecoration(labelText: 'Subcuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setSheetState(() => subcuentaOrigen = v!)),
              const SizedBox(height: 16),
              const Icon(Icons.arrow_downward, color: Colors.white, size: 32),
              const SizedBox(height: 16),
              const Text('Cuenta Destino', style: TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: cuentaDestino, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setSheetState(() => cuentaDestino = v!)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: subcuentaDestino, decoration: const InputDecoration(labelText: 'Subcuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setSheetState(() => subcuentaDestino = v!)),
              const SizedBox(height: 16),
              TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Concepto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final monto = double.tryParse(montoCtrl.text);
                    if (monto == null || monto <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Monto inválido'), backgroundColor: Colors.orange)); return; }
                    if (cuentaOrigen == cuentaDestino) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Cuentas deben ser diferentes'), backgroundColor: Colors.orange)); return; }
                    final fecha = DateTime.now().toIso8601String().split('T')[0];
                    final concepto = conceptoCtrl.text.trim().isEmpty ? 'Transferencia de $cuentaOrigen a $cuentaDestino' : conceptoCtrl.text.trim();
                    await _firestore.collection('transacciones').add({'concepto': '$concepto (salida)', 'monto': monto, 'categoria': 'Transferencia', 'tipo': 'Gasto', 'cuenta': cuentaOrigen, 'subcuenta': subcuentaOrigen, 'negocio': 'Proyectos', 'fecha': fecha, 'descripcion': 'Transferencia a $cuentaDestino', 'reconciliada': true, 'es_transferencia': true, 'cuenta_relacionada': cuentaDestino, 'created_at': FieldValue.serverTimestamp()});
                    await _firestore.collection('transacciones').add({'concepto': '$concepto (entrada)', 'monto': monto, 'categoria': 'Transferencia', 'tipo': 'Ingreso', 'cuenta': cuentaDestino, 'subcuenta': subcuentaDestino, 'negocio': 'Proyectos', 'fecha': fecha, 'descripcion': 'Transferencia desde $cuentaOrigen', 'reconciliada': true, 'es_transferencia': true, 'cuenta_relacionada': cuentaOrigen, 'created_at': FieldValue.serverTimestamp()});
                    Navigator.pop(ctx);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Transferencia de \$${monto.toStringAsFixed(2)}'), backgroundColor: Colors.green));
                  },
                  icon: const Icon(Icons.swap_horiz, color: Colors.white),
                  label: const Text('Transferir', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}