import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ NUEVO: Para el portapapeles
import '../../config/theme.dart';
import '../../services/guiones_service.dart';
import '../../widgets/ios_widgets.dart';

class GuionesScreen extends StatefulWidget {
  const GuionesScreen({super.key});

  @override
  State<GuionesScreen> createState() => _GuionesScreenState();
}

class _GuionesScreenState extends State<GuionesScreen> {
  List<Map<String, dynamic>> _guiones = [];
  List<String> _categorias = [];
  String _filtroCategoria = 'Todas';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _guiones = await GuionesService.getGuiones();
      _categorias = await GuionesService.getCategorias();
    } catch (e) {
      print('Error al cargar: $e');
    }
    setState(() => _cargando = false);
  }

  // ✅ NUEVO: Función para copiar al portapapeles
  void _copiarAlPortapapeles(String texto) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Texto copiado al portapapeles'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guionesFiltrados = _getGuionesFiltrados();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.description, color: Colors.white), SizedBox(width: 8), Text('Guiones')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IOSButton(
              label: 'Nuevo',
              icon: Icons.add,
              onPressed: () => _abrirFormulario(),
              small: true,
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _filtroCategoria,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary,
                    ),
                    items: ['Todas', ..._categorias].map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                    onChanged: (value) => setState(() => _filtroCategoria = value ?? 'Todas'),
                  ),
                ),
                Expanded(
                  child: guionesFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, size: 80, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textTertiary),
                              const SizedBox(height: 16),
                              const Text('No hay guiones', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              const Text('Crea tu primer guion de ventas', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                              const SizedBox(height: 20),
                              IOSButton(
                                label: 'Nuevo guion',
                                icon: Icons.add,
                                onPressed: () => _abrirFormulario(),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: guionesFiltrados.length,
                          itemBuilder: (context, index) => _buildGuionCard(guionesFiltrados[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGuionCard(Map<String, dynamic> guion) {
    final titulo = guion['titulo'] ?? 'Sin título';
    final contenido = guion['contenido'] ?? '';
    final categoria = guion['categoria'] ?? 'General';
    final activo = guion['activo'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IOSCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: IOSColors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description, color: IOSColors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                      const SizedBox(height: 4),
                      IOSBadge(text: categoria, color: IOSColors.purple, filled: true),
                    ],
                  ),
                ),
                if (!activo)
                  const IOSBadge(text: 'Inactivo', color: IOSColors.textSecondary, filled: false),
              ],
            ),
            if (contenido.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                contenido,
                style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context)),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ✅ NUEVO: Botón de copiado rápido
                IOSButton(
                  label: 'Copiar',
                  icon: Icons.copy,
                  color: IOSColors.green,
                  small: true,
                  filled: true,
                  onPressed: () => _copiarAlPortapapeles(contenido),
                ),
                const SizedBox(width: 8),
                IOSButton(
                  label: 'Ver',
                  icon: Icons.visibility,
                  color: IOSColors.blue,
                  small: true,
                  filled: false,
                  onPressed: () => _verGuion(guion),
                ),
                const SizedBox(width: 8),
                IOSButton(
                  label: 'Editar',
                  icon: Icons.edit,
                  color: IOSColors.blue,
                  small: true,
                  filled: false,
                  onPressed: () => _abrirFormulario(guion: guion),
                ),
                const SizedBox(width: 8),
                IOSButton(
                  label: 'Eliminar',
                  icon: Icons.delete,
                  color: IOSColors.red,
                  small: true,
                  filled: false,
                  onPressed: () => _confirmarEliminar(guion['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _verGuion(Map<String, dynamic> guion) {
    final titulo = guion['titulo'] ?? 'Sin título';
    final contenido = guion['contenido'] ?? '';
    final categoria = guion['categoria'] ?? 'General';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text(titulo, style: TextStyle(color: AppTheme.getTextColor(context))),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IOSBadge(text: categoria, color: IOSColors.purple, filled: true),
                const SizedBox(height: 16),
                // ✅ CAMBIO: SelectableText permite seleccionar el texto con el mouse
                SelectableText(
                  contenido,
                  style: TextStyle(fontSize: 14, color: AppTheme.getTextColor(context), height: 1.6),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // ✅ NUEVO: Botón de copiar dentro del dialog
          TextButton(
            onPressed: () => _copiarAlPortapapeles(contenido),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.copy, size: 18), SizedBox(width: 6), Text('Copiar')],
            ),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _abrirFormulario({Map<String, dynamic>? guion}) {
    final esEdicion = guion != null;
    final tituloCtrl = TextEditingController(text: guion?['titulo'] ?? '');
    final contenidoCtrl = TextEditingController(text: guion?['contenido'] ?? '');
    final categoriaCtrl = TextEditingController(text: guion?['categoria'] ?? 'General');
    bool activo = guion?['activo'] ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text(esEdicion ? 'Editar Guion' : 'Nuevo Guion', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IOSInput(controller: tituloCtrl, label: 'Título *'),
                  const SizedBox(height: 12),
                  IOSInput(controller: categoriaCtrl, label: 'Categoría'),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 6),
                        child: const Text('Contenido', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: IOSColors.textSecondary)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: contenidoCtrl,
                          maxLines: 10,
                          style: TextStyle(fontSize: 14, color: AppTheme.getTextColor(context)),
                          decoration: const InputDecoration(
                            hintText: 'Escribe el contenido del guion...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Activo'),
                    value: activo,
                    onChanged: (value) => setDialogState(() => activo = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (tituloCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El título es obligatorio'), backgroundColor: Color(0xFFF59E0B)));
                  return;
                }
                final datos = {
                  'titulo': tituloCtrl.text,
                  'contenido': contenidoCtrl.text,
                  'categoria': categoriaCtrl.text,
                  'activo': activo,
                };
                try {
                  if (esEdicion) {
                    await GuionesService.actualizarGuion(guion['id'], datos);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Guion actualizado'), backgroundColor: Color(0xFF10B981)));
                  } else {
                    await GuionesService.agregarGuion(datos);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Guion creado'), backgroundColor: Color(0xFF10B981)));
                  }
                  Navigator.pop(dialogContext);
                  await _cargarDatos();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                }
              },
              child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar guion?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await GuionesService.eliminarGuion(id);
              Navigator.pop(ctx);
              await _cargarDatos();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getGuionesFiltrados() {
    var guiones = _guiones;
    if (_filtroCategoria != 'Todas') {
      guiones = guiones.where((g) => g['categoria'] == _filtroCategoria).toList();
    }
    return guiones;
  }
}