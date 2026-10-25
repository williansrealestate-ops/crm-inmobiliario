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

  final List<Map<String, dynamic>> _cuentas = [
    {'nombre': 'Efectivo', 'icon': Icons.money, 'color': Colors.green},
    {'nombre': 'Banco', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'nombre': 'Tarjeta', 'icon': Icons.credit_card, 'color': Colors.orange},
    {'nombre': 'Inversión', 'icon': Icons.trending_up, 'color': Colors.purple},
  ];

  final List<Map<String, dynamic>> _categoriasGasto = [
    {'nombre': 'Préstamos', 'icon': Icons.account_balance_wallet, 'presupuesto': 30000.0, 'subcategorias': ['Mensual', 'Extra']},
    {'nombre': 'Personal', 'icon': Icons.people, 'presupuesto': 20000.0, 'subcategorias': ['Nómina', 'Bonos']},
    {'nombre': 'Adair', 'icon': Icons.business, 'presupuesto': 10000.0, 'subcategorias': []},
    {'nombre': 'Capacitación', 'icon': Icons.school, 'presupuesto': 5000.0, 'subcategorias': ['Cursos', 'Certificaciones']},
    {'nombre': 'Deudas', 'icon': Icons.warning, 'presupuesto': 5000.0, 'subcategorias': []},
    {'nombre': 'Mobiliario', 'icon': Icons.chair, 'presupuesto': 3000.0, 'subcategorias': []},
    {'nombre': 'Alquiler', 'icon': Icons.home, 'presupuesto': 2000.0, 'subcategorias': []},
    {'nombre': 'Transporte', 'icon': Icons.directions_car, 'presupuesto': 2000.0, 'subcategorias': ['Gasolina', 'Mantenimiento']},
    {'nombre': 'Insumos de Oficina', 'icon': Icons.print, 'presupuesto': 1000.0, 'subcategorias': []},
    {'nombre': 'Recarga', 'icon': Icons.phone_android, 'presupuesto': 500.0, 'subcategorias': []},
    {'nombre': 'Uber', 'icon': Icons.local_taxi, 'presupuesto': 500.0, 'subcategorias': []},
    {'nombre': 'Propina', 'icon': Icons.card_giftcard, 'presupuesto': 200.0, 'subcategorias': []},
    {'nombre': 'Otros', 'icon': Icons.more_horiz, 'presupuesto': 1000.0, 'subcategorias': []},
  ];

  final List<Map<String, dynamic>> _categoriasIngreso = [
    {'nombre': 'Proyecto', 'icon': Icons.business_center, 'subcategorias': ['Venta', 'Renta']},
    {'nombre': 'Deslinde', 'icon': Icons.map, 'subcategorias': []},
    {'nombre': 'Comisiones', 'icon': Icons.handshake, 'subcategorias': ['Referidos', 'Cierres']},
    {'nombre': 'Renta', 'icon': Icons.home, 'subcategorias': ['Mensual', 'Anual']},
    {'nombre': 'Servicios', 'icon': Icons.build, 'subcategorias': ['Consultoría', 'Asesoría']},
    {'nombre': 'Otros', 'icon': Icons.more_horiz, 'subcategorias': []},
  ];

  final List<String> _negocios = ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'];

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

  Future<void> _cargarDatosEjemplo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Cargar datos de ejemplo', style: TextStyle(color: Colors.white)),
        content: const Text('Esto agregará ~25 transacciones de octubre 2026. ¿Continuar?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cargar', style: TextStyle(color: Color(0xFF0066FF)))),
        ],
      ),
    );
    if (confirm != true) return;

    final transaccionesEjemplo = [
      {'concepto': 'Comisión venta terreno Atasta', 'monto': 25000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-02', 'acreedor': 'Cliente Juan Carlos', 'reconciliada': true},
      {'concepto': 'Comisión deslinde 49 has Edomex', 'monto': 2000.0, 'categoria': 'Deslinde', 'tipo': 'Ingreso', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-05', 'acreedor': 'Cliente Ericka', 'reconciliada': true},
      {'concepto': 'Renta oficina octubre', 'monto': 15000.0, 'categoria': 'Renta', 'tipo': 'Ingreso', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-01', 'acreedor': '', 'reconciliada': true},
      {'concepto': 'Servicio consultoría inmobiliaria', 'monto': 8500.0, 'categoria': 'Servicios', 'tipo': 'Ingreso', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-08', 'acreedor': 'Constructora Corrales', 'reconciliada': true},
      {'concepto': 'Comisión venta casa Polanco', 'monto': 4000.0, 'categoria': 'Comisiones', 'tipo': 'Ingreso', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-12', 'acreedor': 'Cliente Williams', 'reconciliada': false},
      {'concepto': 'Pago préstamo bancario', 'monto': 8500.0, 'categoria': 'Préstamos', 'tipo': 'Gasto', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-05', 'acreedor': 'Banco BBVA', 'reconciliada': true},
      {'concepto': 'Pago préstamo personal', 'monto': 5234.0, 'categoria': 'Préstamos', 'tipo': 'Gasto', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-10', 'acreedor': 'Prestamista', 'reconciliada': true},
      {'concepto': 'Pago tarjeta de crédito', 'monto': 8500.0, 'categoria': 'Préstamos', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-15', 'acreedor': 'BBVA', 'reconciliada': false},
      {'concepto': 'Nómina asesores octubre', 'monto': 12000.0, 'categoria': 'Personal', 'tipo': 'Gasto', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-15', 'acreedor': 'Ericka Blanco', 'reconciliada': true},
      {'concepto': 'Pago Williams', 'monto': 2597.79, 'categoria': 'Personal', 'tipo': 'Gasto', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-20', 'acreedor': 'Williams', 'reconciliada': false},
      {'concepto': 'Pago servicios Adair', 'monto': 6156.58, 'categoria': 'Adair', 'tipo': 'Gasto', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-08', 'acreedor': 'Adair', 'reconciliada': true},
      {'concepto': 'Curso CRM inmobiliario', 'monto': 1500.0, 'categoria': 'Capacitación', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-03', 'acreedor': 'Udemy', 'reconciliada': true},
      {'concepto': 'Certificación ventas', 'monto': 1356.91, 'categoria': 'Capacitación', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-18', 'acreedor': 'Coursera', 'reconciliada': false},
      {'concepto': 'Pago deuda proveedor', 'monto': 2300.0, 'categoria': 'Deudas', 'tipo': 'Gasto', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-22', 'acreedor': 'Proveedor', 'reconciliada': false},
      {'concepto': 'Escritorio nuevo oficina', 'monto': 1200.0, 'categoria': 'Mobiliario', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-06', 'acreedor': 'IKEA', 'reconciliada': true},
      {'concepto': 'Silla ergonómica', 'monto': 745.30, 'categoria': 'Mobiliario', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-14', 'acreedor': 'Office Depot', 'reconciliada': true},
      {'concepto': 'Renta oficina octubre', 'monto': 1400.0, 'categoria': 'Alquiler', 'tipo': 'Gasto', 'cuenta': 'Banco', 'negocio': 'Proyectos', 'fecha': '2026-10-01', 'acreedor': 'Arrendador', 'reconciliada': true},
      {'concepto': 'Gasolina octubre', 'monto': 800.0, 'categoria': 'Transporte', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-10', 'acreedor': 'Pemex', 'reconciliada': true},
      {'concepto': 'Mantenimiento auto', 'monto': 350.0, 'categoria': 'Transporte', 'tipo': 'Gasto', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-20', 'acreedor': 'Taller', 'reconciliada': false},
      {'concepto': 'Papelería y toner', 'monto': 509.52, 'categoria': 'Insumos de Oficina', 'tipo': 'Gasto', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-12', 'acreedor': 'Office Depot', 'reconciliada': true},
      {'concepto': 'Recarga celular octubre', 'monto': 330.0, 'categoria': 'Recarga', 'tipo': 'Gasto', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-05', 'acreedor': 'Telcel', 'reconciliada': true},
      {'concepto': 'Uber visitas clientes', 'monto': 200.0, 'categoria': 'Uber', 'tipo': 'Gasto', 'cuenta': 'Tarjeta', 'negocio': 'Proyectos', 'fecha': '2026-10-15', 'acreedor': 'Uber', 'reconciliada': true},
      {'concepto': 'Propinas mesero', 'monto': 42.0, 'categoria': 'Propina', 'tipo': 'Gasto', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-25', 'acreedor': '', 'reconciliada': false},
      {'concepto': 'Galletas Marías', 'monto': 15.0, 'categoria': 'Otros', 'tipo': 'Gasto', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-24', 'acreedor': '', 'reconciliada': false},
      {'concepto': 'Planos catastrales', 'monto': 1000.0, 'categoria': 'Otros', 'tipo': 'Ingreso', 'cuenta': 'Efectivo', 'negocio': 'Proyectos', 'fecha': '2026-10-24', 'acreedor': '', 'reconciliada': false},
    ];

    int cargados = 0;
    for (var t in transaccionesEjemplo) {
      try {
        await _firestore.collection('transacciones').add({
          ...t,
          'descripcion': '',
          'metodo_pago': t['cuenta'] == 'Efectivo' ? 'Efectivo' : 'Transferencia',
          'referencia': 'REF-${DateTime.now().millisecondsSinceEpoch}',
          'beneficiario': t['acreedor'] ?? '',
          'num_cheque': '',
          'subcategoria': '',
          'importada': false,
          'created_at': FieldValue.serverTimestamp(),
        });
        cargados++;
      } catch (e) {
        print('Error cargando ${t['concepto']}: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $cargados transacciones de ejemplo cargadas'), backgroundColor: Colors.green));
    }
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
                  Row(
                    children: [
                      Expanded(child: _buildMiniCard('Pendientes', Icons.schedule, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMiniCard('Completadas', Icons.check_circle, Colors.green)),
                    ],
                  ),
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
                final docs = snapshot.data!.docs;
                final transaccionesHoy = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['fecha'] == fechaHoy;
                }).toList();
                
                if (transaccionesHoy.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy, color: Colors.grey, size: 64),
                        SizedBox(height: 16),
                        Text('No hay transacciones para hoy', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: transaccionesHoy.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final esIngreso = data['tipo'] == 'Ingreso';
                    final reconciliada = data['reconciliada'] ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle),
                            child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  ],
                                ),
                                Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${esIngreso ? "+" : "-"}\$${data['monto'] ?? '0'}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              if (!reconciliada)
                                TextButton(
                                  onPressed: () => _aprobarTransaccion(doc.id),
                                  child: const Text('Aprobar', style: TextStyle(color: Color(0xFF0066FF), fontSize: 12)),
                                ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(titulo, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _aprobarTransaccion(String id) async {
    await _firestore.collection('transacciones').doc(id).update({'reconciliada': true});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Transacción aprobada'), backgroundColor: Colors.green));
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
            Row(
              children: [
                Expanded(child: _buildTarjetaResumen('Ingresos', Colors.green, Icons.arrow_upward)),
                const SizedBox(width: 12),
                Expanded(child: _buildTarjetaResumen('Gastos', Colors.red, Icons.arrow_downward)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('📈 Tendencia Mensual', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
              child: _buildGraficoLineas(),
            ),
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
            if (data['tipo'] == 'Ingreso') {
              ingresosPorMes[mes] = (ingresosPorMes[mes] ?? 0) + monto;
            } else {
              gastosPorMes[mes] = (gastosPorMes[mes] ?? 0) + monto;
            }
          }
        }
        final meses = ingresosPorMes.keys.toList()..sort();
        if (meses.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < meses.length) return Text(meses[idx].substring(5), style: const TextStyle(color: Colors.grey, fontSize: 10));
                    return const Text('');
                  },
                ),
              ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('${data['categoria'] ?? 'General'} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
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
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar transacciones...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _categoriaFiltro,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white),
                        items: ['Todas', 'Proyecto', 'Deslinde', 'Comisiones', 'Renta', 'Servicios', 'Préstamos', 'Personal', 'Adair', 'Capacitación', 'Deudas', 'Mobiliario', 'Alquiler', 'Transporte', 'Insumos de Oficina', 'Recarga', 'Uber', 'Propina', 'Otros']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (v) => setState(() => _categoriaFiltro = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _cuentaFiltro,
                        decoration: InputDecoration(
                          labelText: 'Cuenta',
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white),
                        items: ['Todas', 'Efectivo', 'Banco', 'Tarjeta', 'Inversión']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _cuentaFiltro = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _negocioFiltro,
                  decoration: InputDecoration(
                    labelText: 'Negocio',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: ['Todos', 'Minerales', 'Combustible', 'Agropecuario', 'Proyectos']
                      .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  onChanged: (v) => setState(() => _negocioFiltro = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Solo pendientes', style: TextStyle(color: Colors.white, fontSize: 12)),
                        value: _soloPendientes,
                        activeColor: const Color(0xFF0066FF),
                        onChanged: (v) => setState(() => _soloPendientes = v ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Solo reconciliadas', style: TextStyle(color: Colors.white, fontSize: 12)),
                        value: _soloReconciliadas,
                        activeColor: Colors.green,
                        onChanged: (v) => setState(() => _soloReconciliadas = v ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
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
                    return data['tipo'] == tipo &&
                        (_search.isEmpty || concepto.contains(_search)) &&
                        (_categoriaFiltro == 'Todas' || categoria == _categoriaFiltro) &&
                        (_cuentaFiltro == 'Todas' || cuenta == _cuentaFiltro) &&
                        (_negocioFiltro == 'Todos' || negocio == _negocioFiltro) &&
                        (!_soloPendientes || !reconciliada) &&
                        (!_soloReconciliadas || reconciliada);
                  }).toList();
                  
                  if (filtrados.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.grey, size: 64),
                          const SizedBox(height: 16),
                          Text('No hay ${tipo.toLowerCase()}s registrados', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  
                  final total = filtrados.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());
                  
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: tipo == 'Ingreso' ? Colors.green : Colors.red),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total:', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final doc = filtrados[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final acreedor = data['acreedor'] ?? '';
                            final reconciliada = data['reconciliada'] ?? false;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: tipo == 'Ingreso' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward,
                                          color: tipo == 'Ingreso' ? Colors.green : Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                      if (reconciliada)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                            child: const Icon(Icons.check, color: Colors.white, size: 10),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                title: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'} • ${data['negocio'] ?? 'Minerales'}', style: const TextStyle(color: Colors.grey)),
                                    if (acreedor.isNotEmpty) Text('Acreedor: $acreedor', style: const TextStyle(color: Colors.orange, fontSize: 11)),
                                    Text('${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('\$${data['monto'] ?? '0'}', style: TextStyle(color: tipo == 'Ingreso' ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(icon: const Icon(Icons.copy, color: Colors.blue, size: 20), onPressed: () => _duplicarTransaccion(data), tooltip: 'Duplicar'),
                                        IconButton(icon: const Icon(Icons.call_split, color: Colors.orange, size: 20), onPressed: () => _dividirTransaccion(doc.id, data), tooltip: 'Dividir'),
                                        IconButton(icon: Icon(reconciliada ? Icons.check_circle : Icons.radio_button_unchecked, color: reconciliada ? Colors.green : Colors.grey, size: 20), onPressed: () => _toggleReconciliar(doc.id, reconciliada)),
                                        IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _mostrarFormularioTransaccion(transaccion: data, docId: doc.id)),
                                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _eliminarTransaccion(doc.id, data['concepto'])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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

  Future<void> _toggleReconciliar(String id, bool actual) async {
    await _firestore.collection('transacciones').doc(id).update({'reconciliada': !actual});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(!actual ? '✅ Reconciliada' : '↩️ Desmarcada'), backgroundColor: !actual ? Colors.green : Colors.grey));
  }

  Future<void> _dividirTransaccion(String id, Map<String, dynamic> data) async {
    final divisiones = (data['divisiones'] as List?)?.map((d) => Map<String, dynamic>.from(d as Map)).toList() ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.call_split, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('✂️ Dividir Transacción', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Total: \$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...divisiones.asMap().entries.map((entry) {
                final idx = entry.key;
                final div = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(child: Text(div['categoria'] ?? '', style: const TextStyle(color: Colors.white))),
                      Text('\$${(div['monto'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        onPressed: () {
                          divisiones.removeAt(idx);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF0066FF)),
                    onPressed: () { setSheetState(() {}); },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _firestore.collection('transacciones').doc(id).update({'divisiones': divisiones});
                    Navigator.pop(ctx);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Transacción dividida'), backgroundColor: Colors.green));
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Guardar Divisiones', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _duplicarTransaccion(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('transacciones').add({
        'concepto': '${data['concepto']} (copia)',
        'monto': data['monto'] ?? 0,
        'categoria': data['categoria'] ?? 'General',
        'fecha': DateTime.now().toIso8601String().split('T')[0],
        'descripcion': data['descripcion'] ?? '',
        'metodo_pago': data['metodo_pago'] ?? 'Efectivo',
        'referencia': data['referencia'] ?? '',
        'tipo': data['tipo'] ?? 'Ingreso',
        'cuenta': data['cuenta'] ?? 'Efectivo',
        'negocio': data['negocio'] ?? 'Minerales',
        'acreedor': data['acreedor'] ?? '',
        'reconciliada': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Transacción duplicada'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildCuentas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💳 Mis Cuentas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: _cuentas.length,
                  itemBuilder: (context, index) {
                    final cuenta = _cuentas[index];
                    double ingresos = 0, gastos = 0;
                    int numTransacciones = 0;
                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['cuenta'] == cuenta['nombre']) {
                        final monto = (data['monto'] ?? 0).toDouble();
                        if (data['tipo'] == 'Ingreso') ingresos += monto;
                        if (data['tipo'] == 'Gasto') gastos += monto;
                        numTransacciones++;
                      }
                    }
                    final balance = ingresos - gastos;
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
                                Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 14)),
                                Text('$numTransacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
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
    );
  }

  Widget _buildCalendarioCompleto() {
    DateTime _mesSeleccionado = DateTime.now();
    return StatefulBuilder(
      builder: (context, setSheetState) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => setSheetState(() => _mesSeleccionado = DateTime(_mesSeleccionado.year, _mesSeleccionado.month - 1))),
                Text('${_mesSeleccionado.year} - ${['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][_mesSeleccionado.month - 1]}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => setSheetState(() => _mesSeleccionado = DateTime(_mesSeleccionado.year, _mesSeleccionado.month + 1))),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  final transaccionesDelMes = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final fechaStr = data['fecha'] as String? ?? '';
                    if (fechaStr.length >= 7) {
                      final fechaParts = fechaStr.split('-');
                      if (fechaParts.length >= 2) {
                        final anio = int.tryParse(fechaParts[0]);
                        final mes = int.tryParse(fechaParts[1]);
                        return anio == _mesSeleccionado.year && mes == _mesSeleccionado.month;
                      }
                    }
                    return false;
                  }).toList();
                  
                  if (transaccionesDelMes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey, size: 64),
                          SizedBox(height: 16),
                          Text('No hay transacciones este mes', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  
                  Map<String, List<Map<String, dynamic>>> porDia = {};
                  for (var doc in transaccionesDelMes) {
                    final data = doc.data() as Map<String, dynamic>;
                    final fechaStr = data['fecha'] as String? ?? '';
                    if (fechaStr.length >= 10) {
                      final dia = fechaStr.substring(8, 10);
                      if (!porDia.containsKey(dia)) porDia[dia] = [];
                      porDia[dia]!.add(data);
                    }
                  }
                  
                  return ListView(
                    children: porDia.entries.map((entry) {
                      final dia = entry.key;
                      final transacciones = entry.value;
                      double totalDia = 0;
                      for (var t in transacciones) {
                        final monto = (t['monto'] ?? 0).toDouble();
                        if (t['tipo'] == 'Ingreso') totalDia += monto;
                        if (t['tipo'] == 'Gasto') totalDia -= monto;
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(dia, style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold)))),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Día $dia • ${transacciones.length} transacciones', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                Text('\$${totalDia.toStringAsFixed(2)}', style: TextStyle(color: totalDia >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...transacciones.map((t) => Padding(
                              padding: const EdgeInsets.only(left: 52, top: 4),
                              child: Row(
                                children: [
                                  Icon(t['tipo'] == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: t['tipo'] == 'Ingreso' ? Colors.green : Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(t['concepto'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12))),
                                  Text('\$${(t['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: t['tipo'] == 'Ingreso' ? Colors.green : Colors.red, fontSize: 12)),
                                ],
                              ),
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Resumen Financiero', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGraficaCircularMoneyPro(),
            const SizedBox(height: 24),
            const Text('💵 Flujo de Caja', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFlujoDeCaja(),
            const SizedBox(height: 24),
            const Text('📈 Comparativo Mensual', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
              PieChartSectionData(value: totalIngresos, title: totalIngresos + totalGastos > 0 ? '${((totalIngresos / (totalIngresos + totalGastos)) * 100).toStringAsFixed(0)}%' : '0%', color: Colors.green, radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              PieChartSectionData(value: totalGastos, title: totalIngresos + totalGastos > 0 ? '${((totalGastos / (totalIngresos + totalGastos)) * 100).toStringAsFixed(0)}%' : '0%', color: Colors.red, radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ];
            break;
          case 1:
            sections = ingresosPorCategoria.entries.map((e) {
              final idx = ingresosPorCategoria.keys.toList().indexOf(e.key);
              return PieChartSectionData(value: e.value, title: totalIngresos > 0 ? '${((e.value / totalIngresos) * 100).toStringAsFixed(0)}%' : '0%', color: colors[idx % colors.length], radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
            }).toList();
            break;
          case 2:
            sections = gastosPorCategoria.entries.map((e) {
              final idx = gastosPorCategoria.keys.toList().indexOf(e.key);
              return PieChartSectionData(value: e.value, title: totalGastos > 0 ? '${((e.value / totalGastos) * 100).toStringAsFixed(0)}%' : '0%', color: colors[idx % colors.length], radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
            }).toList();
            break;
          case 3:
            sections = [PieChartSectionData(value: totalActivos, title: '100%', color: Colors.green, radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))];
            break;
          case 4:
            sections = porCuenta.entries.map((e) {
              final idx = porCuenta.keys.toList().indexOf(e.key);
              return PieChartSectionData(value: e.value.abs(), title: totalActivos > 0 ? '${((e.value.abs() / totalActivos) * 100).toStringAsFixed(0)}%' : '0%', color: colors[idx % colors.length], radius: 110, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
            }).toList();
            break;
          default:
            sections = [];
        }
        
        List<Map<String, dynamic>> items;
        switch (_vistaActual) {
          case 0:
            items = [
              {'label': 'Ingresos', 'value': '\$${totalIngresos.toStringAsFixed(2)}', 'color': Colors.green},
              {'label': 'Gastos', 'value': '\$${totalGastos.toStringAsFixed(2)}', 'color': Colors.red},
            ];
            break;
          case 1:
            items = ingresosPorCategoria.entries.map((e) {
              final idx = ingresosPorCategoria.keys.toList().indexOf(e.key);
              return {'label': e.key.toUpperCase(), 'value': '\$${e.value.toStringAsFixed(2)}', 'color': colors[idx % colors.length]};
            }).toList();
            break;
          case 2:
            items = gastosPorCategoria.entries.map((e) {
              final idx = gastosPorCategoria.keys.toList().indexOf(e.key);
              return {'label': e.key.toUpperCase(), 'value': '\$${e.value.toStringAsFixed(2)}', 'color': colors[idx % colors.length]};
            }).toList();
            break;
          case 3:
            items = [{'label': 'Total Activos', 'value': '\$${totalActivos.toStringAsFixed(2)}', 'color': Colors.green}];
            break;
          case 4:
            items = porCuenta.entries.map((e) {
              final idx = porCuenta.keys.toList().indexOf(e.key);
              return {'label': e.key.toUpperCase(), 'value': '\$${e.value.toStringAsFixed(2)}', 'color': colors[idx % colors.length]};
            }).toList();
            break;
          default:
            items = [];
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
                        : PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 80, startDegreeOffset: 270)),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: item['color'] as Color, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item['label'] as String, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          Text(item['value'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
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

  Widget _buildFlujoDeCaja() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        double ingresos = 0, gastos = 0;
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final monto = (data['monto'] ?? 0).toDouble();
          if (data['tipo'] == 'Ingreso') ingresos += monto;
          if (data['tipo'] == 'Gasto') gastos += monto;
        }
        final flujo = ingresos - gastos;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${ingresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold))]),
              Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${gastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold))]),
              Column(children: [const Text('Flujo', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${flujo.toStringAsFixed(2)}', style: TextStyle(color: flujo >= 0 ? Colors.green : Colors.red, fontSize: 20, fontWeight: FontWeight.bold))]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraficoBarras() {
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
            if (data['tipo'] == 'Ingreso') {
              ingresosPorMes[mes] = (ingresosPorMes[mes] ?? 0) + monto;
            } else {
              gastosPorMes[mes] = (gastosPorMes[mes] ?? 0) + monto;
            }
          }
        }
        final meses = ingresosPorMes.keys.toList()..sort();
        if (meses.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(
              meses.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(toY: ingresosPorMes[meses[i]] ?? 0, color: Colors.green, width: 16),
                  BarChartRodData(toY: gastosPorMes[meses[i]] ?? 0, color: Colors.red, width: 16),
                ],
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < meses.length) return Text(meses[idx].substring(5), style: const TextStyle(color: Colors.grey, fontSize: 10));
                    return const Text('');
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        );
      },
    );
  }

  void _mostrarPresupuestosEditables() {
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
                const Expanded(child: Text('📊 Presupuestos Editables', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Toca el ícono de editar para modificar el presupuesto de cada categoría', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                    itemCount: _categoriasGasto.length,
                    itemBuilder: (context, index) {
                      final cat = _categoriasGasto[index];
                      final gastadoCat = gastado[cat['nombre']] ?? 0.0;
                      final presupuesto = cat['presupuesto'] as double;
                      final porcentaje = (gastadoCat / presupuesto * 100).clamp(0, 100);
                      final excedido = gastadoCat > presupuesto;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(cat['icon'] as IconData, color: const Color(0xFF0066FF)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(cat['nombre'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                Text('\$${gastadoCat.toStringAsFixed(0)} / \$${presupuesto.toStringAsFixed(0)}', style: TextStyle(color: excedido ? Colors.red : Colors.green, fontSize: 11)),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 18),
                                  onPressed: () => _editarPresupuesto(ctx, cat['nombre'] as String, presupuesto),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: porcentaje / 100,
                                backgroundColor: Colors.grey.shade800,
                                valueColor: AlwaysStoppedAnimation<Color>(excedido ? Colors.red : const Color(0xFF0066FF)),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${porcentaje.toStringAsFixed(1)}% utilizado${excedido ? ' ⚠️ EXCEDIDO' : ''}', style: TextStyle(color: excedido ? Colors.red : Colors.grey, fontSize: 11)),
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

  Future<void> _editarPresupuesto(BuildContext ctx, String categoria, double actual) async {
    final controller = TextEditingController(text: actual.toStringAsFixed(0));
    await showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Editar presupuesto: $categoria', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nuevo presupuesto',
            labelStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF111111),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
            },
            child: const Text('Guardar', style: TextStyle(color: Color(0xFF0066FF))),
          ),
        ],
      ),
    );
    final nuevo = double.tryParse(controller.text);
    if (nuevo != null) {
      setState(() {
        final idx = _categoriasGasto.indexWhere((c) => c['nombre'] == categoria);
        if (idx != -1) _categoriasGasto[idx]['presupuesto'] = nuevo;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Presupuesto de $categoria actualizado a \$${nuevo.toStringAsFixed(0)}'), backgroundColor: Colors.green));
    }
  }

  void _mostrarMetasEditables() {
    final nombreCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
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
                const Icon(Icons.flag, color: Color(0xFF0066FF), size: 28),
                const SizedBox(width: 12),
                const Expanded(child: Text('🏆 Metas Editables', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Crea metas y actualiza el progreso manualmente', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nueva Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: 'Nombre de la meta', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: montoCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: 'Monto objetivo', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (nombreCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
                        await _firestore.collection('metas').add({'nombre': nombreCtrl.text.trim(), 'objetivo': double.tryParse(montoCtrl.text) ?? 0, 'actual': 0, 'created_at': FieldValue.serverTimestamp()});
                        Navigator.pop(ctx);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Meta creada'), backgroundColor: Colors.green));
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Crear Meta', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Mis Metas (toca para editar progreso)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('metas').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No hay metas creadas', style: TextStyle(color: Colors.grey)));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final nombre = data['nombre'] ?? 'Sin nombre';
                      final objetivo = (data['objetivo'] ?? 0).toDouble();
                      final actual = (data['actual'] ?? 0).toDouble();
                      final porcentaje = objetivo > 0 ? (actual / objetivo * 100).clamp(0, 100) : 0;
                      final completada = actual >= objetivo;
                      return GestureDetector(
                        onTap: () => _editarMeta(docs[index].id, nombre, objetivo, actual),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(completada ? Icons.check_circle : Icons.flag, color: completada ? Colors.green : const Color(0xFF0066FF)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 18), onPressed: () => _editarMeta(docs[index].id, nombre, objetivo, actual)),
                                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () async { await _firestore.collection('metas').doc(docs[index].id).delete(); }),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('\$${actual.toStringAsFixed(0)} / \$${objetivo.toStringAsFixed(0)}', style: TextStyle(color: completada ? Colors.green : Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: porcentaje / 100,
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(completada ? Colors.green : const Color(0xFF0066FF)),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${porcentaje.toStringAsFixed(1)}% completado${completada ? ' ✅' : ''}', style: TextStyle(color: completada ? Colors.green : Colors.grey, fontSize: 11)),
                            ],
                          ),
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

  Future<void> _editarMeta(String id, String nombre, double objetivo, double actual) async {
    final controller = TextEditingController(text: actual.toStringAsFixed(2));
    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Editar progreso: $nombre', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Objetivo: \$${objetivo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Monto actual ahorrado',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () { Navigator.pop(dialogCtx); }, child: const Text('Guardar', style: TextStyle(color: Color(0xFF0066FF)))),
        ],
      ),
    );
    final nuevo = double.tryParse(controller.text);
    if (nuevo != null) {
      await _firestore.collection('metas').doc(id).update({'actual': nuevo});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Progreso actualizado a \$${nuevo.toStringAsFixed(2)}'), backgroundColor: Colors.green));
    }
  }

  void _mostrarRecurrentesEditables() {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    final categoriaCtrl = TextEditingController(text: 'General');
    String tipoRec = 'Gasto';
    String frecuenciaRec = 'Mensual';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.repeat, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('🔄 Recurrentes Editables', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Crea transacciones recurrentes y edítalas tocando el ícono de editar', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nueva Transacción Recurrente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Concepto', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none))),
                    const SizedBox(height: 8),
                    TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Monto', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none))),
                    const SizedBox(height: 8),
                    TextField(controller: categoriaCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Categoría', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: tipoRec,
                            decoration: InputDecoration(labelText: 'Tipo', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
                            dropdownColor: const Color(0xFF1A1A1A),
                            style: const TextStyle(color: Colors.white),
                            items: ['Ingreso', 'Gasto'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setSheetState(() => tipoRec = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: frecuenciaRec,
                            decoration: InputDecoration(labelText: 'Frecuencia', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF111111), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
                            dropdownColor: const Color(0xFF1A1A1A),
                            style: const TextStyle(color: Colors.white),
                            items: ['Semanal', 'Mensual', 'Anual'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (v) => setSheetState(() => frecuenciaRec = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (conceptoCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
                          await _firestore.collection('recurrentes').add({'concepto': conceptoCtrl.text.trim(), 'monto': double.tryParse(montoCtrl.text) ?? 0, 'categoria': categoriaCtrl.text.trim(), 'tipo': tipoRec, 'frecuencia': frecuenciaRec, 'activa': true, 'created_at': FieldValue.serverTimestamp()});
                          Navigator.pop(ctx);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Recurrente creada'), backgroundColor: Colors.green));
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Crear Recurrente', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Mis Recurrentes (toca editar para modificar)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('recurrentes').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) return const Center(child: Text('No hay transacciones recurrentes', style: TextStyle(color: Colors.grey)));
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final concepto = data['concepto'] ?? 'Sin concepto';
                        final monto = (data['monto'] ?? 0).toDouble();
                        final frecuencia = data['frecuencia'] ?? 'Mensual';
                        final tipo = data['tipo'] ?? 'Gasto';
                        final activa = data['activa'] ?? true;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(color: (tipo == 'Ingreso' ? Colors.green : Colors.red).withOpacity(0.2), shape: BoxShape.circle), child: Icon(tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward, color: tipo == 'Ingreso' ? Colors.green : Colors.red, size: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(concepto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text('$frecuencia • \$${monto.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(icon: Icon(activa ? Icons.toggle_on : Icons.toggle_off, color: activa ? Colors.green : Colors.grey, size: 28), onPressed: () async { await _firestore.collection('recurrentes').doc(docs[index].id).update({'activa': !activa}); }),
                              IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 20), onPressed: () => _editarRecurrente(docs[index].id, data)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () async { await _firestore.collection('recurrentes').doc(docs[index].id).delete(); }),
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
      ),
    );
  }

  Future<void> _editarRecurrente(String id, Map<String, dynamic> data) async {
    final conceptoCtrl = TextEditingController(text: data['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: (data['monto'] ?? 0).toString());
    final categoriaCtrl = TextEditingController(text: data['categoria'] ?? 'General');
    String tipo = data['tipo'] ?? 'Gasto';
    String frecuencia = data['frecuencia'] ?? 'Mensual';
    
    await showModalBottomSheet(
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
              Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFF0066FF), size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Editar Recurrente', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Concepto', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none))),
              const SizedBox(height: 8),
              TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Monto', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none))),
              const SizedBox(height: 8),
              TextField(controller: categoriaCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Categoría', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: tipo,
                      decoration: InputDecoration(labelText: 'Tipo', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      items: ['Ingreso', 'Gasto'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setSheetState(() => tipo = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: frecuencia,
                      decoration: InputDecoration(labelText: 'Frecuencia', labelStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none)),
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      items: ['Semanal', 'Mensual', 'Anual'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) => setSheetState(() => frecuencia = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _firestore.collection('recurrentes').doc(id).update({'concepto': conceptoCtrl.text.trim(), 'monto': double.tryParse(montoCtrl.text) ?? 0, 'categoria': categoriaCtrl.text.trim(), 'tipo': tipo, 'frecuencia': frecuencia});
                    Navigator.pop(ctx);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Recurrente actualizada'), backgroundColor: Colors.green));
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarVistaHoy() { _tabController.animateTo(0); }

  void _mostrarReconciliacionEditable() {
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
                const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 28),
                const SizedBox(width: 12),
                const Expanded(child: Text('✅ Reconciliar (Editable)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Marca/desmarca las transacciones que verificaste con tu estado de cuenta', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final reconciliada = data['reconciliada'] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222))),
                        child: Row(
                          children: [
                            Checkbox(
                              value: reconciliada,
                              activeColor: Colors.green,
                              onChanged: (v) async {
                                await _firestore.collection('transacciones').doc(doc.id).update({'reconciliada': v ?? false});
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v == true ? '✅ Reconciliada' : '↩️ Desmarcada'), backgroundColor: v == true ? Colors.green : Colors.grey));
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['concepto'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('${data['categoria'] ?? ''} • ${data['fecha'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: data['tipo'] == 'Ingreso' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
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

  void _mostrarInformesEditables() {
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
                const Icon(Icons.analytics, color: Color(0xFF0066FF), size: 28),
                const SizedBox(width: 12),
                const Expanded(child: Text('📊 Informes Editables', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildInformeItemEditable('📈 Ingresos/Gastos', 'Ver y editar resumen por periodo', Icons.show_chart, () => _verInformeIngresosGastos(ctx)),
                  _buildInformeItemEditable('💵 Flujo de Caja', 'Entradas y salidas de efectivo', Icons.currency_exchange, () => _verInformeFlujoCaja(ctx)),
                  _buildInformeItemEditable('📋 Transacciones', 'Listado detallado editable', Icons.receipt_long, () => _verInformeTransacciones(ctx)),
                  _buildInformeItemEditable('💳 Activos/Pasivos', 'Balance de cuentas', Icons.account_balance, () => _verInformeActivos(ctx)),
                  _buildInformeItemEditable('📈 Saldo Proyectado', 'Proyección futura', Icons.trending_up, () => _verInformeProyeccion(ctx)),
                  _buildInformeItemEditable('📅 Tendencia', 'Gráfico por periodos', Icons.date_range, () => _verInformeTendencia(ctx)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformeItemEditable(String titulo, String descripcion, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0066FF), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(descripcion, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _verInformeIngresosGastos(BuildContext ctx) { Navigator.pop(ctx); _tabController.animateTo(6); }
  void _verInformeFlujoCaja(BuildContext ctx) { Navigator.pop(ctx); _tabController.animateTo(6); }
  void _verInformeTransacciones(BuildContext ctx) { Navigator.pop(ctx); _tabController.animateTo(2); }
  void _verInformeActivos(BuildContext ctx) { Navigator.pop(ctx); _tabController.animateTo(4); }
  void _verInformeTendencia(BuildContext ctx) { Navigator.pop(ctx); _tabController.animateTo(6); }

  void _verInformeProyeccion(BuildContext ctx) {
    Navigator.pop(ctx);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('📈 Saldo Proyectado', style: TextStyle(color: Colors.white)),
        content: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('transacciones').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            double ingresos = 0, gastos = 0;
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final monto = (data['monto'] ?? 0).toDouble();
              if (data['tipo'] == 'Ingreso') ingresos += monto;
              if (data['tipo'] == 'Gasto') gastos += monto;
            }
            final proyectado = (ingresos - gastos) * 1.1;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingresos actuales: \$${ingresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 8),
                Text('Gastos actuales: \$${gastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                Text('Balance actual: \$${(ingresos - gastos).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Proyección próximo mes (+10%):', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('\$${proyectado.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF0066FF), fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cerrar', style: TextStyle(color: Colors.white)))],
      ),
    );
  }

  void _mostrarCalendario() { _tabController.animateTo(5); }

  Future<void> _importarCSV() async {
    final input = html.FileUploadInputElement()..accept = '.csv';
    input.click();
    input.onChange.listen((e) async {
      final files = input.files;
      if (files == null || files.isEmpty) return;
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoadEnd.listen((e) async {
        final content = reader.result as String;
        final lines = content.split('\n');
        int importados = 0;
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(',');
          if (parts.length >= 8) {
            try {
              await _firestore.collection('transacciones').add({
                'fecha': parts[0].trim(),
                'tipo': parts[1].trim(),
                'concepto': parts[2].trim().replaceAll('"', ''),
                'categoria': parts[3].trim().replaceAll('"', ''),
                'acreedor': parts.length > 4 ? parts[4].trim().replaceAll('"', '') : '',
                'cuenta': parts.length > 5 ? parts[5].trim().replaceAll('"', '') : 'Efectivo',
                'negocio': parts.length > 6 ? parts[6].trim().replaceAll('"', '') : 'Minerales',
                'monto': double.tryParse(parts[parts.length - 4]?.trim() ?? '0') ?? 0,
                'metodo_pago': parts.length > 7 ? parts[7].trim().replaceAll('"', '') : 'Efectivo',
                'referencia': parts.length > 8 ? parts[8].trim().replaceAll('"', '') : '',
                'descripcion': parts.length > 9 ? parts[9].trim().replaceAll('"', '') : '',
                'reconciliada': false,
                'importada': true,
                'created_at': FieldValue.serverTimestamp(),
              });
              importados++;
            } catch (e) {
              print('Error importando línea $i: $e');
            }
          }
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $importados transacciones importadas'), backgroundColor: Colors.green));
      });
    });
  }

  Future<void> _exportarCSV() async {
    try {
      final snapshot = await _firestore.collection('transacciones').orderBy('created_at', descending: true).get();
      final buffer = StringBuffer();
      buffer.writeln('Fecha,Tipo,Concepto,Categoría,Acreedor,Cuenta,Negocio,Monto,Método de Pago,Referencia,Descripción,Reconciliada');
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        buffer.writeln('${data['fecha'] ?? ''},${data['tipo'] ?? ''},"${data['concepto'] ?? ''}","${data['categoria'] ?? ''}","${data['acreedor'] ?? ''}","${data['cuenta'] ?? ''}","${data['negocio'] ?? 'Minerales'}",${data['monto'] ?? 0},"${data['metodo_pago'] ?? ''}","${data['referencia'] ?? ''}","${data['descripcion'] ?? ''}",${data['reconciliada'] ?? false}');
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
    final subcategoriaCtrl = TextEditingController(text: transaccion?['subcategoria'] ?? '');
    final fechaCtrl = TextEditingController(text: transaccion?['fecha'] ?? DateTime.now().toIso8601String().split('T')[0]);
    final descripcionCtrl = TextEditingController(text: transaccion?['descripcion'] ?? '');
    final metodoPagoCtrl = TextEditingController(text: transaccion?['metodo_pago'] ?? 'Efectivo');
    final referenciaCtrl = TextEditingController(text: transaccion?['referencia'] ?? '');
    final acreedorCtrl = TextEditingController(text: transaccion?['acreedor'] ?? '');
    final beneficiarioCtrl = TextEditingController(text: transaccion?['beneficiario'] ?? '');
    final numChequeCtrl = TextEditingController(text: transaccion?['num_cheque'] ?? '');
    String tipo = transaccion?['tipo'] ?? 'Ingreso';
    String cuenta = transaccion?['cuenta'] ?? 'Efectivo';
    String negocio = transaccion?['negocio'] ?? 'Minerales';
    bool reconciliada = transaccion?['reconciliada'] ?? false;
    
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
                Row(
                  children: [
                    Icon(transaccion == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF0066FF), size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text(transaccion == null ? 'Nueva Transacción' : 'Editar Transacción', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSeccion('💰 Información'),
                _buildCampo('Concepto *', conceptoCtrl, icon: Icons.description),
                _buildCampo('Monto', montoCtrl, icon: Icons.attach_money, tipo: TextInputType.number),
                _buildCampo('Acreedor', acreedorCtrl, icon: Icons.person),
                _buildCampo('Beneficiario', beneficiarioCtrl, icon: Icons.person_outline),
                _buildCampo('N° de Cheque', numChequeCtrl, icon: Icons.receipt),
                const SizedBox(height: 12),
                _buildSeccion('📋 Clasificación'),
                Row(
                  children: [
                    Expanded(child: RadioListTile<String>(title: const Text('Ingreso', style: TextStyle(color: Colors.white)), value: 'Ingreso', groupValue: tipo, activeColor: Colors.green, onChanged: (v) => setSheetState(() => tipo = v!))),
                    Expanded(child: RadioListTile<String>(title: const Text('Gasto', style: TextStyle(color: Colors.white)), value: 'Gasto', groupValue: tipo, activeColor: Colors.red, onChanged: (v) => setSheetState(() => tipo = v!))),
                  ],
                ),
                _buildDropdownCategoria(categoriaCtrl, tipo),
                _buildCampo('Subcategoría', subcategoriaCtrl, icon: Icons.subdirectory_arrow_right),
                _buildCampo('Fecha', fechaCtrl, icon: Icons.calendar_today),
                const SizedBox(height: 12),
                _buildSeccion('💳 Cuenta'),
                DropdownButtonFormField<String>(
                  value: cuenta,
                  decoration: InputDecoration(labelText: 'Cuenta', labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setSheetState(() => cuenta = v!),
                ),
                const SizedBox(height: 12),
                _buildSeccion('🏢 Negocio'),
                DropdownButtonFormField<String>(
                  value: negocio,
                  decoration: InputDecoration(labelText: 'Negocio', labelStyle: const TextStyle(color: Colors.grey), prefixIcon: const Icon(Icons.business, color: Color(0xFF0066FF)), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: ['Minerales', 'Combustible', 'Agropecuario', 'Proyectos'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setSheetState(() => negocio = v!),
                ),
                const SizedBox(height: 12),
                _buildSeccion('💳 Método de Pago'),
                _buildCampo('Método de Pago', metodoPagoCtrl, icon: Icons.credit_card),
                _buildCampo('Referencia / Folio', referenciaCtrl, icon: Icons.receipt),
                const SizedBox(height: 12),
                _buildSeccion('📝 Detalles'),
                _buildCampoMultilinea('Descripción', descripcionCtrl),
                CheckboxListTile(
                  title: const Text('Marcar como reconciliada', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('La transacción ha sido verificada', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: reconciliada,
                  activeColor: Colors.green,
                  onChanged: (v) => setSheetState(() => reconciliada = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _guardarTransaccion(ctx, conceptoCtrl, montoCtrl, categoriaCtrl, subcategoriaCtrl, fechaCtrl, descripcionCtrl, metodoPagoCtrl, referenciaCtrl, acreedorCtrl, beneficiarioCtrl, numChequeCtrl, tipo, cuenta, negocio, reconciliada, docId),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(transaccion == null ? 'Crear Transacción' : 'Guardar Cambios', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildDropdownCategoria(TextEditingController ctrl, String tipo) {
    final categorias = tipo == 'Ingreso' ? _categoriasIngreso : _categoriasGasto;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: categorias.any((c) => c['nombre'] == ctrl.text) ? ctrl.text : categorias.first['nombre'],
        decoration: InputDecoration(
          labelText: 'Categoría',
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(categorias.first['icon'] as IconData, color: const Color(0xFF0066FF)),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        dropdownColor: const Color(0xFF1A1A1A),
        style: const TextStyle(color: Colors.white),
        items: categorias.map((cat) => DropdownMenuItem(value: cat['nombre'] as String, child: Row(children: [Icon(cat['icon'] as IconData, color: const Color(0xFF0066FF), size: 20), const SizedBox(width: 8), Text(cat['nombre'] as String)]))).toList(),
        onChanged: (v) => ctrl.text = v ?? '',
      ),
    );
  }

  Widget _buildSeccion(String titulo) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(titulo, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 14, fontWeight: FontWeight.bold)));
  }

  Widget _buildCampo(String label, TextEditingController ctrl, {IconData? icon, TextInputType? tipo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0066FF)) : null,
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCampoMultilinea(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.notes, color: Color(0xFF0066FF)),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<void> _guardarTransaccion(BuildContext ctx, TextEditingController concepto, TextEditingController monto, TextEditingController categoria, TextEditingController subcategoria, TextEditingController fecha, TextEditingController descripcion, TextEditingController metodoPago, TextEditingController referencia, TextEditingController acreedor, TextEditingController beneficiario, TextEditingController numCheque, String tipo, String cuenta, String negocio, bool reconciliada, String? docId) async {
    if (concepto.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El concepto es obligatorio'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final data = {
        'concepto': concepto.text.trim(),
        'monto': double.tryParse(monto.text) ?? 0,
        'categoria': categoria.text.trim(),
        'subcategoria': subcategoria.text.trim(),
        'fecha': fecha.text.trim(),
        'descripcion': descripcion.text.trim(),
        'metodo_pago': metodoPago.text.trim(),
        'referencia': referencia.text.trim(),
        'acreedor': acreedor.text.trim(),
        'beneficiario': beneficiario.text.trim(),
        'num_cheque': numCheque.text.trim(),
        'tipo': tipo,
        'cuenta': cuenta,
        'negocio': negocio,
        'reconciliada': reconciliada,
      };
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar Transacción', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "$concepto"?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('transacciones').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }
}