import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../services/analisis_mercado_service.dart';
import '../../services/local_storage_service.dart';

class AnalisisMercadoScreen extends StatefulWidget {
  const AnalisisMercadoScreen({super.key});

  @override
  State<AnalisisMercadoScreen> createState() => _AnalisisMercadoScreenState();
}

class _AnalisisMercadoScreenState extends State<AnalisisMercadoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _zonaSeleccionada = '';
  String _tipoSeleccionado = 'Todos';
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final zonas = AnalisisMercadoService.getZonasDisponibles();
    if (zonas.isNotEmpty) _zonaSeleccionada = zonas.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _precioCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.trending_up, color: Colors.white), SizedBox(width: 8), Text('Análisis de Mercado')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'Por Zona'), Tab(text: 'Comparativa'), Tab(text: 'Top Zonas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTabZona(), _buildTabComparativa(), _buildTabTopZonas()],
      ),
    );
  }

  Widget _buildTabZona() {
    final zonas = AnalisisMercadoService.getZonasDisponibles();
    if (zonas.isEmpty) {
      return _emptyState('No hay zonas registradas', 'Agrega inmuebles con ubicación para ver el análisis');
    }

    final propiedades = AnalisisMercadoService.getPropiedadesPorZona(_zonaSeleccionada);
    final stats = AnalisisMercadoService.calcularEstadisticas(propiedades);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona una zona', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _zonaSeleccionada,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: AppTheme.getBackgroundColor(context),
                  ),
                  items: zonas.map((z) => DropdownMenuItem<String>(value: z, child: Text(z))).toList(),
                  onChanged: (value) => setState(() => _zonaSeleccionada = value ?? _zonaSeleccionada),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Análisis de Zona', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(_zonaSeleccionada, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Text('${stats['cantidad']} propiedades registradas', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildKPICard('Precio Promedio', AnalisisMercadoService.formatearMoneda(stats['precioPromedio']), const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Precio Mediana', AnalisisMercadoService.formatearMoneda(stats['precioMediana']), const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKPICard('Precio Mínimo', AnalisisMercadoService.formatearMoneda(stats['precioMin']), const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Precio Máximo', AnalisisMercadoService.formatearMoneda(stats['precioMax']), const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildKPICard('Precio/m²', AnalisisMercadoService.formatearMoneda(stats['precioPorM2']), const Color(0xFF8B5CF6))),
              const SizedBox(width: 12),
              Expanded(child: _buildKPICard('Área Promedio', '${stats['areaPromedio'].toStringAsFixed(0)} m²', const Color(0xFF06B6D4))),
            ],
          ),
          const SizedBox(height: 24),

          Text('Propiedades en esta zona', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
          const SizedBox(height: 12),
          if (propiedades.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('No hay propiedades en esta zona', style: TextStyle(color: Color(0xFF64748B)))),
            )
          else
            ...propiedades.map((p) => _buildPropiedadItem(p)),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String valor, Color color) {
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
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  Widget _buildPropiedadItem(Map<String, dynamic> p) {
    final tipo = (p['tipo'] ?? 'Casa').toString();
    final precio = _toDouble(p['precio']);
    final area = _toDouble(p['area']);
    final precioM2 = area > 0 ? precio / area : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.home, color: Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['titulo'] ?? 'Sin título', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
                Text('$tipo • ${area.toStringAsFixed(0)} m²', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AnalisisMercadoService.formatearMoneda(precio), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
              Text('${AnalisisMercadoService.formatearMoneda(precioM2.toDouble())}/m²', style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context))), // ✅ CORREGIDO
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabComparativa() {
    final zonas = AnalisisMercadoService.getZonasDisponibles();
    final tipos = ['Casa', 'Departamento', 'Terreno', 'Local', 'Oficina'];

    if (zonas.isEmpty) {
      return _emptyState('No hay datos', 'Agrega inmuebles para hacer comparativas');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comparativa de Precios', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Compara tu propiedad con el mercado', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _zonaSeleccionada,
                  decoration: const InputDecoration(labelText: 'Zona', border: OutlineInputBorder()),
                  items: zonas.map((z) => DropdownMenuItem<String>(value: z, child: Text(z))).toList(),
                  onChanged: (value) => setState(() => _zonaSeleccionada = value ?? _zonaSeleccionada),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Tipo de propiedad', border: OutlineInputBorder()),
                  items: tipos.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                  onChanged: (value) => setState(() => _tipoSeleccionado = value ?? 'Todos'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _areaCtrl,
                  decoration: const InputDecoration(labelText: 'Área (m²)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.square_foot)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _precioCtrl,
                  decoration: const InputDecoration(labelText: 'Precio propuesto (MXN)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _analizarPrecio,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analizar precio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _analizarPrecio() {
    final area = double.tryParse(_areaCtrl.text.replaceAll(',', '')) ?? 0;
    final precio = double.tryParse(_precioCtrl.text.replaceAll(',', '')) ?? 0;

    if (area <= 0 || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Ingresa área y precio válidos'), backgroundColor: Color(0xFFF59E0B)),
      );
      return;
    }

    final recomendacion = AnalisisMercadoService.recomendarPrecio(
      zona: _zonaSeleccionada,
      tipo: _tipoSeleccionado,
      area: area,
      precioPropuesto: precio,
    );

    _mostrarResultadoAnalisis(recomendacion, precio);
  }

  void _mostrarResultadoAnalisis(Map<String, dynamic> rec, double precioPropuesto) {
    final colorEval = rec['color'] == 'verde' ? const Color(0xFF10B981) : rec['color'] == 'rojo' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    final iconoEval = rec['color'] == 'verde' ? Icons.check_circle : rec['color'] == 'rojo' ? Icons.warning : Icons.info;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Row(
          children: [
            Icon(iconoEval, color: colorEval, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text('Resultado del Análisis', style: TextStyle(color: AppTheme.getTextColor(context)))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colorEval.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(iconoEval, color: colorEval),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec['evaluacion'], style: TextStyle(color: colorEval, fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildResultadoItem('Tu precio propuesto', AnalisisMercadoService.formatearMoneda(precioPropuesto)),
              _buildResultadoItem('Precio recomendado', AnalisisMercadoService.formatearMoneda(rec['precioRecomendado']), esDestacado: true),
              _buildResultadoItem('Rango sugerido', '${AnalisisMercadoService.formatearMoneda(rec['rangoMin'])} - ${AnalisisMercadoService.formatearMoneda(rec['rangoMax'])}'),
              _buildResultadoItem('Diferencia', '${rec['porcentajeDiferencia'] > 0 ? '+' : ''}${rec['porcentajeDiferencia'].toStringAsFixed(1)}%'),
              _buildResultadoItem('Propiedades comparables', '${rec['cantidadComparables']}'),
              _buildResultadoItem('Nivel de confianza', rec['confianza'] == 'alta' ? 'Alta ✓' : 'Media'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _buildResultadoItem(String label, String valor, {bool esDestacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
          Text(valor, style: TextStyle(fontSize: esDestacado ? 15 : 13, fontWeight: esDestacado ? FontWeight.w800 : FontWeight.w700, color: esDestacado ? const Color(0xFF10B981) : AppTheme.getTextColor(context))),
        ],
      ),
    );
  }

  Widget _buildTabTopZonas() {
    final topZonas = AnalisisMercadoService.getTopZonas();
    final distribucion = AnalisisMercadoService.getDistribucionPreciosPorZona();

    if (distribucion.isEmpty) {
      return _emptyState('Sin datos', 'Agrega inmuebles con ubicación');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ranking de Zonas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Zonas con mayor valor promedio', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Precio promedio por zona', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: distribucion.isEmpty ? 100 : distribucion.map((d) => d['promedio'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: distribucion.isEmpty ? 50 : distribucion.map((d) => d['promedio'] as double).reduce((a, b) => a > b ? a : b) / 4, getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.getDividerColor(context), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < distribucion.length) {
                                final zona = distribucion[index]['zona'] as String;
                                final nombreCorto = zona.length > 8 ? '${zona.substring(0, 8)}...' : zona;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(nombreCorto, style: TextStyle(fontSize: 9, color: AppTheme.getTextSecondaryColor(context))),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: distribucion.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value as Map<String, dynamic>;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['promedio'] as double,
                              color: Color(int.parse(data['color'] as String)),
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Top 5 Zonas más caras', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
          const SizedBox(height: 12),
          ...topZonas.asMap().entries.map((entry) {
            final index = entry.key;
            final zona = entry.value as Map<String, dynamic>;
            final maxPrecio = topZonas.isEmpty ? 1.0 : (topZonas.first['promedio'] as double);
            final porcentaje = maxPrecio > 0 ? ((zona['promedio'] as double) / maxPrecio) : 0.0;

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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(int.parse(zona['color'] as String)), Color(int.parse(zona['color'] as String)).withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('#${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(zona['zona'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                            Text('${zona['cantidad']} propiedades', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                          ],
                        ),
                      ),
                      Text(AnalisisMercadoService.formatearMoneda(zona['promedio']), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(int.parse(zona['color'] as String)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: porcentaje.toDouble(), // ✅ CORREGIDO
                      backgroundColor: Color(int.parse(zona['color'] as String)).withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(zona['color'] as String))),
                      minHeight: 8,
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

  Widget _emptyState(String titulo, String subtitulo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(titulo, style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitulo, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }
}