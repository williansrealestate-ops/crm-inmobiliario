import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/chat_ia_service.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreenState();
}

class _ChatIAScreenState extends State<ChatIAScreen> {
  final TextEditingController _mensajeCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _mensajes = [];
  bool _cargando = false;
  final String _userId = 'anonimo';

  @override
  void initState() {
    super.initState();
    _cargarBienvenida();
  }

  void _cargarBienvenida() {
    setState(() {
      _mensajes.add({
        'role': 'assistant',
        'content': '¡Hola! Soy Willians, tu asistente inmobiliario. 🏠\n\nPuedo ayudarte con:\n• Información sobre propiedades\n• Precios y ubicaciones\n• Tipos de inmuebles disponibles\n• Contacto con asesores\n\n¿En qué puedo ayudarte hoy?',
      });
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty || _cargando) return;

    setState(() {
      _mensajes.add({'role': 'user', 'content': texto});
      _cargando = true;
    });

    _mensajeCtrl.clear();
    _scrollToBottom();

    try {
      final mensajesAPI = _mensajes
          .map((m) => {'role': m['role']!, 'content': m['content']!})
          .toList();

      final respuesta = await ChatIAService.enviarMensaje(mensajesAPI);

      setState(() {
        _mensajes.add({'role': 'assistant', 'content': respuesta});
        _cargando = false;
      });

      _scrollToBottom();

      await ChatIAService.guardarMensaje(userId: _userId, role: 'user', message: texto);
      await ChatIAService.guardarMensaje(userId: _userId, role: 'assistant', message: respuesta);
      
    } catch (e) {
      setState(() {
        _mensajes.add({
          'role': 'assistant',
          'content': '❌ Error: No pude procesar tu mensaje. Intenta de nuevo.',
        });
        _cargando = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Text('Asistente IA'),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _mensajes.clear();
                _cargarBienvenida();
              });
            },
            tooltip: 'Limpiar chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esUsuario = msg['role'] == 'user';
                return _buildMensaje(msg['content']!, esUsuario);
              },
            ),
          ),
          if (_cargando)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Willians está escribiendo...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeCtrl,
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _cargando ? Colors.grey : AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(_cargando ? Icons.hourglass_empty : Icons.send, color: Colors.white),
                    onPressed: _cargando ? null : _enviarMensaje,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje(String contenido, bool esUsuario) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esUsuario) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: esUsuario ? AppTheme.primary : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(contenido, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
          if (esUsuario) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mensajeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}