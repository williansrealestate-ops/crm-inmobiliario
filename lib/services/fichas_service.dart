import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FichasService {
  // ✅ Generar ficha técnica en PDF
  static Future<Uint8List> generarFichaPDF({
    required Map<String, dynamic> propiedad,
  }) async {
    final pdf = pw.Document();
    
    final titulo = propiedad['titulo'] ?? 'Sin título';
    final precio = propiedad['precio'] ?? 0;
    final ubicacion = propiedad['ubicacion'] ?? 'Sin ubicación';
    final tipo = propiedad['tipo'] ?? 'Casa';
    final recamaras = _toInt(propiedad['recamaras']);
    final banos = _toInt(propiedad['banos']);
    final area = _toDouble(propiedad['area']);
    final descripcion = propiedad['descripcion'] ?? 'Sin descripción disponible.';
    final caracteristicas = List<String>.from(propiedad['caracteristicas'] ?? []);
    
    final precioFormateado = _formatearMoneda(precio);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header con logo y título
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#0D1B4C'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('REAL ESTATE', style: pw.TextStyle(color: PdfColor.fromHex('#E8D44D'), fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('FICHA TÉCNICA', style: pw.TextStyle(color: PdfColors.white, fontSize: 14)),
                  ],
                ),
                pw.Text(tipo.toUpperCase(), style: pw.TextStyle(color: PdfColor.fromHex('#E8D44D'), fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Título y precio
          pw.Text(titulo, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D1B4C'))),
          pw.SizedBox(height: 8),
          pw.Text(precioFormateado, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#10B981'))),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Icon(pw.IconData(0xe55f), size: 16, color: PdfColor.fromHex('#64748B')),
              pw.SizedBox(width: 4),
              pw.Text(ubicacion, style: pw.TextStyle(fontSize: 12, color: PdfColor.fromHex('#64748B'))),
            ],
          ),
          pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 1),
          pw.SizedBox(height: 16),

          // Características principales
          pw.Text('CARACTERÍSTICAS PRINCIPALES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D1B4C'))),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildCaracteristicaBox('Recámaras', '$recamaras', '🛏️'),
              _buildCaracteristicaBox('Baños', '$banos', '🚿'),
              _buildCaracteristicaBox('Área', '${area.toInt()} m²', '📐'),
            ],
          ),
          pw.SizedBox(height: 20),

          // Descripción
          pw.Text('DESCRIPCIÓN', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D1B4C'))),
          pw.SizedBox(height: 8),
          pw.Text(descripcion, style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#334155'), lineSpacing: 4)),
          pw.SizedBox(height: 20),

          // Características adicionales
          if (caracteristicas.isNotEmpty) ...[
            pw.Text('CARACTERÍSTICAS ADICIONALES', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D1B4C'))),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: caracteristicas.map((c) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  // ✅ CORREGIDO: Usando fromInt con canal Alfa (0x1A = ~10% opacidad)
                  color: PdfColor.fromInt(0x1A0D1B4C),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  border: pw.Border.all(color: PdfColor.fromInt(0x4D0D1B4C)), // 0x4D = ~30% opacidad
                ),
                child: pw.Text('✓ $c', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#0D1B4C'))),
              )).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Contacto
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              // ✅ CORREGIDO: Usando fromInt con canal Alfa
              color: PdfColor.fromInt(0x0D0D1B4C), // 0x0D = ~5% opacidad
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColor.fromInt(0x330D1B4C)), // 0x33 = ~20% opacidad
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CONTACTO', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D1B4C'))),
                pw.SizedBox(height: 8),
                pw.Text('Williams - Asesor Inmobiliario', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Tel: 555-123-4567', style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#64748B'))),
                pw.Text('Email: williams@realestate.com', style: pw.TextStyle(fontSize: 11, color: PdfColor.fromHex('#64748B'))),
              ],
            ),
          ),

          // Footer
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F1F5F9'), 
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generado por Real Estate CRM', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#64748B'))),
                pw.Text('Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#64748B'))),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCaracteristicaBox(String label, String valor, String icono) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
      ),
      child: pw.Column(
        children: [
          pw.Text(icono, style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 4),
          pw.Text(valor, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D1B4C'))),
          pw.SizedBox(height: 2),
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#64748B'))),
        ],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
    return 0;
  }

  static String _formatearMoneda(dynamic valor) {
    if (valor == null) return '\$0';
    final num n = valor is String ? double.tryParse(valor.replaceAll(',', '')) ?? 0 : valor as num;
    if (n >= 1000000) return '\$${(n / 1000000).toStringAsFixed(2)} MDP';
    if (n >= 1000) return '\$${(n / 1000).toStringAsFixed(0)} K';
    return '\$${n.toStringAsFixed(0)}';
  }
}