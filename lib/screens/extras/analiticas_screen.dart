import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../services/analiticas_service.dart';
import '../../services/pipeline_service.dart';

class AnaliticasScreen extends StatefulWidget {
  const AnaliticasScreen({super.key});

  @override
  State<AnaliticasScreen> createState() => _AnaliticasScreenState();
}

class _AnaliticasScreenState extends State<AnaliticasScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final kpis = AnaliticasService.getKPIs();
    final fuentes = AnaliticasService.getFuentesLeads();
    final proyeccion = AnaliticasService.getProyeccionIngresos();
    final conversionEtapa = AnaliticasService.getConversionPorEtapa();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.analytics, color: Colors.white), SizedBox(width: 8), Text('Analytics Avanzado')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPIs Principales
            Row(
              children: [
                Expanded(child: _buildKPICard('Tasa de Conversión', '${kpis['tasaConversion'].toStringAsFixed(1)}%', Icons.trending_up, const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _buildKPICard('Cumplimiento Meta', '${kpis['cumplimientoMeta'].toStringAsFixed(0)}%', Icons.flag, const Color(0xFF3B82F6))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKPICard('Ticket Promedio', PipelineService.formatearMoneda(kpis['ticketPromedio']), Icons.attach_money, const Color(0xFFF59E0B))),
                const SizedBox(width: 12),
                Expanded(child: _buildKPICard('Días p/ Cierre', '${kpis['tiempoPromedioCierre']} días', Icons.access_time, const Color(0xFF8B5CF6))),
              ],
            ),
            const SizedBox(height: 24),

            // Gráfica 1: Proyección de Ingresos
            _buildSectionTitle('Proyección de Ingresos (en miles)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.getDividerColor(context), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < proyeccion.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(proyeccion[index]['mes'], style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Ingresos reales
                      LineChartBarData(
                        spots: proyeccion.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['ingresos'])).toList(),
                        isCurved: true,
                        color: const Color(0xFF10B981),
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: const Color(0xFF10B981).withOpacity(0.1)),
                      ),
                      // Proyección
                      LineChartBarData(
                        spots: proyeccion.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['proyeccion'])).toList(),
                        isCurved: true,
                        color: const Color(0xFF3B82F6),
                        barWidth: 3,
                        dashArray: [5, 5],
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Ingresos Reales', const Color(0xFF10B981)),
                const SizedBox(width: 24),
                _buildLegend('Proyección (+10%)', const Color(0xFF3B82F6)),
              ],
            ),
            const SizedBox(height: 24),

            // Gráfica 2 y 3 en Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Fuentes de Leads'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(context),
                        child: SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: fuentes.map((f) {
                                final color = Color(int.parse(f['color']));
                                final isTouched = _touchedIndex == fuentes.indexOf(f);
                                return PieChartSectionData(
                                  color: color,
                                  value: f['valor'].toDouble(),
                                  title: isTouched ? '${f['valor']}%' : '',
                                  radius: isTouched ? 60 : 50,
                                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                                );
                              }).toList(),
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: fuentes.map((f) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(int.parse(f['color'])), borderRadius: BorderRadius.circular(3))),
                              const SizedBox(width: 4),
                              Text(f['nombre'], style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context))),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Conversión por Etapa'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(context),
                        child: Column(
                          children: conversionEtapa.map((etapa) {
                            final color = Color(int.parse(etapa['color']));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(etapa['icono'], style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(etapa['nombre'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
                                      const Spacer(),
                                      Text('${etapa['tasa']}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: etapa['tasa'] / 100,
                                      backgroundColor: color.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextColor(context))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)));
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: AppTheme.getSurfaceColor(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.getBorderColor(context)),
      boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 12, offset: const Offset(0, 4))],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
      ],
    );
  }
}