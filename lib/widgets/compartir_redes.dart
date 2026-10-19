import 'dart:html' as html;
import 'package:flutter/material.dart';

class CompartirRedes extends StatelessWidget {
  final String titulo;
  final String precio;
  final String ubicacion;
  final String url;

  const CompartirRedes({
    super.key,
    required this.titulo,
    required this.precio,
    required this.ubicacion,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final mensaje = '¡Mira esta propiedad! $titulo en $ubicacion por $precio. Más info: $url';
    final mensajeCodificado = Uri.encodeComponent(mensaje);
    final urlCodificada = Uri.encodeComponent(url);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compartir esta propiedad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBotonRed(
                icono: Icons.chat,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                onTap: () => html.window.open('https://wa.me/?text=$mensajeCodificado', '_blank'),
              ),
              const SizedBox(width: 8),
              _buildBotonRed(
                icono: Icons.facebook,
                color: const Color(0xFF1877F2),
                label: 'Facebook',
                onTap: () => html.window.open('https://www.facebook.com/sharer/sharer.php?u=$urlCodificada', '_blank'),
              ),
              const SizedBox(width: 8),
              _buildBotonRed(
                icono: Icons.tag,
                color: const Color(0xFF1DA1F2),
                label: 'Twitter',
                onTap: () => html.window.open('https://twitter.com/intent/tweet?text=$mensajeCodificado', '_blank'),
              ),
              const SizedBox(width: 8),
              _buildBotonRed(
                icono: Icons.work,
                color: const Color(0xFF0A66C2),
                label: 'LinkedIn',
                onTap: () => html.window.open('https://www.linkedin.com/sharing/share-offsite/?url=$urlCodificada', '_blank'),
              ),
              const SizedBox(width: 8),
              _buildBotonRed(
                icono: Icons.email,
                color: const Color(0xFFEA4335),
                label: 'Email',
                onTap: () => html.window.open('mailto:?subject=${Uri.encodeComponent('Propiedad: $titulo')}&body=$mensajeCodificado', '_blank'),
              ),
              const SizedBox(width: 8),
              _buildBotonRed(
                icono: Icons.copy,
                color: const Color(0xFF6B7280),
                label: 'Copiar',
                onTap: () {
                  html.window.navigator.clipboard?.writeText(mensaje);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Link copiado al portapapeles'), backgroundColor: Color(0xFF10B981)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotonRed({
    required IconData icono,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}