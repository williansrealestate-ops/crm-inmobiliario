import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/inmueble.dart';

class DetalleInmueble extends StatefulWidget {
  final Inmueble inmueble;
  const DetalleInmueble({super.key, required this.inmueble});

  @override
  State<DetalleInmueble> createState() => _DetalleInmuebleState();
}

class _DetalleInmuebleState extends State<DetalleInmueble> {
  final PageController _pageController = PageController();
  int _fotoActual = 0;

  // Fotos de ejemplo (en producción vendrían de la base de datos)
  final List<String> _fotos = [
    'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800',
    'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800',
    'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
    'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Disponible':
        return AppTheme.success;
      case 'Vendido':
        return AppTheme.danger;
      case 'Rentado':
        return AppTheme.primary;
      case 'Reservado':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'Casa':
        return AppTheme.primary;
      case 'Departamento':
        return Colors.purple;
      case 'Terreno':
        return AppTheme.success;
      case 'Gasolinera':
        return AppTheme.accent;
      case 'Hotel':
        return Colors.pink;
      case 'Mina':
        return Colors.brown;
      case 'Local':
        return Colors.teal;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado(widget.inmueble.estadoVenta);
    final colorTipo = _colorTipo(widget.inmueble.tipo);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.inmueble.titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Formulario de edición (próximamente)')),
              );
            },
            icon: const Icon(Icons.edit, color: AppTheme.accent, size: 20),
            label: const Text('Editar',
                style: TextStyle(
                    color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar inmueble'),
                  content: Text(
                      '¿Estás seguro de eliminar "${widget.inmueble.titulo}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${widget.inmueble.titulo} eliminado'),
                            backgroundColor: AppTheme.danger,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.danger),
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete, color: AppTheme.danger, size: 20),
            label: const Text('Borrar',
                style: TextStyle(
                    color: AppTheme.danger, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GALERÍA DE FOTOS
            SizedBox(
              height: 350,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _fotos.length,
                    onPageChanged: (index) {
                      setState(() => _fotoActual = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        _fotos[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.background,
                            child: Icon(Icons.broken_image,
                                size: 80,
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.5)),
                          );
                        },
                      );
                    },
                  ),
                  // Indicadores de fotos
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_fotos.length, (index) {
                        return Container(
                          width: _fotoActual == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _fotoActual == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Contador de fotos
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_fotoActual + 1} / ${_fotos.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO Y PRECIO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.inmueble.titulo,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(widget.inmueble.ubicacion,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.inmueble.precioFormateado,
                          style: const TextStyle(
                              color: AppTheme.success,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BADGES DE TIPO Y ESTADO
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: colorTipo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.inmueble.tipo,
                            style: TextStyle(
                                color: colorTipo, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.inmueble.estadoVenta,
                            style: TextStyle(
                                color: colorEstado,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CARACTERÍSTICAS PRINCIPALES
                  const Text('Características',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildCaracteristica(Icons.bed, 'Habitaciones',
                              '${widget.inmueble.habitaciones}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildCaracteristica(Icons.bathtub, 'Baños',
                              '${widget.inmueble.banos}')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildCaracteristica(
                              Icons.local_parking,
                              'Estacionamientos',
                              '${widget.inmueble.estacionamientos}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildCaracteristica(
                              Icons.square_foot,
                              'Área terreno',
                              '${widget.inmueble.areaTerreno.toStringAsFixed(0)} m²')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildCaracteristica(
                              Icons.home_work,
                              'Área construcción',
                              '${widget.inmueble.areaConstruccion.toStringAsFixed(0)} m²')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // DESCRIPCIÓN
                  const Text('Descripción',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.inmueble.descripcion,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppTheme.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CARACTERÍSTICAS ADICIONALES
                  if (widget.inmueble.caracteristicas.isNotEmpty) ...[
                    const Text('Características adicionales',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              widget.inmueble.caracteristicas.map((caract) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 16, color: AppTheme.primary),
                                  const SizedBox(width: 6),
                                  Text(caract,
                                      style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // UBICACIÓN EN MAPA (simulado)
                  const Text('Ubicación',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Mapa simulado con gradiente
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primary.withValues(alpha: 0.1),
                                      AppTheme.success.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.map,
                                          size: 64,
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.5)),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Mapa interactivo',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '(Requiere API key de Google Maps)',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Marcador de ubicación
                              Positioned(
                                top: 80,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.danger
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.location_on,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.place, 'Dirección',
                                  widget.inmueble.direccion),
                              const Divider(),
                              _buildInfoRow(Icons.location_city, 'Municipio',
                                  widget.inmueble.municipio),
                              const Divider(),
                              _buildInfoRow(
                                  Icons.map, 'Estado', widget.inmueble.estado),
                              const Divider(),
                              _buildInfoRow(
                                  Icons.flag, 'País', widget.inmueble.pais),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PROPIETARIO Y ASESOR
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Propietario',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppTheme.textSecondary)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primary
                                          .withValues(alpha: 0.1),
                                      child: Text(
                                          widget.inmueble.propietario[0],
                                          style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(widget.inmueble.propietario,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Asesor',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppTheme.textSecondary)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.accent
                                          .withValues(alpha: 0.1),
                                      child: Text(widget.inmueble.asesor[0],
                                          style: const TextStyle(
                                              color: AppTheme.accent,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(widget.inmueble.asesor,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // BOTONES DE ACCIÓN
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildActionButton(Icons.call, 'Llamar', () {})),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _buildActionButton(Icons.email, 'Email', () {})),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildActionButton(
                              Icons.share, 'Compartir', () {})),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaracteristica(IconData icon, String label, String valor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(valor,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primary, size: 24),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
