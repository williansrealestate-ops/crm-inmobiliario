import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/plantillas_service.dart';
import '../../services/gamificacion_service.dart';

class GeneradorDocumentosScreen extends StatefulWidget {
  const GeneradorDocumentosScreen({super.key});

  @override
  State<GeneradorDocumentosScreen> createState() => _GeneradorDocumentosScreenState();
}

class _GeneradorDocumentosScreenState extends State<GeneradorDocumentosScreen> {
  Map<String, dynamic>? _plantillaSeleccionada;
  final Map<String, TextEditingController> _controladores = {};

  @override
  void dispose() {
    for (var c in _controladores.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _seleccionarPlantilla(Map<String, dynamic> plantilla) {
    setState(() {
      _plantillaSeleccionada = plantilla;
      _controladores.clear();
      for (var campo in plantilla['campos'] as List) {
        _controladores[campo['id']] = TextEditingController();
      }
    });
  }

  void _generarDocumento() {
    final datos = <String, String>{};
    _controladores.forEach((key, ctrl) {
      datos[key] = ctrl.text;
    });

    final documento = PlantillasService.generarDocumento(_plantillaSeleccionada!['id'], datos);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('📄 ${_plantillaSeleccionada!['nombre']}'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Text(documento, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ElevatedButton.icon(
            onPressed: () {
              html.window.navigator.clipboard?.writeText(documento);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Documento copiado al portapapeles'), backgroundColor: Color(0xFF10B981)));
              
              final resultado = GamificacionService.registrarDocumentoCreado();
              if (resultado['badgesNuevos'] != null && (resultado['badgesNuevos'] as List).isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _mostrarBadgeDesbloqueado((resultado['badgesNuevos'] as List).cast<Map<String, dynamic>>());
                });
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _mostrarBadgeDesbloqueado(List<Map<String, dynamic>> badges) {
    for (var badge in badges) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(' ¡Badge Desbloqueado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge['icono'] ?? '🏅', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(badge['nombre'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(badge['descripcion'] ?? '', style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white), child: const Text('¡Genial!')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.description, color: Colors.white), SizedBox(width: 8), Text('Generador de Documentos')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _plantillaSeleccionada == null ? _buildListaPlantillas() : _buildFormulario(),
    );
  }

  Widget _buildListaPlantillas() {
    final plantillas = PlantillasService.getPlantillas();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝 Selecciona una plantilla', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Genera documentos profesionales en segundos', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 16),
          ...plantillas.map((p) {
            final color = Color(int.parse(p['color']));
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(p['icono'], style: const TextStyle(fontSize: 24)))),
                title: Text(p['nombre'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                subtitle: Text(p['descripcion'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _seleccionarPlantilla(p),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    final campos = _plantillaSeleccionada!['campos'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _plantillaSeleccionada = null)),
              Expanded(child: Text(_plantillaSeleccionada!['nombre'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Completa los campos para generar tu documento:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 16),
          ...campos.map((campo) {
            final ctrl = _controladores[campo['id']]!;
            final esLargo = campo['tipo'] == 'texto_largo';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: ctrl,
                maxLines: esLargo ? 4 : 1,
                decoration: InputDecoration(
                  labelText: campo['label'],
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generarDocumento,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar Documento', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}