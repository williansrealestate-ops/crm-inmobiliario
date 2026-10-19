import 'dart:html' as html;
import 'package:flutter/material.dart';

class WhatsAppFAB extends StatelessWidget {
  final String numero;
  final String mensaje;

  const WhatsAppFAB({
    super.key,
    required this.numero,
    this.mensaje = 'Hola, me interesa conocer más sobre sus propiedades',
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF25D366),
      onPressed: () {
        final url = 'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}';
        html.window.open(url, '_blank');
      },
      child: const Icon(Icons.chat, color: Colors.white, size: 28),
    );
  }
}