import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../services/reportes_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<Map<String, dynamic>> _ventasPorAsesor = [];
  Map<String, int> _embudo = {};
  Map<String, dynamic> _ingresos = {};
  List<Map<String, dynamic>> _topPropiedades = [];
  Map<String, dynamic> _stats = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _ventasPorAsesor = await ReportesService.getVentasPorAsesor();
      _embudo = await ReportesService.getEmbudoConversion();
      _ingresos = await ReportesService.getIngresosProyectadosVsReales();
      _topPropiedades = await ReportesService.getTopPropiedades();
      _stats = await ReportesService.getEstadisticasGenerales();
    } catch (e) {
      print('Error al cargar reportes: $e');
    }
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 8),
            Text('Reportes'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Ventas por Asesor'),
                  const SizedBox(height: 12),
                  _buildGraficoVentasAsesor(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Embudo de Conversión de Clientes'),
                  const SizedBox(height: 12),
                  _buildGraficoEmbudo(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Ingresos Proyectados vs Reales'),
                  const SizedBox(height: 12),
                  _buildGraficoIngresos(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Top 10 Propiedades Más Visitadas'),
                  const SizedBox(height: 12),
                  _buildListaTopPropiedades(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    final totalClientes = _stats['totalClientes'] ?? 0;
    final totalInmuebles = _stats['totalInmuebles'] ?? 0;
    final totalAsesores = _stats['totalAsesores'] ?? 0;

    return Row(
      children: [
        Expanded(child: _buildStatCard('Clientes', '$totalClientes', Icons.people, const Color(0xFF8B5CF6))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Inmuebles', '$totalInmuebles', Icons.home, const Color(0xFF06B6D4))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Asesores', '$totalAsesores', Icons.person, const Color(0xFFF59E0B))),
      ],
    );
  }

  Widget _buildStatCard(String label, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildGraficoVentasAsesor() {
    if (_ventasPorAsesor.isEmpty) {
      return _buildEmptyState('No hay datos de ventas');
    }

    final maxY = (_ventasPorAsesor.first['total'] as double) * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                // ✅ CORRECCIÓN: getTooltipColor en lugar de tooltipBgColor
                getTooltipColor: (group) => Colors.grey[800]!,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final asesor = _ventasPorAsesor[groupIndex]['asesor'];
                  final total = _ventasPorAsesor[groupIndex]['total'];
                  return BarTooltipItem(
                    '$asesor\n\$${_formatearMonto(total as double)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < _ventasPorAsesor.length) {
                      final asesor = _ventasPorAsesor[index]['asesor'].toString();
                      final nombreCorto = asesor.length > 10 
                          ? '${asesor.substring(0, 10)}...' 
                          : asesor;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          nombreCorto,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatearMonto(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _ventasPorAsesor.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value['total'] as double,
                    color: const Color(0xFF3B82F6),
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoEmbudo() {
    if (_embudo.isEmpty) {
      return _buildEmptyState('No hay datos de embudo');
    }

    final etapas = _embudo.keys.toList();
    final valores = _embudo.values.toList();
    final maxValor = valores.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: etapas.asMap().entries.map((entry) {
          final index = entry.key;
          final etapa = entry.value;
          final valor = valores[index];
          final porcentaje = maxValor > 0 ? (valor / maxValor * 100) : 0;
          final colores = [
            const Color(0xFF3B82F6),
            const Color(0xFF8B5CF6),
            const Color(0xFFF59E0B),
            const Color(0xFFEC4899),
            const Color(0xFF10B981),
          ];
          final color = colores[index % colores.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    etapa,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4 * (porcentaje / 100),
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text(
                    '$valor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraficoIngresos() {
    if (_ingresos.isEmpty) {
      return _buildEmptyState('No hay datos de ingresos');
    }

    final proyectados = _ingresos['proyectados'] as double? ?? 0;
    final reales = _ingresos['reales'] as double? ?? 0;
    final porcentaje = _ingresos['porcentajeCierre'] as double? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildIngresoCard(
                  'Proyectados',
                  proyectados,
                  const Color(0xFF3B82F6),
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIngresoCard(
                  'Reales',
                  reales,
                  const Color(0xFF10B981),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.percent, color: Color(0xFF8B5CF6), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tasa de Cierre',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${porcentaje.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: reales,
                    title: 'Reales',
                    color: const Color(0xFF10B981),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: proyectados - reales,
                    title: 'Pendiente',
                    color: const Color(0xFF3B82F6),
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngresoCard(String label, double valor, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_formatearMonto(valor)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaTopPropiedades() {
    if (_topPropiedades.isEmpty) {
      return _buildEmptyState('No hay datos de propiedades');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _topPropiedades.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final propiedad = entry.value;
          final nombre = propiedad['propiedad'].toString();
          final visitas = propiedad['visitas'] as int;
          final colores = [
            const Color(0xFFF59E0B),
            const Color(0xFF94A3B8),
            const Color(0xFFB45309),
          ];
          final color = index <= 3 ? colores[index - 1] : const Color(0xFF64748B);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.getDividerColor(context),
                  width: index < _topPropiedades.length ? 1 : 0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$visitas visitas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String mensaje) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: AppTheme.getTextSecondaryColor(context)),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearMonto(double monto) {
    if (monto >= 1000000) {
      return '${(monto / 1000000).toStringAsFixed(2)}M';
    } else if (monto >= 1000) {
      return '${(monto / 1000).toStringAsFixed(0)}K';
    }
    return monto.toStringAsFixed(0);
  }
}