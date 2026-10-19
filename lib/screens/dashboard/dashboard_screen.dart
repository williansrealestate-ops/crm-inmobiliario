import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onVerNotificaciones;

  const DashboardScreen({super.key, required this.onVerNotificaciones});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalAsesores = 0;
  int _totalClientes = 0;
  int _totalInmuebles = 0;
  int _actividadesHoy = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
    });

    try {
      final client = Supabase.instance.client;

      // Obtener conteos de cada tabla
      final asesoresCount = await client.from('asesores').count();
      final clientesCount = await client.from('clientes').count();
      final inmueblesCount = await client.from('inmuebles').count();

      setState(() {
        _totalAsesores = asesoresCount;
        _totalClientes = clientesCount;
        _totalInmuebles = inmueblesCount;
        _actividadesHoy = 0; // Puedes actualizar esto después
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar datos del dashboard: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buenas tardes, Williams',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjetas de conteo
                    Row(
                      children: [
                        Expanded(
                          child: _buildContadorCard(
                            'Asesores',
                            _totalAsesores,
                            Icons.person,
                            const Color(0xFF001F3F),
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContadorCard(
                            'Clientes',
                            _totalClientes,
                            Icons.people,
                            const Color(0xFF1A0B2E),
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContadorCard(
                            'Inmuebles',
                            _totalInmuebles,
                            Icons.home,
                            const Color(0xFF0B2E2E),
                            const Color(0xFF06B6D4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContadorCard(
                            'Actividades Hoy',
                            _actividadesHoy,
                            Icons.task,
                            const Color(0xFF2E1A00),
                            const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Resumen Financiero
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Resumen Financiero',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFilaFinanciera('Ingresos', '+\$0', const Color(0xFF10B981)),
                          const SizedBox(height: 12),
                          _buildFilaFinanciera('Gastos', '+\$0', const Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          _buildFilaFinanciera('Flujo de Caja', '+\$0', const Color(0xFF3B82F6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actividades de Hoy
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFFF59E0B), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Actividades de Hoy',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '($_actividadesHoy)',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContadorCard(
    String titulo,
    int valor,
    IconData icono,
    Color bgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: accentColor, size: 32),
          const SizedBox(height: 16),
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaFinanciera(String concepto, String monto, Color color) {
    return Row(
      children: [
        Icon(
          concepto == 'Ingresos'
              ? Icons.trending_up
              : concepto == 'Gastos'
                  ? Icons.trending_down
                  : Icons.account_balance,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            concepto,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          monto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}