import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/gamificacion_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = GamificacionService.getPerfil();
    final progreso = GamificacionService.getProgresoNivel();
    final badges = GamificacionService.getBadges();
    final historial = GamificacionService.getHistorial();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.emoji_events, color: Colors.white), SizedBox(width: 8), Text('Mi Perfil')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GamificacionService.resetTodo();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progreso reiniciado')));
              (context as Element).markNeedsBuild();
            },
            tooltip: 'Reiniciar progreso',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de nivel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(progreso['nombreNivel'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                            Text('Nivel ${progreso['nivelActual']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('${progreso['puntos']} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Progreso al siguiente nivel', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progreso['progreso'],
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Faltan ${progreso['faltan']} puntos para el siguiente nivel', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Estadísticas
            const Text(' Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('📚', 'Temas leídos', '${(perfil['temasLeidos'] as List).length}', const Color(0xFF3B82F6))),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('✍️', 'Scripts', '${perfil['scriptsGenerados'] ?? 0}', const Color(0xFF10B981))),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('📄', 'Documentos', '${perfil['documentosCreados'] ?? 0}', const Color(0xFFF59E0B))),
              ],
            ),
            const SizedBox(height: 24),

            // Badges
            Text('🏆 Badges Obtenidos (${badges.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (badges.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('Aún no tienes badges. ¡Usa la Academia y el Asistente para ganarlos!', textAlign: TextAlign.center)),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges.map((badge) => _buildBadgeCard(badge)).toList(),
              ),
            const SizedBox(height: 24),

            // Historial
            const Text('📜 Historial de Puntos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (historial.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('Sin actividad registrada')),
              )
            else
              ...historial.reversed.take(10).map((item) => _buildHistorialItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String icono, String label, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(icono, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(badge['icono'] ?? '🏅', style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(badge['nombre'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(badge['descripcion'] ?? '', style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHistorialItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add, color: Color(0xFF10B981), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['motivo'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(_formatearFecha(item['fecha'] ?? ''), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text('+${item['puntos']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
        ],
      ),
    );
  }

  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fechaIso;
    }
  }
}