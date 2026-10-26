import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:intl/intl.dart';

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
  final Set<String> _tagsDisponibles = {'#urgente', '#deducible', '#cliente', '#personal', '#negocio', '#importante', '#revisar'};

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
    {'nombre': 'Préstamos'}, {'nombre': 'Personal'}, {'nombre': 'Adair'}, {'nombre': 'Capacitación'},
    {'nombre': 'Deudas'}, {'nombre': 'Mobiliario'}, {'nombre': 'Alquiler'}, {'nombre': 'Transporte'},
    {'nombre': 'Insumos de Oficina'}, {'nombre': 'Recarga'}, {'nombre': 'Uber'}, {'nombre': 'Propina'}, {'nombre': 'Otros'},
  ];
  final List<Map<String, dynamic>> _categoriasIngreso = [
    {'nombre': 'Proyecto'}, {'nombre': 'Deslinde'}, {'nombre': 'Comisiones'}, {'nombre': 'Renta'}, {'nombre': 'Servicios'}, {'nombre': 'Otros'},
  ];

  @override
  void initState() { super.initState(); _tabController = TabController(length: 11, vsync: this); _cargarPresupuestos(); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _cargarPresupuestos() async {
    try {
      final snap = await _firestore.collection('presupuestos_personalizados').get();
      setState(() {
        _presupuestosPersonalizados = snap.docs.map((doc) {
          final d = doc.data();
          return {'id': doc.id, 'nombre': d['nombre'] ?? '', 'presupuesto': (d['presupuesto'] ?? 0).toDouble(), 'gastado': (d['gastado'] ?? 0).toDouble(), 'cuenta': d['cuenta'] ?? 'Efectivo', 'subcuenta': d['subcuenta'] ?? 'Proyectos', 'aplicado': d['aplicado'] ?? false};
        }).toList();
      });
    } catch (e) { print(e); }
  }

  Future<void> _agregarPresupuesto(String nombre, double monto, double gastado, String cuenta, String subcuenta) async {
    await _firestore.collection('presupuestos_personalizados').add({'nombre': nombre, 'presupuesto': monto, 'gastado': gastado, 'cuenta': cuenta, 'subcuenta': subcuenta, 'aplicado': false, 'created_at': FieldValue.serverTimestamp()});
    await _cargarPresupuestos();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Presupuesto creado'), backgroundColor: Colors.green));
  }

  Future<void> _eliminarPresupuesto(String id) async {
    await _firestore.collection('presupuestos_personalizados').doc(id).delete();
    await _cargarPresupuestos();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
  }

  Future<void> _toggleAplicar(String id, bool aplicar, String nombre, double monto, String cuenta, String subcuenta) async {
    if (aplicar) {
      await _firestore.collection('transacciones').add({'concepto': 'Presupuesto: $nombre', 'monto': monto, 'categoria': nombre, 'tipo': 'Gasto', 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'reconciliada': true, 'created_at': FieldValue.serverTimestamp()});
      await _firestore.collection('transacciones').add({'concepto': 'Transferencia: $nombre', 'monto': monto, 'categoria': 'Transferencia', 'tipo': 'Ingreso', 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'reconciliada': true, 'created_at': FieldValue.serverTimestamp()});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Aplicado \$${monto.toStringAsFixed(2)}'), backgroundColor: Colors.green));
    }
    await _firestore.collection('presupuestos_personalizados').doc(id).update({'aplicado': aplicar});
    await _cargarPresupuestos();
  }

  Future<void> _generarDatosEjemplo() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Generar Datos', style: TextStyle(color: Colors.white)), content: const Text('¿Crear 80 transacciones + presupuestos + metas?', style: TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí'))]));
    if (confirm != true) return;
    final now = DateTime.now();
    final Map<String, List<Map<String, dynamic>>> datos = {
      'Minerales': [{'concepto': 'Venta cobre', 'monto': 45000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Venta oro', 'monto': 78000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Venta plata', 'monto': 32000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Venta zinc', 'monto': 28000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Consultoría', 'monto': 15000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Maquinaria', 'monto': 25000.0, 'categoria': 'Mobiliario', 'tipo': 'Gasto'}, {'concepto': 'Combustible equipos', 'monto': 8500.0, 'categoria': 'Transporte', 'tipo': 'Gasto'}, {'concepto': 'Salario mina', 'monto': 15000.0, 'categoria': 'Personal', 'tipo': 'Gasto'}, {'concepto': 'Permiso ambiental', 'monto': 5000.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Mantenimiento', 'monto': 12000.0, 'categoria': 'Otros', 'tipo': 'Gasto'}],
      'Combustible': [{'concepto': 'Venta gasolina', 'monto': 52000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Venta diesel', 'monto': 68000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Lubricantes', 'monto': 15000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Aditivos', 'monto': 8500.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Carga', 'monto': 12000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Compra combustible', 'monto': 85000.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Transporte', 'monto': 6500.0, 'categoria': 'Transporte', 'tipo': 'Gasto'}, {'concepto': 'Tanques', 'monto': 4000.0, 'categoria': 'Alquiler', 'tipo': 'Gasto'}, {'concepto': 'Bombas', 'monto': 3200.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Personal estación', 'monto': 9000.0, 'categoria': 'Personal', 'tipo': 'Gasto'}],
      'Agropecuario': [{'concepto': 'Cosecha maíz', 'monto': 35000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Venta ganado', 'monto': 42000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Leche', 'monto': 18000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Hortalizas', 'monto': 22000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Subsidio', 'monto': 8000.0, 'categoria': 'Otros', 'tipo': 'Ingreso'}, {'concepto': 'Fertilizantes', 'monto': 8500.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Alimento ganado', 'monto': 12000.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Riego', 'monto': 3500.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Maquinaria agrícola', 'monto': 25000.0, 'categoria': 'Mobiliario', 'tipo': 'Gasto'}, {'concepto': 'Personal campo', 'monto': 7500.0, 'categoria': 'Personal', 'tipo': 'Gasto'}],
      'Proyectos': [{'concepto': 'Consultoría', 'monto': 25000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Software', 'monto': 45000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Capacitación', 'monto': 18000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Cliente A', 'monto': 35000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso'}, {'concepto': 'Asesoría', 'monto': 12000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso'}, {'concepto': 'Oficina', 'monto': 5000.0, 'categoria': 'Alquiler', 'tipo': 'Gasto'}, {'concepto': 'Equipos', 'monto': 15000.0, 'categoria': 'Mobiliario', 'tipo': 'Gasto'}, {'concepto': 'Licencias', 'monto': 4500.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Marketing', 'monto': 6000.0, 'categoria': 'Otros', 'tipo': 'Gasto'}, {'concepto': 'Admin', 'monto': 12000.0, 'categoria': 'Personal', 'tipo': 'Gasto'}],
    };
    for (var neg in _negocios) {
      final lista = datos[neg] ?? [];
      for (int i = 0; i < lista.length; i++) {
        final d = lista[i]; final f = now.subtract(Duration(days: i * 3 + _negocios.indexOf(neg) * 10));
        await _firestore.collection('transacciones').add({'concepto': d['concepto'], 'monto': d['monto'], 'categoria': d['categoria'], 'tipo': d['tipo'], 'cuenta': i % 2 == 0 ? 'Banco' : 'Efectivo', 'subcuenta': neg, 'negocio': neg, 'fecha': '${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}', 'descripcion': 'Ejemplo $neg', 'reconciliada': i % 3 != 0, 'tags': ['#negocio', '#${neg.toLowerCase()}'], 'created_at': FieldValue.serverTimestamp()});
      }
    }
    for (var p in [{'nombre': 'Personal', 'presupuesto': 50000.0, 'gastado': 43500.0}, {'nombre': 'Transporte', 'presupuesto': 15000.0, 'gastado': 15000.0}, {'nombre': 'Mobiliario', 'presupuesto': 30000.0, 'gastado': 25000.0}, {'nombre': 'Alquiler', 'presupuesto': 20000.0, 'gastado': 9000.0}]) {
      await _firestore.collection('presupuestos_personalizados').add({'nombre': p['nombre'], 'presupuesto': p['presupuesto'], 'gastado': p['gastado'], 'cuenta': 'Banco', 'subcuenta': 'Todos', 'aplicado': false, 'created_at': FieldValue.serverTimestamp()});
    }
    for (var m in [{'nombre': 'Fondo emergencia', 'objetivo': 100000.0, 'actual': 25000.0, 'meses': 12}, {'nombre': 'Expansión', 'objetivo': 250000.0, 'actual': 50000.0, 'meses': 18}, {'nombre': 'Maquinaria', 'objetivo': 150000.0, 'actual': 30000.0, 'meses': 12}]) {
      await _firestore.collection('metas').add({'nombre': m['nombre'], 'objetivo': m['objetivo'], 'actual': m['actual'], 'meses': m['meses'], 'created_at': FieldValue.serverTimestamp()});
    }
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 80 transacciones creadas'), backgroundColor: Colors.green)); await _cargarPresupuestos(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: _mostrarFormularioTransaccion),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: _generarDatosEjemplo, tooltip: 'Generar datos'),
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: _mostrarTransferencia, tooltip: 'Transferir'),
          PopupMenuButton<String>(icon: const Icon(Icons.more_vert, color: Colors.white), onSelected: (v) { if (v == 'exportar') _exportarCSV(); else if (v == 'calendario') _tabController.animateTo(6); else if (v == 'hoy') _tabController.animateTo(0); }, itemBuilder: (_) => [const PopupMenuItem(value: 'hoy', child: Text('Vista Hoy')), const PopupMenuItem(value: 'calendario', child: Text('Calendario')), const PopupMenuItem(value: 'exportar', child: Text('Exportar CSV'))]),
        ],
        bottom: TabBar(controller: _tabController, isScrollable: true, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white70, tabs: const [
          Tab(icon: Icon(Icons.today), text: 'Hoy'), Tab(icon: Icon(Icons.dashboard), text: 'Resumen'), Tab(icon: Icon(Icons.dashboard_customize), text: 'Dashboard'),
          Tab(icon: Icon(Icons.arrow_upward), text: 'Ingresos'), Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'), Tab(icon: Icon(Icons.credit_card), text: 'Cuentas'),
          Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'), Tab(icon: Icon(Icons.show_chart), text: 'Reportes'), Tab(icon: Icon(Icons.pie_chart), text: 'Presupuestos'),
          Tab(icon: Icon(Icons.flag), text: 'Metas'), Tab(icon: Icon(Icons.money_off), text: 'Deudas'),
        ]),
      ),
      body: TabBarView(controller: _tabController, children: [
        _buildVistaHoy(), _buildResumen(), _buildDashboard(), _buildLista('Ingreso'), _buildLista('Gasto'),
        _buildCuentas(), _buildCalendario(), _buildReportes(), _buildPresupuestos(), _buildMetas(), _buildDeudas(),
      ]),
    );
  }

  // ============================================
  // PESTAÑA DEUDAS (NUEVA)
  // ============================================
  Widget _buildDeudas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('💳 Deudas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoNuevaDeuda(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva deuda', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('deudas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money_off, color: Colors.grey.shade700, size: 64),
                        const SizedBox(height: 16),
                        const Text('No hay deudas registradas', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }
              double yoDebo = 0, meDeben = 0;
              int vencidas = 0;
              final now = DateTime.now();
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final monto = (data['monto'] ?? 0).toDouble();
                final tipo = data['tipo'] ?? 'me_deben';
                final estado = data['estado'] ?? 'pendiente';
                final fechaVenc = data['fecha_vencimiento'] != null ? (data['fecha_vencimiento'] as Timestamp).toDate() : null;
                if (estado == 'pendiente') {
                  if (tipo == 'yo_debo') yoDebo += monto; else meDeben += monto;
                  if (fechaVenc != null && fechaVenc.isBefore(now)) vencidas++;
                }
              }
              final balance = meDeben - yoDebo;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3B6E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Balance de deudas', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green[300] : Colors.red[300], fontSize: 32, fontWeight: FontWeight.bold)),
                          Text(balance >= 0 ? 'A tu favor' : 'En contra', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(children: [Text('\$${yoDebo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), const Text('Yo debo', style: TextStyle(color: Colors.white70, fontSize: 10))]),
                              Column(children: [Text('\$${meDeben.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const Text('Me deben', style: TextStyle(color: Colors.white70, fontSize: 10))]),
                              Column(children: [Text('$vencidas', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const Text('Vencidas', style: TextStyle(color: Colors.white70, fontSize: 10))]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final id = doc.id;
                          final persona = data['persona'] ?? 'Sin nombre';
                          final concepto = data['concepto'] ?? '';
                          final monto = (data['monto'] ?? 0).toDouble();
                          final tipo = data['tipo'] ?? 'me_deben';
                          final estado = data['estado'] ?? 'pendiente';
                          final fechaVenc = data['fecha_vencimiento'] != null ? (data['fecha_vencimiento'] as Timestamp).toDate() : null;
                          final interesPorcentaje = (data['interes_porcentaje'] ?? 5.0).toDouble();
                          final calcularInteres = data['calcular_interes'] ?? true;
                          
                          double montoConInteres = monto;
                          bool estaVencida = false;
                          int diasAtraso = 0;
                          
                          if (calcularInteres && fechaVenc != null && estado == 'pendiente') {
                            if (now.isAfter(fechaVenc)) {
                              estaVencida = true;
                              diasAtraso = now.difference(fechaVenc).inDays;
                              final mesesAtraso = diasAtraso / 30.0;
                              final interes = monto * (interesPorcentaje / 100) * mesesAtraso;
                              montoConInteres = monto + interes;
                            }
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: estaVencida ? Colors.red.withOpacity(0.5) : const Color(0xFF222222)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(tipo == 'yo_debo' ? Icons.arrow_downward : Icons.arrow_upward, color: tipo == 'yo_debo' ? Colors.orange : Colors.green, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(persona, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text(concepto, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('\$${monto.toStringAsFixed(2)}', style: TextStyle(color: tipo == 'yo_debo' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                                        if (estaVencida) Text('\$${montoConInteres.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                                if (estaVencida) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning, color: Colors.red, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '$diasAtraso días de atraso • Interés ${interesPorcentaje.toStringAsFixed(1)}%: \$${(montoConInteres - monto).toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.red, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(fechaVenc != null ? 'Vence: ${DateFormat('dd/MM/yyyy').format(fechaVenc)}' : 'Sin fecha', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    const Spacer(),
                                    if (estado == 'pendiente')
                                      TextButton(
                                        onPressed: () => _cambiarEstadoDeuda(id, 'pagado'),
                                        child: const Text('Marcar pagada', style: TextStyle(color: Color(0xFF0066FF), fontSize: 11)),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                      onPressed: () => _mostrarDialogoEditarDeuda(id, data),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                      onPressed: () => _eliminarDeuda(id),
                                    ),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevaDeuda() {
    final personaCtrl = TextEditingController();
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    String tipo = 'me_deben';
    DateTime? fechaVenc;
    double interesPorcentaje = 5.0;
    bool calcularInteres = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Nueva Deuda', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: const [DropdownMenuItem(value: 'me_deben', child: Text('Me deben')), DropdownMenuItem(value: 'yo_debo', child: Text('Yo debo'))],
                  onChanged: (v) => setDialogState(() => tipo = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: personaCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Persona', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Concepto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: interesPorcentaje.toString()),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: '% Interés mensual por atraso', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                  onChanged: (v) { final val = double.tryParse(v); if (val != null) setDialogState(() => interesPorcentaje = val); },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Calcular intereses por atraso', style: TextStyle(color: Colors.white)),
                  value: calcularInteres,
                  activeColor: Colors.green,
                  onChanged: (v) => setDialogState(() => calcularInteres = v ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                    if (picked != null) setDialogState(() => fechaVenc = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha de vencimiento', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                    child: Text(fechaVenc != null ? DateFormat('dd/MM/yyyy').format(fechaVenc!) : 'Seleccionar fecha', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                if (personaCtrl.text.isEmpty || montoCtrl.text.isEmpty) return;
                final monto = double.tryParse(montoCtrl.text);
                if (monto == null) return;
                Navigator.pop(dialogCtx);
                _firestore.collection('deudas').add({
                  'persona': personaCtrl.text,
                  'concepto': conceptoCtrl.text,
                  'monto': monto,
                  'tipo': tipo,
                  'estado': 'pendiente',
                  'fecha_vencimiento': fechaVenc != null ? Timestamp.fromDate(fechaVenc!) : null,
                  'fecha_creacion': Timestamp.now(),
                  'interes_porcentaje': interesPorcentaje,
                  'calcular_interes': calcularInteres,
                });
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Deuda registrada'), backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEditarDeuda(String id, Map<String, dynamic> data) {
    final personaCtrl = TextEditingController(text: data['persona'] ?? '');
    final conceptoCtrl = TextEditingController(text: data['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: (data['monto'] ?? 0).toString());
    String tipo = data['tipo'] ?? 'me_deben';
    String estado = data['estado'] ?? 'pendiente';
    DateTime? fechaVenc = data['fecha_vencimiento'] != null ? (data['fecha_vencimiento'] as Timestamp).toDate() : null;
    double interesPorcentaje = (data['interes_porcentaje'] ?? 5.0).toDouble();
    bool calcularInteres = data['calcular_interes'] ?? true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Editar Deuda', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: const [DropdownMenuItem(value: 'me_deben', child: Text('Me deben')), DropdownMenuItem(value: 'yo_debo', child: Text('Yo debo'))],
                  onChanged: (v) => setDialogState(() => tipo = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: estado,
                  decoration: const InputDecoration(labelText: 'Estado', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: const [DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')), DropdownMenuItem(value: 'pagado', child: Text('Pagado'))],
                  onChanged: (v) => setDialogState(() => estado = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: personaCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Persona', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Concepto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: interesPorcentaje.toString()),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: '% Interés mensual', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                  onChanged: (v) { final val = double.tryParse(v); if (val != null) setDialogState(() => interesPorcentaje = val); },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Calcular intereses por atraso', style: TextStyle(color: Colors.white)),
                  value: calcularInteres,
                  activeColor: Colors.green,
                  onChanged: (v) => setDialogState(() => calcularInteres = v ?? true),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: fechaVenc ?? DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                    if (picked != null) setDialogState(() => fechaVenc = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha de vencimiento', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()),
                    child: Text(fechaVenc != null ? DateFormat('dd/MM/yyyy').format(fechaVenc!) : 'Seleccionar fecha', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                final monto = double.tryParse(montoCtrl.text);
                if (monto == null) return;
                Navigator.pop(dialogCtx);
                _firestore.collection('deudas').doc(id).update({
                  'persona': personaCtrl.text,
                  'concepto': conceptoCtrl.text,
                  'monto': monto,
                  'tipo': tipo,
                  'estado': estado,
                  'fecha_vencimiento': fechaVenc != null ? Timestamp.fromDate(fechaVenc!) : null,
                  'interes_porcentaje': interesPorcentaje,
                  'calcular_interes': calcularInteres,
                });
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Deuda actualizada'), backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _cambiarEstadoDeuda(String id, String estado) {
    _firestore.collection('deudas').doc(id).update({'estado': estado});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deuda marcada como $estado'), backgroundColor: Colors.green));
  }

  void _eliminarDeuda(String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar deuda', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de eliminar esta deuda?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _firestore.collection('deudas').doc(id).delete();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Deuda eliminada'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================
  // RESTO DE PESTAÑAS
  // ============================================
  Widget _buildVistaHoy() {
    final hoy = DateTime.now();
    final fh = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    return Container(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${hoy.day} de ${['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'][hoy.month-1]} ${hoy.year}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: _miniCard('Pend', Icons.schedule, Colors.orange)), const SizedBox(width: 12), Expanded(child: _miniCard('Comp', Icons.check_circle, Colors.green))]),
      ])),
      const SizedBox(height: 24),
      const Text('Transacciones Hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final docs = s.data!.docs.where((d) => (d.data() as Map)['fecha'] == fh).toList();
        if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Sin transacciones hoy', style: TextStyle(color: Colors.grey))));
        double ti = 0, tg = 0;
        for (var d in docs) { final dd = d.data() as Map; final m = (dd['monto'] ?? 0).toDouble(); if (dd['tipo'] == 'Ingreso') ti += m; else tg += m; }
        return Column(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey)), Text('\$${ti.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]), Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey)), Text('\$${tg.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]), Column(children: [const Text('Balance', style: TextStyle(color: Colors.grey)), Text('\$${(ti-tg).toStringAsFixed(2)}', style: TextStyle(color: (ti-tg)>=0?Colors.green:Colors.red, fontSize: 18, fontWeight: FontWeight.bold))])])),
          const SizedBox(height: 16),
          ...docs.map((d) { final dd = d.data() as Map; final ei = dd['tipo'] == 'Ingreso'; final rec = dd['reconciliada'] ?? false; final tags = List<String>.from(dd['tags'] ?? []); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: rec ? Colors.green : const Color(0xFF222222))), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: ei?Colors.green.withOpacity(.2):Colors.red.withOpacity(.2), shape: BoxShape.circle), child: Icon(ei?Icons.arrow_upward:Icons.arrow_downward, color: ei?Colors.green:Colors.red, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(dd['concepto']??'', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), if (rec) const Icon(Icons.check_circle, color: Colors.green, size: 16)]), const SizedBox(height: 4), Text('${dd['categoria']} • ${dd['negocio']}', style: const TextStyle(color: Colors.grey, fontSize: 12)), if (tags.isNotEmpty) ...[const SizedBox(height: 4), Wrap(spacing: 4, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(.2), borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)))).toList())]])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${ei?"+":"-"}\$${dd['monto']}', style: TextStyle(color: ei?Colors.green:Colors.red, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), if (!rec) TextButton(onPressed: () { _firestore.collection('transacciones').doc(d.id).update({'reconciliada': true}); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Aprobada'), backgroundColor: Colors.green)); }, child: const Text('Aprobar', style: TextStyle(color: Color(0xFF0066FF), fontSize: 11)))])])); }),
        ]);
      }),
    ])));
  }

  Widget _miniCard(String t, IconData i, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(.2), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(i, color: c, size: 20), const SizedBox(width: 8), Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold))]));

  Widget _buildDashboard() {
    return Container(padding: const EdgeInsets.all(12), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📊 Dashboard Ejecutivo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        double ing = 0, gas = 0; int n = 0; Map<String, double> pn = {};
        for (var d in s.data!.docs) { final dd = d.data() as Map; final m = (dd['monto']??0).toDouble(); final t = dd['tipo']??''; final ng = dd['negocio']??'Otro'; if(t=='Ingreso')ing+=m; if(t=='Gasto')gas+=m; n++; pn[ng]=(pn[ng]??0)+(t=='Ingreso'?m:-m); }
        final mg = ing>0?((ing-gas)/ing*100):0; final tp = n>0?ing/n:0; final fn = ing-gas;
        return Column(children: [
          GridView.count(crossAxisCount:2, shrinkWrap:true, physics:const NeverScrollableScrollPhysics(), childAspectRatio:3.5, mainAxisSpacing:12, crossAxisSpacing:12, children: [
            _kpi('Ingresos','\$${ing.toStringAsFixed(0)}',Icons.trending_up,Colors.green), _kpi('Gastos','\$${gas.toStringAsFixed(0)}',Icons.trending_down,Colors.red),
            _kpi('Flujo','\$${fn.toStringAsFixed(0)}',Icons.account_balance_wallet,fn>=0?Colors.green:Colors.red), _kpi('Margen','${mg.toStringAsFixed(1)}%',Icons.percent,Colors.blue),
            _kpi('Ticket','\$${tp.toStringAsFixed(0)}',Icons.receipt_long,Colors.orange), _kpi('Trans','$n',Icons.list_alt,Colors.purple),
          ]),
          const SizedBox(height:16), const Text('📈 Por Negocio', style:TextStyle(color:Colors.white,fontSize:14,fontWeight:FontWeight.bold)), const SizedBox(height:8),
          ...pn.entries.map((e)=>Container(margin:const EdgeInsets.only(bottom:6),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF1A1A1A),borderRadius:BorderRadius.circular(8)),child:Row(children:[Expanded(child:Text(e.key,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),Text('\$${e.value.toStringAsFixed(0)}',style:TextStyle(color:e.value>=0?Colors.green:Colors.red,fontWeight:FontWeight.bold))]))),
        ]);
      }),
    ])));
  }

  Widget _kpi(String t, String v, IconData i, Color c) => Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF1A1A1A),borderRadius:BorderRadius.circular(8),border:Border.all(color:c.withOpacity(.3))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Icon(i,color:c,size:24),const SizedBox(height:6),Text(t,style:const TextStyle(color:Colors.grey,fontSize:11)),const SizedBox(height:2),Text(v,style:TextStyle(color:c,fontSize:14,fontWeight:FontWeight.bold),maxLines:1,overflow:TextOverflow.ellipsis)]));

  Widget _buildResumen() {
    return Container(padding:const EdgeInsets.all(16),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').snapshots(),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());double i=0,g=0;for(var d in s.data!.docs){final dd=d.data()as Map;final m=(dd['monto']??0).toDouble();if(dd['tipo']=='Ingreso')i+=m;if(dd['tipo']=='Gasto')g+=m;}return Container(width:double.infinity,padding:const EdgeInsets.all(24),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF0066FF),Color(0xFF0044AA)]),borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Balance Total',style:TextStyle(color:Colors.white70,fontSize:14)),const SizedBox(height:8),Text('\$${(i-g).toStringAsFixed(2)}',style:const TextStyle(color:Colors.white,fontSize:32,fontWeight:FontWeight.bold))]));}),
      const SizedBox(height:16),
      Row(children:[Expanded(child:_tarjetaResumen('Ingresos',Colors.green,Icons.arrow_upward)),const SizedBox(width:12),Expanded(child:_tarjetaResumen('Gastos',Colors.red,Icons.arrow_downward))]),
      const SizedBox(height:24),const Text('📈 Tendencia Mensual',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:16),
      Container(height:250,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFF111111),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFF222222))),child:_buildGraficoLineas()),
      const SizedBox(height:24),const Text(' Últimas',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:16),
      StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').orderBy('created_at',descending:true).limit(5).snapshots(),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;if(d.isEmpty)return const Text('Sin datos',style:TextStyle(color:Colors.grey));return Column(children:d.map((x){final dd=x.data()as Map;final ei=dd['tipo']=='Ingreso';return ListTile(leading:CircleAvatar(backgroundColor:ei?Colors.green.withOpacity(.2):Colors.red.withOpacity(.2),child:Icon(ei?Icons.arrow_upward:Icons.arrow_downward,color:ei?Colors.green:Colors.red)),title:Text(dd['concepto']??'',style:const TextStyle(color:Colors.white)),subtitle:Text('${dd['categoria']} • ${dd['fecha']}',style:const TextStyle(color:Colors.grey)),trailing:Text('${ei?"+":"-"}\$${dd['monto']}',style:TextStyle(color:ei?Colors.green:Colors.red,fontWeight:FontWeight.bold)));}).toList());}),
    ])));
  }

  Widget _tarjetaResumen(String t,Color c,IconData i)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFF111111),borderRadius:BorderRadius.circular(12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(i,color:c,size:20),const SizedBox(width:8),Text(t,style:TextStyle(color:c,fontWeight:FontWeight.bold))]),const SizedBox(height:8),StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').snapshots(),builder:(ct,s){if(!s.hasData)return const Text('\$0',style:TextStyle(color:Colors.white,fontSize:20));double tot=0;for(var d in s.data!.docs){final dd=d.data()as Map;if(dd['tipo']==t)tot+=(dd['monto']??0).toDouble();}return Text('\$${tot.toStringAsFixed(2)}',style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold));})]));

  Widget _buildGraficoLineas() {
    return StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) {
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
      return LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { final idx = value.toInt(); if (idx >= 0 && idx < meses.length) return Text(meses[idx].substring(5), style: const TextStyle(color: Colors.grey, fontSize: 10)); return const Text(''); })), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: List.generate(meses.length, (i) => FlSpot(i.toDouble(), ingresosPorMes[meses[i]] ?? 0)), isCurved: true, color: Colors.green, barWidth: 3, dotData: const FlDotData(show: false)), LineChartBarData(spots: List.generate(meses.length, (i) => FlSpot(i.toDouble(), gastosPorMes[meses[i]] ?? 0)), isCurved: true, color: Colors.red, barWidth: 3, dotData: const FlDotData(show: false))], minX: 0, maxX: (meses.length - 1).toDouble()));
    });
  }

  Widget _buildLista(String tipo) {
    return Container(child:Column(children:[
      Container(padding:const EdgeInsets.all(16),color:const Color(0xFF111111),child:Column(children:[
        TextField(decoration:InputDecoration(hintText:'Buscar...',prefixIcon:const Icon(Icons.search,color:Colors.grey),filled:true,fillColor:const Color(0xFF1A1A1A),border:const OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(8)),borderSide:BorderSide.none)),style:const TextStyle(color:Colors.white),onChanged:(v)=>setState(()=>_search=v.toLowerCase())),
        const SizedBox(height:12),
        Row(children:[Expanded(child:DropdownButtonFormField<String>(value:_categoriaFiltro,decoration:const InputDecoration(labelText:'Cat',filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(8)),borderSide:BorderSide.none)),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:['Todas','Proyecto','Servicios','Personal','Transporte','Alquiler','Mobiliario','Otros'].map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>setState(()=>_categoriaFiltro=v!))),const SizedBox(width:12),Expanded(child:DropdownButtonFormField<String>(value:_negocioFiltro,decoration:const InputDecoration(labelText:'Neg',filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(8)),borderSide:BorderSide.none)),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:['Todos',..._negocios].map((n)=>DropdownMenuItem(value:n,child:Text(n))).toList(),onChanged:(v)=>setState(()=>_negocioFiltro=v!)))]),
        const SizedBox(height:12),
        Row(children:[Expanded(child:CheckboxListTile(title:const Text('Pend',style:TextStyle(color:Colors.white,fontSize:12)),value:_soloPendientes,activeColor:const Color(0xFF0066FF),onChanged:(v)=>setState(()=>_soloPendientes=v??false),contentPadding:EdgeInsets.zero)),Expanded(child:CheckboxListTile(title:const Text('Rec',style:TextStyle(color:Colors.white,fontSize:12)),value:_soloReconciliadas,activeColor:Colors.green,onChanged:(v)=>setState(()=>_soloReconciliadas=v??false),contentPadding:EdgeInsets.zero))]),
      ])),
      Expanded(child:StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').orderBy('created_at',descending:true).snapshots(),builder:(c,s){
        if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator(color:Color(0xFF0066FF)));
        if(s.hasError)return Center(child:Text('Error:${s.error}',style:const TextStyle(color:Colors.red)));
        final all=s.data?.docs??[];
        final filt=all.where((d){final dd=d.data()as Map;final con=(dd['concepto']??'').toString().toLowerCase();final cat=dd['categoria']??'General';final neg=dd['negocio']??'Min';final rec=dd['reconciliada']??false;return dd['tipo']==tipo&&(_search.isEmpty||con.contains(_search))&&(_categoriaFiltro=='Todas'||cat==_categoriaFiltro)&&(_negocioFiltro=='Todos'||neg==_negocioFiltro)&&(!_soloPendientes||!rec)&&(!_soloReconciliadas||rec);}).toList();
        if(filt.isEmpty)return const Center(child:Text('Sin registros',style:TextStyle(color:Colors.grey)));
        final tot=filt.fold<double>(0,(a,d)=>a+((d.data()as Map)['monto']??0).toDouble());
        return Column(children:[
          Container(padding:const EdgeInsets.all(12),margin:const EdgeInsets.only(bottom:12),decoration:BoxDecoration(color:tipo=='Ingreso'?Colors.green.withOpacity(.1):Colors.red.withOpacity(.1),borderRadius:BorderRadius.circular(8),border:Border.all(color:tipo=='Ingreso'?Colors.green:Colors.red)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Total:',style:TextStyle(color:tipo=='Ingreso'?Colors.green:Colors.red,fontWeight:FontWeight.bold)),Text('\$${tot.toStringAsFixed(2)}',style:TextStyle(color:tipo=='Ingreso'?Colors.green:Colors.red,fontSize:20,fontWeight:FontWeight.bold))])),
          Expanded(child:ListView.builder(itemCount:filt.length,itemBuilder:(c,i){final d=filt[i];final dd=d.data()as Map;final ei=dd['tipo']=='Ingreso';final rec=dd['reconciliada']??false;final tags=List<String>.from(dd['tags']??[]);return ListTile(leading:CircleAvatar(backgroundColor:ei?Colors.green.withOpacity(.2):Colors.red.withOpacity(.2),child:Stack(children:[Center(child:Icon(ei?Icons.arrow_upward:Icons.arrow_downward,color:ei?Colors.green:Colors.red)),if(rec)Positioned(right:0,bottom:0,child:Container(padding:const EdgeInsets.all(2),decoration:const BoxDecoration(color:Colors.green,shape:BoxShape.circle),child:const Icon(Icons.check,color:Colors.white,size:10))])),title:Text(dd['concepto']??'',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${dd['categoria']} • ${dd['cuenta']} • ${dd['negocio']}',style:const TextStyle(color:Colors.grey)),if(tags.isNotEmpty)Wrap(spacing:4,children:tags.map((t)=>Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),decoration:BoxDecoration(color:const Color(0xFF0066FF).withOpacity(.2),borderRadius:BorderRadius.circular(4)),child:Text(t,style:const TextStyle(color:Color(0xFF0066FF),fontSize:10)))).toList())]),trailing:Row(mainAxisSize:MainAxisSize.min,children:[IconButton(icon:const Icon(Icons.copy,color:Colors.blue,size:20),onPressed:()=>_duplicar(dd)),IconButton(icon:const Icon(Icons.edit,color:Colors.orange,size:20),onPressed:()=>_mostrarFormularioTransaccion(transaccion:dd,docId:d.id)),IconButton(icon:const Icon(Icons.delete_outline,color:Colors.red,size:20),onPressed:()=>_borrar(d.id))])));})),
        ]);
      })),
    ]));
  }

  Future<void> _duplicar(Map data)async{await _firestore.collection('transacciones').add({...data,'concepto':'${data['concepto']} (copia)','reconciliada':false,'created_at':FieldValue.serverTimestamp()});if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('✅ Duplicada'),backgroundColor:Colors.green));}
  Future<void> _borrar(String id)async{await _firestore.collection('transacciones').doc(id).delete();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('🗑️ Eliminado'),backgroundColor:Colors.red));}

  Widget _buildCuentas() {
    return Container(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text(' Cuentas',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:16),
      Expanded(child:StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').snapshots(),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;return ListView.builder(itemCount:_cuentas.length,itemBuilder:(c,i){final ct=_cuentas[i];double bal=0;int n=0;for(var x in d){final dd=x.data()as Map;if(dd['cuenta']==ct['nombre']){final m=(dd['monto']??0).toDouble();if(dd['tipo']=='Ingreso')bal+=m;if(dd['tipo']=='Gasto')bal-=m;n++;}}return Card(margin:const EdgeInsets.only(bottom:12),color:const Color(0xFF111111),child:ListTile(leading:CircleAvatar(backgroundColor:(ct['color']as Color).withOpacity(.2),child:Icon(ct['icon']as IconData,color:ct['color']as Color)),title:Text(ct['nombre']as String,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),subtitle:Text('$n transacciones',style:const TextStyle(color:Colors.grey)),trailing:Text('\$${bal.toStringAsFixed(2)}',style:TextStyle(color:bal>=0?Colors.green:Colors.red,fontWeight:FontWeight.bold))));});}),
    ]));
  }

  Widget _buildCalendario() {
    DateTime mesSel = DateTime.now();
    return StatefulBuilder(builder:(c,set){return Container(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[IconButton(icon:const Icon(Icons.chevron_left,color:Colors.white),onPressed:()=>set(()=>mesSel=DateTime(mesSel.year,mesSel.month-1))),Text('${mesSel.year} - ${['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'][mesSel.month-1]}',style:const TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),IconButton(icon:const Icon(Icons.chevron_right,color:Colors.white),onPressed:()=>set(()=>mesSel=DateTime(mesSel.year,mesSel.month+1)))]),
      const SizedBox(height:16),
      Expanded(child:StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').snapshots(),builder:(ct,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;final tm=d.where((x){final dd=x.data()as Map;final fs=dd['fecha']as String???'';if(fs.length>=7){final fp=fs.split('-');if(fp.length>=2){final a=int.tryParse(fp[0]);final m=int.tryParse(fp[1]);return a==mesSel.year&&m==mesSel.month;}}return false;}).toList();if(tm.isEmpty)return const Center(child:Text('Sin transacciones este mes',style:TextStyle(color:Colors.grey)));Map<String,List> pd={};for(var x in tm){final dd=x.data()as Map;final fs=dd['fecha']as String???'';if(fs.length>=10){final dia=fs.substring(8,10);pd.putIfAbsent(dia,()=>[]).add(dd);}}return ListView(children:pd.entries.map((e){final dia=e.key;final ts=e.value;double td=0;for(var t in ts){final m=(t['monto']??0).toDouble();if(t['tipo']=='Ingreso')td+=m;else td-=m;}return ExpansionTile(title:Text('Día $dia • ${ts.length} trans • \$${td.toStringAsFixed(0)}',style:const TextStyle(color:Colors.white)),children:ts.map((t)=>ListTile(leading:Icon(t['tipo']=='Ingreso'?Icons.arrow_upward:Icons.arrow_downward,color:t['tipo']=='Ingreso'?Colors.green:Colors.red,size:16),title:Text(t['concepto']??'',style:const TextStyle(color:Colors.white,fontSize:12)),trailing:Text('\$${(t['monto']??0).toStringAsFixed(0)}',style:TextStyle(color:t['tipo']=='Ingreso'?Colors.green:Colors.red)))).toList());}).toList());}),),
    ]));});
  }

  Widget _buildReportes() {
    return Container(padding:const EdgeInsets.all(16),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text(' Reportes',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:16),
      StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').snapshots(),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;double ti=0,tg=0;Map<String,double> ic={},gc={};for(var x in d){final dd=x.data()as Map;final m=(dd['monto']??0).toDouble();final t=dd['tipo']??'';final cat=dd['categoria']??'Otros';if(t=='Ingreso'){ti+=m;ic[cat]=(ic[cat]??0)+m;}else{tg+=m;gc[cat]=(gc[cat]??0)+m;}}return Column(children:[
        Text('Ingresos: \$${ti.toStringAsFixed(0)} | Gastos: \$${tg.toStringAsFixed(0)} | Balance: \$${(ti-tg).toStringAsFixed(0)}',style:TextStyle(color:(ti-tg)>=0?Colors.green:Colors.red,fontWeight:FontWeight.bold)),const SizedBox(height:16),
        const Text('Top Categorías Ingreso',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),const SizedBox(height:8),
        ...ic.entries.toList()..sort((a,b)=>b.value.compareTo(a.value)).take(5).map((e)=>LinearProgressIndicator(value:ti>0?e.value/ti:0,minHeight:20,backgroundColor:Colors.grey.shade800,valueColor:AlwaysStoppedAnimation<Color>(Colors.green),borderRadius:BorderRadius.circular(4))),const SizedBox(height:16),
        const Text('Top Categorías Gasto',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),const SizedBox(height:8),
        ...gc.entries.toList()..sort((a,b)=>b.value.compareTo(a.value)).take(5).map((e)=>LinearProgressIndicator(value:tg>0?e.value/tg:0,minHeight:20,backgroundColor:Colors.grey.shade800,valueColor:AlwaysStoppedAnimation<Color>(Colors.red),borderRadius:BorderRadius.circular(4))),
      ]);}),
      const SizedBox(height:24),const Text('📊 Benchmarking por Negocio',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:16),
      StreamBuilder<QuerySnapshot>(stream:_firestore.collection('transacciones').snapshots(),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;Map<String,double> pn={};for(var x in d){final dd=x.data()as Map;final m=(dd['monto']??0).toDouble();final t=dd['tipo']??'';final ng=dd['negocio']??'Otro';pn[ng]=(pn[ng]??0)+(t=='Ingreso'?m:-m);}final mx=pn.values.fold<double>(0,(a,b)=>b>a?b:a);return Column(children:pn.entries.map((e){final pct=mx>0?(e.value/mx*100).abs():0;return Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF1A1A1A),borderRadius:BorderRadius.circular(8)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(e.key,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),Text('\$${e.value.toStringAsFixed(0)}',style:TextStyle(color:e.value>=0?Colors.green:Colors.red,fontWeight:FontWeight.bold)),const SizedBox(width:8),Text('${pct.toStringAsFixed(1)}%',style:const TextStyle(color:Colors.grey))]),const SizedBox(height:8),ClipRRect(borderRadius:BorderRadius.circular(4),child:LinearProgressIndicator(value:pct/100,minHeight:6,backgroundColor:Colors.grey.shade800,valueColor:AlwaysStoppedAnimation<Color>(e.value>=0?Colors.green:Colors.red)))]));}).toList());}),
    ])));
  }

  Widget _buildPresupuestos() {
    return Container(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('📊 Presupuestos',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),ElevatedButton.icon(onPressed:()=>_dialogoPresupuesto(),icon:const Icon(Icons.add,color:Colors.white),label:const Text('Agregar',style:TextStyle(color:Colors.white)),style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF0066FF)))]),
      const SizedBox(height:16),
      Expanded(child:_presupuestosPersonalizados.isEmpty?const Center(child:Text('No hay presupuestos',style:TextStyle(color:Colors.grey))):ListView.builder(itemCount:_presupuestosPersonalizados.length,itemBuilder:(c,i){final p=_presupuestosPersonalizados[i];final gc=p['gastado']as double;final pr=p['presupuesto']as double;final pc=pr>0?(gc/pr*100).clamp(0,100):0;final ex=gc>pr;final ap=p['aplicado']??false;return Card(margin:const EdgeInsets.only(bottom:12),color:const Color(0xFF1A1A1A),child:ExpansionTile(title:Row(children:[Expanded(child:Text(p['nombre'],style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),Text('\$${gc.toStringAsFixed(0)}/\$${pr.toStringAsFixed(0)}',style:TextStyle(color:ex?Colors.red:Colors.green))]),children:[Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[ClipRRect(borderRadius:BorderRadius.circular(4),child:LinearProgressIndicator(value:pc/100,minHeight:8,backgroundColor:Colors.grey.shade800,valueColor:AlwaysStoppedAnimation<Color>(ex?Colors.red:const Color(0xFF0066FF)))),const SizedBox(height:8),Text('${pc.toStringAsFixed(1)}% usado${ex?' ⚠️ EXCEDIDO':''}',style:TextStyle(color:ex?Colors.red:Colors.grey,fontSize:12)),const SizedBox(height:12),Row(children:[const Text('Aplicar:',style:TextStyle(color:Colors.grey)),const Spacer(),Switch(value:ap,activeColor:Colors.green,onChanged:(v)=>_toggleAplicar(p['id'],v,p['nombre'],pr,p['cuenta'],p['subcuenta']))]),const SizedBox(height:8),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>_dialogoPresupuesto(presupuesto:p),icon:const Icon(Icons.edit,size:16),label:const Text('Editar'),style:OutlinedButton.styleFrom(foregroundColor:const Color(0xFF0066FF)))),const SizedBox(width:8),Expanded(child:OutlinedButton.icon(onPressed:()=>_eliminarPresupuesto(p['id']),icon:const Icon(Icons.delete,size:16),label:const Text('Eliminar'),style:OutlinedButton.styleFrom(foregroundColor:Colors.red)))])]))]);}),),
    ]));
  }

  void _dialogoPresupuesto({Map? presupuesto}) {
    final nc=TextEditingController(text:presupuesto?['nombre']??'');final mc=TextEditingController(text:presupuesto?['presupuesto']?.toString()??'0');final gc=TextEditingController(text:presupuesto?['gastado']?.toString()??'0');String ct='Efectivo';String sc='Proyectos';
    showDialog(context:context,builder:(d)=>AlertDialog(backgroundColor:const Color(0xFF1A1A1A),title:Text(presupuesto!=null?'Editar':'Nuevo',style:const TextStyle(color:Colors.white)),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:nc,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Nombre',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111))),const SizedBox(height:12),TextField(controller:mc,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Monto',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111))),const SizedBox(height:12),TextField(controller:gc,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Gastado',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111))),const SizedBox(height:12),DropdownButtonFormField<String>(value:ct,decoration:const InputDecoration(labelText:'Cuenta',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111)),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:['Efectivo','Banco','Tarjeta','Inversión'].map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>ct=v!),const SizedBox(height:8),DropdownButtonFormField<String>(value:sc,decoration:const InputDecoration(labelText:'Subcuenta',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111)),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:_negocios.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v)=>sc=v!)]),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancelar')),ElevatedButton(onPressed:(){final mo=double.tryParse(mc.text);final ga=double.tryParse(gc.text)??0;if(mo==null||nc.text.isEmpty)return;Navigator.pop(d);_agregarPresupuesto(nc.text.trim(),mo,ga,ct,sc);},style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF0066FF)),child:const Text('Guardar',style:TextStyle(color:Colors.white)))]));
  }

  Widget _buildMetas() {
    return Container(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('🏆 Metas',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),ElevatedButton.icon(onPressed:()=>_dialogoMeta(),icon:const Icon(Icons.add,color:Colors.white),label:const Text('Nueva',style:TextStyle(color:Colors.white)),style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF0066FF)))]),
      const SizedBox(height:16),
      Expanded(child:StreamBuilder<QuerySnapshot>(stream:_firestore.collection('metas').snapshots(),builder:(c,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final d=s.data!.docs;if(d.isEmpty)return const Center(child:Text('No hay metas',style:TextStyle(color:Colors.grey)));return ListView.builder(itemCount:d.length,itemBuilder:(c,i){final md=d[i].data()as Map;final nom=md['nombre']??'';final obj=(md['objetivo']??0).toDouble();final act=(md['actual']??0).toDouble();final ms=(md['meses']??12).toInt();final pc=obj>0?(act/obj*100).clamp(0,100):0;final cp=act>=obj;final rs=obj-act;final am=ms>0?rs/ms:0;return Card(margin:const EdgeInsets.only(bottom:12),color:const Color(0xFF1A1A1A),child:ListTile(title:Text(nom,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('\$${act.toStringAsFixed(0)} / \$${obj.toStringAsFixed(0)} (${pc.toStringAsFixed(1)}%)',style:TextStyle(color:cp?Colors.green:Colors.grey)),const SizedBox(height:8),ClipRRect(borderRadius:BorderRadius.circular(4),child:LinearProgressIndicator(value:pc/100,minHeight:8,backgroundColor:Colors.grey.shade800,valueColor:AlwaysStoppedAnimation<Color>(cp?Colors.green:const Color(0xFF0066FF)))),if(!cp&&rs>0)...[const SizedBox(height:8),Text('Plan: Mensual \$${am.toStringAsFixed(0)} | Semanal \$${(am/4).toStringAsFixed(0)} | Diario \$${(am/30).toStringAsFixed(0)}',style:const TextStyle(color:Color(0xFF0066FF),fontSize:11))]]),trailing:Row(mainAxisSize:MainAxisSize.min,children:[IconButton(icon:const Icon(Icons.edit,color:Color(0xFF0066FF),size:20),onPressed:()=>_dialogoMeta(doc:d[i])),IconButton(icon:const Icon(Icons.delete,color:Colors.red,size:20),onPressed:()=>_firestore.collection('metas').doc(d[i].id).delete())])));});}),
    ]));
  }

  void _dialogoMeta({DocumentSnapshot? doc}) {
    final nc=TextEditingController(text:doc!=null?(doc.data()as Map)['nombre']??'':'');final oc=TextEditingController(text:doc!=null?(doc.data()as Map)['objetivo']?.toString()??'0':'0');final ac=TextEditingController(text:doc!=null?(doc.data()as Map)['actual']?.toString()??'0':'0');final mc=TextEditingController(text:doc!=null?(doc.data()as Map)['meses']?.toString()??'12':'12');
    showDialog(context:context,builder:(d)=>AlertDialog(backgroundColor:const Color(0xFF1A1A1A),title:Text(doc!=null?'Editar Meta':'Nueva Meta',style:const TextStyle(color:Colors.white)),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:nc,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Nombre',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111))),const SizedBox(height:12),TextField(controller:oc,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Objetivo',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111))),const SizedBox(height:12),TextField(controller:ac,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Actual',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111))),const SizedBox(height:12),TextField(controller:mc,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Meses',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF111111)))]),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancelar')),ElevatedButton(onPressed:(){final o=double.tryParse(oc.text);final a=double.tryParse(ac.text)??0;final m=int.tryParse(mc.text)??12;if(o==null||nc.text.isEmpty)return;if(doc!=null){_firestore.collection('metas').doc(doc.id).update({'nombre':nc.text.trim(),'objetivo':o,'actual':a,'meses':m});}else{_firestore.collection('metas').add({'nombre':nc.text.trim(),'objetivo':o,'actual':a,'meses':m,'created_at':FieldValue.serverTimestamp()});}Navigator.pop(d);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('✅ Guardado'),backgroundColor:Colors.green));},style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF0066FF)),child:const Text('Guardar',style:TextStyle(color:Colors.white)))]));
  }

  void _mostrarFormularioTransaccion({Map? transaccion,String? docId}) {
    final cc=TextEditingController(text:transaccion?['concepto']??'');final mc=TextEditingController(text:transaccion?['monto']?.toString()??'0');final catc=TextEditingController(text:transaccion?['categoria']??'General');final fc=TextEditingController(text:transaccion?['fecha']??DateTime.now().toIso8601String().split('T')[0]);String tp=transaccion?['tipo']??'Ingreso';String ct=transaccion?['cuenta']??'Efectivo';String su=transaccion?['subcuenta']??'Minerales';String ng=transaccion?['negocio']??'Minerales';bool rc=transaccion?['reconciliada']??false;Set<String> ta=Set.from(List.from(transaccion?['tags']??[]));
    showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:const Color(0xFF111111),shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(16))),builder:(ctx)=>StatefulBuilder(builder:(c,set)=>Container(padding:EdgeInsets.only(bottom:MediaQuery.of(c).viewInsets.bottom),child:SingleChildScrollView(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(transaccion==null?'Nueva Transacción':'Editar',style:const TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:20),
      TextField(controller:cc,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Concepto*',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder())),const SizedBox(height:12),
      TextField(controller:mc,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Monto',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder())),const SizedBox(height:12),
      Row(children:[Expanded(child:RadioListTile<String>(title:const Text('Ingreso',style:TextStyle(color:Colors.white)),value:'Ingreso',groupValue:tp,activeColor:Colors.green,onChanged:(v)=>set(()=>tp=v!))),Expanded(child:RadioListTile<String>(title:const Text('Gasto',style:TextStyle(color:Colors.white)),value:'Gasto',groupValue:tp,activeColor:Colors.red,onChanged:(v)=>set(()=>tp=v!)))]),const SizedBox(height:12),
      DropdownButtonFormField<String>(value:catc.text,decoration:const InputDecoration(labelText:'Categoría',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder()),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:(tp=='Ingreso'?_categoriasIngreso:_categoriasGasto).map((c)=>DropdownMenuItem(value:c['nombre'],child:Text(c['nombre']))).toList(),onChanged:(v)=>catc.text=v??''),const SizedBox(height:12),
      TextField(controller:fc,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Fecha',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder())),const SizedBox(height:12),
      DropdownButtonFormField<String>(value:ct,decoration:const InputDecoration(labelText:'Cuenta',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder()),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:['Efectivo','Banco','Tarjeta','Inversión'].map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>set(()=>ct=v!)),const SizedBox(height:12),
      DropdownButtonFormField<String>(value:ng,decoration:const InputDecoration(labelText:'Negocio',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder()),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:_negocios.map((n)=>DropdownMenuItem(value:n,child:Text(n))).toList(),onChanged:(v)=>set(()=>ng=v!)),const SizedBox(height:12),
      const Text('🏷️ Tags',style:TextStyle(color:Color(0xFF0066FF),fontWeight:FontWeight.bold)),const SizedBox(height:8),
      Wrap(spacing:8,runSpacing:8,children:_tagsDisponibles.map((t){final sel=ta.contains(t);return FilterChip(label:Text(t,style:TextStyle(color:sel?Colors.white:Colors.grey,fontSize:12)),selected:sel,backgroundColor:const Color(0xFF1A1A1A),selectedColor:const Color(0xFF0066FF),onSelected:(v)=>set(()=>{if(v)ta.add(t);else ta.remove(t);}));}).toList()),const SizedBox(height:12),
      CheckboxListTile(title:const Text('Reconciliada',style:TextStyle(color:Colors.white)),value:rc,activeColor:Colors.green,onChanged:(v)=>set(()=>rc=v??false),contentPadding:EdgeInsets.zero),const SizedBox(height:16),
      SizedBox(width:double.infinity,height:50,child:ElevatedButton.icon(onPressed:()async{if(cc.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('⚠️ Concepto requerido'),backgroundColor:Colors.orange));return;}final dt={'concepto':cc.text.trim(),'monto':double.tryParse(mc.text)??0,'categoria':catc.text,'fecha':fc.text,'tipo':tp,'cuenta':ct,'subcuenta':su,'negocio':ng,'reconciliada':rc,'tags':ta.toList(),'descripcion':'','metodo_pago':'Efectivo','referencia':'','acreedor':''};if(docId==null){dt['created_at']=FieldValue.serverTimestamp();await _firestore.collection('transacciones').add(dt);}else{await _firestore.collection('transacciones').doc(docId).update(dt);}Navigator.pop(c);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(docId==null?'✅ Creada':'✅ Actualizada'),backgroundColor:Colors.green));},icon:const Icon(Icons.save,color:Colors.white),label:Text(transaccion==null?'Crear':'Guardar',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF0066FF)))),
    ])))));
  }

  void _mostrarTransferencia() {
    String co='Inversión',cd='Banco',so='Proyectos',sd='Proyectos';final mc=TextEditingController();final cc=TextEditingController(text:'Transferencia');
    showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:const Color(0xFF111111),shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(16))),builder:(ctx)=>StatefulBuilder(builder:(c,set)=>Container(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text(' Transferir',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:16),
      DropdownButtonFormField<String>(value:co,decoration:const InputDecoration(labelText:'Origen',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder()),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:['Efectivo','Banco','Tarjeta','Inversión'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>set(()=>co=v!)),const SizedBox(height:8),
      DropdownButtonFormField<String>(value:cd,decoration:const InputDecoration(labelText:'Destino',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder()),dropdownColor:const Color(0xFF1A1A1A),style:const TextStyle(color:Colors.white),items:['Efectivo','Banco','Tarjeta','Inversión'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>set(()=>cd=v!)),const SizedBox(height:12),
      TextField(controller:mc,keyboardType:TextInputType.number,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Monto',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder())),const SizedBox(height:12),
      TextField(controller:cc,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'Concepto',labelStyle:TextStyle(color:Colors.grey),filled:true,fillColor:Color(0xFF1A1A1A),border:OutlineInputBorder())),const SizedBox(height:16),
      SizedBox(width:double.infinity,child:ElevatedButton.icon(onPressed:()async{final m=double.tryParse(mc.text);if(m==null||m<=0||co==cd)return;final f=DateTime.now().toIso8601String().split('T')[0];final cn=cc.text.trim().isEmpty?'Transferencia':cc.text.trim();await _firestore.collection('transacciones').add({'concepto':'$cn (salida)','monto':m,'categoria':'Transferencia','tipo':'Gasto','cuenta':co,'subcuenta':so,'negocio':'Proyectos','fecha':f,'reconciliada':true,'created_at':FieldValue.serverTimestamp()});await _firestore.collection('transacciones').add({'concepto':'$cn (entrada)','monto':m,'categoria':'Transferencia','tipo':'Ingreso','cuenta':cd,'subcuenta':sd,'negocio':'Proyectos','fecha':f,'reconciliada':true,'created_at':FieldValue.serverTimestamp()});Navigator.pop(c);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('✅ \$${m.toStringAsFixed(2)}'),backgroundColor:Colors.green));},icon:const Icon(Icons.swap_horiz,color:Colors.white),label:const Text('Transferir',style:TextStyle(color:Colors.white)),style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF0066FF)))),
    ])))));
  }

  Future<void> _exportarCSV()async{try{final s=await _firestore.collection('transacciones').get();final b=StringBuffer();b.writeln('Fecha,Tipo,Concepto,Categoria,Negocio,Monto,Reconciliada');for(var d in s.docs){final dd=d.data()as Map;b.writeln('${dd['fecha']},${dd['tipo']},"${dd['concepto']}","${dd['categoria']}","${dd['negocio']}",${dd['monto']},${dd['reconciliada']}');}final by=utf8.encode(b.toString());final bl=html.Blob([by]);final u=html.Url.createObjectUrlFromBlob(bl);final a=html.AnchorElement(href:u)..setAttribute("download","finanzas.csv")..click();html.Url.revokeObjectUrl(u);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('✅ Exportado'),backgroundColor:Colors.green));}catch(e){print(e);}}
}