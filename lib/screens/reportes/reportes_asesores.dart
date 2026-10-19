import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/reportes_service.dart';
import '../../services/asesores_service.dart';

class ReportesAsesores extends StatefulWidget {
  const ReportesAsesores({super.key});

  @override
  State<ReportesAsesores> createState() => _ReportesAsesoresState();
}

class _ReportesAsesoresState extends State<ReportesAsesores> {
  bool _cargando = true;
  List<Map<String, dynamic>> _reporte = [];
  Map<String, dynamic> _totales = {};
  String _filtroAsesor = 'Todos';
  List<Map<String, dynamic>> _asesores = [];
  String _ordenPor = 'comisionTotal'; // comisionTotal, montoTotal, totalVentas, nombre
  bool _ordenAscendente = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _reporte = await ReportesService.getReporteCompleto();
      _totales = await ReportesService.getTotalesGenerales();
      _asesores = await AsesoresService.getAsesores();
    } catch (e) {
      print('Error al cargar reportes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
    setState(() => _cargando = false);
  }

  List<Map<String, dynamic>> _getReporteFiltrado() {
    var reporte = _reporte;
    
    if (_filtroAsesor != 'Todos') {
      reporte = reporte.where((r) => r['nombre'] == _filtroAsesor).toList();
    }
    
    // Ordenar
    reporte.sort((a, b) {
      dynamic valA = a[_ordenPor];
      dynamic valB = b[_ordenPor];
      
      if (valA is String) valA = valA.toLowerCase();
      if (valB is String) valB = valB.toLowerCase();
      
      int comparacion;
      if (valA is Comparable) {
        comparacion = valA.compareTo(valB);
      } else {
        comparacion = valA.toString().compareTo(valB.toString());
      }
      
      return _ordenAscendente ? comparacion : -comparacion;
    });
    
    return reporte;
  }

  @override
  Widget build(BuildContext context) {
    final reporteFiltrado = _getReporteFiltrado();
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.analytics, color: Colors.white), SizedBox(width: 8), Text('Reportes Asesores')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _exportarCSV, tooltip: 'Exportar CSV'),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos, tooltip: 'Actualizar'),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ✅ Totales generales
                  _buildTotalesGenerales(),
                  const SizedBox(height: 16),
                  
                  // ✅ Filtros y ordenamiento
                  _buildFiltros(),
                  const SizedBox(height: 16),
                  
                  // ✅ Gráfico comparativo
                  _buildGraficoComparativo(reporteFiltrado),
                  const SizedBox(height: 16),
                  
                  // ✅ Tabla de reportes
                  _buildTablaReportes(reporteFiltrado),
                  const SizedBox(height: 16),
                  
                  // ✅ Detalle por asesor (expandible)
                  ...reporteFiltrado.map((item) => _buildDetalleAsesor(item)),
                ],
              ),
            ),
    );
  }

  // ✅ Totales generales
  Widget _buildTotalesGenerales() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('TOTALES GENERALES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTotalItem('Asesores', '${_totales['totalAsesores'] ?? 0}', Icons.people, Colors.white)),
              Expanded(child: _buildTotalItem('Ventas', '${_totales['totalVentas'] ?? 0}', Icons.shopping_cart, Colors.white)),
              Expanded(child: _buildTotalItem('Monto', '\$${_formatearMonto(_totales['montoTotal'] ?? 0)}', Icons.attach_money, Colors.white)),
              Expanded(child: _buildTotalItem('Comisiones', '\$${_formatearMonto(_totales['comisionTotal'] ?? 0)}', Icons.percent, Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 24),
        const SizedBox(height: 4),
        Text(valor, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
      ],
    );
  }

  // ✅ Filtros
  Widget _buildFiltros() {
    return Container(
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
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroAsesor,
                  decoration: const InputDecoration(labelText: 'Asesor', border: OutlineInputBorder()),
                  items: ['Todos', ..._asesores.map((a) => a['nombre'].toString())].map((a) => DropdownMenuItem<String>(value: a, child: Text(a))).toList(),
                  onChanged: (value) => setState(() => _filtroAsesor = value ?? 'Todos'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _ordenPor,
                  decoration: const InputDecoration(labelText: 'Ordenar por', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'comisionTotal', child: Text('Comisiones')),
                    DropdownMenuItem(value: 'montoTotal', child: Text('Monto')),
                    DropdownMenuItem(value: 'totalVentas', child: Text('Ventas')),
                    DropdownMenuItem(value: 'nombre', child: Text('Nombre')),
                  ],
                  onChanged: (value) => setState(() => _ordenPor = value ?? 'comisionTotal'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(_ordenAscendente ? Icons.arrow_upward : Icons.arrow_downward, color: AppTheme.primary),
                onPressed: () => setState(() => _ordenAscendente = !_ordenAscendente),
                tooltip: _ordenAscendente ? 'Ascendente' : 'Descendente',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Gráfico comparativo
  Widget _buildGraficoComparativo(List<Map<String, dynamic>> reporte) {
    if (reporte.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
        child: const Center(child: Text('Sin datos', style: TextStyle(color: Color(0xFF64748B)))),
      );
    }
    
    final maxComision = reporte.map((r) => r['comisionTotal'] as double).reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Comparativo de Comisiones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))),
            ],
          ),
          const SizedBox(height: 16),
          ...reporte.map((item) {
            final nombre = item['nombre'] ?? 'Sin nombre';
            final comision = item['comisionTotal'] as double;
            final porcentaje = maxComision > 0 ? (comision / maxComision) * 100 : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(nombre, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context)), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text('\$${_formatearMonto(comision)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: porcentaje / 100,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ✅ Tabla de reportes
  Widget _buildTablaReportes(List<Map<String, dynamic>> reporte) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Detalle por Asesor (${reporte.length})', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))),
            ],
          ),
          const SizedBox(height: 16),
          
          // Header de tabla
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Asesor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))),
                Expanded(child: Text('Ventas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)), textAlign: TextAlign.center)),
                Expanded(child: Text('Monto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)), textAlign: TextAlign.right)),
                Expanded(child: Text('Comisión', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)), textAlign: TextAlign.right)),
                Expanded(child: Text('%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Filas
          ...reporte.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final nombre = item['nombre'] ?? 'Sin nombre';
            final ventas = item['totalVentas'] as int;
            final monto = item['montoTotal'] as double;
            final comision = item['comisionTotal'] as double;
            final porcentaje = item['porcentajeComision'] as double;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? AppTheme.getBackgroundColor(context) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(nombre, style: TextStyle(fontSize: 11, color: AppTheme.getTextColor(context)), overflow: TextOverflow.ellipsis)),
                  Expanded(child: Text('$ventas', style: TextStyle(fontSize: 11, color: AppTheme.getTextColor(context)), textAlign: TextAlign.center)),
                  Expanded(child: Text('\$${_formatearMonto(monto)}', style: TextStyle(fontSize: 11, color: AppTheme.getTextColor(context)), textAlign: TextAlign.right)),
                  Expanded(child: Text('\$${_formatearMonto(comision)}', style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                  Expanded(child: Text('${porcentaje.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context)), textAlign: TextAlign.right)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ✅ Detalle expandible por asesor
  Widget _buildDetalleAsesor(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text((item['nombre'] ?? 'S').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
        title: Text(item['nombre'] ?? 'Sin nombre', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
        subtitle: Text('${item['totalVentas']} ventas · \$${_formatearMonto(item['comisionTotal'] as double)} comisión', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildMetrica('Ventas', '${item['totalVentas']}', Icons.shopping_cart, const Color(0xFFF59E0B))),
                    Expanded(child: _buildMetrica('Monto Total', '\$${_formatearMonto(item['montoTotal'] as double)}', Icons.attach_money, const Color(0xFF3B82F6))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetrica('Comisión Total', '\$${_formatearMonto(item['comisionTotal'] as double)}', Icons.percent, const Color(0xFF10B981))),
                    Expanded(child: _buildMetrica('Promedio Venta', '\$${_formatearMonto(item['promedioVenta'] as double)}', Icons.trending_up, const Color(0xFF8B5CF6))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetrica('% del Monto', '${(item['porcentajeMonto'] as double).toStringAsFixed(1)}%', Icons.pie_chart, const Color(0xFFEC4899))),
                    Expanded(child: _buildMetrica('% Comisión', '${(item['porcentajeComision'] as double).toStringAsFixed(1)}%', Icons.show_chart, const Color(0xFF06B6D4))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrica(String label, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(height: 4),
          Text(valor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: AppTheme.getTextSecondaryColor(context)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ✅ Exportar a CSV
  void _exportarCSV() async {
    final reporte = _getReporteFiltrado();
    final csv = ReportesService.exportarACSV(reporte);
    
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'reporte_asesores_${DateTime.now().millisecondsSinceEpoch}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ CSV exportado correctamente'), backgroundColor: Color(0xFF10B981)),
    );
  }

  String _formatearMonto(double monto) {
    if (monto >= 1000000) return '${(monto / 1000000).toStringAsFixed(2)}M';
    if (monto >= 1000) return '${(monto / 1000).toStringAsFixed(1)}K';
    return monto.toStringAsFixed(0);
  }
}