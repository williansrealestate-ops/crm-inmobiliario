import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportePdfService {
  static Future<void> generarReporteFinanciero({
    required List<Map<String, dynamic>> transacciones,
    required double totalIngresos,
    required double totalGastos,
    required String empresa,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        footer: (pw.Context context) {
          return pw.Container(
            margin: pw.EdgeInsets.only(top: 20),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Generado automáticamente por $empresa CRM - Página ${context.pageNumber}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // 1. HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      empresa,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Reporte Financiero Detallado',
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      'Fecha: ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500),
                    ),
                  ],
                ),
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      empresa.substring(0, 1).toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // 2. TARJETAS DE RESUMEN
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: PdfColors.green200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Ingresos', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '\$${totalIngresos.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red50,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: PdfColors.red200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Gastos', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '\$${totalGastos.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // 3. TABLA DE TRANSACCIONES
            pw.Text(
              'Detalle de Transacciones',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
              columnWidths: {
                0: pw.FlexColumnWidth(2.5),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableCell('Concepto', isHeader: true),
                    _buildTableCell('Tipo', isHeader: true),
                    _buildTableCell('Fecha', isHeader: true),
                    _buildTableCell('Monto', isHeader: true),
                  ],
                ),
                ...transacciones.map((t) {
                  final esIngreso = t['tipo'] == 'Ingreso';
                  return pw.TableRow(
                    children: [
                      _buildTableCell(t['concepto'] ?? 'Sin concepto'),
                      _buildTableCell(
                        t['tipo'] ?? 'N/A',
                        color: esIngreso ? PdfColors.green : PdfColors.red,
                      ),
                      _buildTableCell(t['fecha'] ?? 'N/A'),
                      _buildTableCell(
                        '\$${(t['monto'] ?? 0).toStringAsFixed(2)}',
                        isBold: true,
                        color: esIngreso ? PdfColors.green : PdfColors.red,
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    // 4. GENERAR Y DESCARGAR
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'Reporte_Financiero_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }
}