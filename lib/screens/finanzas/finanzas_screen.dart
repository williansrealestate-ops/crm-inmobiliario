import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/indexed_db_service.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  int _tabActual = 0;
  String _filtroNegocio = 'Todos';
  List<Map<String, dynamic>> _transacciones = [];
  List<Map<String, dynamic>> _negocios = [];
  Map<String, dynamic> _presupuestos = {};
  bool _cargando = true;

  final List<Map<String, dynamic>> _negociosPredefinidos = [
    {'id': 'inmobiliario', 'nombre': 'Inmobiliario', 'icono': Icons.home.codePoint, 'color': 0xFF3B82F6},
    {'id': 'minerales', 'nombre': 'Minerales', 'icono': Icons.diamond.codePoint, 'color': 0xFFF59E0B},
    {'id': 'combustible', 'nombre': 'Combustible', 'icono': Icons.local_gas_station.codePoint, 'color': 0xFF10B981},
    {'id': 'agropecuario', 'nombre': 'Agropecuario', 'icono': Icons.agriculture.codePoint, 'color': 0xFF8B5CF6},
    {'id': 'proyectos', 'nombre': 'Proyectos', 'icono': Icons.business_center.codePoint, 'color': 0xFFEC4899},
    {'id': 'otros', 'nombre': 'Otros', 'icono': Icons.more_horiz.codePoint, 'color': 0xFF6B7280},
  ];

  // ✅ FUNCIÓN CLAVE: Retorna IconData estáticos para evitar problemas de tree-shaking
  IconData _getIconoPorNegocio(String negocioId) {
    switch (negocioId) {
      case 'inmobiliario': return Icons.home;
      case 'minerales': return Icons.diamond;
      case 'combustible': return Icons.local_gas_station;
      case 'agropecuario': return Icons.agriculture;
      case 'proyectos': return Icons.business_center;
      case 'otros': return Icons.more_horiz;
      default: return Icons.business;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final transJson = await IndexedDBService.get('transacciones_financieras');
      if (transJson != null) {
        _transacciones = List<Map<String, dynamic>>.from(jsonDecode(transJson) as List);
      }
      
      final negJson = await IndexedDBService.get('negocios_finanzas');
      if (negJson != null) {
        _negocios = List<Map<String, dynamic>>.from(jsonDecode(negJson) as List);
      } else {
        _negocios = _negociosPredefinidos;
        await IndexedDBService.put('negocios_finanzas', jsonEncode(_negocios));
      }
      
      final presJson = await IndexedDBService.get('presupuestos_finanzas');
      if (presJson != null) {
        _presupuestos = Map<String, dynamic>.from(jsonDecode(presJson) as Map);
      }
    } catch (e) {
      print('Error al cargar finanzas: $e');
    }
    setState(() => _cargando = false);
  }

  double _getTotalIngresos({String? negocio}) {
    return _transacciones
        .where((t) => t['tipo'] == 'ingreso' && (negocio == null || t['negocio'] == negocio))
        .fold(0.0, (sum, t) => sum + (t['monto'] is num ? (t['monto'] as num).toDouble() : double.tryParse(t['monto'].toString()) ?? 0));
  }

  double _getTotalGastos({String? negocio}) {
    return _transacciones
        .where((t) => t['tipo'] == 'gasto' && (negocio == null || t['negocio'] == negocio))
        .fold(0.0, (sum, t) => sum + (t['monto'] is num ? (t['monto'] as num).toDouble() : double.tryParse(t['monto'].toString()) ?? 0));
  }

  double _getBalance({String? negocio}) {
    return _getTotalIngresos(negocio: negocio) - _getTotalGastos(negocio: negocio);
  }

  String _formatearMoneda(double monto) {
    if (monto >= 1000000) return '\$${(monto / 1000000).toStringAsFixed(2)}M';
    if (monto >= 1000) return '\$${(monto / 1000).toStringAsFixed(1)}K';
    return '\$${monto.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final balanceGlobal = _getBalance();
    final ingresosGlobal = _getTotalIngresos();
    final gastosGlobal = _getTotalGastos();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.account_balance, color: Colors.white), SizedBox(width: 8), Text('Finanzas')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
          IconButton(icon: const Icon(Icons.add), onPressed: () => _abrirFormularioTransaccion(), tooltip: 'Nueva transacción'),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: AppTheme.getSurfaceColor(context),
                  child: Row(
                    children: [
                      _buildTab('Dashboard', 0),
                      _buildTab('Negocios', 1),
                      _buildTab('Transacciones', 2),
                      _buildTab('Presupuestos', 3),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabActual,
                    children: [
                      _buildDashboard(balanceGlobal, ingresosGlobal, gastosGlobal),
                      _buildNegocios(),
                      _buildTransacciones(),
                      _buildPresupuestos(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioTransaccion(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabActual == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabActual = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            border: Border(bottom: BorderSide(color: isSelected ? AppTheme.primary : Colors.transparent, width: 3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.getTextColor(context),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(double balance, double ingresos, double gastos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Balance Global', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _formatearMoneda(balance),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [Icon(Icons.trending_up, color: Colors.white, size: 16), SizedBox(width: 4), Text('Ingresos', style: TextStyle(color: Colors.white70, fontSize: 11))]),
                            const SizedBox(height: 4),
                            Text(_formatearMoneda(ingresos), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [Icon(Icons.trending_down, color: Colors.white, size: 16), SizedBox(width: 4), Text('Gastos', style: TextStyle(color: Colors.white70, fontSize: 11))]),
                            const SizedBox(height: 4),
                            Text(_formatearMoneda(gastos), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Resumen por Negocio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._negocios.map((negocio) => _buildResumenNegocio(negocio)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transacciones Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () => setState(() => _tabActual = 2),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._transacciones.take(5).map((t) => _buildTransaccionCard(t)),
        ],
      ),
    );
  }

  Widget _buildResumenNegocio(Map<String, dynamic> negocio) {
    final ingresos = _getTotalIngresos(negocio: negocio['id']);
    final gastos = _getTotalGastos(negocio: negocio['id']);
    final balance = ingresos - gastos;
    final color = Color(negocio['color'] ?? 0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            // ✅ USANDO FUNCIÓN DE ÍCONO ESTÁTICO
            child: Icon(_getIconoPorNegocio(negocio['id'].toString()), color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(negocio['nombre'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Ingresos: ${_formatearMoneda(ingresos)}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                    const SizedBox(width: 12),
                    Text('Gastos: ${_formatearMoneda(gastos)}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatearMoneda(balance),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
              ),
              Text(balance >= 0 ? '↑ Positivo' : '↓ Negativo', style: TextStyle(fontSize: 11, color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNegocios() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mis Negocios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ..._negocios.map((negocio) => _buildNegocioCard(negocio)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _abrirFormularioNegocio(),
              icon: const Icon(Icons.add_business),
              label: const Text('Agregar Nuevo Negocio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNegocioCard(Map<String, dynamic> negocio) {
    final color = Color(negocio['color'] ?? 0xFF6B7280);
    final ingresos = _getTotalIngresos(negocio: negocio['id']);
    final gastos = _getTotalGastos(negocio: negocio['id']);
    final balance = ingresos - gastos;
    final transaccionesCount = _transacciones.where((t) => t['negocio'] == negocio['id']).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                // ✅ USANDO FUNCIÓN DE ÍCONO ESTÁTICO
                child: Icon(_getIconoPorNegocio(negocio['id'].toString()), color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(negocio['nombre'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('$transaccionesCount transacciones', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                ],
                onSelected: (val) {
                  if (val == 'editar') _abrirFormularioNegocio(negocio: negocio);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 20),
                      const SizedBox(height: 4),
                      Text(_formatearMoneda(ingresos), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                      const Text('Ingresos', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      const Icon(Icons.trending_down, color: Color(0xFFEF4444), size: 20),
                      const SizedBox(height: 4),
                      Text(_formatearMoneda(gastos), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                      const Text('Gastos', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance_wallet, color: balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444), size: 20),
                      const SizedBox(height: 4),
                      Text(_formatearMoneda(balance), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444))),
                      Text('Balance', style: TextStyle(fontSize: 11, color: balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransacciones() {
    final transFiltradas = _transacciones.where((t) {
      if (_filtroNegocio != 'Todos' && t['negocio'] != _filtroNegocio) return false;
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context)))),
          child: DropdownButtonFormField<String>(
            value: _filtroNegocio,
            decoration: InputDecoration(
              labelText: 'Filtrar por negocio',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: AppTheme.getBackgroundColor(context),
            ),
            items: ['Todos', ..._negocios.map((n) => n['nombre'].toString())].map((n) => DropdownMenuItem<String>(value: n, child: Text(n))).toList(),
            onChanged: (v) => setState(() => _filtroNegocio = v ?? 'Todos'),
          ),
        ),
        Expanded(
          child: transFiltradas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No hay transacciones', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(onPressed: () => _abrirFormularioTransaccion(), icon: const Icon(Icons.add), label: const Text('Agregar transacción')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transFiltradas.length,
                  itemBuilder: (context, index) => _buildTransaccionCard(transFiltradas[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildTransaccionCard(Map<String, dynamic> trans) {
    final esIngreso = trans['tipo'] == 'ingreso';
    final negocioId = trans['negocio']?.toString() ?? 'otros';
    final negocio = _negocios.firstWhere((n) => n['id'] == trans['negocio'], orElse: () => {'nombre': 'Otros', 'color': 0xFF6B7280, 'icono': Icons.business.codePoint});
    final color = Color(negocio['color'] ?? 0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            // ✅ USANDO FUNCIÓN DE ÍCONO ESTÁTICO
            child: Icon(_getIconoPorNegocio(negocioId), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trans['descripcion'] ?? 'Sin descripción', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${negocio['nombre']} • ${trans['fecha'] ?? ''}', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${esIngreso ? '+' : '-'}${_formatearMoneda(trans['monto'] is num ? (trans['monto'] as num).toDouble() : double.tryParse(trans['monto'].toString()) ?? 0)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: esIngreso ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
              ),
              TextButton(
                onPressed: () => _eliminarTransaccion(trans['id'].toString()),
                child: const Text('Eliminar', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Presupuestos por Negocio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)), onPressed: () => _abrirFormularioPresupuesto()),
            ],
          ),
          const SizedBox(height: 16),
          ..._negocios.map((negocio) => _buildPresupuestoCard(negocio)),
        ],
      ),
    );
  }

  Widget _buildPresupuestoCard(Map<String, dynamic> negocio) {
    final presupuesto = (_presupuestos[negocio['id']] ?? 0).toDouble();
    final gastos = _getTotalGastos(negocio: negocio['id']);
    final porcentaje = presupuesto > 0 ? (gastos / presupuesto * 100).clamp(0, 100) : 0;
    final color = Color(negocio['color'] ?? 0xFF6B7280);
    final excedido = gastos > presupuesto && presupuesto > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: excedido ? const Color(0xFFEF4444) : color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                // ✅ USANDO FUNCIÓN DE ÍCONO ESTÁTICO
                child: Icon(_getIconoPorNegocio(negocio['id'].toString()), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(negocio['nombre'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              if (excedido) const Text('⚠️ Excedido', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gastado: ${_formatearMoneda(gastos)}', style: const TextStyle(fontSize: 13)),
              Text('Presupuesto: ${_formatearMoneda(presupuesto)}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: porcentaje / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(excedido ? const Color(0xFFEF4444) : color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text('${porcentaje.toStringAsFixed(1)}% utilizado', style: TextStyle(fontSize: 11, color: excedido ? const Color(0xFFEF4444) : AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  void _abrirFormularioTransaccion({Map<String, dynamic>? transaccion}) {
    final esEdicion = transaccion != null;
    final descripcionCtrl = TextEditingController(text: transaccion?['descripcion'] ?? '');
    final montoCtrl = TextEditingController(text: transaccion?['monto']?.toString() ?? '');
    final fechaCtrl = TextEditingController(text: transaccion?['fecha'] ?? DateTime.now().toIso8601String().split('T')[0]);
    String tipo = transaccion?['tipo'] ?? 'gasto';
    String negocioId = transaccion?['negocio'] ?? 'inmobiliario';
    String categoria = transaccion?['categoria'] ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(esEdicion ? 'Editar Transacción' : 'Nueva Transacción', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(dialogContext)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => tipo = 'ingreso'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: tipo == 'ingreso' ? const Color(0xFF10B981) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Ingreso', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => tipo = 'gasto'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: tipo == 'gasto' ? const Color(0xFFEF4444) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Gasto', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonFormField<String>(
                      value: negocioId,
                      dropdownColor: const Color(0xFF2C2C2E),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Negocio', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.business, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                      items: _negocios.map((n) => DropdownMenuItem<String>(value: n['id'].toString(), child: Text(n['nombre'].toString(), style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (v) => setDialogState(() => negocioId = v ?? 'inmobiliario'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: montoCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Monto *', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.attach_money, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: descripcionCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Descripción *', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.description, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      onChanged: (v) => categoria = v,
                      controller: TextEditingController(text: categoria),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Categoría', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.category, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: fechaCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Fecha', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.calendar_today, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.blue))),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final monto = double.tryParse(montoCtrl.text.replaceAll(',', ''));
                          if (descripcionCtrl.text.isEmpty || monto == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Descripción y monto son obligatorios'), backgroundColor: Color(0xFFF59E0B)));
                            return;
                          }
                          final datos = {
                            'id': transaccion?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            'tipo': tipo,
                            'negocio': negocioId,
                            'monto': monto,
                            'descripcion': descripcionCtrl.text,
                            'categoria': categoria,
                            'fecha': fechaCtrl.text,
                          };
                          try {
                            if (esEdicion) {
                              _transacciones = _transacciones.map((t) => t['id'].toString() == transaccion!['id'].toString() ? datos : t).toList();
                            } else {
                              _transacciones.add(datos);
                            }
                            await IndexedDBService.put('transacciones_financieras', jsonEncode(_transacciones));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(esEdicion ? '✅ Transacción actualizada' : '✅ Transacción creada'), backgroundColor: const Color(0xFF10B981)));
                            Navigator.pop(dialogContext);
                            await _cargarDatos();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _abrirFormularioNegocio({Map<String, dynamic>? negocio}) {
    final esEdicion = negocio != null;
    final nombreCtrl = TextEditingController(text: negocio?['nombre'] ?? '');
    int colorValue = negocio?['color'] ?? 0xFF3B82F6;
    int iconoValue = negocio?['icono'] ?? Icons.business.codePoint;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_business, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(esEdicion ? 'Editar Negocio' : 'Nuevo Negocio', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(dialogContext)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Nombre del negocio *', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.business, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.blue))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (nombreCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El nombre es obligatorio'), backgroundColor: Color(0xFFF59E0B)));
                          return;
                        }
                        final datos = {
                          'id': negocio?['id'] ?? nombreCtrl.text.toLowerCase().replaceAll(' ', '_'),
                          'nombre': nombreCtrl.text,
                          'color': colorValue,
                          'icono': iconoValue,
                        };
                        try {
                          if (esEdicion) {
                            _negocios = _negocios.map((n) => n['id'].toString() == negocio!['id'].toString() ? datos : n).toList();
                          } else {
                            _negocios.add(datos);
                          }
                          await IndexedDBService.put('negocios_finanzas', jsonEncode(_negocios));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(esEdicion ? '✅ Negocio actualizado' : '✅ Negocio creado'), backgroundColor: const Color(0xFF10B981)));
                          Navigator.pop(dialogContext);
                          await _cargarDatos();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _abrirFormularioPresupuesto() {
    final ctrlMonto = TextEditingController();
    String negocioId = 'inmobiliario';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text('Establecer Presupuesto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(dialogContext)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonFormField<String>(
                    value: negocioId,
                    dropdownColor: const Color(0xFF2C2C2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Negocio', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.business, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    items: _negocios.map((n) => DropdownMenuItem<String>(value: n['id'].toString(), child: Text(n['nombre'].toString(), style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) => setDialogState(() => negocioId = v ?? 'inmobiliario'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: ctrlMonto,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Monto del presupuesto *', labelStyle: TextStyle(color: Colors.white54, fontSize: 12), prefixIcon: Icon(Icons.attach_money, color: Colors.white54, size: 20), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.blue))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final monto = double.tryParse(ctrlMonto.text.replaceAll(',', ''));
                        if (monto == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Ingresa un monto válido'), backgroundColor: Color(0xFFF59E0B)));
                          return;
                        }
                        _presupuestos[negocioId] = monto;
                        await IndexedDBService.put('presupuestos_finanzas', jsonEncode(_presupuestos));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Presupuesto establecido'), backgroundColor: Color(0xFF10B981)));
                        Navigator.pop(dialogContext);
                        await _cargarDatos();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _eliminarTransaccion(String id) async {
    _transacciones.removeWhere((t) => t['id'].toString() == id.toString());
    await IndexedDBService.put('transacciones_financieras', jsonEncode(_transacciones));
    await _cargarDatos();
  }
}