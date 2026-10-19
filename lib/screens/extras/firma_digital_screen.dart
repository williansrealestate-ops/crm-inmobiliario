import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../config/theme.dart';
import '../../services/firma_digital_service.dart';

// ✅ CORREGIDO: SIN 'required this.titulo'
class FirmaDigitalScreen extends StatefulWidget {
  const FirmaDigitalScreen({super.key});

  @override
  State<FirmaDigitalScreen> createState() => _FirmaDigitalScreenState();
}

class _FirmaDigitalScreenState extends State<FirmaDigitalScreen> with SingleTickerProviderStateMixin {
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
        title: const Row(children: [Icon(Icons.edit_note, color: Colors.white), SizedBox(width: 8), Text('Firma Digital')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _crearNuevoDocumento(),
            tooltip: 'Nuevo documento',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Documentos'),
            Tab(text: 'Firmar'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabDocumentos(),
          _buildTabFirmar(),
          _buildTabHistorial(),
        ],
      ),
    );
  }

  Widget _buildTabDocumentos() {
    final documentos = FirmaDigitalService.getDocumentos();
    final stats = FirmaDigitalService.getEstadisticas();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('${stats['total']}', 'Total', Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('${stats['pendientes']}', 'Pendientes', Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('${stats['firmados']}', 'Firmados', Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Documentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (documentos.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No hay documentos', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _crearNuevoDocumento(), 
                    icon: const Icon(Icons.add), 
                    label: const Text('Crear documento')
                  ),
                ],
              ),
            )
          else
            ...documentos.map((doc) => _buildDocumentoCard(doc)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String valor, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(valor, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDocumentoCard(Map<String, dynamic> doc) {
    final tipo = FirmaDigitalService.tiposDocumento.firstWhere(
      (t) => t['id'] == doc['tipoDocumento'], 
      orElse: () => {'nombre': 'Documento', 'icono': '📄'}
    );
    final estado = doc['estado'] ?? 'borrador';
    final colorEstado = _getColorEstado(estado);
    final iconoEstado = _getIconoEstado(estado);
    final fecha = doc['fechaCreacion'] != null ? DateTime.parse(doc['fechaCreacion']) : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorEstado.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(tipo['icono'], style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tipo['nombre'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                    Text('${fecha.day}/${fecha.month}/${fecha.year}', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconoEstado, size: 12, color: colorEstado),
                    const SizedBox(width: 4),
                    Text(estado.toUpperCase().replaceAll('_', ' '), style: TextStyle(fontSize: 9, color: colorEstado, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _verDocumento(doc),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Ver', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              if (estado != 'firmado')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _irAFirmar(doc),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Firmar', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)), 
                onPressed: () => _confirmarEliminar(doc)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabFirmar() {
    return _FirmaCanvasScreen(onFirmaCompletada: () {
      setState(() {});
      _tabController.index = 0;
    });
  }

  Widget _buildTabHistorial() {
    final firmados = FirmaDigitalService.getDocumentosPorEstado('firmado');

    if (firmados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No hay documentos firmados', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: firmados.length,
      itemBuilder: (context, index) {
        final doc = firmados[firmados.length - 1 - index];
        final tipo = FirmaDigitalService.tiposDocumento.firstWhere(
          (t) => t['id'] == doc['tipoDocumento'], 
          orElse: () => {'nombre': 'Documento', 'icono': '📄'}
        );
        final fechaFirma = doc['fechaFirma'] != null ? DateTime.parse(doc['fechaFirma']) : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tipo['nombre'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text('Firmado por: ${doc['nombreFirmante'] ?? 'Anónimo'}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        if (fechaFirma != null)
                          Text('${fechaFirma.day}/${fechaFirma.month}/${fechaFirma.year} ${fechaFirma.hour}:${fechaFirma.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
              if (doc['firmaBase64'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.getBackgroundColor(context), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Firma digital:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Image.network(doc['firmaBase64'], height: 60, fit: BoxFit.contain),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _verDocumento(doc),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver documento', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _descargarDocumento(doc),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Descargar', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _crearNuevoDocumento() {
    String tipoDocumento = 'contrato_compraventa';
    final campos = <String, TextEditingController>{};
    final camposRequeridos = {'direccion': 'Dirección del inmueble', 'precio': 'Precio'};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text('Nuevo Documento', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipoDocumento,
                  decoration: const InputDecoration(labelText: 'Tipo de documento', border: OutlineInputBorder()),
                  items: FirmaDigitalService.tiposDocumento.map((t) => DropdownMenuItem<String>(value: t['id'] as String, child: Text('${t['icono']} ${t['nombre']}'))).toList(),
                  onChanged: (value) => setState(() => tipoDocumento = value ?? 'contrato_compraventa'),
                ),
                const SizedBox(height: 12),
                ...camposRequeridos.entries.map((entry) {
                  final controller = TextEditingController();
                  campos[entry.key] = controller;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(controller: controller, decoration: InputDecoration(labelText: entry.value, border: const OutlineInputBorder())),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final datos = {
                  'tipoDocumento': tipoDocumento,
                  'direccion': campos['direccion']?.text ?? '',
                  'precio': campos['precio']?.text ?? '',
                };
                FirmaDigitalService.crearDocumento(datos);
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _verDocumento(Map<String, dynamic> doc) {
    final contenido = FirmaDigitalService.generarContenidoDocumento(doc);
    final tipo = FirmaDigitalService.tiposDocumento.firstWhere(
      (t) => t['id'] == doc['tipoDocumento'], 
      orElse: () => {'nombre': 'Documento', 'icono': ''}
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('${tipo['icono']} ${tipo['nombre']}', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: SizedBox(
          width: 600,
          height: 500,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context), 
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: AppTheme.getBorderColor(context))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contenido, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.getTextColor(context))),
                  if (doc['firmaBase64'] != null) ...[
                    const Divider(),
                    const Text('FIRMA:', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Image.network(doc['firmaBase64'], height: 80),
                    const SizedBox(height: 8),
                    Text('Firmado por: ${doc['nombreFirmante']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
      ),
    );
  }

  void _irAFirmar(Map<String, dynamic> doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FirmaCanvasScreen(
          documentoId: doc['id'],
          onFirmaCompletada: () {
            setState(() {});
            _tabController.index = 0;
          },
        ),
      ),
    );
  }

  void _descargarDocumento(Map<String, dynamic> doc) {
    final contenido = FirmaDigitalService.generarContenidoDocumento(doc);
    final blob = html.Blob([contenido], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'documento_${doc['id']}.txt')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Documento descargado'), backgroundColor: Color(0xFF10B981)));
  }

  void _confirmarEliminar(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar documento?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              FirmaDigitalService.eliminarDocumento(doc['id']);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'borrador': return const Color(0xFF64748B);
      case 'pendiente_firma': return const Color(0xFFF59E0B);
      case 'firmado': return const Color(0xFF10B981);
      case 'cancelado': return const Color(0xFFEF4444);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getIconoEstado(String estado) {
    switch (estado) {
      case 'borrador': return Icons.edit;
      case 'pendiente_firma': return Icons.pending;
      case 'firmado': return Icons.check_circle;
      case 'cancelado': return Icons.cancel;
      default: return Icons.circle;
    }
  }
}

// ============================================
// WIDGET DE CANVAS PARA FIRMA
// ============================================

class _FirmaCanvasScreen extends StatefulWidget {
  final String? documentoId;
  final VoidCallback? onFirmaCompletada;

  const _FirmaCanvasScreen({this.documentoId, this.onFirmaCompletada});

  @override
  State<_FirmaCanvasScreen> createState() => _FirmaCanvasScreenState();
}

class _FirmaCanvasScreenState extends State<_FirmaCanvasScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF0D1B4C),
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.edit, color: Colors.white), SizedBox(width: 8), Text('Firmar Documento')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.edit_note, color: Colors.white, size: 28), SizedBox(width: 12), Text('Firma Digital', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))]),
                  SizedBox(height: 8),
                  Text('Dibuja tu firma en el área de abajo', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo del firmante', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 20),
            const Text('Área de firma:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              height: 250,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB), width: 2)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _controller.clear(),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar firma'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isNotEmpty && _nombreCtrl.text.isNotEmpty ? _guardarFirma : null,
                    icon: const Icon(Icons.save, size: 16),
                    label: const Text('Guardar firma'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarFirma() async {
    if (!_controller.isNotEmpty || _nombreCtrl.text.isEmpty) return;

    final bytes = await _controller.toPngBytes();
    if (bytes != null) {
      final base64Signature = 'data:image/png;base64,${base64Encode(bytes)}';
      
      if (widget.documentoId != null) {
        FirmaDigitalService.firmarDocumento(widget.documentoId!, base64Signature, _nombreCtrl.text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Documento firmado exitosamente'), backgroundColor: Color(0xFF10B981)));
        if (widget.onFirmaCompletada != null) widget.onFirmaCompletada!();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Selecciona un documento primero'), backgroundColor: Color(0xFFF59E0B)));
      }
    }
  }
}