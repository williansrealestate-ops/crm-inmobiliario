import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class PdfService {
  /// Genera la ficha técnica de un inmueble en PDF
  static Future<Uint8List> generarFichaInmueble({
    required Map<String, dynamic> inmueble,
    required BuildContext context,
  }) async {
    final pdf = pw.Document();
    
    final titulo = inmueble['titulo'] ?? 'Sin título';
    final tipo = inmueble['tipo'] ?? 'Casa';
    final precio = _formatearPrecio(inmueble['precio'] ?? '0');
    final moneda = inmueble['moneda'] ?? 'MXN';
    final estado = inmueble['estado'] ?? '';
    final municipio = inmueble['municipio'] ?? '';
    final direccion = inmueble['direccion'] ?? '';
    final pais = inmueble['pais'] ?? 'México';
    final areaTerreno = inmueble['areaTerreno'] ?? '0';
    final areaConst = inmueble['areaConstruccion'] ?? '0';
    final habitaciones = inmueble['habitaciones'] ?? '0';
    final banos = inmueble['banos'] ?? '0';
    final estac = inmueble['estacionamientos'] ?? '0';
    final descripcion = inmueble['descripcion'] ?? 'Sin descripción';
    final propietario = inmueble['propietario'] ?? 'No especificado';
    final asesor = inmueble['asesor'] ?? 'No asignado';
    final fechaAlta = inmueble['fechaAlta'] ?? '';
    final estadoVenta = inmueble['estadoVenta'] ?? 'Disponible';
    
    final fotos = List<String>.from(inmueble['fotosBase64'] ?? []);
    
    const colorPrimario = PdfColor.fromInt(0xFF0D1B4C);
    const colorAcento = PdfColor.fromInt(0xFFE8D44D);
    const colorTexto = PdfColor.fromInt(0xFF1E293B);
    const colorTextoSecundario = PdfColor.fromInt(0xFF64748B);
    // ✅ CORRECCIÓN: Color blanco con ~70% de opacidad (0xB3 = 179)
    const colorBlancoSemi = PdfColor.fromInt(0xB3FFFFFF);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 20),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: colorPrimario, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'REAL ESTATE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: colorPrimario,
                    ),
                  ),
                  pw.Text(
                    'Ficha Técnica de Inmueble',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: colorTextoSecundario,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: colorPrimario,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  estadoVenta.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 20),
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generado el ${DateTime.now().toIso8601String().split('T')[0]}',
                style: pw.TextStyle(fontSize: 8, color: colorTextoSecundario),
              ),
              pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 8, color: colorTextoSecundario),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: colorPrimario,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text('📍', style: pw.TextStyle(fontSize: 14, color: colorTextoSecundario)),
              pw.SizedBox(width: 4),
              pw.Text(
                '$direccion, $municipio, $estado, $pais',
                style: pw.TextStyle(fontSize: 11, color: colorTextoSecundario),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: colorPrimario,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PRECIO',
                      // ✅ CORRECCIÓN: Usar colorBlancoSemi en lugar de withOpacity
                      style: pw.TextStyle(fontSize: 10, color: colorBlancoSemi),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '$precio $moneda',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TIPO',
                      style: pw.TextStyle(fontSize: 10, color: colorBlancoSemi),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      tipo.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: colorAcento,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          if (fotos.isNotEmpty) ...[
            pw.Text(
              'Galería de Fotos',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: colorPrimario,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fotos.take(4).map((fotoBase64) {
                return pw.Container(
                  width: 240,
                  height: 160,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(
                      pw.MemoryImage(_base64ToBytes(fotoBase64)),
                      fit: pw.BoxFit.cover,
                      width: 240,
                      height: 160,
                    ),
                  ),
                );
              }).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          pw.Text(
            'Características',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: colorPrimario,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              _buildFilaCaracteristica('Área de Terreno', '$areaTerreno m²', 'Área Construcción', '$areaConst m²', colorPrimario),
              _buildFilaCaracteristica('Habitaciones', habitaciones, 'Baños', banos, colorPrimario),
              _buildFilaCaracteristica('Estacionamientos', estac, 'Estado', estadoVenta, colorPrimario),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text(
            'Descripción',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: colorPrimario,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              descripcion,
              style: pw.TextStyle(fontSize: 11, color: colorTexto, height: 1.5),
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Text(
            'Información de Contacto',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: colorPrimario,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: colorPrimario, width: 1),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Propietario', propietario, colorTextoSecundario),
                pw.SizedBox(height: 8),
                _buildInfoRow('Asesor', asesor, colorTextoSecundario),
                pw.SizedBox(height: 8),
                _buildInfoRow('Fecha de alta', fechaAlta, colorTextoSecundario),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> mostrarPdf({
    required Map<String, dynamic> inmueble,
    required BuildContext context,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final pdfBytes = await generarFichaInmueble(
        inmueble: inmueble,
        context: context,
      );

      if (context.mounted) Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Ficha_${inmueble['titulo'] ?? 'inmueble'}.pdf',
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e')),
        );
      }
    }
  }

  static pw.TableRow _buildFilaCaracteristica(
    String label1, String valor1,
    String label2, String valor2,
    PdfColor color,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Row(
            children: [
              pw.Container(
                width: 6,
                height: 6,
                decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
              ),
              pw.SizedBox(width: 8),
              pw.Text(label1, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Spacer(),
              pw.Text(valor1, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Row(
            children: [
              pw.Container(
                width: 6,
                height: 6,
                decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
              ),
              pw.SizedBox(width: 8),
              pw.Text(label2, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Spacer(),
              pw.Text(valor2, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String valor, PdfColor color) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(fontSize: 11, color: color, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          valor,
          style: pw.TextStyle(fontSize: 11, color: PdfColors.black),
        ),
      ],
    );
  }

  static String _formatearPrecio(String precio) {
    final valor = double.tryParse(precio) ?? 0;
    if (valor >= 1000000) return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '\$${(valor / 1000).toStringAsFixed(0)}K';
    return '\$${valor.toStringAsFixed(0)}';
  }

  static Uint8List _base64ToBytes(String base64String) {
    if (base64String.contains(',')) {
      base64String = base64String.split(',').last;
    }
    return base64Decode(base64String);
  }
}