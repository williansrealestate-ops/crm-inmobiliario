import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/automatizacion_service.dart';

class AutomatizacionScreen extends StatefulWidget {
  const AutomatizacionScreen({super.key});

  @override
  State<AutomatizacionScreen> createState() => _AutomatizacionScreenState();
}

class _AutomatizacionScreenState extends State<AutomatizacionScreen> with SingleTickerProviderStateMixin {
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
        title: const Row(children: [Icon(Icons.auto_awesome, color: Colors.white), SizedBox(width: 8), Text('Automatización')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Reglas'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabReglas(),
          _buildTabPendientes(),
          _buildTabHistorial(),
        ],
      ),
    );
  }

  Widget _buildTabReglas() {
    final reglas = AutomatizacionService.getReglas();
    final stats = AutomatizacionService.getEstadisticas();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('${stats['totalEnviados']}', 'Enviados', Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('${stats['reglasActivas']}/${stats['totalReglas']}', 'Reglas Activas', Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('${stats['tasaExito'].toStringAsFixed(0)}%', 'Tasa Éxito', Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Reglas de Automatización', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          ...reglas.map((regla) => _buildReglaCard(regla)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String valor, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(valor, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildReglaCard(Map<String, dynamic> regla) {
    final activa = regla['activa'] == true;
    final color = activa ? const Color(0xFF10B981) : const Color(0xFF64748B);
    final icono = _getIconoEtapa(regla['etapa']);
    final nombreEtapa = _getNombreEtapa(regla['etapa']);
    final tiempoHoras = regla['tiempoHoras'] as int;
    final tiempoTexto = tiempoHoras >= 24 ? '${tiempoHoras ~/ 24} días' : '$tiempoHoras horas';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activa ? color.withOpacity(0.3) : AppTheme.getBorderColor(context)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icono, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(regla['titulo'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                    Text('$nombreEtapa • Después de $tiempoTexto', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                  ],
                ),
              ),
              Switch(
                value: activa,
                onChanged: (value) {
                  setState(() {
                    regla['activa'] = value;
                    AutomatizacionService.guardarReglas(AutomatizacionService.getReglas());
                  });
                },
                activeColor: const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              regla['mensaje'],
              style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context), fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_getIconoCanal(regla['canal']), size: 14, color: color),
              const SizedBox(width: 4),
              Text(regla['canal'].toString().toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _editarRegla(regla),
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Editar', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabPendientes() {
    final pendientes = AutomatizacionService.verificarSeguimientosPendientes();

    if (pendientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No hay seguimientos pendientes', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendientes.length,
      itemBuilder: (context, index) {
        final pendiente = pendientes[index];
        final op = pendiente['operacion'] as Map<String, dynamic>;
        final regla = pendiente['regla'] as Map<String, dynamic>;
        final horas = pendiente['horasTranscurridas'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.schedule, color: Color(0xFFF59E0B), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(regla['titulo'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('${op['cliente']} • $horas horas en etapa', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.getBackgroundColor(context), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  regla['mensaje']
                      .toString()
                      .replaceAll('{cliente}', op['cliente'] ?? 'cliente')
                      .replaceAll('{propiedad}', op['titulo'] ?? 'propiedad'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _enviarSeguimiento(pendiente),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Enviar seguimiento'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabHistorial() {
    final historial = AutomatizacionService.getHistorial();

    if (historial.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No hay historial de envíos', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historial.length,
      itemBuilder: (context, index) {
        final registro = historial[historial.length - 1 - index];
        final exitoso = registro['exitoso'] == true;
        final fecha = DateTime.parse(registro['fecha']);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: exitoso ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFEF4444).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(exitoso ? Icons.check_circle : Icons.error, color: exitoso ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(registro['reglaTitulo'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${registro['cliente']} • ${registro['canal']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _enviarSeguimiento(Map<String, dynamic> pendiente) {
    final resultado = AutomatizacionService.enviarSeguimiento(pendiente);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['exitoso'] == true ? '✅ ${resultado['resultado']}' : '⚠️ ${resultado['resultado']}'),
        backgroundColor: resultado['exitoso'] == true ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
      ),
    );
    
    setState(() {});
  }

  void _editarRegla(Map<String, dynamic> regla) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Editar regla', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: regla['titulo']),
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                onChanged: (value) => regla['titulo'] = value,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: regla['mensaje']),
                decoration: const InputDecoration(labelText: 'Mensaje', border: OutlineInputBorder()),
                maxLines: 4,
                onChanged: (value) => regla['mensaje'] = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              AutomatizacionService.guardarReglas(AutomatizacionService.getReglas());
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  IconData _getIconoEtapa(String etapa) {
    switch (etapa) {
      case 'prospecto': return Icons.person;
      case 'calificado': return Icons.check_circle;
      case 'visita': return Icons.home;
      case 'oferta': return Icons.handshake;
      case 'reservado': return Icons.lock;
      case 'cerrado': return Icons.celebration;
      default: return Icons.circle;
    }
  }

  String _getNombreEtapa(String etapa) {
    switch (etapa) {
      case 'prospecto': return 'Prospecto';
      case 'calificado': return 'Calificado';
      case 'visita': return 'Visita';
      case 'oferta': return 'Oferta';
      case 'reservado': return 'Reservado';
      case 'cerrado': return 'Cerrado';
      default: return etapa;
    }
  }

  IconData _getIconoCanal(String canal) {
    switch (canal) {
      case 'whatsapp': return Icons.message;
      case 'email': return Icons.email;
      case 'sms': return Icons.sms;
      default: return Icons.send;
    }
  }
}