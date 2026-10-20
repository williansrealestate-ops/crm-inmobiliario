import 'package:supabase_flutter/supabase_flutter.dart';

class ChatIAService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Enviar mensaje a la Edge Function
  static Future<String> enviarMensaje(List<Map<String, String>> mensajes) async {
    try {
      final response = await _client.functions.invoke(
        'chat-ia',
        body: {'messages': mensajes},
      );

      if (response.data != null && response.data['response'] != null) {
        return response.data['response'] as String;
      } else {
        return 'Lo siento, no pude procesar tu mensaje. Intenta de nuevo.';
      }
    } catch (e) {
      print('❌ Error en Chat IA: $e');
      return 'Error de conexión. Por favor, intenta más tarde.';
    }
  }

  // Guardar mensaje en historial
  static Future<void> guardarMensaje({
    required String userId,
    required String role,
    required String message,
  }) async {
    try {
      await _client.from('chat_history').insert({
        'user_id': userId,
        'role': role,
        'message': message,
      });
    } catch (e) {
      print('❌ Error al guardar mensaje: $e');
    }
  }
}