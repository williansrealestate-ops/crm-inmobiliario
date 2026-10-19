import 'dart:html' as html;

class ThemeService {
  static const String _keyTema = 'tema_preferido';
  
  static bool esModoOscuro() {
    return html.window.localStorage[_keyTema] == 'oscuro';
  }
  
  static void alternarTema() {
    final esOscuro = esModoOscuro();
    html.window.localStorage[_keyTema] = esOscuro ? 'claro' : 'oscuro';
  }
  
  static void establecerTema(bool oscuro) {
    html.window.localStorage[_keyTema] = oscuro ? 'oscuro' : 'claro';
  }
}