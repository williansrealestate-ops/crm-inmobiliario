import 'package:flutter/material.dart';
import '../config/theme.dart';

class VitrinaHeader extends StatelessWidget {
  final Map<String, dynamic> config;
  final int totalPropiedades;
  final List<String> ubicaciones;
  final Function(String)? onBuscar;

  const VitrinaHeader({
    super.key,
    required this.config,
    required this.totalPropiedades,
    required this.ubicaciones,
    this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.85),
            AppTheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra superior con logo y navegación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.home, color: Color(0xFF007AFF), size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config['titulo'] ?? 'Real Estate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        config['descripcion'] ?? 'Encuentra tu propiedad ideal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (config['telefono'] != null && config['telefono'].toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          config['telefono'],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Hero section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Encuentra la propiedad\n de tus sueños',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Más de $totalPropiedades propiedades exclusivas en ${ubicaciones.length} ubicaciones',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.home,
                    valor: '$totalPropiedades',
                    label: 'Propiedades',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.location_on,
                    valor: '${ubicaciones.length}',
                    label: 'Ubicaciones',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: const _StatCard(
                    icon: Icons.verified,
                    valor: '100%',
                    label: 'Confiable',
                  ),
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: onBuscar,
                decoration: const InputDecoration(
                  hintText: 'Buscar por título o ubicación...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF8E8E93)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String valor;
  final String label;

  const _StatCard({
    required this.icon,
    required this.valor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}