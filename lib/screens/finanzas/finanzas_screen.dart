import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

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
  int _vistaReporte = 0;
  List<Map<String, dynamic>> _presupuestos = [];

  final List<String> _categorias = ['Todas', 'Proyecto', 'Servicios', 'Personal', 'Transporte', 'Alquiler', 'Mobiliario', 'Deudas', 'Otros'];
  final List<String> _cuentasLista = ['Todas', 'Efectivo', 'Banco', 'Tarjeta', 'Inversión'];
  final List<String> _negocios = ['Todos', 'Minerales', 'Combustible', 'Agropecuario', 'Proyectos'];
  final List<String> _meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
  final List<Color> _coloresGrafico = [Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.red, Colors.teal, Colors.amber, Colors.cyan, Colors.pink];

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
        _presupuestos = snap.docs.map((doc) {
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

  Future<void> _toggleAplicarPresupuesto(String id, bool aplicar, String nombre, double monto, String cuenta, String subcuenta) async {
    if (aplicar) {
      await _firestore.collection('transacciones').add({'concepto': 'Presupuesto: $nombre', 'monto': monto, 'categoria': nombre, 'tipo': 'Gasto', 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'reconciliada': true, 'created_at': FieldValue.serverTimestamp()});
      await _firestore.collection('transacciones').add({'concepto': 'Transferencia: $nombre', 'monto': monto, 'categoria': 'Transferencia', 'tipo': 'Ingreso', 'cuenta': cuenta, 'subcuenta': subcuenta, 'negocio': 'Proyectos', 'fecha': DateTime.now().toIso8601String().split('T')[0], 'reconciliada': true, 'created_at': FieldValue.serverTimestamp()});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Aplicado \$${monto.toStringAsFixed(2)}'), backgroundColor: Colors.green));
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
        title: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: _mostrarFormularioTransaccion),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: _generarDatosEjemplo, tooltip: 'Generar datos'),
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: _mostrarTransferencia, tooltip: 'Transferir'),
        ],
        bottom: TabBar(
          controller: _tabController, isScrollable: true, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white70, 
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Hoy'), Tab(icon: Icon(Icons.dashboard), text: 'Resumen'), Tab(icon: Icon(Icons.dashboard_customize), text: 'Dashboard'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ingresos'), Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'), Tab(icon: Icon(Icons.credit_card), text: 'Cuentas'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'), Tab(icon: Icon(Icons.show_chart), text: 'Reportes'), Tab(icon: Icon(Icons.pie_chart), text: 'Presupuestos'),
            Tab(icon: Icon(Icons.flag), text: 'Metas'), Tab(icon: Icon(Icons.money_off), text: 'Deudas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVistaHoy(), _buildResumen(), _buildDashboard(), _buildListaTransacciones('Ingreso'), _buildListaTransacciones('Gasto'),
          _buildCuentas(), _buildCalendario(), _buildReportes(), _buildPresupuestos(), _buildMetas(), _buildPlaceholder('Deudas'),
        ],
      ),
    );
  }

  Widget _buildMetas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🏆 Mis Metas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _dialogoMeta(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva Meta', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('metas').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag_outlined, color: Colors.grey.shade700, size: 64),
                        const SizedBox(height: 16),
                        const Text('No hay metas definidas', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = data['nombre'] ?? 'Sin nombre';
                    final objetivo = (data['objetivo'] ?? 0).toDouble();
                    final actual = (data['actual'] ?? 0).toDouble();
                    final meses = (data['meses'] ?? 12).toInt();
                    
                    final porcentaje = objetivo > 0 ? (actual / objetivo * 100).clamp(0, 100) : 0;
                    final completada = actual >= objetivo;
                    final restante = (objetivo - actual).clamp(0, double.infinity);
                    
                    final ahorroMensual = meses > 0 ? restante / meses : 0;
                    final ahorroSemanal = ahorroMensual / 4;
                    final ahorroDiario = ahorroMensual / 30;
                    final fechaEstimada = DateTime.now().add(Duration(days: (restante > 0 ? meses : 0) * 30));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: completada ? Colors.green : const Color(0xFF222222)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(completada ? Icons.emoji_events : Icons.flag, color: completada ? Colors.amber : const Color(0xFF0066FF), size: 28),
                              const SizedBox(width: 12),
                              Expanded(child: Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                              IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _dialogoMeta(meta: data, docId: doc.id)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _eliminarMeta(doc.id)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${actual.toStringAsFixed(0)} / \$${objetivo.toStringAsFixed(0)}', style: TextStyle(color: completada ? Colors.green : Colors.white, fontWeight: FontWeight.bold)),
                              Text('${porcentaje.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: porcentaje / 100,
                              backgroundColor: Colors.grey.shade800,
                              valueColor: AlwaysStoppedAnimation<Color>(completada ? Colors.green : const Color(0xFF0066FF)),
                              minHeight: 10,
                            ),
                          ),
                          if (!completada && restante > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.auto_awesome, color: Color(0xFF0066FF), size: 16),
                                      SizedBox(width: 8),
                                      Text('🎯 Plan de Ahorro Recomendado', style: TextStyle(color: Color(0xFF0066FF), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _planItem('Mensual', ahorroMensual),
                                      _planItem('Semanal', ahorroSemanal),
                                      _planItem('Diario', ahorroDiario),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                                      const SizedBox(width: 8),
                                      Text('Fecha estimada: ${_formatDate(fechaEstimada)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _actualizarMetaActual(doc.id, actual, objetivo),
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                label: const Text('Registrar Ahorro', style: TextStyle(color: Colors.green)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                              ),
                            ),
                          ] else if (completada) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  SizedBox(width: 8),
                                  Text('¡Meta alcanzada! 🎉', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
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

  Widget _planItem(String periodo, double monto) {
    return Column(
      children: [
        Text(periodo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text('\$${monto.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }

  void _dialogoMeta({Map<String, dynamic>? meta, String? docId}) {
    final nombreCtrl = TextEditingController(text: meta?['nombre'] ?? '');
    final objetivoCtrl = TextEditingController(text: meta?['objetivo']?.toString() ?? '0');
    final actualCtrl = TextEditingController(text: meta?['actual']?.toString() ?? '0');
    final mesesCtrl = TextEditingController(text: meta?['meses']?.toString() ?? '12');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(meta != null ? 'Editar Meta' : 'Nueva Meta', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre de la meta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: objetivoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto objetivo (\$)', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: actualCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto actual ahorrado (\$)', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: mesesCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Plazo (meses)', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
            ],
          ),
        ),
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
              
              final updateData = {'nombre': nombreCtrl.text.trim(), 'objetivo': objetivo, 'actual': actual, 'meses': meses};
              if (docId != null) {
                _firestore.collection('metas').doc(docId).update(updateData);
              } else {
                updateData['created_at'] = FieldValue.serverTimestamp();
                _firestore.collection('metas').add(updateData);
              }
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Meta guardada'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _actualizarMetaActual(String docId, double actualActual, double objetivo) {
    final montoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Registrar Ahorro', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Meta actual: \$${actualActual.toStringAsFixed(0)} / \$${objetivo.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto a agregar (\$)', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(montoCtrl.text);
              if (monto == null || monto <= 0) return;
              Navigator.pop(dialogCtx);
              _firestore.collection('metas').doc(docId).update({'actual': FieldValue.increment(monto)});
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ahorro registrado'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _eliminarMeta(String docId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar Meta', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de eliminar esta meta?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _firestore.collection('metas').doc(docId).delete();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Meta eliminada'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestos() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📊 Mis Presupuestos', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _dialogoPresupuesto(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Agregar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _presupuestos.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.pie_chart_outline, color: Colors.grey.shade700, size: 64), const SizedBox(height: 16), const Text('No hay presupuestos', style: TextStyle(color: Colors.grey, fontSize: 16))]))
                : ListView.builder(
                    itemCount: _presupuestos.length,
                    itemBuilder: (context, index) {
                      final p = _presupuestos[index];
                      final gastado = p['gastado'] as double;
                      final presupuesto = p['presupuesto'] as double;
                      final porcentaje = presupuesto > 0 ? (gastado / presupuesto * 100).clamp(0, 100) : 0;
                      final excedido = gastado > presupuesto;
                      final aplicado = p['aplicado'] ?? false;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: aplicado ? Colors.green : const Color(0xFF222222))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Icon(Icons.category, color: const Color(0xFF0066FF), size: 24),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('${p['cuenta']} • ${p['subcuenta']}', style: const TextStyle(color: Colors.grey, fontSize: 11))])),
                            if (aplicado) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF0066FF), size: 20), onPressed: () => _dialogoPresupuesto(presupuesto: p), tooltip: 'Editar'),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _eliminarPresupuesto(p['id'])),
                          ]),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\$${gastado.toStringAsFixed(0)} / \$${presupuesto.toStringAsFixed(0)}', style: TextStyle(color: excedido ? Colors.red : Colors.green, fontSize: 14, fontWeight: FontWeight.bold)), Text('${porcentaje.toStringAsFixed(1)}%', style: TextStyle(color: excedido ? Colors.red : Colors.grey, fontSize: 12))]),
                          const SizedBox(height: 8),
                          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: porcentaje / 100, minHeight: 8, backgroundColor: Colors.grey.shade800, valueColor: AlwaysStoppedAnimation<Color>(excedido ? Colors.red : const Color(0xFF0066FF)))),
                          if (excedido) const Padding(padding: EdgeInsets.only(top: 8), child: Text('⚠️ EXCEDIDO', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 12),
                          Row(children: [const Text('Aplicar:', style: TextStyle(color: Colors.grey, fontSize: 12)), const Spacer(), Switch(value: aplicado, activeColor: Colors.green, onChanged: (v) => _toggleAplicarPresupuesto(p['id'], v, p['nombre'], presupuesto, p['cuenta'], p['subcuenta'])), Text(aplicado ? 'Activo' : 'Inactivo', style: TextStyle(color: aplicado ? Colors.green : Colors.grey, fontSize: 12))]),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _dialogoPresupuesto({Map? presupuesto}) {
    final nc = TextEditingController(text: presupuesto?['nombre'] ?? '');
    final mc = TextEditingController(text: presupuesto?['presupuesto']?.toString() ?? '0');
    final gc = TextEditingController(text: presupuesto?['gastado']?.toString() ?? '0');
    String ct = presupuesto?['cuenta'] ?? 'Efectivo';
    String sc = presupuesto?['subcuenta'] ?? 'Proyectos';
    showDialog(context: context, builder: (d) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: Text(presupuesto != null ? 'Editar' : 'Nuevo', style: const TextStyle(color: Colors.white)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nc, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: mc, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: gc, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Gastado', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: ct, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => ct = v!),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(value: sc, decoration: const InputDecoration(labelText: 'Subcuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF111111), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: _negocios.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => sc = v!),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancelar')), ElevatedButton(onPressed: () {
      final mo = double.tryParse(mc.text); final ga = double.tryParse(gc.text) ?? 0;
      if (mo == null || nc.text.isEmpty) return;
      Navigator.pop(d);
      if (presupuesto != null) {
        _firestore.collection('presupuestos_personalizados').doc(presupuesto['id']).update({'nombre': nc.text.trim(), 'presupuesto': mo, 'gastado': ga, 'cuenta': ct, 'subcuenta': sc});
      } else {
        _agregarPresupuesto(nc.text.trim(), mo, ga, ct, sc);
      }
      _cargarPresupuestos();
    }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)), child: const Text('Guardar', style: TextStyle(color: Colors.white)))]));
  }

  Widget _buildReportes() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Reportes Financieros', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: ElevatedButton(onPressed: () => setState(() => _vistaReporte = 0), style: ElevatedButton.styleFrom(backgroundColor: _vistaReporte == 0 ? const Color(0xFF0066FF) : const Color(0xFF1A1A1A), foregroundColor: Colors.white), child: const Text('Por Categoría'))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: () => setState(() => _vistaReporte = 1), style: ElevatedButton.styleFrom(backgroundColor: _vistaReporte == 1 ? const Color(0xFF0066FF) : const Color(0xFF1A1A1A), foregroundColor: Colors.white), child: const Text('Por Negocio')))]),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              double totalIngresos = 0, totalGastos = 0;
              Map<String, double> ingresosPorCategoria = {}, gastosPorCategoria = {}, porNegocio = {};
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final monto = (data['monto'] ?? 0).toDouble();
                final tipo = data['tipo'] ?? '';
                final categoria = data['categoria'] ?? 'Otros';
                final negocio = data['negocio'] ?? 'Otros';
                if (tipo == 'Ingreso') { totalIngresos += monto; ingresosPorCategoria[categoria] = (ingresosPorCategoria[categoria] ?? 0) + monto; }
                else { totalGastos += monto; gastosPorCategoria[categoria] = (gastosPorCategoria[categoria] ?? 0) + monto; }
                porNegocio[negocio] = (porNegocio[negocio] ?? 0) + (tipo == 'Ingreso' ? monto : -monto);
              }
              final balance = totalIngresos - totalGastos;
              return Column(children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${totalIngresos.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]), Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${totalGastos.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]), Column(children: [const Text('Balance', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('\$${balance.toStringAsFixed(0)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold))])])),
                const SizedBox(height: 24),
                if (_vistaReporte == 0) ...[
                  const Text('Distribución por Categoría', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(height: 300, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: _buildGraficoCategorias(ingresosPorCategoria, gastosPorCategoria)),
                  const SizedBox(height: 24),
                  _buildListaCategorias(ingresosPorCategoria, gastosPorCategoria),
                ] else ...[
                  const Text('Rendimiento por Negocio', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(height: 300, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: _buildGraficoNegocios(porNegocio)),
                  const SizedBox(height: 24),
                  _buildListaNegocios(porNegocio),
                ],
              ]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoCategorias(Map<String, double> ingresos, Map<String, double> gastos) {
    final todasCategorias = {...ingresos.keys, ...gastos.keys}.toList();
    if (todasCategorias.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
    final secciones = todasCategorias.asMap().entries.map((entry) {
      final idx = entry.key; final cat = entry.value;
      final valorIngreso = ingresos[cat] ?? 0; final valorGasto = gastos[cat] ?? 0;
      return PieChartSectionData(value: valorIngreso + valorGasto, title: cat.length > 8 ? '${cat.substring(0, 8)}..' : cat, color: _coloresGrafico[idx % _coloresGrafico.length], radius: 100, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold));
    }).toList();
    return PieChart(PieChartData(sections: secciones, sectionsSpace: 2, centerSpaceRadius: 40, startDegreeOffset: 270));
  }

  Widget _buildGraficoNegocios(Map<String, double> porNegocio) {
    if (porNegocio.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: Colors.grey)));
    final maxValor = porNegocio.values.fold<double>(0, (max, val) => val.abs() > max ? val.abs() : max);
    return BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: maxValor * 1.2, minY: -maxValor * 0.3, barTouchData: BarTouchData(enabled: false), titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { final negocios = porNegocio.keys.toList(); if (value.toInt() >= 0 && value.toInt() < negocios.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(negocios[value.toInt()].length > 6 ? '${negocios[value.toInt()].substring(0, 6)}..' : negocios[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10))); return const SizedBox.shrink(); })), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))), borderData: FlBorderData(show: false), barGroups: porNegocio.entries.toList().asMap().entries.map((entry) { final idx = entry.key; final valor = entry.value.value; return BarChartGroupData(x: idx, barRods: [BarChartRodData(toY: valor, color: valor >= 0 ? Colors.green : Colors.red, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]); }).toList()));
  }

  Widget _buildListaCategorias(Map<String, double> ingresos, Map<String, double> gastos) {
    final todasCategorias = {...ingresos.keys, ...gastos.keys}.toList();
    todasCategorias.sort((a, b) { final totalA = (ingresos[a] ?? 0) + (gastos[a] ?? 0); final totalB = (ingresos[b] ?? 0) + (gastos[b] ?? 0); return totalB.compareTo(totalA); });
    return Column(children: todasCategorias.map((cat) {
      final ing = ingresos[cat] ?? 0; final gas = gastos[cat] ?? 0; final total = ing + gas; final idx = todasCategorias.indexOf(cat); final color = _coloresGrafico[idx % _coloresGrafico.length];
      return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)), child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Row(children: [if (ing > 0) Text('In: \$${ing.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 11)), if (ing > 0 && gas > 0) const SizedBox(width: 8), if (gas > 0) Text('Gas: \$${gas.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 11))])])), Text('\$${total.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold))]));
    }).toList());
  }

  Widget _buildListaNegocios(Map<String, double> porNegocio) {
    final negociosOrdenados = porNegocio.entries.toList()..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final maxValor = porNegocio.values.fold<double>(0, (max, val) => val.abs() > max ? val.abs() : max);
    return Column(children: negociosOrdenados.map((entry) {
      final negocio = entry.key; final valor = entry.value; final porcentaje = maxValor > 0 ? (valor.abs() / maxValor * 100) : 0; final color = valor >= 0 ? Colors.green : Colors.red;
      return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(negocio, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), Text('\$${valor.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text('${porcentaje.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 11))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: porcentaje / 100, backgroundColor: Colors.grey.shade800, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6))]));
    }).toList());
  }

  Widget _buildCalendario() {
    DateTime mesSeleccionado = DateTime.now();
    return StatefulBuilder(builder: (context, setEstado) {
      return Container(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => setEstado(() => mesSeleccionado = DateTime(mesSeleccionado.year, mesSeleccionado.month - 1))), Text('${_meses[mesSeleccionado.month - 1]} ${mesSeleccionado.year}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => setEstado(() => mesSeleccionado = DateTime(mesSeleccionado.year, mesSeleccionado.month + 1)))]),
        const SizedBox(height: 16),
        Expanded(child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(), builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          final transaccionesDelMes = docs.where((doc) { final data = doc.data() as Map<String, dynamic>; final fechaStr = data['fecha'] as String? ?? ''; if (fechaStr.length >= 7) { final partes = fechaStr.split('-'); if (partes.length >= 2) { final anio = int.tryParse(partes[0]); final mes = int.tryParse(partes[1]); return anio == mesSeleccionado.year && mes == mesSeleccionado.month; } } return false; }).toList();
          if (transaccionesDelMes.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, color: Colors.grey.shade700, size: 64), const SizedBox(height: 16), Text('No hay transacciones en ${_meses[mesSeleccionado.month - 1]}', style: const TextStyle(color: Colors.grey, fontSize: 16))]));
          Map<String, List<Map<String, dynamic>>> porDia = {};
          for (var doc in transaccionesDelMes) { final data = doc.data() as Map<String, dynamic>; final fechaStr = data['fecha'] as String? ?? ''; if (fechaStr.length >= 10) { final dia = fechaStr.substring(8, 10); porDia.putIfAbsent(dia, () => []).add(data); } }
          final diasOrdenados = porDia.keys.toList()..sort((a, b) => b.compareTo(a));
          return ListView.builder(itemCount: diasOrdenados.length, itemBuilder: (context, index) {
            final dia = diasOrdenados[index]; final transacciones = porDia[dia]!; double totalDia = 0;
            for (var t in transacciones) { final monto = (t['monto'] ?? 0).toDouble(); if (t['tipo'] == 'Ingreso') totalDia += monto; else totalDia -= monto; }
            return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))), child: ExpansionTile(backgroundColor: const Color(0xFF111111), collapsedBackgroundColor: const Color(0xFF111111), iconColor: Colors.white, collapsedIconColor: Colors.white, title: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(dia, style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 14)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Día $dia • ${transacciones.length} transacciones', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text('${_meses[mesSeleccionado.month - 1]} ${mesSeleccionado.year}', style: const TextStyle(color: Colors.grey, fontSize: 11))])), Text('\$${totalDia.toStringAsFixed(2)}', style: TextStyle(color: totalDia >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16))])), children: [const Divider(color: Color(0xFF222222)), ...transacciones.map((t) { final esIngreso = t['tipo'] == 'Ingreso'; return ListTile(leading: Container(width: 35, height: 35, decoration: BoxDecoration(color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 18)), title: Text(t['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontSize: 14)), subtitle: Text('${t['categoria'] ?? 'General'} • ${t['negocio'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 11)), trailing: Text('${esIngreso ? "+" : "-"}\$${(t['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold))); }).toList()]));
          });
        })),
      ]));
    });
  }

  Widget _buildCuentas() {
    return Container(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('💳 Mis Cuentas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), const Text('Saldos calculados automáticamente', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 16),
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final cuentas = [{'nombre': 'Efectivo', 'icon': Icons.money, 'color': Colors.green}, {'nombre': 'Banco', 'icon': Icons.account_balance, 'color': Colors.blue}, {'nombre': 'Tarjeta', 'icon': Icons.credit_card, 'color': Colors.orange}, {'nombre': 'Inversión', 'icon': Icons.trending_up, 'color': Colors.purple}];
        return ListView.builder(itemCount: cuentas.length, itemBuilder: (context, index) {
          final cuenta = cuentas[index]; double balance = 0; int numTransacciones = 0;
          for (var doc in docs) { final data = doc.data() as Map<String, dynamic>; if (data['cuenta'] == cuenta['nombre']) { final monto = (data['monto'] ?? 0).toDouble(); if (data['tipo'] == 'Ingreso') balance += monto; if (data['tipo'] == 'Gasto') balance -= monto; numTransacciones++; } }
          return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: (cuenta['color'] as Color).withOpacity(0.2), shape: BoxShape.circle), child: Icon(cuenta['icon'] as IconData, color: cuenta['color'] as Color, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cuenta['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text('$numTransacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 12))])), Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]));
        });
      })),
    ]));
  }

  Widget _buildListaTransacciones(String tipo) {
    final colorPrincipal = tipo == 'Ingreso' ? Colors.green : Colors.red;
    final iconoPrincipal = tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward;
    return Container(child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(16), color: const Color(0xFF111111), child: Column(children: [
        TextField(decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)), style: const TextStyle(color: Colors.white), onChanged: (v) => setState(() => _search = v.toLowerCase())),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: DropdownButtonFormField<String>(value: _categoriaFiltro, decoration: const InputDecoration(labelText: 'Categoría', filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _categoriaFiltro = v!))), const SizedBox(width: 12), Expanded(child: DropdownButtonFormField<String>(value: _cuentaFiltro, decoration: const InputDecoration(labelText: 'Cuenta', filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: _cuentasLista.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _cuentaFiltro = v!)))]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _negocioFiltro, decoration: const InputDecoration(labelText: 'Negocio', filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: _negocios.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setState(() => _negocioFiltro = v!)),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: CheckboxListTile(title: const Text('Solo pendientes', style: TextStyle(color: Colors.white, fontSize: 12)), value: _soloPendientes, activeColor: const Color(0xFF0066FF), onChanged: (v) => setState(() => _soloPendientes = v ?? false), contentPadding: EdgeInsets.zero)), Expanded(child: CheckboxListTile(title: const Text('Solo reconciliadas', style: TextStyle(color: Colors.white, fontSize: 12)), value: _soloReconciliadas, activeColor: Colors.green, onChanged: (v) => setState(() => _soloReconciliadas = v ?? false), contentPadding: EdgeInsets.zero))]),
      ])),
      Expanded(child: Container(width: double.infinity, padding: const EdgeInsets.all(16), child: StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        final transacciones = snapshot.data?.docs ?? [];
        final filtrados = transacciones.where((doc) { final data = doc.data() as Map<String, dynamic>; final concepto = (data['concepto'] ?? '').toString().toLowerCase(); final categoria = data['categoria'] ?? 'General'; final cuenta = data['cuenta'] ?? 'Efectivo'; final negocio = data['negocio'] ?? 'Minerales'; final reconciliada = data['reconciliada'] ?? false; return data['tipo'] == tipo && (_search.isEmpty || concepto.contains(_search)) && (_categoriaFiltro == 'Todas' || categoria == _categoriaFiltro) && (_cuentaFiltro == 'Todas' || cuenta == _cuentaFiltro) && (_negocioFiltro == 'Todos' || negocio == _negocioFiltro) && (!_soloPendientes || !reconciliada) && (!_soloReconciliadas || reconciliada); }).toList();
        if (filtrados.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(iconoPrincipal, color: Colors.grey, size: 64), const SizedBox(height: 16), Text('No hay ${tipo.toLowerCase()}s registrados', style: const TextStyle(color: Colors.grey, fontSize: 16))]));
        final total = filtrados.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());
        return Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: colorPrincipal.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: colorPrincipal)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total:', style: TextStyle(color: colorPrincipal, fontSize: 16, fontWeight: FontWeight.bold)), Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: colorPrincipal, fontSize: 20, fontWeight: FontWeight.bold))])), Expanded(child: ListView.builder(itemCount: filtrados.length, itemBuilder: (context, index) { final doc = filtrados[index]; final data = doc.data() as Map<String, dynamic>; final acreedor = data['acreedor'] ?? ''; final reconciliada = data['reconciliada'] ?? false; final tags = List<String>.from(data['tags'] ?? []); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: colorPrincipal.withOpacity(0.2), shape: BoxShape.circle), child: Icon(iconoPrincipal, color: colorPrincipal, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16)]), const SizedBox(height: 4), Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'} • ${data['negocio'] ?? 'Sin negocio'}', style: const TextStyle(color: Colors.grey, fontSize: 12)), if (acreedor.isNotEmpty) Text('Acreedor: $acreedor', style: const TextStyle(color: Colors.orange, fontSize: 11)), if (tags.isNotEmpty) ...[const SizedBox(height: 4), Wrap(spacing: 4, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)))).toList())]])), Text('\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: colorPrincipal, fontSize: 16, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.end, children: [IconButton(icon: const Icon(Icons.copy, color: Colors.blue, size: 18), onPressed: () => _duplicarTransaccion(data), tooltip: 'Duplicar'), IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 18), onPressed: () => _mostrarFormularioTransaccion(transaccion: data, docId: doc.id), tooltip: 'Editar'), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _confirmarEliminar(doc.id, data['concepto'] ?? ''), tooltip: 'Eliminar')])]))); })))]);
      }))),
    ]));
  }

  Future<void> _duplicarTransaccion(Map<String, dynamic> data) async {
    await _firestore.collection('transacciones').add({'concepto': '${data['concepto']} (copia)', 'monto': data['monto'] ?? 0, 'categoria': data['categoria'] ?? 'General', 'fecha': data['fecha'] ?? DateTime.now().toIso8601String().split('T')[0], 'descripcion': data['descripcion'] ?? '', 'metodo_pago': data['metodo_pago'] ?? 'Efectivo', 'referencia': data['referencia'] ?? '', 'tipo': data['tipo'] ?? 'Ingreso', 'cuenta': data['cuenta'] ?? 'Efectivo', 'subcuenta': data['subcuenta'] ?? 'Minerales', 'negocio': data['negocio'] ?? 'Minerales', 'acreedor': data['acreedor'] ?? '', 'tags': data['tags'] ?? [], 'reconciliada': false, 'created_at': FieldValue.serverTimestamp()});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Duplicada'), backgroundColor: Colors.green));
  }

  Future<void> _confirmarEliminar(String id, String concepto) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Eliminar transacción', style: TextStyle(color: Colors.white)), content: Text('¿Eliminar "$concepto"?', style: const TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar', style: TextStyle(color: Colors.white)))]));
    if (confirm == true) { await _firestore.collection('transacciones').doc(id).delete(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red)); }
  }

  Widget _buildVistaHoy() {
    final hoy = DateTime.now(); final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    return Container(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.calendar_today, color: Colors.white70, size: 20), const SizedBox(width: 8), Expanded(child: Text('${hoy.day} de ${_meses[hoy.month - 1]} ${hoy.year}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))]), const SizedBox(height: 16), StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return Row(children: [Expanded(child: _miniCard('...', Icons.schedule, Colors.orange)), const SizedBox(width: 12), Expanded(child: _miniCard('...', Icons.check_circle, Colors.green))]); final docs = snapshot.data!.docs; int pendientes = 0, completadas = 0; for (var doc in docs) { final data = doc.data() as Map<String, dynamic>; if (data['fecha'] == fechaHoy) { if (data['reconciliada'] == true) completadas++; else pendientes++; } } return Row(children: [Expanded(child: _miniCard('$pendientes Pendientes', Icons.schedule, Colors.orange)), const SizedBox(width: 12), Expanded(child: _miniCard('$completadas Completadas', Icons.check_circle, Colors.green))]); })])),
      const SizedBox(height: 24), const Text('📋 Transacciones de Hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
      StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['fecha'] == fechaHoy).toList(); if (docs.isEmpty) return Container(width: double.infinity, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: const Column(children: [Icon(Icons.event_busy, color: Colors.grey, size: 64), SizedBox(height: 16), Text('No hay transacciones para hoy', style: TextStyle(color: Colors.grey, fontSize: 16)), SizedBox(height: 8), Text('Usa el botón + para agregar una', style: TextStyle(color: Colors.grey, fontSize: 14))])); double totalIngresos = 0, totalGastos = 0; for (var doc in docs) { final data = doc.data() as Map<String, dynamic>; final monto = (data['monto'] ?? 0).toDouble(); if (data['tipo'] == 'Ingreso') totalIngresos += monto; else totalGastos += monto; } return Column(children: [Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey)), Text('\$${totalIngresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]), Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey)), Text('\$${totalGastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]), Column(children: [const Text('Balance', style: TextStyle(color: Colors.grey)), Text('\$${(totalIngresos - totalGastos).toStringAsFixed(2)}', style: TextStyle(color: (totalIngresos - totalGastos) >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold))])])), ...docs.map((doc) { final data = doc.data() as Map<String, dynamic>; final esIngreso = data['tipo'] == 'Ingreso'; final reconciliada = data['reconciliada'] ?? false; final tags = List<String>.from(data['tags'] ?? []); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222))), child: Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), shape: BoxShape.circle), child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16)]), const SizedBox(height: 4), Text('${data['categoria'] ?? 'General'} • ${data['negocio'] ?? 'Sin negocio'}', style: const TextStyle(color: Colors.grey, fontSize: 12)), if (tags.isNotEmpty) ...[const SizedBox(height: 4), Wrap(spacing: 4, children: tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)))).toList())]])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${esIngreso ? "+" : "-"}\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), if (!reconciliada) TextButton(onPressed: () async { await _firestore.collection('transacciones').doc(doc.id).update({'reconciliada': true}); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Transacción aprobada'), backgroundColor: Colors.green)); }, child: const Text('Aprobar', style: TextStyle(color: Color(0xFF0066FF), fontSize: 11))) else const Icon(Icons.check_circle, color: Colors.green, size: 20)])])); }).toList()]); })])),
    ])));
  }

  Widget _miniCard(String titulo, IconData icon, Color color) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(titulo, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)))]));

  Widget _buildResumen() {
    return Container(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Balance Total', style: TextStyle(color: Colors.white70, fontSize: 14)), const SizedBox(height: 8), StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)); double ingresos = 0, gastos = 0; for (var doc in snapshot.data!.docs) { final data = doc.data() as Map<String, dynamic>; final monto = (data['monto'] ?? 0).toDouble(); if (data['tipo'] == 'Ingreso') ingresos += monto; if (data['tipo'] == 'Gasto') gastos += monto; } return Text('\$${(ingresos - gastos).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)); })])),
      const SizedBox(height: 16), Row(children: [Expanded(child: _tarjetaResumen('Ingresos', Colors.green, Icons.arrow_upward)), const SizedBox(width: 12), Expanded(child: _tarjetaResumen('Gastos', Colors.red, Icons.arrow_downward))]),
    ])));
  }

  Widget _tarjetaResumen(String titulo, Color color, IconData icon) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(titulo, style: TextStyle(color: color, fontWeight: FontWeight.bold))]), const SizedBox(height: 8), StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) { if (!snapshot.hasData) return const Text('\$0', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)); double total = 0; for (var doc in snapshot.data!.docs) { final data = doc.data() as Map<String, dynamic>; if (data['tipo'] == titulo) total += (data['monto'] ?? 0).toDouble(); } return Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)); })]));
  }

  Widget _buildDashboard() {
    return Container(padding: const EdgeInsets.all(12), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📊 Dashboard Ejecutivo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), const Text('Indicadores clave de rendimiento', style: TextStyle(color: Colors.grey, fontSize: 11)), const SizedBox(height: 12),
      StreamBuilder<QuerySnapshot>(stream: _firestore.collection('transacciones').snapshots(), builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs; double ingresos = 0, gastos = 0; int numTransacciones = 0; Map<String, double> porNegocio = {};
        for (var doc in docs) { final data = doc.data() as Map<String, dynamic>; final monto = (data['monto'] ?? 0).toDouble(); final tipo = data['tipo'] ?? ''; final negocio = data['negocio'] ?? 'Otros'; if (tipo == 'Ingreso') ingresos += monto; if (tipo == 'Gasto') gastos += monto; numTransacciones++; porNegocio[negocio] = (porNegocio[negocio] ?? 0) + (tipo == 'Ingreso' ? monto : -monto); }
        final margenGanancia = ingresos > 0 ? ((ingresos - gastos) / ingresos * 100) : 0; final ticketPromedio = numTransacciones > 0 ? ingresos / numTransacciones : 0; final flujoNeto = ingresos - gastos;
        return Column(children: [GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.8, mainAxisSpacing: 8, crossAxisSpacing: 8, children: [_kpiCard('Ingresos', '\$${ingresos.toStringAsFixed(0)}', Icons.trending_up, Colors.green), _kpiCard('Gastos', '\$${gastos.toStringAsFixed(0)}', Icons.trending_down, Colors.red), _kpiCard('Flujo Neto', '\$${flujoNeto.toStringAsFixed(0)}', Icons.account_balance_wallet, flujoNeto >= 0 ? Colors.green : Colors.red), _kpiCard('Margen', '${margenGanancia.toStringAsFixed(1)}%', Icons.percent, Colors.blue), _kpiCard('Ticket Prom.', '\$${ticketPromedio.toStringAsFixed(0)}', Icons.receipt_long, Colors.orange), _kpiCard('Transacciones', '$numTransacciones', Icons.list_alt, Colors.purple)]), const SizedBox(height: 16), const Text('📈 Rendimiento por Negocio', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...porNegocio.entries.map((e) { final porcentaje = ingresos > 0 ? (e.value / ingresos * 100).abs() : 0; final color = e.value >= 0 ? Colors.green : Colors.red; return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.3))), child: Row(children: [Expanded(child: Text(e.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))), Text('\$${e.value.toStringAsFixed(0)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(width: 8), Text('${porcentaje.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 10))])); }).toList()]);
      }),
    ])));
  }

  Widget _kpiCard(String titulo, String valor, IconData icono, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))), child: Row(children: [Icon(icono, color: color, size: 18), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 9)), const SizedBox(height: 2), Text(valor, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)]))]));
  }

  Widget _buildPlaceholder(String nombre) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.construction, color: Colors.grey.shade700, size: 64), const SizedBox(height: 16), Text('$nombre - En desarrollo', style: const TextStyle(color: Colors.grey, fontSize: 16)]));
  }

  void _mostrarFormularioTransaccion({Map<String, dynamic>? transaccion, String? docId}) {
    final conceptoCtrl = TextEditingController(text: transaccion?['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: transaccion?['monto']?.toString() ?? '0');
    String tipo = transaccion?['tipo'] ?? 'Ingreso';
    String cuenta = transaccion?['cuenta'] ?? 'Efectivo';
    String negocio = transaccion?['negocio'] ?? 'Minerales';
    bool reconciliada = transaccion?['reconciliada'] ?? false;

    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF111111), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) => Container(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(transaccion == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF0066FF), size: 28), const SizedBox(width: 12), Expanded(child: Text(transaccion == null ? 'Nueva Transacción' : 'Editar', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx))]),
      const SizedBox(height: 20),
      TextField(controller: conceptoCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Concepto *', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: montoCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Monto', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder())),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: RadioListTile<String>(title: const Text('Ingreso', style: TextStyle(color: Colors.white)), value: 'Ingreso', groupValue: tipo, activeColor: Colors.green, onChanged: (v) => setSheetState(() => tipo = v!))), Expanded(child: RadioListTile<String>(title: const Text('Gasto', style: TextStyle(color: Colors.white)), value: 'Gasto', groupValue: tipo, activeColor: Colors.red, onChanged: (v) => setSheetState(() => tipo = v!)))]),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: cuenta, decoration: const InputDecoration(labelText: 'Cuenta', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setSheetState(() => cuenta = v!)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: negocio, decoration: const InputDecoration(labelText: 'Negocio', labelStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Color(0xFF1A1A1A), border: OutlineInputBorder()), dropdownColor: const Color(0xFF1A1A1A), style: const TextStyle(color: Colors.white), items: _negocios.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setSheetState(() => negocio = v!)),
      const SizedBox(height: 12),
      CheckboxListTile(title: const Text('Reconciliada', style: TextStyle(color: Colors.white)), value: reconciliada, activeColor: Colors.green, onChanged: (v) => setSheetState(() => reconciliada = v ?? false), contentPadding: EdgeInsets.zero),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: () async {
        if (conceptoCtrl.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Concepto obligatorio'), backgroundColor: Colors.orange)); return; }
        final hoy = DateTime.now(); final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
        final data = {'concepto': conceptoCtrl.text.trim(), 'monto': double.tryParse(montoCtrl.text) ?? 0, 'tipo': tipo, 'cuenta': cuenta, 'negocio': negocio, 'categoria': 'General', 'fecha': transaccion?['fecha'] ?? fechaHoy, 'reconciliada': reconciliada, 'tags': transaccion?['tags'] ?? [], 'descripcion': transaccion?['descripcion'] ?? '', 'subcuenta': negocio, 'metodo_pago': 'Efectivo', 'referencia': '', 'acreedor': ''};
        if (docId == null) { data['created_at'] = FieldValue.serverTimestamp(); await _firestore.collection('transacciones').add(data); } else { await _firestore.collection('transacciones').doc(docId).update(data); }
        Navigator.pop(ctx); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? '✅ Creada' : '✅ Actualizada'), backgroundColor: Colors.green));
      }, icon: const Icon(Icons.save, color: Colors.white), label: Text(transaccion == null ? 'Crear' : 'Guardar', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
      const SizedBox(height: 20),
    ])))));
  }

  void _mostrarTransferencia() { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transferencia entre cuentas - Próximamente'), backgroundColor: Colors.orange)); }

  Future<void> _generarDatosEjemplo() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text('Generar Datos', style: TextStyle(color: Colors.white)), content: const Text('¿Crear transacciones de ejemplo para hoy?', style: TextStyle(color: Colors.grey)), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí'))]));
    if (confirm != true) return;
    final hoy = DateTime.now(); final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    final ejemplos = [{'concepto': 'Venta del día', 'monto': 5000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso', 'negocio': 'Minerales', 'cuenta': 'Banco', 'reconciliada': false, 'tags': ['#negocio']}, {'concepto': 'Pago proveedor', 'monto': 1500.0, 'categoria': 'Deudas', 'tipo': 'Gasto', 'negocio': 'Combustible', 'cuenta': 'Efectivo', 'reconciliada': true, 'tags': ['#urgente']}, {'concepto': 'Servicio consultoría', 'monto': 8000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso', 'negocio': 'Proyectos', 'cuenta': 'Banco', 'reconciliada': false, 'tags': ['#cliente']}];
    for (var t in ejemplos) { await _firestore.collection('transacciones').add({...t, 'fecha': fechaHoy, 'descripcion': 'Ejemplo del día', 'subcuenta': t['negocio'], 'metodo_pago': 'Efectivo', 'referencia': '', 'acreedor': '', 'created_at': FieldValue.serverTimestamp()}); }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ 3 transacciones de ejemplo creadas para hoy'), backgroundColor: Colors.green));
  }
}