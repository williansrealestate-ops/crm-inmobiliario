import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class GuionesScreen extends StatefulWidget {
  final String? busqueda;
  const GuionesScreen({super.key, this.busqueda});

  @override
  State<GuionesScreen> createState() => _GuionesScreenState();
}

class _GuionesScreenState extends State<GuionesScreen> {
  List<Map<String, dynamic>> _guiones = [];

  @override
  void initState() {
    super.initState();
    _cargarGuiones();
  }

  void _cargarGuiones() {
    setState(() { _guiones = LocalStorageService.getGuiones(); });
  }

  List<Map<String, dynamic>> get _guionesFiltrados {
    final busquedaActiva = widget.busqueda ?? '';
    if (busquedaActiva.isEmpty) return _guiones;
    return _guiones.where((g) {
      final texto = '${g['titulo']} ${g['contenido'] ?? ''}'.toLowerCase();
      return texto.contains(busquedaActiva.toLowerCase());
    }).toList();
  }

  void _mostrarFormularioGuion({Map<String, dynamic>? guion}) {
    final esEditar = guion != null;
    final tituloCtrl = TextEditingController(text: guion?['titulo'] ?? '');
    final contenidoCtrl = TextEditingController(text: guion?['contenido'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEditar ? 'Editar Guion' : 'Nuevo Guion'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(controller: contenidoCtrl, decoration: const InputDecoration(labelText: 'Contenido'), maxLines: 10),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            final datos = {'titulo': tituloCtrl.text, 'contenido': contenidoCtrl.text};
            if (esEditar) { LocalStorageService.actualizarGuion(guion!['id'].toString(), {...datos, 'id': guion['id'].toString()}); } else { LocalStorageService.agregarGuion(datos); }
            Navigator.pop(ctx);
            _cargarGuiones();
          }, child: Text(esEditar ? 'Guardar' : 'Agregar')),
        ],
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> guion) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Eliminar Guion'), content: Text('¿Estás seguro de eliminar "${guion['titulo']}"?'), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
      ElevatedButton(onPressed: () { LocalStorageService.eliminarGuion(guion['id'].toString()); Navigator.pop(ctx); _cargarGuiones(); }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger), child: const Text('Eliminar')),
    ]));
  }

  void _copiarGuion(Map<String, dynamic> guion) {
    Clipboard.setData(ClipboardData(text: '${guion['titulo']}\n\n${guion['contenido'] ?? ''}'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Guion copiado al portapapeles'), backgroundColor: AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Guiones', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))), const SizedBox(height: 4), Text('Scripts de ventas y seguimiento', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 14))])),
              const SizedBox(width: 12),
              ElevatedButton.icon(onPressed: () => _mostrarFormularioGuion(), icon: const Icon(Icons.add, size: 18), label: const Text('Nuevo Guion'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white)),
            ]),
            const SizedBox(height: 24),
            if (widget.busqueda != null && widget.busqueda!.isNotEmpty) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Text('Buscando: "${widget.busqueda}"', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600))])),
              const SizedBox(height: 16),
            ],
            if (_guionesFiltrados.isEmpty)
              Card(child: Padding(padding: const EdgeInsets.all(60), child: Center(child: Column(children: [Icon(Icons.article, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('No hay guiones', style: TextStyle(color: Colors.grey, fontSize: 16))]))))
            else
              ..._guionesFiltrados.map((g) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withOpacity(0.2))), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(g['titulo'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.getTextPrimaryColor(context)))), IconButton(icon: const Icon(Icons.copy, color: AppTheme.primary, size: 20), onPressed: () => _copiarGuion(g), tooltip: 'Copiar guion'), IconButton(icon: const Icon(Icons.edit, color: AppTheme.primary, size: 20), onPressed: () => _mostrarFormularioGuion(guion: g)), IconButton(icon: const Icon(Icons.delete, color: AppTheme.danger, size: 20), onPressed: () => _confirmarEliminar(g))]),
                const SizedBox(height: 8),
                Text(g['contenido'] ?? '', style: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13, height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
              ])))).toList(),
          ],
        ),
      ),
    );
  }
}