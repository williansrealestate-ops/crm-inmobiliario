import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/asesores_service.dart';

class DashboardAsesores extends StatefulWidget {
  const DashboardAsesores({super.key});

  @override
  State<DashboardAsesores> createState() => _DashboardAsesoresState();
}

class _DashboardAsesoresState extends State<DashboardAsesores> {
  bool _cargando = true;
  
  // ✅ Datos del dashboard
  int _totalAsesores = 0;
  int _activos = 0;
  int _inactivos = 0;
  int _totalVentas = 0;
  double _totalComisiones = 0;
  double _promedioComision = 0;
  double _tasaActividad = 0;
  
  Map<String, int> _porGrupo = {};
  Map<String, int> _porEspecialidad = {};
  Map<String, int> _porInmobiliaria = {};
  Map<String, int> _porPais = {};
  
  List<Map<String, dynamic>> _topAsesores = [];
  List<Map<String, dynamic>> _asesoresRecientes = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final asesores = await AsesoresService.getAsesores();
      
      // ✅ Calcular estadísticas
      _totalAsesores = asesores.length;
      _activos = asesores.where((a) => a['activo'] == true).length;
      _inactivos = _totalAsesores - _activos;
      _totalVentas = asesores.fold<int>(0, (sum, a) => sum + ((a['ventas'] ?? 0) as int));
      _totalComisiones = asesores.fold<double>(0, (sum, a) => sum + ((a['comisiones'] ?? 0) as num).toDouble());
      
      // ✅ Promedio de comisión
      if (_totalAsesores > 0) {
        final totalComision = asesores.fold<double>(0, (sum, a) => sum + ((a['comisionPorcentaje'] ?? 0) as num).toDouble());
        _promedioComision = totalComision / _totalAsesores;
        _tasaActividad = (_activos / _totalAsesores) * 100;
      }
      
      // ✅ Distribución por grupo
      _porGrupo = _agruparPor(asesores, 'grupo', 'Sin grupo');
      
      // ✅ Distribución por especialidad
      _porEspecialidad = _agruparPor(asesores, 'especialidad', 'General');
      
      // ✅ Distribución por inmobiliaria
      _porInmobiliaria = _agruparPor(asesores, 'inmobiliaria', 'Independiente');
      
      // ✅ Distribución por país
      _porPais = _agruparPor(asesores, 'pais', 'Sin país');
      
      // ✅ Top 5 asesores por comisiones
      final asesoresOrdenados = List<Map<String, dynamic>>.from(asesores);
      asesoresOrdenados.sort((a, b) => ((b['comisiones'] ?? 0) as num).compareTo((a['comisiones'] ?? 0) as num));
      _topAsesores = asesoresOrdenados.take(5).toList();
      
