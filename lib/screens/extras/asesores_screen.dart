import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/asesores_service.dart';
import '../../widgets/ios_widgets.dart';

class AsesoresScreen extends StatefulWidget {
  const AsesoresScreen({super.key});

  @override
  State<AsesoresScreen> createState() => _AsesoresScreenState();
}

class _AsesoresScreenState extends State<AsesoresScreen> {
  String _busqueda = '';
  String _grupoFiltro = 'Todos';
  String _inmobiliariaFiltro = 'Todas';
  
  // ✅ Cache en memoria
  List<Map<String, dynamic>> _asesores = [];
  List<String> _grupos = [];
  Map<String, dynamic> _stats = {'total': 0, 'activos': 0, 'totalVentas': 0};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _asesores = await AsesoresService.getAsesores();
      _grupos = await AsesoresService.getGrupos();
      _stats = await AsesoresService.getEstadisticas();
    } catch (e) {
      print('Error al cargar: $e');
    }
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final asesores = _getAsesoresFiltrados();
    final grupos = _getGruposDisponibles();
    final inmobiliarias = _getInmobiliariasDisponibles();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Asesores', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        backgroundColor: AppTheme.getBackgroundColor(context),
        foregroundColor: AppTheme.getTextColor(context),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.group), onPressed: _gestionarGrupos),
          IconButton(icon: const Icon(Icons.upload), onPressed: _importarAsesores),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _busqueda = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar asesores...',
                        prefixIcon: Icon(Icons.search, color: IOSColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _grupoFiltro,
                          decoration: InputDecoration(
                            labelText: 'Grupo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary,
                          ),
                          items: ['Todos', ...grupos].map((g) => DropdownMenuItem<String>(value: g, child: Text(g))).toList(),
                          onChanged: (value) => setState(() => _grupoFiltro = value ?? 'Todos'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _inmobiliariaFiltro,
                          decoration: InputDecoration(
                            labelText: 'Inmobiliaria',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary,
                          ),
                          items: ['Todas', ...inmobiliarias].map((i) => DropdownMenuItem<String>(value: i, child: Text(i))).toList(),
                          onChanged: (value) => setState(() => _inmobiliariaFiltro = value ?? 'Todas'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: IOSKPI(label: 'Asesores', value: '${_stats['total']}', icon: Icons.people, color: IOSColors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: IOSKPI(label: 'Activos', value: '${_stats['activos']}', icon: Icons.check_circle, color: IOSColors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: IOSKPI(label: 'Ventas', value: '${_stats['totalVentas']}', icon: Icons.shopping_cart, color: IOSColors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: asesores.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off, size: 80, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textTertiary),
                              const SizedBox(height: 16),
                              const Text('No hay asesores registrados', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              const Text('Agrega tu primer asesor', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                              const SizedBox(height: 20),
                              IOSButton(
                                label: 'Agregar asesor',
                                icon: Icons.add,
                                onPressed: () => _abrirFormulario(),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: asesores.length,
                          itemBuilder: (context, index) => _buildAsesorCard(asesores[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildAsesorCard(Map<String, dynamic> asesor) {
    final nombre = asesor['nombre'] ?? 'Sin nombre';
    final pais = asesor['pais'] ?? '';
    final estado = asesor['estado'] ?? '';
    final telefono = asesor['telefono'] ?? '';
    final email = asesor['email'] ?? '';
    final grupo = asesor['grupo'] ?? 'Sin grupo';
    final especialidad = asesor['especialidad'] ?? 'General';
    final inmobiliaria = asesor['inmobiliaria'] ?? '';
    final catalogo = asesor['catalogo'] ?? '';
    final activo = asesor['activo'] ?? true;
    final ventas = asesor['ventas'] ?? 0;
    final comisiones = asesor['comisiones'] ?? 0.0;
    final comisionPorcentaje = asesor['comisionPorcentaje'] ?? 3.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IOSCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(asesor, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                      const SizedBox(height: 4),
                      if (inmobiliaria.isNotEmpty)
                        Row(children: [
                          Icon(Icons.business, size: 13, color: IOSColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(inmobiliaria, style: TextStyle(fontSize: 13, color: IOSColors.textSecondary), overflow: TextOverflow.ellipsis)),
                        ]),
                      if (pais.isNotEmpty || estado.isNotEmpty)
                        Row(children: [
                          Icon(Icons.location_on, size: 13, color: IOSColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('$pais${pais.isNotEmpty && estado.isNotEmpty ? ", " : ""}$estado', style: TextStyle(fontSize: 13, color: IOSColors.textSecondary)),
                        ]),
                    ],
                  ),
                ),
                IOSBadge(text: activo ? 'Activo' : 'Inactivo', color: activo ? IOSColors.green : IOSColors.textSecondary, filled: activo),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: IOSColors.purple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.group, size: 14, color: IOSColors.purple),
                      const SizedBox(width: 6),
                      Expanded(child: Text(grupo, style: TextStyle(fontSize: 12, color: IOSColors.purple, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: IOSColors.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.star, size: 14, color: IOSColors.teal),
                      const SizedBox(width: 6),
                      Expanded(child: Text(especialidad, style: TextStyle(fontSize: 12, color: IOSColors.teal, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
              ],
            ),
            if (catalogo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: IOSColors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.inventory_2, size: 14, color: IOSColors.orange),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Catálogo: $catalogo', style: TextStyle(fontSize: 12, color: IOSColors.orange, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Teléfono', style: TextStyle(fontSize: 11, color: IOSColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(telefono.isEmpty ? 'Sin teléfono' : telefono, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
                  ]),
                ),
                if (email.isNotEmpty)
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Email', style: TextStyle(fontSize: 11, color: IOSColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(email, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context)), overflow: TextOverflow.ellipsis),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.percent, size: 15, color: IOSColors.textSecondary),
              const SizedBox(width: 4),
              Text('Comisión: $comisionPorcentaje%', style: TextStyle(fontSize: 13, color: IOSColors.textSecondary)),
            ]),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: IOSColors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Text('Ventas', style: TextStyle(fontSize: 10, color: IOSColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('$ventas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: IOSColors.orange)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: IOSColors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Text('Comisiones', style: TextStyle(fontSize: 10, color: IOSColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('\$${comisiones.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: IOSColors.green)),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IOSButton(label: 'Editar', icon: Icons.edit, color: IOSColors.blue, small: true, filled: false, onPressed: () => _abrirFormulario(asesor: asesor)),
              const SizedBox(width: 8),
              IOSButton(label: 'Eliminar', icon: Icons.delete, color: IOSColors.red, small: true, filled: false, onPressed: () => _confirmarEliminar(asesor['id'])),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> asesor, {double size = 56}) {
    final foto = asesor['foto'] as String?;
    final nombre = asesor['nombre'] ?? 'S';
    final inicial = nombre.substring(0, 1).toUpperCase();

    if (foto != null && foto.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(base64Decode(foto.split(',').last), width: size, height: size, fit: BoxFit.cover),
        );
      } catch (e) {}
    }
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [IOSColors.blue, IOSColors.indigo]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Text(inicial, style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w800))),
    );
  }

  void _abrirFormulario({Map<String, dynamic>? asesor}) {
    final esEdicion = asesor != null;
    final nombreCtrl = TextEditingController(text: asesor?['nombre'] ?? '');
    final paisCtrl = TextEditingController(text: asesor?['pais'] ?? '');
    final estadoCtrl = TextEditingController(text: asesor?['estado'] ?? '');
    final telefonoCtrl = TextEditingController(text: asesor?['telefono'] ?? '');
    final emailCtrl = TextEditingController(text: asesor?['email'] ?? '');
    final grupoCtrl = TextEditingController(text: asesor?['grupo'] ?? '');
    final inmobiliariaCtrl = TextEditingController(text: asesor?['inmobiliaria'] ?? '');
    final catalogoCtrl = TextEditingController(text: asesor?['catalogo'] ?? '');
    final especialidadCtrl = TextEditingController(text: asesor?['especialidad'] ?? '');
    final notasCtrl = TextEditingController(text: asesor?['notas'] ?? '');
    final comisionCtrl = TextEditingController(text: asesor?['comisionPorcentaje']?.toString() ?? '3.0');
    bool activo = asesor?['activo'] ?? true;
    String? fotoBase64 = asesor?['foto'];
    bool _cargandoFoto = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text(esEdicion ? 'Editar Asesor' : 'Nuevo Asesor', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () {
                    final fileInput = html.FileUploadInputElement()..accept = 'image/*'..click();
                    fileInput.onChange.listen((e) {
                      final files = fileInput.files;
                      if (files != null && files.isNotEmpty) {
                        final file = files.first;
                        final reader = html.FileReader();
                        setDialogState(() => _cargandoFoto = true);
                        reader.onLoadEnd.listen((e) async {
                          try {
                            final originalBase64 = reader.result as String;
                            final img = html.ImageElement()..src = originalBase64;
                            await img.onLoad.first;
                            final canvas = html.CanvasElement()..width = 200..height = 200;
                            final ctx = canvas.context2D;
                            ctx.drawImageScaledFromSource(img, 0, 0, img.width!, img.height!, 0, 0, 200, 200);
                            final compressedBase64 = canvas.toDataUrl('image/jpeg', 0.7);
                            setDialogState(() { fotoBase64 = compressedBase64; _cargandoFoto = false; });
                          } catch (err) {
                            setDialogState(() { fotoBase64 = null; _cargandoFoto = false; });
                          }
                        });
                        reader.readAsDataUrl(file);
                      }
                    });
                  },
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: AppTheme.getBackgroundColor(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.getBorderColor(context))),
                    child: _cargandoFoto
                        ? const Center(child: CircularProgressIndicator())
                        : fotoBase64 != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(base64Decode(fotoBase64!.split(',').last), width: 100, height: 100, fit: BoxFit.cover))
                            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 32, color: AppTheme.getTextSecondaryColor(context)), const SizedBox(height: 4), Text('Subir foto', style: TextStyle(fontSize: 10, color: AppTheme.getTextSecondaryColor(context)))]),
                  ),
                ),
                if (fotoBase64 != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(onPressed: () { setDialogState(() { fotoBase64 = null; }); }, icon: const Icon(Icons.delete, size: 16, color: Color(0xFFEF4444)), label: const Text('Quitar foto', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12))),
                ],
                const SizedBox(height: 16),
                IOSInput(controller: nombreCtrl, label: 'Nombre *'),
                const SizedBox(height: 8),
                IOSInput(controller: paisCtrl, label: 'País'),
                const SizedBox(height: 8),
                IOSInput(controller: estadoCtrl, label: 'Estado'),
                const SizedBox(height: 8),
                IOSInput(controller: telefonoCtrl, label: 'Teléfono', keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                IOSInput(controller: emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 8),
                IOSInput(controller: inmobiliariaCtrl, label: 'Inmobiliaria'),
                const SizedBox(height: 8),
                IOSInput(controller: grupoCtrl, label: 'Grupo/Equipo'),
                const SizedBox(height: 8),
                IOSInput(controller: catalogoCtrl, label: 'Catálogo'),
                const SizedBox(height: 8),
                IOSInput(controller: especialidadCtrl, label: 'Especialidad'),
                const SizedBox(height: 8),
                IOSInput(controller: notasCtrl, label: 'Notas', maxLines: 3),
                const SizedBox(height: 8),
                IOSInput(controller: comisionCtrl, label: 'Comisión (%)', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                SwitchListTile(title: const Text('Activo'), value: activo, onChanged: (value) { setDialogState(() { activo = value; }); }, contentPadding: EdgeInsets.zero),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ El nombre es obligatorio'), backgroundColor: Color(0xFFF59E0B)));
                  return;
                }
                final datos = {
                  'nombre': nombreCtrl.text, 'pais': paisCtrl.text, 'estado': estadoCtrl.text,
                  'telefono': telefonoCtrl.text, 'email': emailCtrl.text, 'inmobiliaria': inmobiliariaCtrl.text,
                  'grupo': grupoCtrl.text, 'catalogo': catalogoCtrl.text, 'especialidad': especialidadCtrl.text,
                  'notas': notasCtrl.text, 'comisionPorcentaje': double.tryParse(comisionCtrl.text) ?? 3.0,
                  'activo': activo, 'foto': fotoBase64,
                };
                try {
                  if (esEdicion && asesor != null) {
                    await AsesoresService.actualizarAsesor(asesor['id'], datos);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Asesor actualizado'), backgroundColor: Color(0xFF10B981)));
                  } else {
                    await AsesoresService.agregarAsesor(datos);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Asesor creado'), backgroundColor: Color(0xFF10B981)));
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
        title: Text('¿Eliminar asesor?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await AsesoresService.eliminarAsesor(id);
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

  void _gestionarGrupos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Gestionar Grupos', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: SizedBox(width: double.maxFinite, child: StatefulBuilder(
          builder: (ctx, setDialogState) => FutureBuilder<List<String>>(
            future: AsesoresService.getGrupos(),
            builder: (ctx, snapshot) {
              final grupos = snapshot.data ?? [];
              return Column(mainAxisSize: MainAxisSize.min, children: [
                if (grupos.isEmpty) const Text('No hay grupos creados', style: TextStyle(color: Color(0xFF64748B)))
                else ...grupos.map((grupo) => ListTile(
                  title: Text(grupo, style: TextStyle(color: AppTheme.getTextColor(context))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                    onPressed: () async {
                      await AsesoresService.eliminarGrupo(grupo);
                      setDialogState(() {});
                      await _cargarDatos();
                    },
                  ),
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(),
                  decoration: const InputDecoration(labelText: 'Nuevo grupo', border: OutlineInputBorder()),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      await AsesoresService.agregarGrupo(value);
                      setDialogState(() {});
                      await _cargarDatos();
                    }
                  },
                ),
              ]);
            },
          ),
        )),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
      ),
    );
  }

  void _importarAsesores() {
    final fileInput = html.FileUploadInputElement()..accept = '.json'..click();
    fileInput.onChange.listen((e) async {
      final files = fileInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) async {
          try {
            final datos = jsonDecode(reader.result as String);
            List<dynamic> asesoresArray = [];
            if (datos is List) {
              asesoresArray = datos;
            } else if (datos is Map) {
              final clavesPosibles = ['asesores', 'asesores_datos', 'asesores_data', 'lista_asesores', 'asesores_list'];
              for (var clave in clavesPosibles) {
                if (datos.containsKey(clave) && datos[clave] is List) { asesoresArray = datos[clave]; break; }
              }
            }
            if (asesoresArray.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ No se encontraron asesores'), backgroundColor: Color(0xFFF59E0B)));
              return;
            }
            final asesores = asesoresArray.map((a) => Map<String, dynamic>.from(a as Map)).toList();
            for (var asesor in asesores) {
              if (!asesor.containsKey('id')) asesor['id'] = DateTime.now().millisecondsSinceEpoch.toString();
              if (!asesor.containsKey('activo')) asesor['activo'] = true;
              if (!asesor.containsKey('ventas')) asesor['ventas'] = 0;
              if (!asesor.containsKey('comisiones')) asesor['comisiones'] = 0.0;
              if (!asesor.containsKey('comisionPorcentaje')) asesor['comisionPorcentaje'] = 3.0;
            }
            await AsesoresService.guardarAsesores(asesores);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${asesores.length} asesores importados'), backgroundColor: const Color(0xFF10B981)));
            await _cargarDatos();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)));
          }
        });
        reader.readAsText(file);
      }
    });
  }

  List<Map<String, dynamic>> _getAsesoresFiltrados() {
    var asesores = _asesores;
    if (_grupoFiltro != 'Todos') asesores = asesores.where((a) => (a['grupo'] ?? '') == _grupoFiltro).toList();
    if (_inmobiliariaFiltro != 'Todas') asesores = asesores.where((a) => (a['inmobiliaria'] ?? '') == _inmobiliariaFiltro).toList();
    if (_busqueda.isNotEmpty) asesores = asesores.where((a) => (a['nombre'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) || (a['inmobiliaria'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) || (a['grupo'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase())).toList();
    return asesores;
  }

  List<String> _getGruposDisponibles() => _grupos;

  List<String> _getInmobiliariasDisponibles() {
    return _asesores.map((a) => (a['inmobiliaria'] ?? 'Sin inmobiliaria').toString()).toSet().toList();
  }
}