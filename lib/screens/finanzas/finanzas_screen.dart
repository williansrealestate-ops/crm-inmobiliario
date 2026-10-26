import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _mostrarFormularioTransaccion,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            onPressed: _generarDatosEjemplo,
            tooltip: 'Generar datos',
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            onPressed: _mostrarTransferencia,
            tooltip: 'Transferir',
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVistaHoy(),
          _buildPlaceholder('Resumen'),
          _buildPlaceholder('Dashboard'),
          _buildPlaceholder('Ingresos'),
          _buildPlaceholder('Gastos'),
          _buildPlaceholder('Cuentas'),
          _buildPlaceholder('Calendario'),
          _buildPlaceholder('Reportes'),
          _buildPlaceholder('Presupuestos'),
          _buildPlaceholder('Metas'),
          _buildPlaceholder('Deudas'),
        ],
      ),
    );
  }

  // ==========================================
  // ✅ PESTAÑA "HOY" COMPLETA Y FUNCIONAL
  // ==========================================
  Widget _buildVistaHoy() {
    final hoy = DateTime.now();
    final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Fecha
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${hoy.day} de ${['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][hoy.month - 1]} ${hoy.year}',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('transacciones').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Row(
                          children: [
                            Expanded(child: _miniCard('...', Icons.schedule, Colors.orange)),
                            const SizedBox(width: 12),
                            Expanded(child: _miniCard('...', Icons.check_circle, Colors.green)),
                          ],
                        );
                      }
                      final docs = snapshot.data!.docs;
                      int pendientes = 0;
                      int completadas = 0;
                      for (var doc in docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (data['fecha'] == fechaHoy) {
                          if (data['reconciliada'] == true) {
                            completadas++;
                          } else {
                            pendientes++;
                          }
                        }
                      }
                      return Row(
                        children: [
                          Expanded(child: _miniCard('$pendientes Pendientes', Icons.schedule, Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _miniCard('$completadas Completadas', Icons.check_circle, Colors.green)),
                        ],
                      );
                    },
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
                final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['fecha'] == fechaHoy).toList();
                if (docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy, color: Colors.grey, size: 64),
                        SizedBox(height: 16),
                        Text('No hay transacciones para hoy', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Usa el botón + para agregar una', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                }

                double totalIngresos = 0;
                double totalGastos = 0;
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final monto = (data['monto'] ?? 0).toDouble();
                  if (data['tipo'] == 'Ingreso') {
                    totalIngresos += monto;
                  } else {
                    totalGastos += monto;
                  }
                }

                return Column(
                  children: [
                    // Tarjeta de Totales
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey)), Text('\$${totalIngresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]),
                          Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey)), Text('\$${totalGastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
                          Column(children: [const Text('Balance', style: TextStyle(color: Colors.grey)), Text('\$${(totalIngresos - totalGastos).toStringAsFixed(2)}', style: TextStyle(color: (totalIngresos - totalGastos) >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                    ),
                    // Lista de Transacciones
                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final esIngreso = data['tipo'] == 'Ingreso';
                      final reconciliada = data['reconciliada'] ?? false;
                      final tags = List<String>.from(data['tags'] ?? []);
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
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${data['categoria'] ?? 'General'} • ${data['negocio'] ?? 'Sin negocio'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  if (tags.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: tags.map((t) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                        child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)),
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${esIngreso ? "+" : "-"}\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                if (!reconciliada)
                                  TextButton(
                                    onPressed: () async {
                                      await _firestore.collection('transacciones').doc(doc.id).update({'reconciliada': true});
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Transacción aprobada'), backgroundColor: Colors.green),
                                        );
                                      }
                                    },
                                    child: const Text('Aprobar', style: TextStyle(color: Color(0xFF0066FF), fontSize: 11)),
                                  )
                                else
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(String titulo, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String nombre) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Colors.grey.shade700, size: 64),
          const SizedBox(height: 16),
          Text('$nombre - En desarrollo', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('La pestaña "Hoy" ya está 100% funcional', style: TextStyle(color: Colors.green, fontSize: 14)),
        ],
      ),
    );
  }

  void _mostrarFormularioTransaccion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario de transacción - Próximamente'), backgroundColor: Colors.orange),
    );
  }

  void _mostrarTransferencia() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transferencia entre cuentas - Próximamente'), backgroundColor: Colors.orange),
    );
  }

  Future<void> _generarDatosEjemplo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Generar Datos', style: TextStyle(color: Colors.white)),
        content: const Text('¿Crear transacciones de ejemplo para hoy?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
        ],
      ),
    );
    if (confirm != true) return;
    
    final hoy = DateTime.now();
    final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    
    final ejemplos = [
      {'concepto': 'Venta del día', 'monto': 5000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso', 'negocio': 'Minerales', 'cuenta': 'Banco', 'reconciliada': false, 'tags': ['#negocio']},
      {'concepto': 'Pago proveedor', 'monto': 1500.0, 'categoria': 'Deudas', 'tipo': 'Gasto', 'negocio': 'Combustible', 'cuenta': 'Efectivo', 'reconciliada': true, 'tags': ['#urgente']},
      {'concepto': 'Servicio consultoría', 'monto': 8000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso', 'negocio': 'Proyectos', 'cuenta': 'Banco', 'reconciliada': false, 'tags': ['#cliente']},
    ];
    
    for (var t in ejemplos) {
      await _firestore.collection('transacciones').add({
        ...t,
        'fecha': fechaHoy,
        'descripcion': 'Ejemplo del día',
        'subcuenta': t['negocio'],
        'metodo_pago': 'Efectivo',
        'referencia': '',
        'acreedor': '',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 3 transacciones de ejemplo creadas para hoy'), backgroundColor: Colors.green),
      );
    }
  }
}