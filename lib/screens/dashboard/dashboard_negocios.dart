import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardNegociosScreen extends StatefulWidget {
  const DashboardNegociosScreen({super.key});

  @override
  State<DashboardNegociosScreen> createState() => _DashboardNegociosScreenState();
}

class _DashboardNegociosScreenState extends State<DashboardNegociosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _negocioSeleccionado = 'Minerales';

  final List<Map<String, dynamic>> _negocios = [
    {'nombre': 'Minerales', 'icon': Icons.diamond, 'color': Colors.orange},
    {'nombre': 'Combustible', 'icon': Icons.local_gas_station, 'color': Colors.green},
    {'nombre': 'Agropecuario', 'icon': Icons.agriculture, 'color': Colors.purple},
    {'nombre': 'Proyectos', 'icon': Icons.business_center, 'color': Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.dashboard, color: Colors.white),
          SizedBox(width: 8),
          Text('Dashboard de Negocios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            // Selector de negocio
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF111111),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _negocios.map((negocio) {
                  final isSelected = _negocioSeleccionado == negocio['nombre'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _negocioSeleccionado = negocio['nombre'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? negocio['color'] as Color : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? negocio['color'] as Color : const Color(0xFF333333)),
                        ),
                        child: Row(
                          children: [
                            Icon(negocio['icon'] as IconData, color: isSelected ? Colors.white : Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Text(negocio['nombre'] as String, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header del negocio
                    _buildHeaderNegocio(),
                    const SizedBox(height: 24),
                    
                    // KPIs desde Finanzas
                    const Text('KPIs Financieros', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildKPIsFinancieros(),
                    const SizedBox(height: 24),
                    
                    // Balance del Mes
                    const Text('Balance del Mes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildBalanceDelMes(),
                    const SizedBox(height: 24),
                    
                    // Últimas transacciones
                    const Text('Últimas Transacciones', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildUltimasTransacciones(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderNegocio() {
    final negocio = _negocios.firstWhere((n) => n['nombre'] == _negocioSeleccionado);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [negocio['color'] as Color, (negocio['color'] as Color).withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(negocio['icon'] as IconData, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_negocioSeleccionado, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Dashboard en tiempo real', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIsFinancieros() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').where('negocio', isEqualTo: _negocioSeleccionado).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        final ingresos = docs.where((d) => (d.data() as Map)['tipo'] == 'Ingreso').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
        final gastos = docs.where((d) => (d.data() as Map)['tipo'] == 'Gasto').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
        final balance = ingresos - gastos;
        final numTransacciones = docs.length;

        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildKPI('Ingresos', '\$${ingresos.toStringAsFixed(0)}', Icons.arrow_upward, Colors.green),
            _buildKPI('Gastos', '\$${gastos.toStringAsFixed(0)}', Icons.arrow_downward, Colors.red),
            _buildKPI('Balance', '\$${balance.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.blue),
            _buildKPI('Transacciones', '$numTransacciones', Icons.receipt_long, Colors.purple),
            _buildKPI('Promedio', numTransacciones > 0 ? '\$${(ingresos / numTransacciones).toStringAsFixed(0)}' : '\$0', Icons.calculate, Colors.orange),
            _buildKPI('Margen', ingresos > 0 ? '${((balance / ingresos) * 100).toStringAsFixed(1)}%' : '0%', Icons.percent, Colors.teal),
          ],
        );
      },
    );
  }

  Widget _buildKPI(String titulo, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(valor, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBalanceDelMes() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').where('negocio', isEqualTo: _negocioSeleccionado).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        final ingresos = docs.where((d) => (d.data() as Map)['tipo'] == 'Ingreso').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
        final gastos = docs.where((d) => (d.data() as Map)['tipo'] == 'Gasto').fold<double>(0, (sum, doc) => sum + ((doc.data() as Map)['monto'] ?? 0).toDouble());
        final balance = ingresos - gastos;
        final margen = ingresos > 0 ? (balance / ingresos) * 100 : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Ingresos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('\$${ingresos.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    const Text('Gastos', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('\$${gastos.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Balance', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('\$${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: margen / 100,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(margen >= 0 ? Colors.green : Colors.red),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text('Margen: ${margen.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUltimasTransacciones() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transacciones').where('negocio', isEqualTo: _negocioSeleccionado).orderBy('created_at', descending: true).limit(5).snapshots(),
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
}