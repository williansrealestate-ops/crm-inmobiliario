import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/asistente_ia_service.dart';

class AsistenteIAChatScreen extends StatefulWidget {
  const AsistenteIAChatScreen({super.key}); // ✅ CONSTRUCTOR CONST

  @override
  State<AsistenteIAChatScreen> createState() => _AsistenteIAChatScreenState();
}

class _AsistenteIAChatScreenState extends State<AsistenteIAChatScreen> {
  final TextEditingController _mensajeCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _mensajes = [];
  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  
  bool _escribiendo = false;
  bool _datosCapturados = false;
  String _nombre = '', _telefono = '', _email = '';

  @override
  void initState() {
    super.initState();
    _agregarMensajeBot('¡Hola! 👋 Soy el asistente virtual de Real Estate. ¿Cómo te llamas?');
  }

  @override
  void dispose() {
    _mensajeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _agregarMensajeBot(String texto) {
    setState(() {
      _mensajes.add({'texto': texto, 'esBot': true, 'timestamp': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _agregarMensajeUsuario(String texto) {
    setState(() {
      _mensajes.add({'texto': texto, 'esBot': false, 'timestamp': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _enviarMensaje() {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty) return;
    _agregarMensajeUsuario(texto);
    _mensajeCtrl.clear();

    if (!_datosCapturados) {
      if (_nombre.isEmpty) {
        _nombre = texto;
        _datosCapturados = true;
        setState(() => _escribiendo = true);
        Future.delayed(const Duration(milliseconds: 1000), () {
          _agregarMensajeBot('¡Mucho gusto $_nombre! 📱 ¿Cuál es tu número de teléfono o WhatsApp?');
          setState(() => _escribiendo = false);
        });
        return;
      } else if (_telefono.isEmpty) {
        _telefono = texto;
        setState(() => _escribiendo = true);
        Future.delayed(const Duration(milliseconds: 1000), () {
          _agregarMensajeBot('Perfecto. ¿Y tu correo electrónico? (Opcional)');
          setState(() => _escribiendo = false);
        });
        return;
      } else if (_email.isEmpty) {
        _email = texto;
        _datosCapturados = true;
        setState(() => _escribiendo = true);
        Future.delayed(const Duration(milliseconds: 1000), () {
          _agregarMensajeBot('¡Excelente! Ahora cuéntame, ¿qué tipo de propiedad estás buscando? 🏠');
          setState(() => _escribiendo = false);
        });
        return;
      }
    }

    setState(() => _escribiendo = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      final respuesta = AsistenteIAService.generarRespuesta(texto, _nombre);
      _agregarMensajeBot(respuesta);
      setState(() => _escribiendo = false);
    });
  }

  void _finalizarConversacion() {
    final lead = AsistenteIAService.calificarLead(nombre: _nombre, telefono: _telefono, email: _email, mensajes: _mensajes);
    AsistenteIAService.guardarConversacion(sessionId: _sessionId, mensajes: _mensajes, leadCalificado: lead);
    AsistenteIAService.guardarLead(lead);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Lead Calificado', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: $_nombre', style: TextStyle(color: AppTheme.getTextColor(context))),
            Text('Teléfono: $_telefono', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
            if (_email.isNotEmpty) Text('Email: $_email', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Nivel de interés: ${lead['nivelInteres']} (${lead['puntuacion']} pts)', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); _reiniciarChat(); }, child: const Text('Nueva conversación')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _reiniciarChat() {
    setState(() {
      _mensajes.clear(); _nombre = ''; _telefono = ''; _email = ''; _datosCapturados = false;
    });
    _agregarMensajeBot('¡Hola! 👋 Soy el asistente virtual de Real Estate. ¿Cómo te llamas?');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.smart_toy, color: Colors.white), SizedBox(width: 8), Text('Chat IA')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.check_circle), onPressed: _finalizarConversacion, tooltip: 'Finalizar y calificar')],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_escribiendo ? 1 : 0),
              itemBuilder: (context, index) {
                if (_escribiendo && index == _mensajes.length) {
                  return Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(16)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Escribiendo', style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic))])));
                }
                final msg = _mensajes[index];
                final esBot = msg['esBot'] as bool;
                return Align(
                  alignment: esBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: esBot ? AppTheme.getSurfaceColor(context) : AppTheme.primary,
                      borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(esBot ? 4 : 16), bottomRight: Radius.circular(esBot ? 16 : 4)),
                    ),
                    child: Text(msg['texto'], style: TextStyle(color: esBot ? AppTheme.getTextColor(context) : Colors.white, fontSize: 14)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, -2))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeCtrl,
                    decoration: InputDecoration(hintText: 'Escribe tu mensaje...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)), filled: true, fillColor: AppTheme.getBackgroundColor(context)),
                    onSubmitted: (_) => _enviarMensaje(),
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(24)), child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _enviarMensaje)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}