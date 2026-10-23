import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/contenido_academico.dart';
import '../../services/gamificacion_service.dart';

class ConocimientosScreen extends StatefulWidget {
  const ConocimientosScreen({super.key});

  @override
  State<ConocimientosScreen> createState() => _ConocimientosScreenState();
}

class _ConocimientosScreenState extends State<ConocimientosScreen> {
  String? _temaSeleccionado;
  final List<String> _temasLeidos = [];

  @override
  Widget build(BuildContext context) {
    final perfil = GamificacionService.getPerfil();
    _temasLeidos.clear();
    _temasLeidos.addAll(List<String>.from(perfil['temasLeidos'] ?? []));

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: _temaSeleccionado == null
          ? _buildListaTemas()
          : _buildDetalleTema(_temaSeleccionado!),
    );
  }

  Widget _buildListaTemas() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            height: 140,
            backgroundColor: AppTheme.getBackgroundColor(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: AppTheme.primary, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Academia Inmobiliaria',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'v${ContenidoAcademico.version}',
                          style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Guía profesional actualizada - ${ContenidoAcademico.ultimaActualizacion}',
                    style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Tarjeta de progreso
              _buildTarjetaProgreso(),
              const SizedBox(height: 16),

              // Filtros por nivel
              const Text('📚 Temas por Nivel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._buildTemasPorNivel(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaProgreso() {
    final totalTemas = ContenidoAcademico.temasAcademia.length;
    final leidos = _temasLeidos.length;
    final progreso = totalTemas > 0 ? leidos / totalTemas : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tu Progreso',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$leidos de $totalTemas', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const Text('temas completados', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Text('${(progreso * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTemasPorNivel() {
    final niveles = ['Principiante', 'Intermedio', 'Avanzado'];
    final colores = {
      'Principiante': const Color(0xFF10B981),
      'Intermedio': const Color(0xFF3B82F6),
      'Avanzado': const Color(0xFF8B5CF6),
    };

    return niveles.map((nivel) {
      final temas = ContenidoAcademico.temasAcademia.where((t) => t['nivel'] == nivel).toList();
      if (temas.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colores[nivel]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$nivel (${temas.length})',
              style: TextStyle(color: colores[nivel], fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          ...temas.map((tema) => _buildTemaCard(tema)),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildTemaCard(Map<String, dynamic> tema) {
    final color = Color(int.parse(tema['color']));
    final estaLeido = _temasLeidos.contains(tema['id']);

    return GestureDetector(
      onTap: () {
        setState(() {
          _temaSeleccionado = tema['id'];
        });
        // Registrar puntos por leer tema
        final resultado = GamificacionService.marcarTemaLeido(tema['id']);
        if (resultado['subioNivel'] == true) {
          _mostrarNotificacionNivel(resultado);
        }
        if (resultado['badgesNuevos'] != null && (resultado['badgesNuevos'] as List).isNotEmpty) {
          _mostrarBadgesNuevos((resultado['badgesNuevos'] as List).cast<Map<String, dynamic>>());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: estaLeido ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(tema['icono'] ?? '', style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tema['titulo'],
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(tema['duracion'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tema['nivel'] ?? '',
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              estaLeido ? Icons.check_circle : Icons.arrow_forward_ios,
              color: estaLeido ? const Color(0xFF10B981) : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleTema(String temaId) {
    final tema = ContenidoAcademico.temasAcademia.firstWhere(
      (t) => t['id'] == temaId,
      orElse: () => {'titulo': 'Tema no encontrado', 'contenido': '', 'nivel': '', 'duracion': '', 'icono': '📚', 'color': '0xFF6B7280'},
    );

    final color = Color(int.parse(tema['color'] ?? '0xFF6B7280'));

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(tema['titulo'] ?? ''),
        backgroundColor: color,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _temaSeleccionado = null),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del tema
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(tema['icono'] ?? '', style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tema['nivel'] ?? '', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          '⏱️ ${tema['duracion'] ?? ''} de lectura',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido del tema
            _buildContenidoTema(tema['contenido'] ?? ''),
            const SizedBox(height: 24),

            // Botón de marcar como leído
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final resultado = GamificacionService.marcarTemaLeido(temaId);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Tema marcado como leído (+${resultado['puntosGanados']} puntos)'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                  if (resultado['subioNivel'] == true) {
                    _mostrarNotificacionNivel(resultado);
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: Text(_temasLeidos.contains(temaId) ? '✅ Ya leído' : 'Marcar como leído (+25 pts)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _temasLeidos.contains(temaId) ? const Color(0xFF10B981) : color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón volver
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _temaSeleccionado = null),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a la lista'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoTema(String contenido) {
    // Procesar el contenido markdown básico
    final lineas = contenido.split('\n');
    final widgets = <Widget>[];

    for (var linea in lineas) {
      if (linea.startsWith('# ')) {
        widgets.add(Text(linea.substring(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)));
        widgets.add(const SizedBox(height: 16));
      } else if (linea.startsWith('## ')) {
        widgets.add(Text(linea.substring(3), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))));
        widgets.add(const SizedBox(height: 12));
      } else if (linea.startsWith('### ')) {
        widgets.add(Text(linea.substring(4), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF334155))));
        widgets.add(const SizedBox(height: 8));
      } else if (linea.startsWith('• ') || linea.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•', style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(width: 8),
              Expanded(child: Text(linea.substring(2), style: const TextStyle(fontSize: 14, height: 1.5))),
            ],
          ),
        ));
      } else if (linea.startsWith('**') && linea.endsWith('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(linea.replaceAll('**', ''), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ));
      } else if (linea.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else {
        widgets.add(Text(linea, style: const TextStyle(fontSize: 14, height: 1.5)));
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  void _mostrarNotificacionNivel(Map<String, dynamic> resultado) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 ¡Subiste de Nivel!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 64),
            const SizedBox(height: 16),
            Text('Ahora eres ${resultado['nombreNivel']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Nivel ${resultado['nivel']}', style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  void _mostrarBadgesNuevos(List<Map<String, dynamic>> badges) {
    for (var badge in badges) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🏆 ¡Badge Desbloqueado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge['icono'] ?? '🏅', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(badge['nombre'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(badge['descripcion'] ?? '', style: const TextStyle(color: Color(0xFF64748B)), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('¡Increíble!'),
            ),
          ],
        ),
      );
    }
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  final Color backgroundColor;
  _StickyHeaderDelegate({required this.height, required this.child, required this.backgroundColor});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: child);
  }
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}