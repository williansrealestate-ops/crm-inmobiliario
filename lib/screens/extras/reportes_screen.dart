import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/backup_service.dart';
import '../../services/pipeline_service.dart';
import '../../services/finanzas_service.dart';
import '../../services/local_storage_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  Widget build(BuildContext context) {
    final resumenPipeline = PipelineService.getResumenPipeline();
    final resumenFinanciero = FinanzasService.getResumenFinanciero();
    final totalInmuebles = LocalStorageService.getInmuebles().length;
    final totalClientes = LocalStorageService.getClientes().length;
    final totalActividades = LocalStorageService.getActividades().length;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.analytics, color: Colors.white), SizedBox(width: 8), Text('Reportes')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reportes del Sistema', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Resumen general de tu CRM inmobiliario', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // KPIs principales
            Row(
              children: [
                Expanded(child: _buildKPICard('Inmuebles', '$totalInmuebles', Icons.home, const Color(0xFF3B82F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildKPICard('Clientes', '$totalClientes', Icons.people, const Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildKPICard('Actividades', '$totalActividades', Icons.task, const Color(0xFFF59E0B))),
                const SizedBox(width: 12),
                Expanded(child: _buildKPICard('Operaciones', '${resumenPipeline['total']}', Icons.view_kanban, const Color(0xFF8B5CF6))),
              ],
            ),
            const SizedBox(height: 24),

            // Pipeline
            _buildSectionTitle('Resumen del Pipeline'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Total de operaciones', '${resumenPipeline['total']}'),
                  const Divider(),
                  _buildInfoRow('Valor total', PipelineService.formatearMoneda(resumenPipeline['valorTotal'])),
                  const Divider(),
                  ...PipelineService.etapas.map((etapa) {
                    final etapaId = etapa['id'];
                    final datos = resumenPipeline[etapaId] as Map<String, dynamic>;
                    return _buildInfoRow(
                      '${etapa['icono']} ${etapa['nombre']}',
                      '${datos['cantidad']} - ${PipelineService.formatearMoneda(datos['valor'])}',
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Finanzas
            _buildSectionTitle('Resumen Financiero'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Ingresos del mes', _formatearMoneda(resumenFinanciero['ingresosMes'])),
                  const Divider(),
                  _buildInfoRow('Gastos del mes', _formatearMoneda(resumenFinanciero['gastosMes'])),
                  const Divider(),
                  _buildInfoRow('Balance del mes', _formatearMoneda(resumenFinanciero['balanceMes'])),
                  const Divider(),
                  _buildInfoRow('Ingresos del año', _formatearMoneda(resumenFinanciero['ingresosAnio'])),
                  const Divider(),
                  _buildInfoRow('Meta mensual', _formatearMoneda(resumenFinanciero['metaMensual'])),
                  const Divider(),
                  _buildInfoRow('Progreso meta', '${(resumenFinanciero['progresoMetaMensual'] as double).toStringAsFixed(1)}%'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Backup y Restauración
            _buildSectionTitle('Respaldo de Datos'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Column(
                children: [
                  const Text('Exporta o importa todos los datos de tu CRM', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton.icon(
                        onPressed: () => BackupService.exportarDatosConContext(context),
                        icon: const Icon(Icons.download, size: 14),
                        label: const Text('Exportar', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: const Size(0, 30),
                        ),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton.icon(
                        onPressed: () => BackupService.importarDatosConContext(context),
                        icon: const Icon(Icons.upload, size: 14),
                        label: const Text('Importar', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: const Size(0, 30),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String label, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context)));
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context))),
          Text(valor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
        ],
      ),
    );
  }

  // ✅ Método local para formatear moneda (ya que FinanzasService no tiene formatearMoneda)
  String _formatearMoneda(dynamic valor) {
    if (valor == null) return '\$0';
    final num n = valor is String ? double.tryParse(valor.replaceAll(',', '')) ?? 0 : valor as num;
    if (n >= 1000000) return '\$${(n / 1000000).toStringAsFixed(2)} M';
    if (n >= 1000) return '\$${(n / 1000).toStringAsFixed(0)} K';
    return '\$${n.toStringAsFixed(0)}';
  }
}