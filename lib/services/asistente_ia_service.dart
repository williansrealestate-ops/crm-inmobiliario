import 'dart:convert';
import 'dart:html' as html;
import 'local_storage_service.dart';

class AsistenteIAService {
  static const String _keyConversaciones = 'asistente_ia_conversaciones';
  static const String _keyLeads = 'asistente_ia_leads';

  static final Map<String, List<String>> palabrasClave = {
    'buscar_propiedad': ['buscar', 'quiero', 'necesito', 'casa', 'departamento', 'terreno', 'propiedad', 'inmueble'],
    'agendar_visita': ['visita', 'agendar', 'cita', 'ver', 'conocer', 'cuando puedo', 'disponible'],
    'informacion_general': ['informacion', 'detalles', 'caracteristicas', 'descripcion', 'saber mas'],
    'calificar_lead': ['presupuesto', 'financiamiento', 'credito', 'enganche', 'mensualidad'],
    'despedida': ['adios', 'gracias', 'hasta luego', 'chao', 'bye'],
    'saludo': ['hola', 'buenos dias', 'buenas tardes', 'buenas noches', 'hey', 'saludos'],
    'precio': ['precio', 'costo', 'cuanto cuesta', 'valor', 'cuanto vale'],
    'ubicacion': ['ubicacion', 'donde esta', 'zona', 'colonia', 'direccion', 'cerca de'],
  };

  static String detectarIntencion(String mensaje) {
    final mensajeLower = mensaje.toLowerCase();
    Map<String, int> puntuaciones = {};

    for (var entrada in palabrasClave.entries) {
      int puntuacion = 0;
      for (String palabra in entrada.value) {
        if (mensajeLower.contains(palabra)) puntuacion++;
      }
      if (puntuacion > 0) puntuaciones[entrada.key] = puntuacion;
    }

    if (puntuaciones.isEmpty) return 'informacion_general';
    return puntuaciones.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static String generarRespuesta(String mensaje, String? nombreCliente) {
    final intencion = detectarIntencion(mensaje);
    final propiedades = LocalStorageService.getInmuebles();
    final mensajeLower = mensaje.toLowerCase();

    switch (intencion) {
      case 'saludo':
        return '¡Hola${nombreCliente != null ? " $nombreCliente" : ""}! 👋 Soy el asistente virtual de Real Estate. ¿Qué tipo de inmueble estás buscando?';
      case 'buscar_propiedad':
        String tipo = 'casa';
        if (mensajeLower.contains('departamento')) tipo = 'departamento';
        if (mensajeLower.contains('terreno')) tipo = 'terreno';
        final filtradas = propiedades.where((p) => (p['tipo'] ?? '').toString().toLowerCase().contains(tipo)).toList();
        if (filtradas.isEmpty) return 'Disculpa, no tengo propiedades de tipo "$tipo" disponibles. ¿Te interesa otro tipo?';
        final top3 = filtradas.take(3).toList();
        String resp = '¡Excelente! 🏠 Tengo ${filtradas.length} propiedades de tipo "$tipo". Aquí las más destacadas:\n\n';
        for (int i = 0; i < top3.length; i++) {
          final prop = top3[i];
          resp += '${i + 1}. **${prop['titulo']}**\n   📍 ${prop['ubicacion']}\n   💰 \$${_formatearNumero(prop['precio'])}\n\n';
        }
        return '$resp¿Te gustaría agendar una visita?';
      case 'agendar_visita':
        return '¡Perfecto! 📅 Para coordinar, ¿podrías decirme:\n1. ¿Qué propiedad te interesa?\n2. ¿Qué día y hora te conviene?\nUn asesor te contactará en menos de 2 horas.';
      case 'precio':
        return 'Nuestras propiedades van desde los \$500,000 hasta los \$15,000,000. 💰 ¿Tienes un presupuesto específico en mente?';
      case 'ubicacion':
        final zonas = propiedades.map((p) => p['ubicacion']).toSet().toList();
        return 'Tenemos propiedades en: ${zonas.take(5).join(", ")}. ¿Hay alguna zona en particular que te interese?';
      case 'despedida':
        return '¡Fue un placer ayudarte! 😊 Si tienes más preguntas, no dudes en contactarnos. ¡Que tengas excelente día!';
      default:
        return 'Entiendo. Puedo ayudarte con:\n🏠 Buscar propiedades\n📅 Agendar visitas\n💰 Información de precios\n📍 Ubicaciones\n¿En qué te puedo ayudar?';
    }
  }

  static Map<String, dynamic> calificarLead({
    required String nombre,
    required String telefono,
    required String email,
    required List<Map<String, dynamic>> mensajes,
  }) {
    int puntuacion = 0;
    List<String> intereses = [];
    for (var msg in mensajes) {
      final texto = (msg['texto'] ?? '').toString().toLowerCase();
      final intencion = detectarIntencion(texto);
      if (intencion == 'buscar_propiedad') puntuacion += 20;
      if (intencion == 'agendar_visita') puntuacion += 30;
      if (intencion == 'calificar_lead') puntuacion += 25;
      if (texto.contains('casa')) intereses.add('Casa');
      if (texto.contains('departamento')) intereses.add('Departamento');
    }
    String nivel = puntuacion >= 60 ? 'Alto' : (puntuacion >= 30 ? 'Medio' : 'Bajo');
    return {
      'nombre': nombre, 'telefono': telefono, 'email': email,
      'puntuacion': puntuacion, 'nivelInteres': nivel, 'intereses': intereses,
      'fecha': DateTime.now().toIso8601String(),
    };
  }

  static void guardarConversacion({required String sessionId, required List<Map<String, dynamic>> mensajes, Map<String, dynamic>? leadCalificado}) {
    try {
      final conv = _getConversaciones();
      conv.add({'sessionId': sessionId, 'mensajes': mensajes, 'leadCalificado': leadCalificado, 'fecha': DateTime.now().toIso8601String()});
      html.window.localStorage[_keyConversaciones] = jsonEncode(conv);
    } catch (e) { print('Error: $e'); }
  }

  static List<Map<String, dynamic>> _getConversaciones() {
    try {
      final json = html.window.localStorage[_keyConversaciones];
      if (json != null) return (jsonDecode(json) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {}
    return [];
  }

  static void guardarLead(Map<String, dynamic> lead) {
    try {
      final leads = _getLeads();
      leads.add(lead);
      html.window.localStorage[_keyLeads] = jsonEncode(leads);
    } catch (e) { print('Error: $e'); }
  }

  static List<Map<String, dynamic>> _getLeads() {
    try {
      final json = html.window.localStorage[_keyLeads];
      if (json != null) return (jsonDecode(json) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {}
    return [];
  }

  static String _formatearNumero(dynamic numero) {
    if (numero == null) return '0';
    final num n = numero is String ? double.tryParse(numero.replaceAll(',', '')) ?? 0 : numero as num;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }
}