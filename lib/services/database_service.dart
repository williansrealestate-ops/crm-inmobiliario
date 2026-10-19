import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class DatabaseService {
  static const String sheetApiUrl =
      'https://script.google.com/macros/s/AKfycbzhiEl1Tsa77tbFZ3wtY1wqwb2gDqN1xFZEPvTJdvPahESKwukfpgrhoOVGjatAjnx-ww/exec';

  Future<List<Map<String, dynamic>>> getData(String sheetName) async {
    try {
      final url = '$sheetApiUrl?sheet=$sheetName';
      debugPrint('🔗 Solicitando: $url');

      if (kIsWeb) {
        // Método para WEB usando XMLHttpRequest (evita CORS)
        final completer = Completer<String>();

        final xhr = html.HttpRequest();
        xhr.open('GET', url);

        xhr.onLoad.listen((_) {
          completer.complete(xhr.responseText);
        });

        xhr.onError.listen((_) {
          completer.completeError('Error en la petición');
        });

        xhr.send();

        final responseText = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw 'Timeout',
        );

        debugPrint('📡 Respuesta recibida: ${responseText.length} caracteres');

        final dynamic decoded = json.decode(responseText);

        if (decoded is List) {
          debugPrint('✅ ${decoded.length} registros encontrados');
          return decoded
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }

        if (decoded is Map && decoded.containsKey('error')) {
          debugPrint(' Error del servidor: ${decoded['error']}');
        }

        return [];
      } else {
        // Para desktop/mobile (requiere http package)
        debugPrint('️ Método desktop no implementado aún');
        return [];
      }
    } catch (e) {
      debugPrint(' Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClientes() => getData('Clientes');
  Future<List<Map<String, dynamic>>> getAsesores() => getData('Asesores');
  Future<List<Map<String, dynamic>>> getInmuebles() => getData('Inmuebles');
  Future<List<Map<String, dynamic>>> getTareas() => getData('Tareas');
  Future<List<Map<String, dynamic>>> getPropiedades() => getData('Propiedades');
  Future<List<Map<String, dynamic>>> getInmobiliarias() =>
      getData('Inmobiliarias');

  Future<int> countRecords(String sheetName) async {
    final data = await getData(sheetName);
    return data.length;
  }
}
