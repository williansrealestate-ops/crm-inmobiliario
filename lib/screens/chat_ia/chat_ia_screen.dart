import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/chat_ia_service.dart';
import '../../services/indexed_db_service.dart';

class ChatIAScreen extends StatefulWidget {
  const ChatIAScreen({super.key});

  @override
  State<ChatIAScreen> createState() => _ChatIAScreen();
}

class _ChatIAScreen extends State<ChatIAScreen> {
  final TextEditingController _controlador = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _mensajes = [];
  bool _escribiendo = false;

  // ✅ Colores adaptativos
  Color _colorBurbujaIA(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.white;
  }

  Color _colorInput(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  Color _colorBorde(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF333333)
        : Colors.grey.shade200;
  }

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
    if (_mensajes.isEmpty) {
      _agregarMensajeIA('¡Hola! 👋 Soy el asistente virtual de **Williams Real Estate**.\n\nPuedo ayudarte con información sobre propiedades, precios, financiamiento, visitas y más.\n\n¿En qué puedo ayudarte hoy?');
    }
  }

  Future<void> _cargarHistorial() async {
    try {
      final json = await IndexedDBService.get('chat_ia_historial');
      if (json != null) {
        final lista = jsonDecode(json) as List;
        setState(() {
          _mensajes = lista.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (e) {
      print('Error al cargar historial: $e');
    }
  }

  Future<void> _guardarHistorial() async {
    await IndexedDBService.put('chat_ia_historial', jsonEncode(_mensajes));
  }

  void _agregarMensajeIA(String texto) {
    setState(() {
      _mensajes.add({
        'texto': texto,
        'esUsuario': false,
        'fecha': DateTime.now().toIso8601String(),
      });
    });
    _guardarHistorial();
    _scrollAlFinal();
  }

  void _enviarMensaje(String texto) {
    if (texto.trim().isEmpty) return;
    
    setState(() {
      _mensajes.add({
        'texto': texto,
        'esUsuario': true,
        'fecha': DateTime.now().toIso8601String(),
      });
      _escribiendo = true;
    });
    _scrollAlFinal();
    _controlador.clear();
    
    Future.delayed(const Duration(milliseconds: 800), () {
      final respuesta = ChatIAService.obtenerRespuesta(texto);
      setState(() {
        _escribiendo = false;
        _mensajes.add({
          'texto': respuesta,
          'esUsuario': false,
          'fecha': DateTime.now().toIso8601String(),
        });
      });
      _guardarHistorial();
      _scrollAlFinal();
    });
  }

  void _scrollAlFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _limpiarChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Limpiar conversación?'),
        content: const Text('Se borrarán todos los mensajes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() => _mensajes.clear());
              _guardarHistorial();
              Navigator.pop(ctx);
              _agregarMensajeIA('Conversación reiniciada. ¿En qué puedo ayudarte?');
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorBurbujaIA = _colorBurbujaIA(context);
    final colorInput = _colorInput(context);
    final colorBorde = _colorBorde(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.smart_toy, color: Color(0xFF007AFF), size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asistente Virtual', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('Williams Real Estate • En línea', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _limpiarChat,
                  tooltip: 'Limpiar chat',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sugerencias rápidas
          if (_mensajes.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preguntas frecuentes:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ChatIAService.getSugerencias().map((s) {
                      return GestureDetector(
                        onTap: () => _enviarMensaje(s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF007AFF), fontWeight: FontWeight.w600)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _mensajes.length + (_escribiendo ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mensajes.length && _escribiendo) {
                  return _buildMensajeEscribiendo(colorBurbujaIA, colorBorde);
                }
                return _buildMensaje(_mensajes[index], colorBurbujaIA, colorBorde);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorInput,
              border: Border(top: BorderSide(color: colorBorde)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controlador,
                    style: TextStyle(color: AppTheme.getTextColor(context)),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      isDense: true,
                    ),
                    onSubmitted: _enviarMensaje,
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF007AFF),
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _enviarMensaje(_controlador.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje(Map<String, dynamic> msg, Color colorBurbujaIA, Color colorBorde) {
    final esUsuario = msg['esUsuario'] == true;
    final texto = msg['texto']?.toString() ?? '';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esUsuario)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF007AFF),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esUsuario ? const Color(0xFF007AFF) : colorBurbujaIA,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esUsuario ? 16 : 4),
                  bottomRight: Radius.circular(esUsuario ? 4 : 16),
                ),
                border: esUsuario ? null : Border.all(color: colorBorde),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  color: esUsuario ? Colors.white : AppTheme.getTextColor(context),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (esUsuario) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMensajeEscribiendo(Color colorBurbujaIA, Color colorBorde) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF007AFF),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorBurbujaIA,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: colorBorde),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPuntoAnimado(0),
                const SizedBox(width: 4),
                _buildPuntoAnimado(1),
                const SizedBox(width: 4),
                _buildPuntoAnimado(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuntoAnimado(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.getTextSecondaryColor(context),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}