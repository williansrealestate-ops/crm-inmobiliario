import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/comisiones_service.dart';
import '../../services/pipeline_service.dart';

class ComisionesScreen extends StatefulWidget {
  const ComisionesScreen({super.key});

  @override
  State<ComisionesScreen> createState() => _ComisionesScreenState();
}

class _ComisionesScreenState extends State<ComisionesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.white), SizedBox(width: 8), Text('Comisiones')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _mostrarConfiguracion, tooltip: 'Configuración'),
          IconButton(icon: const Icon(Icons.add), onPressed: _calcularNuevaComision, tooltip: 'Calcular comisión'),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Resumen'), Tab(text: 'Historial'), Tab(text: 'Por Asesor')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTabResumen(), _buildTabHistorial(), _buildTabAsesores()],
      ),
    );
  }

  Widget _buildTabResumen() {
    final stats = ComisionesService.getEstadisticas();
    final config = ComisionesService.getConfig();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Configuración actual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.settings, color: Colors.white, size: 20), SizedBox(width: 8), Text('Configuración Actual', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildConfigItem('Comisión Base', '${config['porcentajeBase']}%')),
                    Expanded(child: _buildConfigItem('Alto Valor (>${ComisionesService.formatearMoneda((config['umbralAltoValor'] as num).toDouble())})', '${config['porcentajeAltoValor']}%')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildConfigItem('Split Asesor', '${config['splitAsesor']}%')),
                    Expanded(child: _buildConfigItem('Split Agencia', '${config['splitAgencia']}%')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // KPIs
          Row(
            children: [
              Expanded(child: _buildKPICard('Total Comisiones', ComisionesService.formatearMoneda(stats['total']), Icons.account_balance_wallet, const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Este Mes', ComisionesService.formatearMoneda(stats['esteMes']), Icons.calendar_today, const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKPICard('Pagadas', ComisionesService.formatearMoneda(stats['pagadas']), Icons.check_circle, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Pendientes', ComisionesService.formatearMoneda(stats['pendientes']), Icons.pending_actions, const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 24),

          // Resumen visual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Distribución de Comisiones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                const SizedBox(height: 16),
                _buildBarraProgreso('Pagadas', stats['pagadas'], stats['total'], const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildBarraProgreso('Pendientes', stats['pendientes'], stats['total'], const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLeyenda('Pagadas', const Color(0xFF10B981)),
                    const SizedBox(width: 24),
                    _buildLeyenda('Pendientes', const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildKPICard(String label, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  Widget _buildBarraProgreso(String label, double valor, double total, Color color) {
    final porcentaje = total > 0 ? (valor / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
            Text('${(porcentaje * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: porcentaje,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLeyenda(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
      ],
    );
  }

  Widget _buildTabHistorial() {
    final comisiones = ComisionesService.getComisiones();

    if (comisiones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No hay comisiones registradas', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _calcularNuevaComision, icon: const Icon(Icons.add), label: const Text('Calcular primera comisión')),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comisiones.length,
      itemBuilder: (context, index) {
        final comision = comisiones[comisiones.length - 1 - index];
        final estado = comision['estado'] as String;
        final colorEstado = estado == 'pagada' ? const Color(0xFF10B981) : estado == 'pendiente' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
        final iconoEstado = estado == 'pagada' ? Icons.check_circle : estado == 'pendiente' ? Icons.pending : Icons.cancel;
        final fecha = DateTime.parse(comision['fecha']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorEstado.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(iconoEstado, color: colorEstado, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Comisión #${index + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                        Text('${fecha.day}/${fecha.month}/${fecha.year}', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(estado.toUpperCase(), style: TextStyle(fontSize: 10, color: colorEstado, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Operación', ComisionesService.formatearMoneda(comision['valorOperacion']))),
                  Expanded(child: _buildInfoItem('Comisión Total', ComisionesService.formatearMoneda(comision['comisionTotal']))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildInfoItem('Asesor', ComisionesService.formatearMoneda(comision['comisionAsesor']))),
                  Expanded(child: _buildInfoItem('Agencia', ComisionesService.formatearMoneda(comision['comisionAgencia']))),
                ],
              ),
              if ((comision['bono'] as num).toDouble() > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                      const SizedBox(width: 8),
                      Text('Bono: ${ComisionesService.formatearMoneda(comision['bono'])}', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _verDetalle(comision),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (estado == 'pendiente')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _marcarPagada(comision['id']),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Marcar Pagada', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)), onPressed: () => _confirmarEliminar(comision['id'])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context))),
        const SizedBox(height: 2),
        Text(valor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
      ],
    );
  }

  Widget _buildTabAsesores() {
    final comisiones = ComisionesService.getComisiones();
    final Map<String, double> porAsesor = {};

    for (var c in comisiones) {
      final asesor = c['asesor'] as String;
      final total = (c['totalPagar'] as num).toDouble();
      porAsesor[asesor] = (porAsesor[asesor] ?? 0) + total;
    }

    if (porAsesor.isEmpty) {
      return const Center(child: Text('No hay datos de asesores', style: TextStyle(color: Color(0xFF64748B))));
    }

    final sorted = porAsesor.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        final total = porAsesor.values.fold<double>(0, (sum, v) => sum + v);
        final porcentaje = total > 0 ? (entry.value / total) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                        Text('${ComisionesService.getComisionesPorAsesor(entry.key).length} operaciones', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(ComisionesService.formatearMoneda(entry.value), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                      Text('${(porcentaje * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  backgroundColor: AppTheme.getBorderColor(context),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calcularNuevaComision() {
    final operaciones = PipelineService.getOperaciones().where((o) => o['etapa'] == 'cerrado').toList();
    String? operacionSeleccionada;
    String asesor = 'Williams';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text('Calcular Nueva Comisión', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (operaciones.isEmpty)
                  const Text('No hay operaciones cerradas. Cierra una operación en el Pipeline primero.', style: TextStyle(color: Color(0xFF64748B)))
                else ...[
                  DropdownButtonFormField<String>(
                    value: operacionSeleccionada,
                    decoration: const InputDecoration(labelText: 'Operación cerrada', border: OutlineInputBorder()),
                    items: operaciones.map((o) => DropdownMenuItem<String>(value: o['id'], child: Text('${o['titulo']} - ${ComisionesService.formatearMoneda(o['valor'])}'))).toList(),
                    onChanged: (value) => setState(() => operacionSeleccionada = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Asesor', border: OutlineInputBorder()),
                    onChanged: (value) => asesor = value,
                    controller: TextEditingController(text: asesor),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: operacionSeleccionada == null
                  ? null
                  : () {
                      final op = operaciones.firstWhere((o) => o['id'] == operacionSeleccionada);
                      final comision = ComisionesService.calcularComision(
                        valorOperacion: (op['valor'] as num).toDouble(),
                        asesor: asesor,
                        tipoOperacion: op['tipo'] ?? 'Venta',
                      );
                      ComisionesService.guardarComision(comision);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Comisión calculada y guardada'), backgroundColor: Color(0xFF10B981)));
                      setState(() {});
                    },
              child: const Text('Calcular'),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalle(Map<String, dynamic> comision) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Detalle de Comisión', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem('Valor de operación', ComisionesService.formatearMoneda(comision['valorOperacion'])),
              _buildDetalleItem('Porcentaje aplicado', '${comision['porcentaje']}%'),
              _buildDetalleItem('Comisión total', ComisionesService.formatearMoneda(comision['comisionTotal'])),
              _buildDetalleItem('Parte del asesor', ComisionesService.formatearMoneda(comision['comisionAsesor'])),
              _buildDetalleItem('Parte de la agencia', ComisionesService.formatearMoneda(comision['comisionAgencia'])),
              _buildDetalleItem('Bono', ComisionesService.formatearMoneda(comision['bono'])),
              const Divider(),
              _buildDetalleItem('TOTAL A PAGAR', ComisionesService.formatearMoneda(comision['totalPagar']), esTotal: true),
              _buildDetalleItem('Asesor', comision['asesor']),
              _buildDetalleItem('Tipo', comision['tipoOperacion']),
              _buildDetalleItem('Estado', comision['estado']),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
      ),
    );
  }

  Widget _buildDetalleItem(String label, String valor, {bool esTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: esTotal ? 14 : 12, fontWeight: esTotal ? FontWeight.w800 : FontWeight.w600, color: AppTheme.getTextColor(context))),
          Text(valor, style: TextStyle(fontSize: esTotal ? 16 : 13, fontWeight: esTotal ? FontWeight.w800 : FontWeight.w700, color: esTotal ? const Color(0xFF10B981) : AppTheme.getTextColor(context))),
        ],
      ),
    );
  }

  void _marcarPagada(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Marcar como pagada?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción registrará la fecha de pago.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ComisionesService.actualizarEstado(id, 'pagada');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Comisión marcada como pagada'), backgroundColor: Color(0xFF10B981)));
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar comisión?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ComisionesService.eliminarComision(id);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarConfiguracion() {
    final config = ComisionesService.getConfig();
    final porcentajeBaseCtrl = TextEditingController(text: config['porcentajeBase'].toString());
    final porcentajeAltoCtrl = TextEditingController(text: config['porcentajeAltoValor'].toString());
    final umbralCtrl = TextEditingController(text: config['umbralAltoValor'].toString());
    final splitAsesorCtrl = TextEditingController(text: config['splitAsesor'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Configuración de Comisiones', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: porcentajeBaseCtrl, decoration: const InputDecoration(labelText: 'Comisión Base (%)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: porcentajeAltoCtrl, decoration: const InputDecoration(labelText: 'Comisión Alto Valor (%)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: umbralCtrl, decoration: const InputDecoration(labelText: 'Umbral Alto Valor (MXN)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: splitAsesorCtrl, decoration: const InputDecoration(labelText: 'Split Asesor (%)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nuevoConfig = {
                'porcentajeBase': double.tryParse(porcentajeBaseCtrl.text) ?? 3.0,
                'porcentajeAltoValor': double.tryParse(porcentajeAltoCtrl.text) ?? 4.0,
                'umbralAltoValor': double.tryParse(umbralCtrl.text) ?? 2000000,
                'splitAsesor': double.tryParse(splitAsesorCtrl.text) ?? 70,
                'splitAgencia': 100 - (double.tryParse(splitAsesorCtrl.text) ?? 70),
              };
              ComisionesService.guardarConfig(nuevoConfig);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Configuración actualizada'), backgroundColor: Color(0xFF10B981)));
              setState(() {});
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}