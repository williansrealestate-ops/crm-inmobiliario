import 'dart:convert';
import 'indexed_db_service.dart';

class FavoritosService {
  static const String _key = 'favoritos_inmuebles';

  static Future<List<String>> obtenerFavoritos() async {
    try {
      final json = await IndexedDBService.get(_key);
      if (json != null) {
        final lista = jsonDecode(json) as List;
        return lista.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
    return [];
  }

  static Future<void> guardarFavoritos(List<String> ids) async {
    await IndexedDBService.put(_key, jsonEncode(ids));
  }

  static Future<bool> esFavorito(String id) async {
    final favoritos = await obtenerFavoritos();
    return favoritos.contains(id);
  }

  static Future<void> toggleFavorito(String id) async {
    final favoritos = await obtenerFavoritos();
    if (favoritos.contains(id)) {
      favoritos.remove(id);
    } else {
      favoritos.add(id);
    }
    await guardarFavoritos(favoritos);
  }

  static Future<int> contarFavoritos() async {
    final favoritos = await obtenerFavoritos();
    return favoritos.length;
  }
}