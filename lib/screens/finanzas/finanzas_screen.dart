import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'finanzas_hoy.dart';

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
          Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () {}),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: () {}, tooltip: 'Generar datos'),
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: () {}, tooltip: 'Transferir'),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {},
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'hoy', child: Text('Vista Hoy')),
              const PopupMenuItem(value: 'exportar', child: Text('Exportar CSV')),
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
            Tab(icon: Icon(Icons.money_off), text: 'Deudas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FinanzasHoyWidget(firestore: _firestore),
          _placeholder('Resumen'),
          _placeholder('Dashboard'),
          _placeholder('Ingresos'),
          _placeholder('Gastos'),
          _placeholder('Cuentas'),
          _placeholder('Calendario'),
          _placeholder('Reportes'),
          _placeholder('Presupuestos'),
          _placeholder('Metas'),
          _placeholder('Deudas'),
        ],
      ),
    );
  }

  Widget _placeholder(String nombre) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, color: Colors.grey.shade700, size: 64),
            const SizedBox(height: 16),
            Text('$nombre - En desarrollo', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}