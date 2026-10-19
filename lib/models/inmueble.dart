class Inmueble {
  final int id;
  final String titulo;
  final String tipo;
  final double precio;
  final String moneda;
  final String pais;
  final String estado;
  final String municipio;
  final String direccion;
  final double areaTerreno;
  final String unidadArea;
  final double areaConstruccion;
  final int habitaciones;
  final int banos;
  final int estacionamientos;
  final String estadoVenta;
  final String descripcion;
  final List<String> caracteristicas;
  final List<String> fotos;
  final double comision;
  final double porcentajeComision;
  final String fechaAlta;
  final String propietario;
  final String asesor;

  Inmueble({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.precio,
    this.moneda = 'MXN',
    required this.pais,
    required this.estado,
    required this.municipio,
    required this.direccion,
    this.areaTerreno = 0,
    this.unidadArea = 'm2',
    this.areaConstruccion = 0,
    this.habitaciones = 0,
    this.banos = 0,
    this.estacionamientos = 0,
    this.estadoVenta = 'Disponible',
    this.descripcion = '',
    this.caracteristicas = const [],
    this.fotos = const [],
    this.comision = 0,
    this.porcentajeComision = 6,
    this.fechaAlta = '',
    this.propietario = '',
    this.asesor = '',
  });

  String get ubicacion => '$municipio, $estado, $pais';

  String get precioFormateado {
    final precioFormateado = precio.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '\$$precioFormateado $moneda';
  }

  String get comisionFormateada {
    final comisionFormateada = comision.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '\$$comisionFormateada MXN';
  }
}
