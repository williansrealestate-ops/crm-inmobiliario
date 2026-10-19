import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/contenido_academico.dart';
import '../../services/whatsapp_service.dart';
import '../../services/gamificacion_service.dart';
import '../../services/analisis_inteligente_service.dart';
import 'conocimientos_screen.dart';

class AsistenteVirtualScreen extends StatefulWidget {
  const AsistenteVirtualScreen({super.key});

  @override
  State<AsistenteVirtualScreen> createState() => _AsistenteVirtualScreenState();
}

class _AsistenteVirtualScreenState extends State<AsistenteVirtualScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  final TextEditingController _sentimientoCtrl = TextEditingController();
  final TextEditingController _clienteNombreCtrl = TextEditingController();
  final TextEditingController _clienteTelefonoCtrl = TextEditingController();

  String _scriptTipo = 'captacion';
  String _scriptNombreCliente = '';
  String _scriptPropiedad = '';

  final Map<String, Map<String, dynamic>> _knowledgeBase = ContenidoAcademico.baseConocimientoChatbot;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
    if (_messages.isEmpty) {
      final mensajeBienvenida = AnalisisInteligenteService.generarMensajeBienvenida();
      _addBotMessage(
        mensajeBienvenida,
        opciones: [
          {'label': '📊 Ver recomendaciones de hoy', 'action': 'recomendaciones'},
          {'label': '🔒 Operaciones en proceso', 'action': 'operaciones'},
          {'label': '🎯 Clientes calificados', 'action': 'clientes_calificados'},
          {'label': '📈 Mi perfil profesional', 'action': 'perfil'},
          {'label': ' Captación', 'action': 'captacion'},
          {'label': '📄 Documentos', 'action': 'documentos'},
          {'label': ' Objeciones', 'action': 'objeciones'},
          {'label': '📊 Analizar Sentimiento', 'action': 'sentimiento'},
          {'label': '🎯 Generar Script', 'action': 'script'},
          {'label': ' Ir a Academia', 'action': 'academia'},
        ],
      );
    }
  }

  void _cargarHistorial() {
    try {
      final historialJson = html.window.localStorage['chatbot_historial'];
      if (historialJson != null && historialJson.isNotEmpty) {
        final historial = jsonDecode(historialJson) as List;
        final mensajesValidos = <Map<String, dynamic>>[];
        for (var item in historial) {
          if (item is Map && item.containsKey('text') && item.containsKey('isUser')) {
            mensajesValidos.add(Map<String, dynamic>.from(item));
          }
        }
        if (mensajesValidos.isNotEmpty) {
          setState(() {
            _messages.addAll(mensajesValidos);
          });
        } else {
          _limpiarHistorialSilencioso();
        }
      }
    } catch (e) {
      print('Error cargando historial: $e');
      _limpiarHistorialSilencioso();
    }
  }

  void _limpiarHistorialSilencioso() {
    try {
      html.window.localStorage.remove('chatbot_historial');
    } catch (e) {
      print('Error limpiando historial: $e');
    }
  }

  void _guardarHistorial() {
    try {
      final historialJson = jsonEncode(_messages);
      html.window.localStorage['chatbot_historial'] = historialJson;
    } catch (e) {
      print('Error guardando historial: $e');
    }
  }

  void _addBotMessage(String text, {List<Map<String, dynamic>>? opciones}) {
    if (!mounted) return;
    setState(() {
      _isTyping = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add({'text': text, 'isUser': false, 'opciones': opciones});
        _isTyping = false;
      });
      _scrollToBottom();
      _guardarHistorial();
    });
  }

  void _addUserMessage(String label, String action) {
    if (!mounted) return;
    setState(() {
      _messages.add({'text': label, 'isUser': true});
    });
    _scrollToBottom();
    _guardarHistorial();
    _procesarRespuesta(action);
  }

  void _procesarRespuesta(String accion) {
    if (accion == 'recomendaciones') {
      _mostrarRecomendacionesDiarias();
      return;
    }

    if (accion == 'operaciones') {
      _mostrarOperacionesEnProceso();
      return;
    }

    if (accion == 'clientes_calificados') {
      _mostrarClientesCalificados();
      return;
    }

    if (accion == 'perfil') {
      _mostrarPerfilProfesional();
      return;
    }

    if (accion == 'academia') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConocimientosScreen()),
      );
      return;
    }

    if (accion == 'busqueda') {
      return;
    }

    if (accion == 'sentimiento') {
      _mostrarDialogoSentimiento();
      return;
    }

    if (accion == 'script') {
      _mostrarDialogoScript();
      return;
    }

    if (accion == 'inicio') {
      final mensajeBienvenida = AnalisisInteligenteService.generarMensajeBienvenida();
      _addBotMessage(
        mensajeBienvenida,
        opciones: [
          {'label': ' Ver recomendaciones de hoy', 'action': 'recomendaciones'},
          {'label': ' Operaciones en proceso', 'action': 'operaciones'},
          {'label': '🎯 Clientes calificados', 'action': 'clientes_calificados'},
          {'label': '📈 Mi perfil profesional', 'action': 'perfil'},
          {'label': '🏠 Captación', 'action': 'captacion'},
          {'label': '📄 Documentos', 'action': 'documentos'},
          {'label': '🤝 Objeciones', 'action': 'objeciones'},
          {'label': ' Analizar Sentimiento', 'action': 'sentimiento'},
          {'label': '🎯 Generar Script', 'action': 'script'},
          {'label': '📚 Ir a Academia', 'action': 'academia'},
        ],
      );
      return;
    }

    final info = _knowledgeBase[accion];
    if (info != null) {
      final contenido = info['contenido'] as String;
      final caso = info['caso'] as String;
      final mensajeCompleto = contenido + '\n\n' + caso;
      _addBotMessage(
        mensajeCompleto,
        opciones: [
          {'label': '🔄 Volver al inicio', 'action': 'inicio'},
          {'label': '📊 Analizar Sentimiento', 'action': 'sentimiento'},
          {'label': '🎯 Generar Script', 'action': 'script'},
          {'label': '📚 Ir a Academia', 'action': 'academia'},
        ],
      );
    }
  }

  void _mostrarRecomendacionesDiarias() {
    final recomendaciones = AnalisisInteligenteService.generarRecomendacionesDiarias();

    if (recomendaciones.isEmpty) {
      _addBotMessage(
        '✅ ¡Excelente! No tienes recomendaciones urgentes para hoy.\n\nTu negocio está en buen estado. Sigue con el seguimiento sistemático de tus clientes y propiedades.',
        opciones: [
          {'label': '🔄 Volver al inicio', 'action': 'inicio'},
        ],
      );
      return;
    }

    String mensaje = '🎯 **Recomendaciones para hoy:**\n\n';
    for (var i = 0; i < recomendaciones.length; i++) {
      final rec = recomendaciones[i];
      mensaje = mensaje + '${i + 1}. ' + rec['titulo'].toString() + '\n';
      mensaje = mensaje + rec['descripcion'].toString() + '\n\n';
    }

    final opciones = <Map<String, dynamic>>[];
    for (var rec in recomendaciones) {
      opciones.add({'label': rec['accion'], 'action': 'accion_recomendacion', 'recomendacion': rec});
    }
    opciones.add({'label': '🔄 Volver al inicio', 'action': 'inicio'});

    _addBotMessage(mensaje, opciones: opciones);
  }

  void _mostrarOperacionesEnProceso() {
    final operaciones = AnalisisInteligenteService.getOperacionesEnProceso();

    if (operaciones.isEmpty) {
      _addBotMessage(
        '🔒 No tienes operaciones reservadas en este momento.\n\n¡Es momento de generar más reservas! Enfócate en mostrar propiedades a tus clientes calificados.',
        opciones: [
          {'label': ' Ver clientes calificados', 'action': 'clientes_calificados'},
          {'label': '🔄 Volver al inicio', 'action': 'inicio'},
        ],
      );
      return;
    }

    String mensaje = '🔒 **Operaciones en proceso (' + operaciones.length.toString() + '):**\n\n';
    for (var op in operaciones) {
      final dias = _calcularDiasDesdeFecha(op['fechaReserva'] ?? op['fechaIngreso'] ?? '');
      mensaje = mensaje + '• **' + op['titulo'].toString() + '** - ' + dias.toString() + ' días reservado\n';
      mensaje = mensaje + '  Precio: \$' + _formatearNumero(op['precio'] ?? '0') + '\n';
      mensaje = mensaje + '  Comprador: ' + (op['propietario'] ?? 'No asignado') + '\n\n';
    }

    _addBotMessage(
      mensaje,
      opciones: [
        {'label': '📊 Ver recomendaciones', 'action': 'recomendaciones'},
        {'label': '🔄 Volver al inicio', 'action': 'inicio'},
      ],
    );
  }

  void _mostrarClientesCalificados() {
    final clientes = AnalisisInteligenteService.getClientesCalificadosSinPropiedad();

    if (clientes.isEmpty) {
      _addBotMessage(
        '🎯 No tienes clientes calificados sin propiedad asignada.\n\n¡Excelente trabajo! Todos tus clientes calificados tienen propiedades en proceso.',
        opciones: [
          {'label': '🔒 Ver operaciones en proceso', 'action': 'operaciones'},
          {'label': '🔄 Volver al inicio', 'action': 'inicio'},
        ],
      );
      return;
    }

    String mensaje = '🎯 **Clientes calificados sin propiedad (' + clientes.length.toString() + '):**\n\n';
    for (var c in clientes) {
      final presupuesto = c['presupuesto'] ?? '0';
      mensaje = mensaje + '• **' + c['nombre'].toString() + '**\n';
      mensaje = mensaje + '  Presupuesto: \$' + _formatearNumero(presupuesto.toString()) + '\n';
      mensaje = mensaje + '  Tipo: ' + (c['tipo'] ?? 'No especificado') + '\n';
      mensaje = mensaje + '  Teléfono: ' + (c['telefono'] ?? 'No registrado') + '\n\n';
    }

    _addBotMessage(
      mensaje,
      opciones: [
        {'label': '📊 Ver recomendaciones', 'action': 'recomendaciones'},
        {'label': '🔄 Volver al inicio', 'action': 'inicio'},
      ],
    );
  }

  void _mostrarPerfilProfesional() {
    final perfil = AnalisisInteligenteService.getAnalisisPerfil();

    String mensaje = '📈 **Tu Perfil Profesional:**\n\n';
    mensaje = mensaje + '**Nivel:** ' + perfil['nivel'].toString() + ' 🏆\n\n';
    mensaje = mensaje + '**Métricas clave:**\n';
    mensaje = mensaje + '• Ventas cerradas: ' + perfil['totalVentas'].toString() + '\n';
    mensaje = mensaje + '• Ingresos generados: \$' + _formatearNumero(perfil['totalIngresos'].toString()) + '\n';
    mensaje = mensaje + '• Tasa de cierre: ' + (perfil['tasaCierre'] as double).toStringAsFixed(0) + '%\n';
    mensaje = mensaje + '• Productividad: ' + (perfil['tasaProductividad'] as double).toStringAsFixed(0) + '%\n\n';

    final fortalezas = perfil['fortalezas'] as List;
    if (fortalezas.isNotEmpty) {
      mensaje = mensaje + '**✅ Fortalezas:**\n';
      for (var f in fortalezas) {
        mensaje = mensaje + '• ' + f.toString() + '\n';
      }
      mensaje = mensaje + '\n';
    }

    final areasMejora = perfil['areasMejora'] as List;
    if (areasMejora.isNotEmpty) {
      mensaje = mensaje + '**🎯 Áreas de mejora:**\n';
      for (var a in areasMejora) {
        mensaje = mensaje + '• ' + a.toString() + '\n';
      }
    }

    _addBotMessage(
      mensaje,
      opciones: [
        {'label': '📊 Ver recomendaciones', 'action': 'recomendaciones'},
        {'label': ' Ir a Academia', 'action': 'academia'},
        {'label': '🔄 Volver al inicio', 'action': 'inicio'},
      ],
    );
  }

  void _buscarEnBaseDeConocimiento(String query) {
    final queryLower = query.toLowerCase();
    final resultados = <String>[];

    _knowledgeBase.forEach((key, value) {
      final contenido = value['contenido'].toString().toLowerCase();
      final titulo = value['titulo'].toString().toLowerCase();
      final caso = value['caso'].toString().toLowerCase();

      if (contenido.contains(queryLower) ||
          titulo.contains(queryLower) ||
          caso.contains(queryLower)) {
        resultados.add(key);
      }
    });

    if (resultados.isNotEmpty) {
      final primerResultado = resultados.first;
      final info = _knowledgeBase[primerResultado]!;
      final contenido = info['contenido'] as String;
      final caso = info['caso'] as String;
      final mensajeCompleto = contenido + '\n\n' + caso;
      _addBotMessage(
        mensajeCompleto,
        opciones: [
          {'label': '🔄 Volver al inicio', 'action': 'inicio'},
          {'label': '📚 Ir a Academia', 'action': 'academia'},
        ],
      );
    } else {
      final mensajeNoEncontrado = '🔍 No encontré información específica sobre "' + query + '" en mi base de conocimiento.\n\nTe sugiero:\n1. Revisar la sección de **Academia** para información detallada.\n2. Intentar con otras palabras clave.\n3. Seleccionar un tema de las opciones disponibles.';
      _addBotMessage(
        mensajeNoEncontrado,
        opciones: [
          {'label': '📚 Ir a Academia', 'action': 'academia'},
          {'label': '🔄 Ver todos los temas', 'action': 'inicio'},
        ],
      );
    }
  }

  void _analizarSentimiento(String texto) {
    final textoLower = texto.toLowerCase();
    
    final palabrasPositivas = [
      'me gusta', 'me encanta', 'interesante', 'interesado', 'quiero', 'me interesa',
      'perfecto', 'excelente', 'genial', 'bueno', 'sí', 'claro', 'por supuesto',
      'adelante', 'procedamos', 'me parece bien', 'estoy de acuerdo', 'me convence',
      'urgente', 'necesito', 'importante', 'cuánto', 'precio', 'financiamiento',
      'cuándo puedo', 'visitar', 'ver', 'información', 'detalles'
    ];
    
    final palabrasNegativas = [
      'no me gusta', 'no me interesa', 'no quiero', 'caro', 'muy caro',
      'no tengo', 'no puedo', 'imposible', 'difícil', 'no', 'jamás',
      'lo voy a pensar', 'déjame ver', 'quizás', 'tal vez', 'no estoy seguro',
      'no tengo dinero', 'no me alcanza', 'muy lejos', 'no me convence',
      'déjalo así', 'olvídalo', 'no insistas', 'no me llames'
    ];
    
    final palabrasNeutrales = [
      'ok', 'entiendo', 'ajá', 'mmm', 'déjame revisar', 'voy a checar',
      'hablamos luego', 'te aviso', 'mañana', 'la próxima semana'
    ];

    int puntajePositivo = 0;
    int puntajeNegativo = 0;
    int puntajeNeutral = 0;

    for (var palabra in palabrasPositivas) {
      if (textoLower.contains(palabra)) puntajePositivo++;
    }
    for (var palabra in palabrasNegativas) {
      if (textoLower.contains(palabra)) puntajeNegativo++;
    }
    for (var palabra in palabrasNeutrales) {
      if (textoLower.contains(palabra)) puntajeNeutral++;
    }

    String resultado;
    String emoji;
    String recomendacion;

    if (puntajePositivo > puntajeNegativo && puntajePositivo > puntajeNeutral) {
      resultado = '🟢 INTERÉS ALTO';
      emoji = '';
      recomendacion = 'Este cliente está MUY interesado. **Acción inmediata:**\n\n1. Agenda una visita HOY o mañana.\n2. Prepara documentos de precalificación.\n3. Ten listo el comparativo de mercado.\n4. Usa técnicas de cierre directo.\n5. Envía información detallada por WhatsApp ahora mismo.\n\n💡 *Este cliente puede cerrar en los próximos 7 días.*';
    } else if (puntajeNegativo > puntajePositivo) {
      resultado = ' INTERÉS BAJO';
      emoji = '️';
      recomendacion = 'Este cliente muestra POCO interés. **Recomendación:**\n\n1. No insistas demasiado (puede generar rechazo).\n2. Pregúntale qué le genera dudas específicas.\n3. Ofrece alternativas diferentes.\n4. Dale espacio y haz seguimiento en 7-10 días.\n\n💡 *A veces un "no" hoy es un "sí" en 3 meses.*';
    } else {
      resultado = '🟡 INTERÉS MODERADO';
      emoji = '⏳';
      recomendacion = 'Este cliente está INDECISO. **Estrategia recomendada:**\n\n1. Haz preguntas abiertas para entender sus dudas reales.\n2. Ofrece más información específica.\n3. Invítalo a una visita sin compromiso.\n4. Comparte testimonios de clientes satisfechos.\n5. Usa la técnica de cierre por opciones.\n\n💡 *La indecisión suele ocultar una objeción no expresada.*';
    }

    final mensajeAnalisis = emoji + ' **Análisis de Sentimiento:** ' + resultado + '\n\n**Texto analizado:** "' + texto + '"\n\n**Indicadores detectados:**\n• Señales positivas: ' + puntajePositivo.toString() + '\n• Señales negativas: ' + puntajeNegativo.toString() + '\n• Señales neutrales: ' + puntajeNeutral.toString() + '\n\n**Recomendación:**\n' + recomendacion;

    _addBotMessage(
      mensajeAnalisis,
      opciones: [
        {'label': '🔄 Volver al inicio', 'action': 'inicio'},
        {'label': ' Analizar otro texto', 'action': 'sentimiento'},
        {'label': '🎯 Generar script para este cliente', 'action': 'script'},
      ],
    );

    GamificacionService.registrarSentimientoAnalizado();
  }

  String _generarScript(String tipo, String nombreCliente, String propiedad) {
    final nombre = nombreCliente.isNotEmpty ? nombreCliente : '[Nombre del cliente]';
    final prop = propiedad.isNotEmpty ? propiedad : '[descripción de la propiedad]';

    switch (tipo) {
      case 'captacion':
        return ' **SCRIPT: LLAMADA DE CAPTACIÓN**\n\n"Hola ' + nombre + ', soy [Tu nombre] de [Tu inmobiliaria]. Te llamo porque vi que tienes una propiedad en [zona] y me gustaría platicar contigo sobre una oportunidad.\n\n¿Tienes 2 minutos?\n\n[Esperar respuesta]\n\nExcelente. Resulta que tengo clientes muy interesados en la zona y tu propiedad podría ser exactamente lo que buscan. Me gustaría agendar una visita para hacer una valuación profesional sin compromiso.\n\n¿Te parece bien el [día] a las [hora]?\n\n[Si acepta]\nPerfecto, te enviaré un WhatsApp con los detalles. ¡Gracias ' + nombre + '!"';

      case 'seguimiento':
        return '📞 **SCRIPT: SEGUIMIENTO POST-VISITA**\n\n"Hola ' + nombre + ', soy [Tu nombre]. Te llamo para saber qué te pareció ' + prop + ' que visitamos el [día].\n\n[Esperar respuesta]\n\nMe alegra que te haya gustado. ¿Tienes alguna duda o algo que quieras revisar nuevamente?\n\n[Si tiene dudas]\nCon gusto te aclaro todo. ¿Qué te parece si agendamos una segunda visita?\n\n[Si está interesado]\nExcelente. Para avanzar, necesitaría que me confirmes:\n1. ¿Tienes financiamiento pre-aprobado?\n2. ¿En qué tiempo te gustaría cerrar?\n\n[Si no está interesado]\nEntiendo perfectamente. ¿Hay algo específico que no te haya convencido?"';

      case 'cierre':
        return '🎯 **SCRIPT: CIERRE DE VENTA**\n\n"Hola ' + nombre + ', te llamo con buenas noticias sobre ' + prop + '.\n\n[Esperar respuesta]\n\nEl propietario me comentó que tiene otra oferta muy seria para mañana. Antes de responderle, quería darte la oportunidad porque sé que te interesa mucho.\n\n¿Te gustaría hacer una oferta hoy?\n\n[Si dice que sí]\nPerfecto. ¿Qué precio tendrías en mente?\n\n[Negociar]\n\nExcelente. Para formalizar, necesitaría:\n1. Copia de tu identificación\n2. Comprobante de ingresos o pre-aprobación\n3. Un anticipo del 10%\n\n¿Podrías traerlo mañana a las [hora]?\n\n[Si duda]\nEntiendo que es una decisión importante. ¿Qué te genera duda específicamente?"';

      case 'objeciones':
        return ' **SCRIPT: MANEJO DE OBJECIONES**\n\n**Si dice "Es muy caro":**\n"Entiendo tu preocupación, ' + nombre + '. Sin embargo, este precio refleja el valor real de mercado. De hecho, propiedades similares en la zona se han vendido hasta un 10% más caro en los últimos 6 meses. ¿Te gustaría que te muestre el comparativo?"\n\n**Si dice "Lo voy a pensar":**\n"Claro, es una decisión importante. ¿Hay algo específico que te genere duda? A veces lo que parece "pensarlo" es una objeción no expresada. ¿Qué te preocupa realmente?"\n\n**Si dice "Necesito hablarlo con mi esposa/esposo":**\n"Por supuesto, es una decisión en pareja. ¿Qué te parece si agendamos una visita juntos para que ambos la conozcan?"';

      default:
        return 'Script no disponible.';
    }
  }

  void _mostrarDialogoSentimiento() {
    _sentimientoCtrl.clear();
    _clienteNombreCtrl.clear();
    _clienteTelefonoCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.psychology, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text('Análisis de Sentimiento'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pega aquí la respuesta del cliente y analizaré su nivel de interés:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sentimientoCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Ej: "Me interesa mucho la casa, ¿cuándo puedo visitarla?"',
                    border: OutlineInputBorder(),
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Datos del cliente (opcional, para enviar por WhatsApp):', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                TextField(
                  controller: _clienteNombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del cliente', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _clienteTelefonoCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono (con lada)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final texto = _sentimientoCtrl.text.trim();
                if (texto.isNotEmpty) {
                  Navigator.pop(ctx);
                  _addUserMessage('📊 Analizar: "' + texto + '"', 'sentimiento_analisis');
                  _analizarSentimiento(texto);
                  
                  final telefono = _clienteTelefonoCtrl.text.trim();
                  final nombre = _clienteNombreCtrl.text.trim();
                  if (telefono.isNotEmpty) {
                    Future.delayed(const Duration(seconds: 1), () {
                      _addBotMessage(
                        '📱 ¿Deseas enviar este análisis al cliente ' + nombre + ' por WhatsApp?',
                        opciones: [
                          {'label': '📱 Sí, enviar por WhatsApp', 'action': 'whatsapp_sentimiento', 'telefono': telefono, 'nombre': nombre, 'texto': texto},
                          {'label': '❌ No, gracias', 'action': 'inicio'},
                        ],
                      );
                    });
                  }
                }
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Analizar'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoScript() {
    _scriptNombreCliente = '';
    _scriptPropiedad = '';
    _scriptTipo = 'captacion';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.article, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Generador de Scripts'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona el tipo de script:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _scriptTipo,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'captacion', child: Text('📞 Llamada de Captación')),
                    DropdownMenuItem(value: 'seguimiento', child: Text('📞 Seguimiento Post-Visita')),
                    DropdownMenuItem(value: 'cierre', child: Text('🎯 Cierre de Venta')),
                    DropdownMenuItem(value: 'objeciones', child: Text('🤝 Manejo de Objeciones')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _scriptTipo = value ?? 'captacion';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => _scriptNombreCliente = value,
                  decoration: const InputDecoration(labelText: 'Nombre del cliente (opcional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _scriptPropiedad = value,
                  decoration: const InputDecoration(labelText: 'Propiedad (opcional)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final script = _generarScript(_scriptTipo, _scriptNombreCliente, _scriptPropiedad);
                _addUserMessage(' Generar script: ' + _scriptTipo, 'script_generado');
                _addBotMessage(
                  script,
                  opciones: [
                    {'label': '📱 Enviar por WhatsApp', 'action': 'whatsapp_script', 'script': script},
                    {'label': '📋 Copiar script', 'action': 'copiar_script', 'script': script},
                    {'label': '🔄 Generar otro', 'action': 'script'},
                    {'label': '🔄 Volver al inicio', 'action': 'inicio'},
                  ],
                );
                GamificacionService.registrarScriptGenerado();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _copiarAlPortapapeles(String texto) {
    try {
      html.window.navigator.clipboard?.writeText(texto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Script copiado al portapapeles'), backgroundColor: Color(0xFF10B981)),
      );
    } catch (e) {
      print('Error copiando: $e');
    }
  }

  void _enviarWhatsApp(String telefono, String nombre, String mensaje) {
    final mensajeCompleto = 'Hola ' + nombre + ',\n\n' + mensaje + '\n\nSaludos,\n[Tu nombre]\n[Tu inmobiliaria]';
    WhatsAppService.enviarMensaje(telefono, mensajeCompleto);
    _addBotMessage(
      '✅ Mensaje enviado a ' + nombre + ' (' + telefono + ') por WhatsApp.\n\n**Mensaje enviado:**\n' + mensajeCompleto,
      opciones: [
        {'label': '🔄 Volver al inicio', 'action': 'inicio'},
      ],
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && _scrollController.position.hasPixels) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _limpiarHistorial() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar Historial'),
        content: const Text('¿Estás seguro de borrar todo el historial de conversaciones?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() { _messages.clear(); });
              _limpiarHistorialSilencioso();
              Navigator.pop(ctx);
              _addBotMessage('Historial borrado. ¿En qué puedo ayudarte?', opciones: [
                {'label': '🏠 Captación', 'action': 'captacion'},
                {'label': '📊 Analizar Sentimiento', 'action': 'sentimiento'},
                {'label': '🎯 Generar Script', 'action': 'script'},
              ]);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  void _limpiarHistorialDirecto() {
    setState(() { _messages.clear(); });
    _limpiarHistorialSilencioso();
    _addBotMessage('Historial borrado. ¿En qué puedo ayudarte?', opciones: [
      {'label': '🏠 Captación', 'action': 'captacion'},
      {'label': '📊 Analizar Sentimiento', 'action': 'sentimiento'},
      {'label': '🎯 Generar Script', 'action': 'script'},
      {'label': '📚 Ir a Academia', 'action': 'academia'},
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _sentimientoCtrl.dispose();
    _clienteNombreCtrl.dispose();
    _clienteTelefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.smart_toy, color: Colors.white), SizedBox(width: 8), Text('Asistente Inmobiliario 4.0')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _limpiarHistorial, tooltip: 'Limpiar historial'),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) return _buildTypingIndicator();
                if (index >= _messages.length) return const SizedBox.shrink();
                final msg = _messages[index];
                final text = msg['text']?.toString() ?? '';
                final isUser = msg['isUser'] == true;
                List<Map<String, dynamic>>? opciones;
                if (msg['opciones'] != null && msg['opciones'] is List) {
                  opciones = (msg['opciones'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
                }
                return _buildMessageBubble(text, isUser, opciones);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), border: Border(top: BorderSide(color: AppTheme.getBorderColor(context)))),
            child: Column(
              children: [
                if (_messages.length > 2)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(onPressed: _limpiarHistorialDirecto, icon: const Icon(Icons.delete_sweep, size: 16), label: const Text('Limpiar chat', style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(foregroundColor: AppTheme.danger)),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu pregunta...',
                          hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context), fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              final query = _textController.text.trim();
                              if (query.isNotEmpty) {
                                _addUserMessage('🔍 ' + query, 'busqueda');
                                _buscarEnBaseDeConocimiento(query);
                                _textController.clear();
                              }
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _addUserMessage('🔍 ' + value, 'busqueda');
                            _buscarEnBaseDeConocimiento(value);
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [_buildDot(), const SizedBox(width: 4), _buildDot(delay: 200), const SizedBox(width: 4), _buildDot(delay: 400)]),
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, -4 * value), child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF64748B), shape: BoxShape.circle)));
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, List<Map<String, dynamic>>? opciones) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: isUser ? const Radius.circular(16) : Radius.zero, bottomRight: isUser ? Radius.zero : const Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: isUser ? Colors.white : const Color(0xFF0F172A), fontSize: 14, height: 1.5)),
            if (opciones != null && !isUser) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.black12),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opciones.map((opcion) {
                  final label = opcion['label']?.toString() ?? '';
                  final action = opcion['action']?.toString() ?? '';
                  
                  if (action == 'whatsapp_sentimiento') {
                    return ElevatedButton.icon(
                      onPressed: () {
                        final telefono = opcion['telefono']?.toString() ?? '';
                        final nombre = opcion['nombre']?.toString() ?? '';
                        final analisis = 'Análisis de tu mensaje: Revisa el resumen que te envié. Estoy aquí para ayudarte con cualquier duda sobre la propiedad.';
                        _enviarWhatsApp(telefono, nombre, analisis);
                      },
                      icon: const Icon(Icons.message, color: Color(0xFF25D366), size: 16),
                      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366).withOpacity(0.1), foregroundColor: const Color(0xFF25D366), side: const BorderSide(color: Color(0xFF25D366)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    );
                  }
                  
                  if (action == 'whatsapp_script') {
                    return ElevatedButton.icon(
                      onPressed: () {
                        final script = opcion['script']?.toString() ?? '';
                        _mostrarDialogoWhatsAppScript(script);
                      },
                      icon: const Icon(Icons.message, color: Color(0xFF25D366), size: 16),
                      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366).withOpacity(0.1), foregroundColor: const Color(0xFF25D366), side: const BorderSide(color: Color(0xFF25D366)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    );
                  }
                  
                  if (action == 'copiar_script') {
                    return ElevatedButton.icon(
                      onPressed: () {
                        final script = opcion['script']?.toString() ?? '';
                        _copiarAlPortapapeles(script);
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, elevation: 0, side: BorderSide(color: AppTheme.primary.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    );
                  }
                  
                  return ElevatedButton(
                    onPressed: () => _addUserMessage(label, action),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary, elevation: 0, side: BorderSide(color: AppTheme.primary.withOpacity(0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoWhatsAppScript(String script) {
    final telefonoCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.message, color: Color(0xFF25D366)), SizedBox(width: 8), Text('Enviar por WhatsApp')]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del cliente', border: OutlineInputBorder())),
            const SizedBox(height: 8),
            TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono (con lada, ej: 5215512345678)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            const Text('Vista previa del mensaje:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)),
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(child: Text(script, style: const TextStyle(fontSize: 11))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () {
              final telefono = telefonoCtrl.text.trim();
              final nombre = nombreCtrl.text.trim();
              if (telefono.isNotEmpty) {
                Navigator.pop(ctx);
                _enviarWhatsApp(telefono, nombre, script);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un teléfono válido'), backgroundColor: Color(0xFFEF4444)));
              }
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Enviar'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  int _calcularDiasDesdeFecha(String fechaStr) {
    if (fechaStr.isEmpty) return 0;
    try {
      final partes = fechaStr.split('/');
      final fecha = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
      final hoy = DateTime.now();
      return hoy.difference(fecha).inDays;
    } catch (e) {
      return 0;
    }
  }

  String _formatearNumero(String numero) {
    final valor = double.tryParse(numero.replaceAll(',', '')) ?? 0;
    if (valor >= 1000000) return (valor / 1000000).toStringAsFixed(1) + 'M';
    if (valor >= 1000) return (valor / 1000).toStringAsFixed(0) + 'K';
    return valor.toStringAsFixed(0);
  }
}