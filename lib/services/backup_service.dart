import 'dart:html' as html;
import 'dart:convert';
import 'indexed_db_service.dart';

class BackupService {
  // ✅ Claves de IndexedDB a respaldar
  static const List<String> _claves = [
    'asesores',
    'asesores_grupos',
    'clientes',
    'clientes_tipos',
    'inmuebles',
    'inmuebles_tipos',
    'ventas',
  ];

  // ✅ CREAR RESPALDO (Exportar todos los datos a JSON)
  static Future<void> crearRespaldo() async {
    final Map<String, dynamic> respaldo = {};
    
    for (var clave in _claves) {
      try {
        final datos = await IndexedDBService.get(clave);
        if (datos != null) {
          respaldo[clave] = datos;
          print('✅ $clave: respaldado');
        }
      } catch (e) {
        print('⚠️ Error al respaldar $clave: $e');
      }
    }
    
    // Agregar metadata
    respaldo['_metadata'] = {
      'fecha': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'app': 'Real Estate CRM',
      'totalRegistros': respaldo.length - 1,
    };
    
    // Descargar archivo
    final jsonStr = JsonEncoder.withIndent('  ').convert(respaldo);
    final blob = html.Blob([jsonStr], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'respaldo_crm_${DateTime.now().millisecondsSinceEpoch}.json')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    print('🎉 Respaldo creado exitosamente');
  }

  // ✅ IMPORTAR RESPALDO (Desde archivo JSON)
  static Future<Map<String, dynamic>> importarRespaldo() async {
    return await _seleccionarArchivo();
  }

  // ✅ Seleccionar archivo JSON
  static Future<Map<String, dynamic>> _seleccionarArchivo() async {
    final fileInput = html.FileUploadInputElement()
      ..accept = '.json'
      ..click();

    final files = await fileInput.onChange.first.then((_) => fileInput.files);
    
    if (files == null || files.isEmpty) {
      return {};
    }
    
    final file = files.first;
    final reader = html.FileReader();
    reader.readAsText(file);
    
    final text = await reader.onLoad.first.then((_) => reader.result as String);
    final datos = jsonDecode(text) as Map<String, dynamic>;
    
    return datos;
  }

  // ✅ Restaurar datos desde respaldo
  static Future<void> restaurarDesdeArchivo(Map<String, dynamic> datos) async {
    int registrosRestaurados = 0;
    
    for (var clave in _claves) {
      if (datos.containsKey(clave)) {
        await IndexedDBService.put(clave, datos[clave]);
        registrosRestaurados++;
        print('✅ $clave: restaurado');
      }
    }
    
    print('🎉 $registrosRestaurados secciones restauradas');
  }

  // ✅ Eliminar todos los datos (limpiar)
  static Future<void> limpiarTodo() async {
    for (var clave in _claves) {
      await IndexedDBService.delete(clave);
    }
    print('🗑️ Todos los datos eliminados');
  }

  // ✅ Obtener tamaño del respaldo
  static Future<int> getTamanoRespaldo() async {
    int total = 0;
    for (var clave in _claves) {
      final datos = await IndexedDBService.get(clave);
      if (datos != null) {
        total += datos.toString().length;
      }
    }
    return total;
  }

  // ✅ Obtener conteo de registros por sección
  static Future<Map<String, int>> getConteoRegistros() async {
    final conteo = <String, int>{};
    
    for (var clave in _claves) {
      try {
        final datos = await IndexedDBService.get(clave);
        if (datos != null) {
          final lista = jsonDecode(datos) as List;
          conteo[clave] = lista.length;
        } else {
          conteo[clave] = 0;
        }
      } catch (e) {
        conteo[clave] = 0;
      }
    }
    
    return conteo;
  }
}