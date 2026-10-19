import 'dart:html' as html;
import 'dart:convert';

class FileStorageService {
  static const String _fileName = 'real_estate_crm_data.json';
  static const String _localStorageKey = 'crm_data_backup';

  // ✅ Guardar datos como archivo descargable
  static void descargarArchivo(Map<String, dynamic> datos) {
    try {
      final jsonStr = jsonEncode(datos);
      
      // Crear blob y descargar
      final blob = html.Blob([jsonStr], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$_fileName')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      print('✅ Archivo descargado: ${(jsonStr.length / 1024).toStringAsFixed(2)} KB');
    } catch (e) {
      print(' Error al descargar: $e');
    }
  }

  // ✅ Cargar datos desde archivo seleccionado
  static Future<Map<String, dynamic>?> cargarDesdeArchivo() async {
    try {
      final fileInput = html.FileUploadInputElement()
        ..accept = '.json'
        ..click();

      final files = await fileInput.onChange.first.then((_) => fileInput.files);
      
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        reader.readAsText(file);
        
        final text = await reader.onLoad.first.then((_) => reader.result as String);
        final datos = jsonDecode(text) as Map<String, dynamic>;
        
        print('✅ Archivo cargado: ${(text.length / 1024).toStringAsFixed(2)} KB');
        return datos;
      }
    } catch (e) {
      print('❌ Error al cargar archivo: $e');
    }
    return null;
  }

  // ✅ Guardar en localStorage como respaldo
  static void guardarRespaldoLocal(Map<String, dynamic> datos) {
    try {
      final jsonStr = jsonEncode(datos);
      html.window.localStorage[_localStorageKey] = jsonStr;
      print('✅ Respaldo local creado');
    } catch (e) {
      print('️ No se pudo crear respaldo local: $e');
    }
  }

  // ✅ Cargar desde respaldo local
  static Map<String, dynamic>? cargarRespaldoLocal() {
    try {
      final jsonStr = html.window.localStorage[_localStorageKey];
      if (jsonStr != null) {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {}
    return null;
  }

  // ✅ Auto-guardar en localStorage (sin fotos para no llenarlo)
  static void autoGuardar(Map<String, dynamic> datos) {
    try {
      final datosSinFotos = Map<String, dynamic>.from(datos);
      if (datosSinFotos['asesores'] is List) {
        final asesores = (datosSinFotos['asesores'] as List).map((a) {
          final asesor = Map<String, dynamic>.from(a as Map);
          asesor.remove('foto'); // Quitar fotos del respaldo local
          return asesor;
        }).toList();
        datosSinFotos['asesores'] = asesores;
      }
      guardarRespaldoLocal(datosSinFotos);
    } catch (e) {
      print('⚠️ Error en auto-guardado: $e');
    }
  }
}