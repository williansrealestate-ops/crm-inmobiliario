import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<void> enviarMensaje(String telefono, String mensaje) async {
    String telefonoLimpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (telefonoLimpio.length == 10) telefonoLimpio = '52$telefonoLimpio';
    final mensajeCodificado = Uri.encodeComponent(mensaje);
    final url = Uri.parse('https://wa.me/$telefonoLimpio?text=$mensajeCodificado');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, webOnlyWindowName: '_blank');
    }
  }

  static Future<void> llamar(String telefono) async {
    final url = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  static Future<void> enviarEmail(String email, String asunto, String cuerpo) async {
    final url = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(asunto)}&body=${Uri.encodeComponent(cuerpo)}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}