      // ✅ Asesores más recientes (últimos 5)
      final asesoresRecientes = List<Map<String, dynamic>>.from(asesores);
      asesoresRecientes.sort((a, b) => (b['fechaRegistro'] ?? '').compareTo(a['fechaRegistro'] ?? ''));
      _asesoresRecientes = asesoresRecientes.take(5).toList();
      
    } catch (e) {
      print('Error al cargar dashboard: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al cargar: $e'), backgroundColor: const Color(0xFFEF4444)),
      );
    }
    setState(() => _cargando = false);
  }

  // ✅ Método auxiliar para agrupar
  Map<String, int> _agruparPor(List<Map<String, dynamic>> lista, String campo, String defaultValue) {
    final mapa = <String, int>{};
    for (var item in lista) {
      final valor = (item[campo] ?? defaultValue).toString();
      final key = valor.isEmpty ? defaultValue : valor;
      mapa[key] = (mapa[key] ?? 0) + 1;
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.dashboard, color: Colors.white), SizedBox(width: 8), Text('Dashboard Asesores')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
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
                  // ✅ KPIs principales
                  _buildKPIsRow(),
                  const SizedBox(height: 16),
                  
                  // ✅ Indicadores circulares
                  Row(
                    children: [
                      Expanded(child: _buildCircularCard('Tasa de Actividad', '${_tasaActividad.toStringAsFixed(1)}%', 'activos del total', const Color(0xFF10B981))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildCircularCard('Promedio Comisión', '${_promedioComision.toStringAsFixed(1)}%', 'por asesor', const Color(0xFFF59E0B))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ✅ Top asesores
                  _buildTopAsesores(),
                  const SizedBox(height: 16),
                  
                  // ✅ Asesores recientes
                  _buildAsesoresRecientes(),
                  const SizedBox(height: 16),
                  
                  // ✅ Gráficos de distribución
                  _buildBarChart('Asesores por Especialidad', _porEspecialidad, const Color(0xFF8B5CF6)),
                  const SizedBox(height: 16),
                  
                  _buildBarChart('Asesores por Grupo', _porGrupo, const Color(0xFF3B82F6)),
                  const SizedBox(height: 16),
                  
                  _buildBarChart('Asesores por Inmobiliaria', _porInmobiliaria, const Color(0xFF06B6D4)),
                  const SizedBox(height: 16),
                  
                  _buildBarChart('Asesores por País', _porPais, const Color(0xFFEC4899)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ✅ Fila de KPIs principales
  Widget _buildKPIsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildKPICard('Total Asesores', '$_totalAsesores', Icons.people, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard('Activos', '$_activos', Icons.check_circle, const Color(0xFF10B981))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKPICard('Inactivos', '$_inactivos', Icons.cancel, const Color(0xFF64748B))),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard('Ventas Totales', '$_totalVentas', Icons.shopping_cart, const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKPICard('Comisiones', '\$${_totalComisiones.toStringAsFixed(0)}', Icons.attach_money, const Color(0xFF8B5CF6))),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard('Promedio Comisión', '${_promedioComision.toStringAsFixed(1)}%', Icons.percent, const Color(0xFFEC4899))),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String label, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  // ✅ Tarjeta circular con porcentaje
  Widget _buildCircularCard(String titulo, String valor, String subtitulo, Color color) {
    final porcentaje = double.tryParse(valor.replaceAll('%', '')) ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: porcentaje / 100,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
          const SizedBox(height: 2),
          Text(subtitulo, style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  // ✅ Top asesores por comisión
  Widget _buildTopAsesores() {
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
              const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text('Top 5 Asesores por Comisión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))),
            ],
          ),
          const SizedBox(height: 16),
          if (_topAsesores.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Sin datos disponibles', style: TextStyle(color: Color(0xFF64748B)))))
          else
            ..._topAsesores.asMap().entries.map((entry) {
              final index = entry.key;
              final asesor = entry.value;
              final nombre = asesor['nombre'] ?? 'Sin nombre';
              final comisiones = (asesor['comisiones'] ?? 0) as num;
              final ventas = (asesor['ventas'] ?? 0) as num;
              final maxComisiones = (_topAsesores.first['comisiones'] ?? 1) as num;
              final porcentaje = maxComisiones > 0 ? (comisiones / maxComisiones) * 100 : 0;
              
              final colorMedalla = index == 0 ? const Color(0xFFF59E0B) : index == 1 ? const Color(0xFF94A3B8) : index == 2 ? const Color(0xFFCD7F32) : AppTheme.primary;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorMedalla,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                              const SizedBox(height: 2),
                              Text('$ventas ventas', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                            ],
                          ),
                        ),
                        Text('\$${comisiones.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje / 100,
                        minHeight: 6,
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

  // ✅ Asesores recientes
  Widget _buildAsesoresRecientes() {
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
              const Icon(Icons.history, color: Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text('Asesores Recientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))),
            ],
          ),
          const SizedBox(height: 16),
          if (_asesoresRecientes.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Sin datos disponibles', style: TextStyle(color: Color(0xFF64748B)))))
          else
            ..._asesoresRecientes.map((asesor) {
              final nombre = asesor['nombre'] ?? 'Sin nombre';
              final fecha = asesor['fechaRegistro'] ?? '';
              final activo = asesor['activo'] ?? true;
              final inicial = nombre.substring(0, 1).toUpperCase();
              
              String fechaFormateada = '';
              if (fecha.isNotEmpty) {
                try {
                  final date = DateTime.parse(fecha);
                  fechaFormateada = '${date.day}/${date.month}/${date.year}';
                } catch (e) {
                  fechaFormateada = 'Reciente';
                }
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(inicial, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
                          const SizedBox(height: 2),
                          Text('Registrado: $fechaFormateada', style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: activo ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF64748B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activo ? 'Activo' : 'Inactivo',
                        style: TextStyle(fontSize: 9, color: activo ? const Color(0xFF10B981) : const Color(0xFF64748B), fontWeight: FontWeight.w700),
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

  // ✅ Gráfico de barras
  Widget _buildBarChart(String titulo, Map<String, int> datos, Color color) {
    if (datos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context))),
        child: Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
      );
    }
    
    final maxValor = datos.values.reduce((a, b) => a > b ? a : b);
    final total = datos.values.fold<int>(0, (a, b) => a + b);
    
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
              Icon(Icons.bar_chart, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)))),
              Text('Total: $total', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
            ],
          ),
          const SizedBox(height: 16),
          ...datos.entries.map((entry) {
            final label = entry.key;
            final valor = entry.value;
            final porcentaje = maxValor > 0 ? (valor / maxValor) * 100 : 0;
            final porcentajeTotal = total > 0 ? (valor / total) * 100 : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context)), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('$valor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 45,
                        child: Text('(${porcentajeTotal.toStringAsFixed(0)}%)', style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context)), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: porcentaje / 100,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
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
}