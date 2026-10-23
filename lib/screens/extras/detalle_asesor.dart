import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class DetalleAsesor extends StatelessWidget {
  final Map<String, dynamic> asesor;

  const DetalleAsesor({super.key, required this.asesor});

  void _copiarTexto(BuildContext context, String texto, String label) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $label copiado al portapapeles'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final nombre = asesor['nombre'] ?? '';
    final telefono = asesor['telefono'] ?? '';
    final email = asesor['email'] ?? '';
    final oficina = asesor['oficina'] ?? '';
    final pais = asesor['pais'] ?? '';
    final estado = asesor['estado'] ?? '';
    final fechaIngreso = asesor['fechaIngreso'] ?? '';
    final notas = asesor['notas'] ?? '';
    final fotoBase64 = asesor['fotoBase64'] ?? '';

    final inmuebles = LocalStorageService.getInmuebles();
    final misInmuebles = inmuebles.where((i) => i['asesor'] == nombre).toList();
    final totalInmuebles = misInmuebles.length;
    final totalVentas = misInmuebles.where((i) => i['estadoVenta'] == 'Vendido').length;
    final totalIngresos = misInmuebles.fold(0.0, (sum, i) {
      return sum + (double.tryParse(i['comision']?.toString() ?? '0') ?? 0);
    });
    final efectividad = totalInmuebles > 0 ? (totalVentas / totalInmuebles) * 100 : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Detalle del Asesor'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context, true);
            },
            tooltip: 'Editar asesor',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: fotoBase64.isNotEmpty
                        ? Image.network(fotoBase64, fit: BoxFit.cover)
                        : Container(
                            color: AppTheme.primary.withOpacity(0.2),
                            child: Center(
                              child: Text(
                                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        oficina.isNotEmpty ? oficina : 'Sin oficina',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.home,
                    '$totalInmuebles',
                    'Inmuebles',
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.shopping_bag,
                    '$totalVentas',
                    'Ventas',
                    AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.attach_money,
                    '\$${(totalIngresos / 1000).toStringAsFixed(0)}K',
                    'Ingresos',
                    AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getBorderColor(context)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Efectividad de ventas',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        '${efectividad.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: efectividad >= 50 ? AppTheme.success : AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: efectividad / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        efectividad >= 50 ? AppTheme.success : AppTheme.warning,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              'Información de Contacto',
              Icons.contact_mail,
              [
                _buildInfoRow(context, Icons.email, 'Email', email, () => _copiarTexto(context, email, 'Email')),
                _buildInfoRow(context, Icons.phone, 'Teléfono', telefono, () => _copiarTexto(context, telefono, 'Teléfono')),
                _buildInfoRow(context, Icons.location_on, 'Ubicación', '$oficina, $estado, $pais', null),
              ],
            ),

            const SizedBox(height: 24),

            if (notas.isNotEmpty) ...[
              _buildSection(
                context,
                'Notas',
                Icons.note,
                [],
                customContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.getBorderColor(context)),
                      ),
                      child: Text(
                        notas,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextPrimaryColor(context),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _copiarTexto(context, notas, 'Notas'),
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar notas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Fecha de ingreso: $fechaIngreso',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> rows, {
    Widget? customContent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (customContent != null)
          customContent
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(context)),
            ),
            child: Column(
              children: rows,
            ),
          ),
      ],
    );
  }

  // ✅ CORREGIDO: Se agregó BuildContext context como primer parámetro
  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, VoidCallback? onCopy) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.getBorderColor(context)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.getTextSecondaryColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: onCopy,
              tooltip: 'Copiar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}