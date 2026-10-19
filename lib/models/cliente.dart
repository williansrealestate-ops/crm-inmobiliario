class Cliente {
  final int id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final String tipo; // Comprador, Vendedor, Inversionista
  final String interes; // Casa, Departamento, Terreno, etc.
  final String estado; // Activo, Inactivo, Prospecto
  final String pais; // México, USA, etc.
  final String estadoUbicacion; // Campeche, Tabasco, etc.
  final String presupuesto;
  final String notas;
  final String fotoUrl;
  final String fechaAlta;

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.tipo,
    required this.interes,
    required this.estado,
    required this.pais,
    required this.estadoUbicacion,
    required this.presupuesto,
    required this.notas,
    required this.fotoUrl,
    required this.fechaAlta,
  });

  String get nombreCompleto => '$nombre $apellido';
}
