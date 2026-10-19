import 'package:flutter/material.dart';

class TestimoniosSection extends StatefulWidget {
  const TestimoniosSection({super.key});

  @override
  State<TestimoniosSection> createState() => _TestimoniosSectionState();
}

class _TestimoniosSectionState extends State<TestimoniosSection> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _paginaActual = 0;

  final List<Map<String, dynamic>> _testimonios = [
    {
      'nombre': 'Juan Pérez',
      'cargo': 'Inversionista',
      'foto': 'JP',
      'estrellas': 5,
      'texto': 'Excelente servicio. Williams me ayudó a encontrar el terreno perfecto en Cozumel para mi proyecto de inversión. Profesionalismo total.',
      'fecha': 'Octubre 2026',
    },
    {
      'nombre': 'María López',
      'cargo': 'Compradora primera vez',
      'foto': 'ML',
      'estrellas': 5,
      'texto': 'El proceso fue muy claro y transparente. Me guiaron en cada paso de la compra de mi primera casa. ¡100% recomendados!',
      'fecha': 'Septiembre 2026',
    },
    {
      'nombre': 'Carlos Ruiz',
      'cargo': 'Empresario',
      'foto': 'CR',
      'estrellas': 5,
      'texto': 'Adquirí una hacienda en Puebla con su ayuda. El equipo conoce muy bien el mercado y las opciones de financiamiento.',
      'fecha': 'Agosto 2026',
    },
    {
      'nombre': 'Ana Martínez',
      'cargo': 'Inversionista internacional',
      'foto': 'AM',
      'estrellas': 5,
      'texto': 'Desde Dubai pude gestionar la compra de una propiedad en México. La comunicación fue impecable en todo momento.',
      'fecha': 'Julio 2026',
    },
    {
      'nombre': 'Luis García',
      'cargo': 'Desarrollador',
      'foto': 'LG',
      'estrellas': 5,
      'texto': 'He trabajado con Williams en múltiples proyectos. Su conocimiento del mercado inmobiliario es excepcional.',
      'fecha': 'Junio 2026',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
      ),
      child: Column(
        children: [
          const Text(
            'Lo que dicen nuestros clientes',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Más de 500 familias confían en nosotros',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _testimonios.length,
              onPageChanged: (index) => setState(() => _paginaActual = index),
              itemBuilder: (context, index) {
                final t = _testimonios[index];
                final isSelected = index == _paginaActual;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? const Color(0xFF0066FF).withOpacity(0.2) : Colors.black.withOpacity(0.08),
                        blurRadius: isSelected ? 20 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < t['estrellas'] ? Icons.star : Icons.star_border,
                            color: const Color(0xFFF59E0B),
                            size: 20,
                          )),
                          const Spacer(),
                          Text(
                            t['fecha'],
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Text(
                          '"${t['texto']}"',
                          style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.6, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                t['foto'],
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t['nombre'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                              Text(t['cargo'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_testimonios.length, (index) {
              final isActive = index == _paginaActual;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF0066FF) : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}