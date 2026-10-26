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
  void initState() { 
    super.initState(); 
    _tabController = TabController(length: 11, vsync: this); 
    _cargarPresupuestos(); 
  }
  
  @override
  void dispose() { 
    _tabController.dispose(); 
    super.dispose(); 
  }

  Future<void> _cargarPresupuestos() async {
    try {
      final snap = await _firestore.collection('presupuestos_personalizados').get();
      setState(() {
        _presupuestosPersonalizados = snap.docs.map((doc) {
          final d = doc.data();
          return {
            'id': doc.id, 
            'nombre': d['nombre'] ?? '', 
            'presupuesto': (d['presupuesto'] ?? 0).toDouble(), 
            'gastado': (d['gastado'] ?? 0).toDouble(), 
            'cuenta': d['cuenta'] ?? 'Efectivo', 
            'subcuenta': d['subcuenta'] ?? 'Proyectos', 
            'aplicado': d['aplicado'] ?? false
          };
        }).toList();
      });
    } catch (e) { 
      print(e); 
    }
  }

  Future<void> _agregarPresupuesto(String nombre, double monto, double gastado, String cuenta, String subcuenta) async {
    await _firestore.collection('presupuestos_personalizados').add({
      'nombre': nombre, 
      'presupuesto': monto, 
      'gastado': gastado, 
      'cuenta': cuenta, 
      'subcuenta': subcuenta, 
      'aplicado': false, 
      'created_at': FieldValue.serverTimestamp()
    });
    await _cargarPresupuestos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Presupuesto creado'), backgroundColor: Colors.green));
    }
  }

  Future<void> _eliminarPresupuesto(String id) async {
    await _firestore.collection('presupuestos_personalizados').doc(id).delete();
    await _cargarPresupuestos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }

  Future<void> _toggleAplicar(String id, bool aplicar, String nombre, double monto, String cuenta, String subcuenta) async {
    if (aplicar) {
      await _firestore.collection('transacciones').add({
        'concepto': 'Presupuesto: $nombre', 
        'monto': monto, 
        'categoria': nombre, 
        'tipo': 'Gasto', 
        'cuenta': cuenta, 
        'subcuenta': subcuenta, 
        'negocio': 'Proyectos', 
        'fecha': DateTime.now().toIso8601String().split('T')[0], 
        'reconciliada': true, 
        'created_at': FieldValue.serverTimestamp()
      });
      await _firestore.collection('transacciones').add({
        'concepto': 'Transferencia: $nombre', 
        'monto': monto, 
        'categoria': 'Transferencia', 
        'tipo': 'Ingreso', 
        'cuenta': cuenta, 
        'subcuenta': subcuenta, 
        'negocio': 'Proyectos', 
        'fecha': DateTime.now().toIso8601String().split('T')[0], 
        'reconciliada': true, 
        'created_at': FieldValue.serverTimestamp()
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Aplicado \$${monto.toStringAsFixed(2)}'), backgroundColor: Colors.green));
      }
    }
    await _firestore.collection('presupuestos_personalizados').doc(id).update({'aplicado': aplicar});
    await _cargarPresupuestos();
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
          Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: _mostrarFormularioTransaccion),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: _generarDatosEjemplo, tooltip: 'Generar datos'),
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: _mostrarTransferencia, tooltip: 'Transferir'),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white), 
            onSelected: (v) { 
              if (v == 'exportar') _exportarCSV(); 
              else if (v == 'calendario') _tabController.animateTo(6); 
              else if (v == 'hoy') _tabController.animateTo(0); 
            }, 
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'hoy', child: Text('Vista Hoy')), 
              const PopupMenuItem(value: 'calendario', child: Text('Calendario')), 
              const PopupMenuItem(value: 'exportar', child: Text('Exportar CSV'))
            ]
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
            Tab(icon: Icon(Icons.money_off), text: 'Deudas'),
          ]
        ),
      ),
      body: TabBarView(
        controller: _tabController, 
        children: [
          _buildVistaHoy(), 
          _buildResumen(), 
          _buildDashboard(), 
          _buildLista('Ingreso'), 
          _buildLista('Gasto'),
          _buildCuentas(), 
          _buildCalendario(), 
          _buildReportes(), 
          _buildPresupuestos(), 
          _buildMetas(), 
          _buildDeudas(),
        ]
      ),
    );
  }

  // ============================================
  // PESTAÑA DEUDAS
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
                  onChanged: (v) { 
                    final val = double.tryParse(v); 
                    if (val != null) setDialogState(() => interesPorcentaje = val); 
                  },
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
                  onChanged: (v) { 
                    final val = double.tryParse(v); 
                    if (val != null) setDialogState(() => interesPorcentaje = val); 
                  },
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
  // RESTO DE WIDGETS SIMPLIFICADOS
  // ============================================
  
  Widget _buildVistaHoy() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Vista Hoy - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Resumen - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Dashboard - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildLista(String tipo) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(child: Text('Lista de $tipo - En desarrollo', style: const TextStyle(color: Colors.white))),
    );
  }

  Widget _buildCuentas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Cuentas - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildCalendario() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Calendario - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildReportes() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Reportes - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildPresupuestos() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Presupuestos - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildMetas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Metas - En desarrollo', style: TextStyle(color: Colors.white))),
    );
  }

  void _mostrarFormularioTransaccion() {}
  void _mostrarTransferencia() {}
  Future<void> _exportarCSV() async {}
  Future<void> _generarDatosEjemplo() async {}
}