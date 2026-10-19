import 'dart:convert';
import 'dart:html' as html;

class ExamenesService {
  static const String _keyResultados = 'examenes_resultados';

  static final List<Map<String, dynamic>> examenes = [
    {
      'id': 'basico',
      'titulo': 'Examen Básico Inmobiliario',
      'descripcion': 'Conceptos fundamentales del mercado inmobiliario',
      'duracion': 15,
      'preguntas': [
        {'pregunta': '¿Qué es el AMV?', 'opciones': ['Análisis de Mercado de Valores', 'Avalúo Municipal de Vivienda', 'Asesoría de Mercado Variable'], 'correcta': 0},
        {'pregunta': '¿Cuál es la comisión estándar por venta?', 'opciones': ['3%', '6%', '10%'], 'correcta': 1},
        {'pregunta': '¿Qué documento acredita la propiedad?', 'opciones': ['Predial', 'Escritura pública', 'INE'], 'correcta': 1},
        {'pregunta': '¿Cuántos años se conservan documentos por Ley Antilavado?', 'opciones': ['3 años', '5 años', '10 años'], 'correcta': 1},
        {'pregunta': '¿Qué es la plusvalía?', 'opciones': ['Impuesto', 'Aumento de valor', 'Tipo de crédito'], 'correcta': 1},
      ],
    },
    {
      'id': 'legal',
      'titulo': 'Marco Legal Inmobiliario',
      'descripcion': 'Leyes y regulaciones aplicables',
      'duracion': 20,
      'preguntas': [
        {'pregunta': '¿Qué es la LFPIORPI?', 'opciones': ['Ley de Protección al Consumidor', 'Ley Antilavado', 'Ley de Vivienda'], 'correcta': 1},
        {'pregunta': '¿Cuál es el umbral 2026 para enajenación?', 'opciones': ['5,000 UMAs', '7,350 UMAs', '10,000 UMAs'], 'correcta': 1},
        {'pregunta': '¿Quién da fe pública en una compraventa?', 'opciones': ['El asesor', 'El notario', 'El juez'], 'correcta': 1},
        {'pregunta': '¿Qué es el ISAI?', 'opciones': ['Impuesto sobre Adquisición de Inmuebles', 'Impuesto Social', 'Impuesto Anual'], 'correcta': 0},
        {'pregunta': '¿Cuánto dura un fideicomiso en zona restringida?', 'opciones': ['25 años', '50 años', '100 años'], 'correcta': 1},
      ],
    },
    {
      'id': 'ventas',
      'titulo': 'Técnicas de Venta y Cierre',
      'descripcion': 'Habilidades comerciales avanzadas',
      'duracion': 15,
      'preguntas': [
        {'pregunta': '¿Qué es el cierre silencioso?', 'opciones': ['No hablar después de la oferta', 'Cerrar sin contrato', 'Vender sin comisión'], 'correcta': 0},
        {'pregunta': '¿Cuál es la regla del 30% en financiamiento?', 'opciones': ['30% de enganche', 'Mensualidad no debe exceder 30% del ingreso', '30% de comisión'], 'correcta': 1},
        {'pregunta': '¿Qué significa BANT?', 'opciones': ['Budget, Authority, Need, Timing', 'Buy, Analyze, Negotiate, Trade', 'Bank, Account, Number, Transfer'], 'correcta': 0},
        {'pregunta': '¿Cuál es el tiempo promedio de venta?', 'opciones': ['30 días', '90-180 días', '1 año'], 'correcta': 1},
        {'pregunta': '¿Qué hacer cuando el cliente dice "lo voy a pensar"?', 'opciones': ['Insistir', 'Indagar la objeción real', 'Despedirse'], 'correcta': 1},
      ],
    },
  ];

  static List<Map<String, dynamic>> getResultados() {
    try {
      final json = html.window.localStorage[_keyResultados];
      if (json != null) {
        return (jsonDecode(json) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  static void guardarResultado(Map<String, dynamic> resultado) {
    final resultados = getResultados();
    resultado['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    resultado['fecha'] = DateTime.now().toIso8601String();
    resultados.add(resultado);
    try {
      html.window.localStorage[_keyResultados] = jsonEncode(resultados);
    } catch (e) {
      print('Error: $e');
    }
  }

  static Map<String, dynamic>? getMejorResultado(String examenId) {
    final resultados = getResultados().where((r) => r['examenId'] == examenId).toList();
    if (resultados.isEmpty) return null;
    resultados.sort((a, b) => (b['porcentaje'] as double).compareTo(a['porcentaje'] as double));
    return resultados.first;
  }
}