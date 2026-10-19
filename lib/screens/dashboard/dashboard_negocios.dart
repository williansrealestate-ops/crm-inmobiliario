import 'package:flutter/material.dart';
import '../../config/theme.dart';

class DashboardNegociosScreen extends StatefulWidget {
  const DashboardNegociosScreen({super.key});

  @override
  State<DashboardNegociosScreen> createState() => _DashboardNegociosScreenState();
}

class _DashboardNegociosScreenState extends State<DashboardNegociosScreen> {
  int _negocioSeleccionado = 0;

  final List<Map<String, dynamic>> _negocios = [
    {'id': 'minerales', 'nombre': 'Minerales', 'icono': Icons.diamond, 'color': const Color(0xFFF59E0B), 'colorGradiente': const Color(0xFFD97706)},
    {'id': 'combustible', 'nombre': 'Combustible', 'icono': Icons.local_gas_station, 'color': const Color(0xFF10B981), 'colorGradiente': const Color(0xFF059669)},
    {'id': 'agropecuario', 'nombre': 'Agropecuario', 'icono': Icons.agriculture, 'color': const Color(0xFF8B5CF6), 'colorGradiente': const Color(0xFF7C3AED)},
    {'id': 'proyectos', 'nombre': 'Proyectos', 'icono': Icons.business_center, 'color': const Color(0xFFEC4899), 'colorGradiente': const Color(0xFFDB2777)},
  ];

