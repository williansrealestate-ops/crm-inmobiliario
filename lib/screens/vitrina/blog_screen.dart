import 'package:flutter/material.dart';
import '../../config/theme.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  String _categoriaSeleccionada = 'Todos';
  final List<String> _categorias = ['Todos', 'Inversión', 'Consejos', 'Mercado', 'Legal', 'Noticias'];

  final List<Map<String, dynamic>> _articulos = [
    {
      'id': '1',
      'titulo': '5 Zonas con Mayor Plusvalía en México 2026',
      'categoria': 'Inversión',
      'fecha': '15 Oct 2026',
      'autor': 'Williams Carrillo',
      'imagen': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800',
      'resumen': 'Descubre las 5 zonas con mayor potencial de crecimiento inmobiliario en México para este año.',
      'contenido': 'El mercado inmobiliario mexicano presenta oportunidades únicas en 2026. Las zonas costeras como Cozumel, Tulum y Manzanillo muestran plusvalías del 15-20% anual. En el centro del país, ciudades como Querétaro y San Miguel de Allende continúan su crecimiento sostenido. Para inversionistas internacionales, Dubai representa una alternativa interesante con retornos del 8-12% anual. La clave está en diversificar y asesorarse con expertos locales.',
    },
    {
      'id': '2',
      'titulo': 'Guía Completa: Cómo Comprar tu Primera Casa',
      'categoria': 'Consejos',
      'fecha': '12 Oct 2026',
      'autor': 'Williams Carrillo',
      'imagen': 'https://images.unsplash.com/photo-1560520653-9e0e4c89eb11?w=800',
      'resumen': 'Todo lo que necesitas saber antes de comprar tu primera propiedad en México.',
      'contenido': 'Comprar tu primera casa es una decisión importante. Primero, define tu presupuesto considerando no solo el precio de la propiedad sino también gastos de escrituración (5-8% del valor). Segundo, obtén una pre-aprobación de crédito hipotecario. Tercero, investiga la zona: servicios, seguridad, plusvalía. Cuarto, visita la propiedad en diferentes horarios. Quinto, revisa toda la documentación legal con un notario de confianza.',
    },
    {
      'id': '3',
      'titulo': 'Tendencias del Mercado Inmobiliario 2026',
      'categoria': 'Mercado',
      'fecha': '10 Oct 2026',
      'autor': 'Williams Carrillo',
      'imagen': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
      'resumen': 'Análisis de las principales tendencias que están transformando el sector inmobiliario.',
      'contenido': 'El mercado inmobiliario 2026 está marcado por la digitalización, propiedades sustentables y el trabajo remoto. Las casas con oficinas en casa aumentaron 40% en demanda. Las propiedades eco-friendly obtienen 15% más valor. El mercado de lujo en zonas turísticas crece 25% anual. Los créditos hipotecarios tienen tasas competitivas del 9-11% anual.',
    },
    {
      'id': '4',
      'titulo': 'Aspectos Legales de la Compraventa en México',
      'categoria': 'Legal',
      'fecha': '8 Oct 2026',
      'autor': 'Williams Carrillo',
      'imagen': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
      'resumen': 'Conoce los aspectos legales esenciales para una transacción segura.',
      'contenido': 'La compraventa en México requiere: contrato de compraventa firmado ante notario, pago de impuestos (ISAI, ISR), escrituración pública, registro en el Registro Público de la Propiedad. Para extranjeros en zona restringida (50km de costa, 100km de fronteras) se requiere fideicomiso bancario. Siempre verifica que la propiedad esté libre de gravámenes.',
    },
    {
      'id': '5',
      'titulo': 'Inversión Inmobiliaria en Dubai: Oportunidades 2026',
      'categoria': 'Inversión',
      'fecha': '5 Oct 2026',
      'autor': 'Williams Carrillo',
      'imagen': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
      'resumen': 'Por qué Dubai se ha convertido en el destino favorito de inversionistas mexicanos.',
      'contenido': 'Dubai ofrece: cero impuestos sobre la renta, retornos del 8-12% anual, visa dorada por inversión (2M AED), mercado transparente y regulado. Las zonas más rentables: Downtown Dubai, Dubai Marina, Palm Jumeirah. El proceso de compra para extranjeros es sencillo y puede completarse en 30-60 días.',
    },
    {
      'id': '6',
      'titulo': 'Nuevas Regulaciones Hipotecarias 2026',
      'categoria': 'Noticias',
      'fecha': '1 Oct 2026',
      'autor': 'Williams Carrillo',
      'imagen': 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
      'resumen': 'Cambios importantes en las regulaciones de créditos hipotecarios.',
      'contenido': 'Las nuevas regulaciones incluyen: requisitos más flexibles para primera vivienda, tasas preferenciales para créditos verdes (propiedades sustentables), digitalización del proceso de aprobación, y mayores montos de financiamiento (hasta 95% del valor para ciertos perfiles). Consulta con tu asesor para conocer las opciones disponibles.',
    },
  ];

  List<Map<String, dynamic>> get _articulosFiltrados {
    if (_categoriaSeleccionada == 'Todos') return _articulos;
    return _articulos.where((a) => a['categoria'] == _categoriaSeleccionada).toList();
  }

  Color _getColorCategoria(String categoria) {
    switch (categoria) {
      case 'Inversión': return const Color(0xFF10B981);
      case 'Consejos': return const Color(0xFF3B82F6);
      case 'Mercado': return const Color(0xFFF59E0B);
      case 'Legal': return const Color(0xFFEF4444);
      case 'Noticias': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Blog Inmobiliario',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF1E40AF)]),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Noticias y Consejos',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mantente informado sobre el mundo inmobiliario',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            // Filtros de categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              color: Colors.white,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categorias.map((cat) {
                  final isSelected = _categoriaSeleccionada == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _categoriaSeleccionada = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de artículos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: _articulosFiltrados.map((articulo) => _buildArticuloCard(articulo)).toList(),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildArticuloCard(Map<String, dynamic> articulo) {
    final colorCat = _getColorCategoria(articulo['categoria']);
    return GestureDetector(
      onTap: () => _verDetalle(articulo),
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: Container(
                height: 200,
                width: double.infinity,
                color: colorCat.withOpacity(0.2),
                child: Image.network(
                  articulo['imagen'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child: Icon(Icons.article, size: 64, color: colorCat)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorCat.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          articulo['categoria'],
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorCat),
                        ),
                      ),
                      const Spacer(),
                      Text(articulo['fecha'], style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    articulo['titulo'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937), height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    articulo['resumen'],
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('W', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                      ),
                      const SizedBox(width: 8),
                      Text(articulo['autor'], style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalle(Map<String, dynamic> articulo) {
    final colorCat = _getColorCategoria(articulo['categoria']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorCat.withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    articulo['imagen'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(child: Icon(Icons.article, size: 80, color: colorCat)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorCat.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  articulo['categoria'],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorCat),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                articulo['titulo'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1F2937), height: 1.3),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Text(articulo['fecha'], style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(width: 16),
                  const Icon(Icons.person, size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Text(articulo['autor'], style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                articulo['contenido'],
                style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.7),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}