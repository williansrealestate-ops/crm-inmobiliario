import 'dart:html' as html;
import 'package:flutter/material.dart';

class SharePropertyButton extends StatelessWidget {
  final String titulo;
  final String precio;
  final String ubicacion;

  const SharePropertyButton({
    super.key,
    required this.titulo,
    required this.precio,
    required this.ubicacion,
  });

  @override
  Widget build(BuildContext context) {
    final url = html.window.location.href;
    final mensaje = '¡Mira esta propiedad! $titulo en $ubicacion por $precio. Más info aquí: $url';

    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.share, color: Color(0xFF007AFF), size: 20),
      ),
      onSelected: (value) {
        switch (value) {
          case 'whatsapp':
            html.window.open(
              'https://wa.me/?text=${Uri.encodeComponent(mensaje)}',
              '_blank',
            );
            break;
          case 'facebook':
            html.window.open(
              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}',
              '_blank',
            );
            break;
          case 'twitter':
            html.window.open(
              'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(mensaje)}',
              '_blank',
            );
            break;
          case 'copy':
            // ✅ Corrección: Verificación de null safety para el portapapeles
            final clipboard = html.window.navigator.clipboard;
            if (clipboard != null) {
              clipboard.writeText(mensaje);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Link copiado al portapapeles'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'whatsapp',
          child: Row(children: [
            Icon(Icons.chat, color: Color(0xFF25D366)),
            SizedBox(width: 8),
            Text('WhatsApp'),
          ]),
        ),
        const PopupMenuItem(
          value: 'facebook',
          child: Row(children: [
            Icon(Icons.facebook, color: Color(0xFF1877F2)),
            SizedBox(width: 8),
            Text('Facebook'),
          ]),
        ),
        const PopupMenuItem(
          value: 'twitter',
          child: Row(children: [
            Icon(Icons.tag, color: Color(0xFF1DA1F2)),
            SizedBox(width: 8),
            Text('Twitter'),
          ]),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            Icon(Icons.copy),
            SizedBox(width: 8),
            Text('Copiar link'),
          ]),
        ),
      ],
    );
  }
}