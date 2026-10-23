import 'package:flutter/material.dart';
import '../../config/theme.dart';

class DetalleCliente extends StatelessWidget {
  final Map<String, dynamic> cliente;
  const DetalleCliente({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    final nombre = cliente['nombre'] ?? '';
    final telefono = cliente['telefono'] ?? '';
    final email = cliente['email'] ?? '';
    final tipo = cliente['tipo'] ?? '';
    final presupuesto = cliente['presupuesto'] ?? '';
    final interes = cliente['interes'] ?? '';
    final pais = cliente['pais'] ?? '';
    final estado = cliente['estadoUbicacion'] ?? '';
    final notas = cliente['notas'] ?? '';
    final catalogo = cliente['catalogo'] ?? '';
    final fotoBase64 = cliente['fotoBase64'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Detalle del Cliente'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primary, width: 3)),
                  child: ClipOval(
                    child: fotoBase64.isNotEmpty
                        ? Image.network(fotoBase64, fit: BoxFit.cover)
                        : Container(color: AppTheme.primary.withOpacity(0.2), child: const Center(child: const Icon(Icons.person, color: AppTheme.primary, size: 40))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.getTextPrimaryColor(context))),
                      const SizedBox(height: 4),
                      Text(tipo, style: TextStyle(fontSize: 14, color: AppTheme.getTextSecondaryColor(context))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(context, 'Información de Contacto', [
              if (telefono.isNotEmpty) _buildRow(context, Icons.phone, 'Teléfono', telefono),
              if (email.isNotEmpty) _buildRow(context, Icons.email, 'Email', email),
              if (pais.isNotEmpty) _buildRow(context, Icons.public, 'País', pais),
              if (estado.isNotEmpty) _buildRow(context, Icons.location_on, 'Estado', estado),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Intereses', [
              if (interes.isNotEmpty) _buildRow(context, Icons.star, 'Interés', interes),
              if (presupuesto.isNotEmpty) _buildRow(context, Icons.account_balance_wallet, 'Presupuesto', '\$$presupuesto'),
              if (catalogo.isNotEmpty) _buildRow(context, Icons.inventory_2, 'Catálogo', catalogo),
            ]),
            const SizedBox(height: 16),
            if (notas.isNotEmpty) ...[
              _buildSection(context, 'Notas', [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: Text(notas, style: TextStyle(fontSize: 14, color: AppTheme.getTextPrimaryColor(context), height: 1.5)),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getTextPrimaryColor(context))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.getBorderColor(context)))),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.getTextSecondaryColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.getTextPrimaryColor(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}