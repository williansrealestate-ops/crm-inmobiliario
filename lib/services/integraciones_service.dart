import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'finanzas_service.dart'; // ✅ IMPORT NECESARIO AGREGADO

class IntegracionesService {
  
  // ✅ MÉTODO CORREGIDO: Ahora está DENTRO de la clase IntegracionesService
  static Future<void> verificarLogrosFinancieros() async {
    final resumen = await FinanzasService.getResumenFinanciero();
    final metas = await FinanzasService.getMetas();

    // Las funciones de badges están comentadas porque no existen en tu código actual.
    // Si las tienes definidas más abajo, puedes descomentarlas.
    
    if (resumen['ingresosMes'] >= metas['metaMensual']) {
      // await agregarBadgeFinanciero('meta_mensual');
    }
    
    if (resumen['ingresosAnio'] >= metas['metaAnual']) {
      // await agregarBadgeFinanciero('meta_anual');
    }

    if (resumen['ingresosMes'] > 0) {
      // await agregarBadgeFinanciero('primer_ingreso');
    }

    if (resumen['ingresosMes'] > metas['metaMensual'] * 1.5) {
      // await agregarBadgeFinanciero('sobrecumplimiento');
    }
  }

  // ✅ MÉTODO QUE YA USABAS EN EL FORMULARIO (Mantén tu lógica real si es diferente)
  static Map<String, dynamic> calcularComisionParaFinanzas(double montoVenta, double porcentajeComision) {
    final comisionBruta = montoVenta * (porcentajeComision / 100);
    final impuestos = comisionBruta * 0.16; // Ejemplo: 16% de retención/IVA
    final comisionNeta = comisionBruta - impuestos;

    return {
      'comisionBruta': comisionBruta,
      'impuestos': impuestos,
      'comisionNeta': comisionNeta,
    };
  }

  // ========================================================================
  // ⚠️ AQUÍ DEBES PEGAR EL RESTO DE TUS MÉTODOS EXISTENTES 
  // (como getBadgesFinancieros, agregarBadgeFinanciero, etc.)
  // Asegúrate de que TODOS estén dentro de estas llaves { } de la clase.
  // ========================================================================

} // ✅ ESTA ES LA LLAVE DE CIERRE DE LA CLASE. NADA DEBE IR DESPUÉS DE ESTA LLAVE.