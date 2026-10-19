import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/referidos_service.dart';

class ReferidosScreen extends StatefulWidget {
  const ReferidosScreen({super.key});

  @override
  State<ReferidosScreen> createState() => _ReferidosScreenState();
}

class _ReferidosScreenState extends State<ReferidosScreen> with SingleTickerProviderStateMixin {
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
        title: const Row(children: [Icon(Icons.group_add, color: Colors.white), SizedBox(width: 8), Text('Sistema de Referidos')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Mi Código'),
            Tab(text: 'Mis Referidos'),
            Tab(text: 'Niveles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabMiCodigo(),
          _buildTabMisReferidos(),
          _buildTabNiveles(),
        ],
      ),
    );
  }

  Widget _buildTabMiCodigo() {
    final stats = ReferidosService.getEstadisticas();
    final nivel = ReferidosService.getNivelActual();
    final siguienteNivel = ReferidosService.getSiguienteNivel();
    final linkReferido = ReferidosService.generarLinkReferido();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con código
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(int.parse(nivel['color'])),
                  Color(int.parse(nivel['color'])).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(int.parse(nivel['color'])).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(nivel['icono'], style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'Nivel ${nivel['nombre']}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tu código: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        stats['codigoPropio'],
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: stats['codigoPropio']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Código copiado'), backgroundColor: Color(0xFF10B981)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.copy, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Estadísticas
          Row(
            children: [
              Expanded(child: _buildStatCard('${stats['totalReferidos']}', 'Total Referidos', const Color(0xFF3B82F6), Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('${stats['referidosExitosos']}', 'Exitosos', const Color(0xFF10B981), Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('${stats['puntosGanados']}', 'Puntos', const Color(0xFFF59E0B), Icons.star)),
            ],
          ),
          const SizedBox(height: 24),

          // Link compartible
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
                const Row(
                  children: [
                    Icon(Icons.link, color: Color(0xFF3B82F6), size: 20),
                    SizedBox(width: 8),
                    Text('Link de Referido', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
                    linkReferido,
                    style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context), fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: linkReferido));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Link copiado al portapapeles'), backgroundColor: Color(0xFF10B981)),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copiar Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Abrir WhatsApp con el link
                          final mensaje = '¡Hola! Te recomiendo este servicio inmobiliario. Usa mi código ${stats['codigoPropio']} para obtener beneficios: $linkReferido';
                          final url = 'https://wa.me/?text=${Uri.encodeComponent(mensaje)}';
                          // Implementar apertura de URL
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recompensa del nivel actual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tu Recompensa Actual', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        nivel['recompensa'],
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Progreso al siguiente nivel
          if (siguienteNivel != null) ...[
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
                  Row(
                    children: [
                      Text(siguienteNivel['icono'], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Siguiente Nivel: ${siguienteNivel['nombre']}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)),
                            ),
                            Text(
                              'Necesitas ${siguienteNivel['minimo']} referidos exitosos',
                              style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (stats['referidosExitosos'] / siguienteNivel['minimo']).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.getBorderColor(context),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(siguienteNivel['color']))),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats['referidosExitosos']} / ${siguienteNivel['minimo']} referidos exitosos',
                    style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String valor, String label, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildTabMisReferidos() {
    final referidos = ReferidosService.getMisReferidos();

    if (referidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Aún no tienes referidos', style: TextStyle(fontSize: 18, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Comparte tu código y empieza a ganar recompensas', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: referidos.length,
      itemBuilder: (context, index) {
        final referido = referidos[referidos.length - 1 - index];
        final estado = referido['estado'];
        final colorEstado = estado == 'exitoso' ? const Color(0xFF10B981) : estado == 'pendiente' ? const Color(0xFFF59E0B) : const Color(0xFF64748B);
        final iconoEstado = estado == 'exitoso' ? Icons.check_circle : estado == 'pendiente' ? Icons.pending : Icons.cancel;
        final fecha = DateTime.parse(referido['fechaRegistro']);

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
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconoEstado, color: colorEstado, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          referido['nombreReferido'],
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)),
                        ),
                        Text(
                          '${fecha.day}/${fecha.month}/${fecha.year}',
                          style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estado.toUpperCase(),
                      style: TextStyle(fontSize: 10, color: colorEstado, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      referido['emailReferido'],
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    referido['telefonoReferido'],
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              if (estado == 'exitoso') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '¡Referido exitoso! +100 puntos ganados',
                          style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabNiveles() {
    final nivelActual = ReferidosService.getNivelActual();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sistema de Niveles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Gana más recompensas mientras más referidos exitosos tengas',
            style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context)),
          ),
          const SizedBox(height: 24),
          ...ReferidosService.niveles.map((nivel) {
            final esActual = nivel['nombre'] == nivelActual['nombre'];
            final color = Color(int.parse(nivel['color']));
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: esActual ? color.withOpacity(0.1) : AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: esActual ? color : AppTheme.getBorderColor(context),
                  width: esActual ? 2 : 1,
                ),
                boxShadow: esActual ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(nivel['icono'], style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Nivel ${nivel['nombre']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: esActual ? color : AppTheme.getTextColor(context),
                                  ),
                                ),
                                if (esActual) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ACTUAL',
                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nivel['minimo']}-${nivel['maximo']} referidos exitosos',
                              style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.card_giftcard, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recompensa:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              Text(
                                nivel['recompensa'],
                                style: TextStyle(fontSize: 12, color: AppTheme.getTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('¿Cómo funciona?', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 12),
                Text('1. Comparte tu código único con amigos y familiares', style: TextStyle(color: Colors.white, fontSize: 12)),
                SizedBox(height: 4),
                Text('2. Cuando cierren una operación, tú ganas puntos y subes de nivel', style: TextStyle(color: Colors.white, fontSize: 12)),
                SizedBox(height: 4),
                Text('3. Desbloquea recompensas exclusivas en cada nivel', style: TextStyle(color: Colors.white, fontSize: 12)),
                SizedBox(height: 4),
                Text('4. ¡Mientras más referidos, mejores beneficios!', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}