  final Map<String, Map<String, dynamic>> _datosNegocios = {
    'minerales': {
      'produccionMes': 1250, 'produccionUnidad': 'toneladas', 'reservas': 45000, 'reservasUnidad': 'toneladas',
      'precioActual': 1850, 'precioUnidad': 'USD/ton', 'operacionesActivas': 3, 'empleados': 47, 'maquinaria': 12,
      'ingresosMes': 2312500, 'gastosMes': 1450000,
      'operaciones': [
        {'nombre': 'Mina El Dorado', 'estado': 'Activa', 'produccion': 450, 'icono': Icons.landscape}, // ✅ CORREGIDO
        {'nombre': 'Mina La Esperanza', 'estado': 'Activa', 'produccion': 520, 'icono': Icons.terrain},
        {'nombre': 'Mina San José', 'estado': 'Mantenimiento', 'produccion': 0, 'icono': Icons.build},
      ],
      'alertas': [
        {'tipo': 'warning', 'mensaje': 'Mina San José en mantenimiento programado'},
        {'tipo': 'success', 'mensaje': 'Producción mensual +12% vs mes anterior'},
      ],
    },
    'combustible': {
      'ventasDia': 8500, 'ventasUnidad': 'litros', 'inventario': 125000, 'inventarioUnidad': 'litros',
      'precioMagna': 22.50, 'precioPremium': 24.80, 'precioDiesel': 23.90, 'estaciones': 4, 'empleados': 28, 'tanques': 16,
      'ingresosMes': 1912500, 'gastosMes': 1650000,
      'operaciones': [
        {'nombre': 'Estación Centro', 'ventas': 2800, 'estado': 'Operativa', 'icono': Icons.store},
        {'nombre': 'Estación Norte', 'ventas': 2200, 'estado': 'Operativa', 'icono': Icons.store},
        {'nombre': 'Estación Sur', 'ventas': 1900, 'estado': 'Operativa', 'icono': Icons.store},
        {'nombre': 'Estación Poniente', 'ventas': 1600, 'estado': 'Bajo inventario', 'icono': Icons.store},
      ],
      'alertas': [
        {'tipo': 'danger', 'mensaje': 'Estación Poniente: Inventario bajo (15%)'},
        {'tipo': 'success', 'mensaje': 'Ventas diarias +8% vs promedio'},
      ],
    },
    'agropecuario': {
      'hectareas': 2450, 'hectareasUnidad': 'has cultivadas', 'ganado': 850, 'ganadoUnidad': 'cabezas',
      'cosechaEsperada': 18500, 'cosechaUnidad': 'toneladas', 'temporada': 'Otoño-Invierno 2026', 'empleados': 65, 'tractores': 8,
      'ingresosMes': 1250000, 'gastosMes': 890000,
      'operaciones': [
        {'nombre': 'Rancho El Paraíso', 'tipo': 'Ganado bovino', 'cantidad': 420, 'icono': Icons.pets},
        {'nombre': 'Campo Los Álamos', 'tipo': 'Maíz', 'cantidad': 850, 'icono': Icons.grass},
        {'nombre': 'Hacienda San Miguel', 'tipo': 'Sorgo', 'cantidad': 620, 'icono': Icons.eco},
      ],
      'alertas': [
        {'tipo': 'warning', 'mensaje': 'Se acerca temporada de siembra'},
        {'tipo': 'success', 'mensaje': 'Ganado en excelente estado sanitario'},
      ],
    },
    'proyectos': {
      'proyectosActivos': 7, 'proyectosCompletados': 23, 'inversionTotal': 15800000, 'roi': 18.5, 'empleados': 120, 'contratistas': 8, 'enTiempo': 5, 'retrasados': 2,
      'ingresosMes': 3200000, 'gastosMes': 2750000,
      'operaciones': [
        {'nombre': 'Torre Corporativa A', 'progreso': 75, 'inversion': 4500000, 'icono': Icons.apartment},
        {'nombre': 'Desarrollo Habitacional B', 'progreso': 45, 'inversion': 3200000, 'icono': Icons.home},
        {'nombre': 'Plaza Comercial C', 'progreso': 90, 'inversion': 2800000, 'icono': Icons.store},
        {'nombre': 'Infraestructura Vial D', 'progreso': 30, 'inversion': 1900000, 'icono': Icons.route}, // ✅ CORREGIDO
      ],
      'alertas': [
        {'tipo': 'danger', 'mensaje': '2 proyectos con retraso > 15 días'},
        {'tipo': 'success', 'mensaje': 'ROI promedio +18.5% este trimestre'},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final negocioActual = _negocios[_negocioSeleccionado];
    final datos = _datosNegocios[negocioActual['id']]!;
    final balance = datos['ingresosMes'] - datos['gastosMes'];

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.dashboard, color: Colors.white), SizedBox(width: 8), Text('Dashboard de Negocios')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.getSurfaceColor(context),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_negocios.length, (index) {
                  final neg = _negocios[index];
                  final isSelected = _negocioSeleccionado == index;
                  return GestureDetector(
                    onTap: () => setState(() => _negocioSeleccionado = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? neg['color'] : AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? neg['color'] : AppTheme.getDividerColor(context), width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(neg['icono'], color: isSelected ? Colors.white : neg['color'], size: 20),
                          const SizedBox(width: 8),
                          Text(neg['nombre'], style: TextStyle(color: isSelected ? Colors.white : AppTheme.getTextColor(context), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderNegocio(negocioActual, datos),
                  const SizedBox(height: 24),
                  const Text('KPIs Principales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildKPIsGrid(negocioActual, datos),
                  const SizedBox(height: 24),
                  const Text('Balance del Mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildBalanceCard(datos, balance),
                  const SizedBox(height: 24),
                  const Text('Operaciones Activas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...List<Map<String, dynamic>>.from(datos['operaciones']).map((op) => _buildOperacionCard(op, negocioActual)),
                  const SizedBox(height: 24),
                  const Text('Alertas y Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...List<Map<String, dynamic>>.from(datos['alertas']).map((alerta) => _buildAlertaCard(alerta)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderNegocio(Map<String, dynamic> negocio, Map<String, dynamic> datos) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [negocio['color'], negocio['colorGradiente']], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: negocio['color'].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: Icon(negocio['icono'], color: Colors.white, size: 40)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(negocio['nombre'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Dashboard en tiempo real', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
          ])),
        ],
      ),
    );
  }

  Widget _buildKPIsGrid(Map<String, dynamic> negocio, Map<String, dynamic> datos) {
    final id = negocio['id'];
    List<Map<String, dynamic>> kpis = [];
    if (id == 'minerales') {
      kpis = [
        {'label': 'Producción Mes', 'valor': '${datos['produccionMes']} ${datos['produccionUnidad']}', 'icono': Icons.factory, 'color': const Color(0xFF3B82F6)},
        {'label': 'Reservas', 'valor': '${datos['reservas']} ${datos['reservasUnidad']}', 'icono': Icons.inventory, 'color': const Color(0xFF10B981)},
        {'label': 'Precio Actual', 'valor': '\$${datos['precioActual']} ${datos['precioUnidad']}', 'icono': Icons.trending_up, 'color': const Color(0xFFF59E0B)},
        {'label': 'Operaciones', 'valor': '${datos['operacionesActivas']} activas', 'icono': Icons.settings, 'color': const Color(0xFF8B5CF6)},
        {'label': 'Empleados', 'valor': '${datos['empleados']}', 'icono': Icons.people, 'color': const Color(0xFFEC4899)},
        {'label': 'Maquinaria', 'valor': '${datos['maquinaria']} equipos', 'icono': Icons.build, 'color': const Color(0xFF06B6D4)},
      ];
    } else if (id == 'combustible') {
      kpis = [
        {'label': 'Ventas Hoy', 'valor': '${datos['ventasDia']} ${datos['ventasUnidad']}', 'icono': Icons.local_gas_station, 'color': const Color(0xFF10B981)},
        {'label': 'Inventario', 'valor': '${datos['inventario']} ${datos['inventarioUnidad']}', 'icono': Icons.storage, 'color': const Color(0xFF3B82F6)},
        {'label': 'Magna', 'valor': '\$${datos['precioMagna']}', 'icono': Icons.local_gas_station, 'color': const Color(0xFFF59E0B)}, // ✅ CORREGIDO
        {'label': 'Premium', 'valor': '\$${datos['precioPremium']}', 'icono': Icons.local_gas_station, 'color': const Color(0xFF8B5CF6)}, // ✅ CORREGIDO
        {'label': 'Estaciones', 'valor': '${datos['estaciones']}', 'icono': Icons.store, 'color': const Color(0xFFEC4899)},
        {'label': 'Empleados', 'valor': '${datos['empleados']}', 'icono': Icons.people, 'color': const Color(0xFF06B6D4)},
      ];
    } else if (id == 'agropecuario') {
      kpis = [
        {'label': 'Hectáreas', 'valor': '${datos['hectareas']} ${datos['hectareasUnidad']}', 'icono': Icons.landscape, 'color': const Color(0xFF10B981)},
        {'label': 'Ganado', 'valor': '${datos['ganado']} ${datos['ganadoUnidad']}', 'icono': Icons.pets, 'color': const Color(0xFF8B5CF6)},
        {'label': 'Cosecha Esperada', 'valor': '${datos['cosechaEsperada']} ${datos['cosechaUnidad']}', 'icono': Icons.grass, 'color': const Color(0xFFF59E0B)},
        {'label': 'Temporada', 'valor': datos['temporada'], 'icono': Icons.calendar_today, 'color': const Color(0xFF3B82F6)},
        {'label': 'Empleados', 'valor': '${datos['empleados']}', 'icono': Icons.people, 'color': const Color(0xFFEC4899)},
        {'label': 'Tractores', 'valor': '${datos['tractores']}', 'icono': Icons.agriculture, 'color': const Color(0xFF06B6D4)},
      ];
    } else if (id == 'proyectos') {
      kpis = [
        {'label': 'Proyectos Activos', 'valor': '${datos['proyectosActivos']}', 'icono': Icons.business_center, 'color': const Color(0xFF3B82F6)},
        {'label': 'Completados', 'valor': '${datos['proyectosCompletados']}', 'icono': Icons.check_circle, 'color': const Color(0xFF10B981)},
        {'label': 'Inversión Total', 'valor': '\$${(datos['inversionTotal'] / 1000000).toStringAsFixed(1)}M', 'icono': Icons.attach_money, 'color': const Color(0xFFF59E0B)},
        {'label': 'ROI', 'valor': '${datos['roi']}%', 'icono': Icons.trending_up, 'color': const Color(0xFF8B5CF6)},
        {'label': 'En Tiempo', 'valor': '${datos['enTiempo']}', 'icono': Icons.schedule, 'color': const Color(0xFF10B981)},
        {'label': 'Retrasados', 'valor': '${datos['retrasados']}', 'icono': Icons.warning, 'color': const Color(0xFFEF4444)},
      ];
    }
    return Wrap(spacing: 12, runSpacing: 12, children: kpis.map((kpi) => _buildKPICard(kpi)).toList());
  }

  Widget _buildKPICard(Map<String, dynamic> kpi) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: (kpi['color'] as Color).withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(kpi['icono'], color: kpi['color'], size: 24),
        const SizedBox(height: 8),
        Text(kpi['label'], style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        const SizedBox(height: 4),
        Text(kpi['valor'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
      ]),
    );
  }

  Widget _buildBalanceCard(Map<String, dynamic> datos, double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.getDividerColor(context))),
      child: Column(children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ingresos', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Text('\$${(datos['ingresosMes'] / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gastos', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Text('\$${(datos['gastosMes'] / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Balance', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Text('\$${(balance / 1000).toStringAsFixed(0)}K', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444))),
          ])),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: datos['gastosMes'] / datos['ingresosMes'], backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)), minHeight: 12),
        ),
        const SizedBox(height: 8),
        Text('Margen: ${((balance / datos['ingresosMes']) * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
      ]),
    );
  }

  Widget _buildOperacionCard(Map<String, dynamic> op, Map<String, dynamic> negocio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getDividerColor(context))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: negocio['color'].withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(op['icono'], color: negocio['color'], size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(op['nombre'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (op['tipo'] != null) Text(op['tipo'], style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
          if (op['progreso'] != null) ...[
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: op['progreso'] / 100, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(negocio['color']), minHeight: 8)),
            const SizedBox(height: 4),
            Text('Progreso: ${op['progreso']}%', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
          ],
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (op['produccion'] != null) Text('${op['produccion']} ton', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
          if (op['ventas'] != null) Text('${op['ventas']} L', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
          if (op['cantidad'] != null) Text('${op['cantidad']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6))),
          if (op['inversion'] != null) Text('\$${(op['inversion'] / 1000000).toStringAsFixed(1)}M', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFEC4899))),
          if (op['estado'] != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: (op['estado'] == 'Activa' || op['estado'] == 'Operativa') ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(op['estado'], style: TextStyle(fontSize: 10, color: (op['estado'] == 'Activa' || op['estado'] == 'Operativa') ? const Color(0xFF10B981) : const Color(0xFFF59E0B), fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildAlertaCard(Map<String, dynamic> alerta) {
    Color color;
    IconData icono;
    if (alerta['tipo'] == 'danger') { color = const Color(0xFFEF4444); icono = Icons.error; } 
    else if (alerta['tipo'] == 'warning') { color = const Color(0xFFF59E0B); icono = Icons.warning; } 
    else { color = const Color(0xFF10B981); icono = Icons.check_circle; }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [Icon(icono, color: color, size: 20), const SizedBox(width: 12), Expanded(child: Text(alerta['mensaje'], style: TextStyle(fontSize: 13, color: AppTheme.getTextColor(context))))]),
    );
  }
}