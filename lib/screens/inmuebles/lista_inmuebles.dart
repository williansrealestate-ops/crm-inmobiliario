import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/inmuebles_supabase_service.dart'; // ✅ CAMBIADO A SUPABASE
import '../../services/asesores_service.dart';
import '../../widgets/searchable_dropdown.dart';

class ListaInmuebles extends StatefulWidget {
  const ListaInmuebles({super.key});

  @override
  State<ListaInmuebles> createState() => _ListaInmueblesState();
}

class _ListaInmueblesState extends State<ListaInmuebles> {
  String _tipoFiltro = 'Todos';
  String _busqueda = '';
  String _asesorFiltro = 'Todos';
  
  List<Map<String, dynamic>> _inmuebles = [];
  List<Map<String, dynamic>> _asesores = [];
  List<String> _tipos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      _inmuebles = await InmueblesSupabaseService.getInmuebles(); // ✅ SUPABASE
      _asesores = await AsesoresService.getAsesores();
      _tipos = await InmueblesSupabaseService.getTipos(); // ✅ SUPABASE
    } catch (e) {
      print('Error al cargar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inmuebles = _getInmueblesFiltrados();
    final tiposFiltro = ['Todos', ..._tipos];

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.home, color: Colors.white), SizedBox(width: 8), Text('Inmuebles')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.upload), onPressed: _importarInmuebles, tooltip: 'Importar inmuebles'),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _mostrarDialogoInmueble(),
              tooltip: 'Nuevo inmueble',
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context)))),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) => setState(() => _busqueda = value),
                        decoration: InputDecoration(
                          hintText: 'Buscar por título, ubicación o asesor...',
                          hintStyle: TextStyle(color: AppTheme.getTextTertiaryColor(context)),
                          prefixIcon: Icon(Icons.search, color: AppTheme.getTextSecondaryColor(context)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: AppTheme.getBackgroundColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tiposFiltro.map((tipo) {
                            final isSelected = _tipoFiltro == tipo;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(tipo, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppTheme.getTextColor(context))),
                                selected: isSelected,
                                onSelected: (selected) => setState(() => _tipoFiltro = tipo),
                                backgroundColor: AppTheme.getBackgroundColor(context),
                                selectedColor: AppTheme.primary,
                                checkmarkColor: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_asesores.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: _asesorFiltro,
                          decoration: InputDecoration(
                            labelText: 'Filtrar por asesor',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: AppTheme.getBackgroundColor(context),
                          ),
                          items: ['Todos', ..._asesores.map((a) => a['nombre'].toString())].map((a) => DropdownMenuItem<String>(value: a, child: Text(a))).toList(),
                          onChanged: (value) => setState(() => _asesorFiltro = value ?? 'Todos'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: inmuebles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_work, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No hay inmuebles disponibles', style: TextStyle(fontSize: 16, color: AppTheme.getTextSecondaryColor(context))),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(onPressed: () => _mostrarDialogoInmueble(), icon: const Icon(Icons.add), label: const Text('Agregar inmueble')),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: inmuebles.length,
                          itemBuilder: (context, index) => _buildInmuebleCard(inmuebles[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildInmuebleCard(Map<String, dynamic> inmueble) {
    final tipo = (inmueble['tipo'] ?? 'Casa').toString();
    final colorTipo = _getColorPorTipo(tipo);
    final iconoTipo = _getIconoPorTipo(tipo);
    final precioRaw = inmueble['precio'];
    double precio = 0;
    if (precioRaw is num) {
      precio = precioRaw.toDouble();
    } else if (precioRaw is String) {
      precio = double.tryParse(precioRaw.replaceAll(',', '')) ?? 0;
    }
    final titulo = (inmueble['titulo'] ?? 'Sin título').toString();
    final ubicacion = (inmueble['ubicacion'] ?? 'Sin ubicación').toString();
    final recamaras = _toInt(inmueble['recamaras']);
    final banos = _toInt(inmueble['banos']);
    final area = _toDouble(inmueble['area']);
    final asesor = inmueble['asesor'] ?? '';
    final tieneCoordenadas = _toDouble(inmueble['latitud']) != 0;
    final fotos = (inmueble['fotos'] as List?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorTipo.withOpacity(0.15), colorTipo.withOpacity(0.05)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: colorTipo.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(iconoTipo, color: colorTipo, size: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(tieneCoordenadas ? Icons.location_on : Icons.location_off, size: 14, color: tieneCoordenadas ? AppTheme.getTextSecondaryColor(context) : const Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(ubicacion, style: TextStyle(fontSize: 12, color: tieneCoordenadas ? AppTheme.getTextSecondaryColor(context) : const Color(0xFFEF4444)), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      if (asesor.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(children: [Icon(Icons.person, size: 14, color: const Color(0xFF8B5CF6)), const SizedBox(width: 4), Expanded(child: Text('Asesor: $asesor', style: TextStyle(fontSize: 12, color: const Color(0xFF8B5CF6), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))]),
                      ],
                    ],
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: colorTipo, borderRadius: BorderRadius.circular(20)), child: Text(tipo, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (recamaras > 0) ...[_buildCaracteristica(Icons.bed, '$recamaras Rec.'), const SizedBox(width: 16)],
                  if (banos > 0) ...[_buildCaracteristica(Icons.bathtub, '$banos Baños'), const SizedBox(width: 16)],
                  if (area > 0) _buildCaracteristica(Icons.square_foot, '${area.toInt()} m²'),
                  if (fotos.isNotEmpty) ...[const SizedBox(width: 16), _buildCaracteristica(Icons.photo, '${fotos.length} fotos')],
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.attach_money, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(_formatearMoneda(precio), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                ]),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildActionButton(icon: Icons.edit, label: 'Editar', color: const Color(0xFF3B82F6), onPressed: () => _mostrarDialogoInmueble(inmueble: inmueble))),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3))),
                      child: IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFEF4444)), onPressed: () => _confirmarEliminar(inmueble), tooltip: 'Eliminar inmueble', padding: const EdgeInsets.all(10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristica(IconData icono, String texto) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icono, size: 16, color: AppTheme.getTextSecondaryColor(context)), const SizedBox(width: 4), Text(texto, style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context), fontWeight: FontWeight.w600))]);
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))]),
      ),
    );
  }

  void _mostrarDialogoInmueble({Map<String, dynamic>? inmueble}) {
    final esEdicion = inmueble != null;
    final tituloCtrl = TextEditingController(text: inmueble?['titulo'] ?? '');
    final tipoCtrl = TextEditingController(text: inmueble?['tipo'] ?? 'Casa');
    final ubicacionCtrl = TextEditingController(text: inmueble?['ubicacion'] ?? '');
    final precioCtrl = TextEditingController(text: inmueble?['precio']?.toString() ?? '');
    final recamarasCtrl = TextEditingController(text: inmueble?['recamaras']?.toString() ?? '0');
    final banosCtrl = TextEditingController(text: inmueble?['banos']?.toString() ?? '0');
    final areaCtrl = TextEditingController(text: inmueble?['area']?.toString() ?? '0');
    final descripcionCtrl = TextEditingController(text: inmueble?['descripcion'] ?? '');
    final videoUrlCtrl = TextEditingController(text: inmueble?['videoUrl'] ?? '');
    final latitudCtrl = TextEditingController(text: inmueble?['latitud']?.toString() ?? '');
    final longitudCtrl = TextEditingController(text: inmueble?['longitud']?.toString() ?? '');
    String asesorSeleccionado = inmueble?['asesor'] ?? '';
    
    List<String> fotosTemp = List<String>.from((inmueble?['fotos'] as List?)?.cast<String>() ?? []);
    
    bool _geocodificando = false;
    String _geocodificacionMsg = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(esEdicion ? Icons.edit : Icons.add_home, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        esEdicion ? 'Editar Inmueble' : 'Nuevo Inmueble',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDarkField(tituloCtrl, 'Título *', Icons.title),
                  const SizedBox(height: 16),
                  _buildDarkDropdown(
                    tipoCtrl.text,
                    'Tipo de propiedad',
                    Icons.category,
                    _tipos.isEmpty ? ['Casa', 'Departamento', 'Terreno', 'Local', 'Oficina', 'Hacienda', 'Gasolinera'] : _tipos,
                    (value) => setDialogState(() => tipoCtrl.text = value ?? 'Casa'),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: ubicacionCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Ubicación (ciudad, estado, país)',
                              labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                              prefixIcon: const Icon(Icons.location_on, color: Colors.white54, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              if (_geocodificacionMsg.isNotEmpty) {
                                setDialogState(() => _geocodificacionMsg = '');
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _geocodificando ? Colors.grey : const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: _geocodificando 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.search, color: Colors.white),
                          onPressed: _geocodificando ? null : () async {
                            if (ubicacionCtrl.text.trim().isEmpty) {
                              setDialogState(() => _geocodificacionMsg = '⚠️ Ingresa una ubicación primero');
                              return;
                            }
                            setDialogState(() {
                              _geocodificando = true;
                              _geocodificacionMsg = ' Buscando coordenadas...';
                            });
                            try {
                              final url = 'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(ubicacionCtrl.text)}&limit=1';
                              final response = await html.HttpRequest.getString(url);
                              final data = jsonDecode(response) as List;
                              if (data.isNotEmpty) {
                                final lat = double.parse(data[0]['lat']);
                                final lng = double.parse(data[0]['lon']);
                                setDialogState(() {
                                  latitudCtrl.text = lat.toString();
                                  longitudCtrl.text = lng.toString();
                                  _geocodificacionMsg = '✅ Coordenadas: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
                                  _geocodificando = false;
                                });
                              } else {
                                setDialogState(() {
                                  _geocodificacionMsg = '❌ No se encontró la ubicación. Intenta ser más específico.';
                                  _geocodificando = false;
                                });
                              }
                            } catch (e) {
                              setDialogState(() {
                                _geocodificacionMsg = '⚠️ Error al buscar: $e';
                                _geocodificando = false;
                              });
                            }
                          },
                          tooltip: 'Buscar coordenadas automáticamente',
                        ),
                      ),
                    ],
                  ),
                  
                  if (_geocodificacionMsg.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _geocodificacionMsg,
                      style: TextStyle(
                        fontSize: 11,
                        color: _geocodificacionMsg.startsWith('✅') ? const Color(0xFF10B981) : 
                               _geocodificacionMsg.startsWith('❌') || _geocodificacionMsg.startsWith('⚠️') ? const Color(0xFFEF4444) : 
                               const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDarkField(latitudCtrl, 'Latitud', Icons.my_location, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDarkField(longitudCtrl, 'Longitud', Icons.my_location, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDarkField(precioCtrl, 'Precio (MXN)', Icons.attach_money, isNumber: true),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDarkField(recamarasCtrl, 'Recámaras', Icons.bed, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDarkField(banosCtrl, 'Baños', Icons.bathtub, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildDarkField(areaCtrl, 'Área (m² o has)', Icons.square_foot, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SearchableDropdown(
                      value: asesorSeleccionado.isEmpty ? 'Sin asesor asignado' : asesorSeleccionado,
                      hint: 'Asesor que trae la propiedad',
                      icon: Icons.person,
                      items: ['Sin asesor asignado', ..._asesores.map((a) => a['nombre'].toString()).toList()],
                      showAvatars: true,
                      avatarLetters: Map.fromEntries(
                        _asesores.map((a) => MapEntry(
                          a['nombre'].toString(),
                          a['nombre'].toString().isNotEmpty ? a['nombre'].toString().substring(0, 1).toUpperCase() : '?',
                        )),
                      ),
                      onChanged: (val) => setDialogState(() {
                        asesorSeleccionado = val == 'Sin asesor asignado' ? '' : val;
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  _buildDarkField(descripcionCtrl, 'Descripción', Icons.description, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildDarkField(videoUrlCtrl, 'URL de Video YouTube (opcional)', Icons.play_circle_outline),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.photo_library, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text('Fotos del inmueble (${fotosTemp.length}/10)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('📸 Subir fotos (máx. 10)', style: TextStyle(fontSize: 12, color: Colors.white54))),
                            if (fotosTemp.length < 10)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 20),
                                  onPressed: () async {
                                    final fileInput = html.FileUploadInputElement()
                                      ..accept = 'image/*'
                                      ..multiple = true
                                      ..click();
                                    
                                    fileInput.onChange.listen((e) async {
                                      final files = fileInput.files;
                                      if (files != null && files.isNotEmpty) {
                                        final restantes = 10 - fotosTemp.length;
                                        for (var file in files.take(restantes)) {
                                          final reader = html.FileReader();
                                          reader.readAsDataUrl(file);
                                          await reader.onLoad.first;
                                          final originalBase64 = reader.result as String;
                                          
                                          final img = html.ImageElement()..src = originalBase64;
                                          await img.onLoad.first;
                                          final canvas = html.CanvasElement()..width = 600..height = 600;
                                          final ctx = canvas.context2D;
                                          final scale = 600 / (img.width! > img.height! ? img.width! : img.height!);
                                          final w = (img.width! * scale).toInt();
                                          final h = (img.height! * scale).toInt();
                                          ctx.drawImageScaled(img, 0, 0, w, h);
                                          final compressed = canvas.toDataUrl('image/jpeg', 0.7);
                                          
                                          setDialogState(() => fotosTemp.add(compressed));
                                        }
                                      }
                                    });
                                  },
                                  tooltip: 'Agregar fotos',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (fotosTemp.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fotosTemp.length,
                              itemBuilder: (context, idx) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: MemoryImage(base64Decode(fotosTemp[idx].split(',').last)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => setDialogState(() => fotosTemp.removeAt(idx)),
                                        child: Container(
                                          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        else
                          const Text('Sin fotos', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.blue)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final precio = double.tryParse(precioCtrl.text.replaceAll(',', ''));
                          if (tituloCtrl.text.isEmpty || precio == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Título y precio son obligatorios'), backgroundColor: Color(0xFFF59E0B)));
                            return;
                          }
                          
                          final datos = {
                            'titulo': tituloCtrl.text,
                            'tipo': tipoCtrl.text,
                            'ubicacion': ubicacionCtrl.text,
                            'precio': precio,
                            'recamaras': int.tryParse(recamarasCtrl.text) ?? 0,
                            'banos': int.tryParse(banosCtrl.text) ?? 0,
                            'area': double.tryParse(areaCtrl.text) ?? 0,
                            'descripcion': descripcionCtrl.text,
                            'videoUrl': videoUrlCtrl.text,
                            'asesor': asesorSeleccionado,
                            'latitud': double.tryParse(latitudCtrl.text),
                            'longitud': double.tryParse(longitudCtrl.text),
                            'fotos': fotosTemp,
                          };
                          
                          try {
                            if (inmueble == null) {
                              await InmueblesSupabaseService.agregarInmueble(datos); // ✅ SUPABASE
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Inmueble creado correctamente'), backgroundColor: Color(0xFF10B981)));
                            } else {
                              await InmueblesSupabaseService.actualizarInmueble(inmueble['id'], datos); // ✅ SUPABASE
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Inmueble actualizado correctamente'), backgroundColor: Color(0xFF10B981)));
                            }
                            Navigator.pop(dialogContext);
                            await _cargarDatos();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
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

  Widget _buildDarkField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDarkDropdown(String value, String label, IconData icon, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2C2C2E),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: items.map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(color: Colors.white)),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> inmueble) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar inmueble?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: Text('¿Estás seguro de eliminar "${inmueble['titulo']}"?', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await InmueblesSupabaseService.eliminarInmueble(inmueble['id']); // ✅ SUPABASE
                Navigator.pop(ctx);
                await _cargarDatos();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Inmueble eliminado'), backgroundColor: Color(0xFF10B981)));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _importarInmuebles() {
    final fileInput = html.FileUploadInputElement()..accept = '.json'..click();
    fileInput.onChange.listen((e) async {
      final files = fileInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) async {
          try {
            final contenido = jsonDecode(reader.result as String);
            List<dynamic> inmueblesArray = [];
            
            if (contenido is List) {
              inmueblesArray = contenido;
            } else if (contenido is Map) {
              final clavesPosibles = ['inmuebles', 'inmuebles_datos', 'inmuebles_data', 'lista_inmuebles', 'propiedades'];
              for (var clave in clavesPosibles) {
                if (contenido.containsKey(clave) && contenido[clave] is List) {
                  inmueblesArray = contenido[clave];
                  break;
                }
              }
            }
            
            if (inmueblesArray.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚠️ No se encontraron inmuebles en el archivo'),
                  backgroundColor: Color(0xFFF59E0B),
                ),
              );
              return;
            }
            
            final inmuebles = inmueblesArray.map((i) {
              final inmuebleMap = Map<String, dynamic>.from(i as Map);
              return {
                'titulo': inmuebleMap['titulo'] ?? inmuebleMap['title'] ?? 'Sin título',
                'tipo': inmuebleMap['tipo'] ?? inmuebleMap['type'] ?? 'Casa',
                'ubicacion': inmuebleMap['ubicacion'] ?? inmuebleMap['location'] ?? '',
                'precio': _toDouble(inmuebleMap['precio'] ?? inmuebleMap['price'] ?? 0),
                'recamaras': _toInt(inmuebleMap['recamaras'] ?? inmuebleMap['bedrooms'] ?? 0),
                'banos': _toInt(inmuebleMap['banos'] ?? inmuebleMap['bathrooms'] ?? 0),
                'area': _toDouble(inmuebleMap['area'] ?? inmuebleMap['surface'] ?? 0),
                'descripcion': inmuebleMap['descripcion'] ?? inmuebleMap['description'] ?? '',
                'videoUrl': inmuebleMap['videoUrl'] ?? inmuebleMap['video_url'] ?? '',
                'asesor': inmuebleMap['asesor'] ?? inmuebleMap['agent'] ?? '',
                'latitud': inmuebleMap['latitud'] ?? inmuebleMap['lat'],
                'longitud': inmuebleMap['longitud'] ?? inmuebleMap['lng'] ?? inmuebleMap['lon'],
                'fotos': inmuebleMap['fotos'] ?? inmuebleMap['photos'] ?? [],
                'tipo_negocio': inmuebleMap['tipo_negocio'] ?? 'Inmobiliario',
              };
            }).toList();
            
            final confirmado = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.getSurfaceColor(context),
                title: const Text('Confirmar importación', style: TextStyle(color: Colors.white)),
                content: Text(
                  'Se importarán ${inmuebles.length} inmuebles. ¿Deseas continuar?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    child: const Text('Importar'),
                  ),
                ],
              ),
            );
            
            if (confirmado != true) return;
            
            int exitosos = 0;
            int errores = 0;
            
            for (var inmueble in inmuebles) {
              try {
                await InmueblesSupabaseService.agregarInmueble(inmueble); // ✅ SUPABASE
                exitosos++;
              } catch (e) {
                print('Error al importar inmueble ${inmueble['titulo']}: $e');
                errores++;
              }
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ $exitosos inmuebles importados' + (errores > 0 ? ' ($errores errores)' : '')),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
            
            await _cargarDatos();
            
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error al importar: $e'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        });
        reader.readAsText(file);
      }
    });
  }

  List<Map<String, dynamic>> _getInmueblesFiltrados() {
    var inmuebles = _inmuebles;
    if (_tipoFiltro != 'Todos') {
      inmuebles = inmuebles.where((i) => (i['tipo'] ?? '') == _tipoFiltro).toList();
    }
    if (_asesorFiltro != 'Todos') {
      inmuebles = inmuebles.where((i) => (i['asesor'] ?? '') == _asesorFiltro).toList();
    }
    if (_busqueda.isNotEmpty) {
      inmuebles = inmuebles.where((i) =>
        (i['titulo'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
        (i['ubicacion'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
        (i['asesor'] ?? '').toString().toLowerCase().contains(_busqueda.toLowerCase())
      ).toList();
    }
    return inmuebles;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  String _formatearMoneda(double precio) {
    if (precio >= 1000000) return '\$${(precio / 1000000).toStringAsFixed(2)} MDP';
    if (precio >= 1000) return '\$${(precio / 1000).toStringAsFixed(0)} K';
    return '\$${precio.toStringAsFixed(0)}';
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return const Color(0xFF3B82F6);
      case 'departamento': return const Color(0xFF8B5CF6);
      case 'terreno': return const Color(0xFFF59E0B);
      case 'local': return const Color(0xFF10B981);
      case 'oficina': return const Color(0xFFEC4899);
      case 'hacienda': return const Color(0xFF64748B);
      case 'gasolinera': return const Color(0xFF06B6D4);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'casa': return Icons.home;
      case 'departamento': return Icons.apartment;
      case 'terreno': return Icons.landscape;
      case 'local': return Icons.storefront;
      case 'oficina': return Icons.business;
      case 'hacienda': return Icons.agriculture;
      case 'gasolinera': return Icons.local_gas_station;
      default: return Icons.home_work;
    }
  }
}