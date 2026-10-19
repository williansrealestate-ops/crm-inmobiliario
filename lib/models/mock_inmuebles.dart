import 'inmueble.dart';

class MockInmuebles {
  // Lista temporal para datos en memoria (cuando se agregan nuevos)
  static List<Inmueble> lista = [];

  // Método para calcular ingresos totales (suma de comisiones)
  static double get ingresosTotales {
    return lista.fold(0, (total, inmueble) => total + inmueble.comision);
  }

  // Método para calcular ventas totales
  static double get ventasTotales {
    return lista.fold(0, (total, inmueble) => total + inmueble.precio);
  }
}
