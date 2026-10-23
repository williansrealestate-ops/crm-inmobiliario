import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/indexed_db_service.dart';

class AcademiaScreen extends StatefulWidget {
  const AcademiaScreen({super.key});

  @override
  State<AcademiaScreen> createState() => _AcademiaScreenState();
}

class _AcademiaScreenState extends State<AcademiaScreen> {
  List<Map<String, dynamic>> _cursos = [];
  String _filtroTipo = 'Todos';
  bool _cargando = true;

  // ✅ Color adaptativo para tarjetas
  Color _colorTarjeta(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  Color _colorBorde(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF333333)
        : Colors.grey.shade200;
  }

  Color _colorFiltroNoSeleccionado(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.white;
  }

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  Future<void> _cargarCursos() async {
    setState(() => _cargando = true);
    try {
      final json = await IndexedDBService.get('cursos_academia');
      if (json != null) {
        final lista = jsonDecode(json) as List;
        _cursos = lista.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error al cargar academia: $e');
    }
    setState(() => _cargando = false);
  }

  Future<void> _guardarCursos() async {
    await IndexedDBService.put('cursos_academia', jsonEncode(_cursos));
  }

  List<Map<String, dynamic>> get _cursosFiltrados {
    if (_filtroTipo == 'Todos') return _cursos;
    return _cursos.where((c) => c['tipo'] == _filtroTipo).toList();
  }

  void _mostrarFormularioCurso({Map<String, dynamic>? curso}) {
    final esEdicion = curso != null;
    final tituloCtrl = TextEditingController(text: curso?['titulo'] ?? '');
    final descCtrl = TextEditingController(text: curso?['descripcion'] ?? '');
    final urlCtrl = TextEditingController(text: curso?['url'] ?? '');
    String tipoSeleccionado = curso?['tipo'] ?? 'Video';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esEdicion ? 'Editar Curso' : 'Nuevo Curso',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.getTextColor(context)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tituloCtrl,
                    decoration: InputDecoration(
                      labelText: 'Título del curso',
                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descripción breve',
                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tipoSeleccionado,
                    decoration: InputDecoration(
                      labelText: 'Tipo de contenido',
                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['Video', 'PDF', 'Lectura'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setDialogState(() => tipoSeleccionado = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlCtrl,
                    decoration: InputDecoration(
                      labelText: 'URL (YouTube, Drive, Docs, etc.)',
                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                      helperText: 'Pega el enlace al recurso externo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (tituloCtrl.text.isEmpty || urlCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa título y URL')));
                              return;
                            }
                            final nuevoCurso = {
                              'id': curso?['id'] ?? 'curso_${DateTime.now().millisecondsSinceEpoch}',
                              'titulo': tituloCtrl.text,
                              'descripcion': descCtrl.text,
                              'tipo': tipoSeleccionado,
                              'url': urlCtrl.text,
                              'completado': curso?['completado'] ?? false,
                              'fecha': DateTime.now().toIso8601String().split('T')[0],
                            };
                            if (esEdicion) {
                              final index = _cursos.indexWhere((c) => c['id'] == curso['id']);
                              if (index != -1) _cursos[index] = nuevoCurso;
                            } else {
                              _cursos.add(nuevoCurso);
                            }
                            _guardarCursos();
                            Navigator.pop(ctx);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCompletado(String id) async {
    final index = _cursos.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      _cursos[index]['completado'] = !(_cursos[index]['completado'] ?? false);
      await _guardarCursos();
      setState(() {});
    }
  }

  void _abrirCurso(String url) {
    html.window.open(url, '_blank');
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'Video': return Icons.play_circle_outline;
      case 'PDF': return Icons.picture_as_pdf;
      case 'Lectura': return Icons.menu_book;
      default: return Icons.article;
    }
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'Video': return const Color(0xFFEF4444);
      case 'PDF': return const Color(0xFFDC2626);
      case 'Lectura': return const Color(0xFF3B82F6);
      default: return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completados = _cursos.where((c) => c['completado'] == true).length;
    final porcentaje = _cursos.isEmpty ? 0 : ((completados / _cursos.length) * 100).round();
    final colorTarjeta = _colorTarjeta(context);
    final colorBorde = _colorBorde(context);
    final colorFiltro = _colorFiltroNoSeleccionado(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header con progreso
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF007AFF),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Colors.white, size: 32),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Academia Inmobiliaria', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                                Text('Capacitación continua para asesores', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _mostrarFormularioCurso(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nuevo Curso'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tu progreso: $porcentaje%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: porcentaje / 100,
                                      backgroundColor: Colors.white24,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text('$completados/${_cursos.length}\nCursos', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Filtros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['Todos', 'Video', 'PDF', 'Lectura'].map((tipo) {
                      final isSelected = _filtroTipo == tipo;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filtroTipo = tipo),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF007AFF) : colorFiltro,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF007AFF) : colorBorde,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  tipo,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.getTextColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de cursos
                Expanded(
                  child: _cursosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No hay cursos en esta categoría',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: _cursosFiltrados.length,
                          itemBuilder: (context, index) {
                            final curso = _cursosFiltrados[index];
                            final colorTipo = _getColorTipo(curso['tipo']);
                            final iconoTipo = _getIconoTipo(curso['tipo']);
                            final completado = curso['completado'] ?? false;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              color: colorTarjeta,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: colorBorde),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: colorTipo.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(iconoTipo, color: colorTipo, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  curso['titulo'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.getTextColor(context),
                                                    decoration: completado ? TextDecoration.lineThrough : null,
                                                  ),
                                                ),
                                              ),
                                              if (completado)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF10B981).withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Completado',
                                                        style: TextStyle(
                                                          color: Color(0xFF10B981),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            curso['descripcion'] ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.getTextSecondaryColor(context),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () => _abrirCurso(curso['url']),
                                                icon: const Icon(Icons.open_in_new, size: 16),
                                                label: const Text('Ver recurso'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorTipo,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                onPressed: () => _toggleCompletado(curso['id']),
                                                icon: Icon(
                                                  completado ? Icons.check_box : Icons.check_box_outline_blank,
                                                  color: completado ? const Color(0xFF10B981) : Colors.grey,
                                                ),
                                                label: Text(
                                                  completado ? 'Completado' : 'Marcar como visto',
                                                  style: TextStyle(
                                                    color: completado ? const Color(0xFF10B981) : Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert, color: AppTheme.getTextSecondaryColor(context)),
                                                onSelected: (v) {
                                                  if (v == 'editar') _mostrarFormularioCurso(curso: curso);
                                                  if (v == 'eliminar') {
                                                    _cursos.removeWhere((c) => c['id'] == curso['id']);
                                                    _guardarCursos();
                                                    setState(() {});
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'editar',
                                                    child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Editar')]),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'eliminar',
                                                    child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))]),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}