import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/contactos_service.dart';
import '../../services/whatsapp_service.dart';

class ContactosScreen extends StatefulWidget {
  const ContactosScreen({super.key});

  @override
  State<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  String _categoriaSeleccionada = 'notario';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.contacts, color: Colors.white), SizedBox(width: 8), Text('Red de Contactos')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _mostrarDialogoContacto(), tooltip: 'Nuevo contacto'),
        ],
      ),
      body: Column(
        children: [
          // ✅ CORREGIDO: Categorías sin overflow
          Container(
            height: 160, // ✅ Aumentado para acomodar nombres largos
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ContactosService.categorias.length,
              itemBuilder: (context, index) {
                final cat = ContactosService.categorias[index];
                final isSelected = _categoriaSeleccionada == cat['id'];
                final color = Color(int.parse(cat['color']));
                final cantidad = ContactosService.getContactosPorCategoria(cat['id']).length;

                return GestureDetector(
                  onTap: () => setState(() => _categoriaSeleccionada = cat['id']),
                  child: Container(
                    width: 110, // ✅ Reducido para dar más espacio vertical
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // ✅ Padding mínimo
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? color : AppTheme.getBorderColor(context), width: isSelected ? 2.5 : 1),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? color.withOpacity(0.15) : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ Distribución uniforme
                      children: [
                        Text(cat['icono'], style: const TextStyle(fontSize: 26)), // ✅ Reducido de 28 a 26
                        Text(
                          cat['nombre'],
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? color : AppTheme.getTextSecondaryColor(context)),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('$cantidad', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)), // ✅ Reducido de 12 a 12
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(child: _buildListaContactos()),
        ],
      ),
    );
  }

  Widget _buildListaContactos() {
    final contactos = ContactosService.getContactosPorCategoria(_categoriaSeleccionada);
    final categoria = ContactosService.categorias.firstWhere((c) => c['id'] == _categoriaSeleccionada);

    if (contactos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(categoria['icono'], style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No hay ${categoria['nombre']} registrados', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoContacto(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar contacto'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contactos.length,
      itemBuilder: (context, index) {
        final contacto = contactos[index];
        return _buildContactoCard(contacto, categoria);
      },
    );
  }

  Widget _buildContactoCard(Map<String, dynamic> contacto, Map<String, dynamic> categoria) {
    final color = Color(int.parse(categoria['color']));
    final calificacion = contacto['calificacion'] ?? 5;
    final operaciones = contacto['operacionesJuntas'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.getSurfaceColor(context), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.getBorderColor(context)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(categoria['icono'], style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacto['nombre'] ?? 'Sin nombre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                    Text(contacto['empresa'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _mostrarDialogoContacto(contacto: contacto), color: const Color(0xFF3B82F6)),
              IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () => _confirmarEliminar(contacto), color: const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text('$calificacion/5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Icon(Icons.handshake, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text('$operaciones operaciones', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          if ((contacto['especialidad'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Especialidad: ${contacto['especialidad']}', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
          ],
          if ((contacto['zona'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Zona: ${contacto['zona']}', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if ((contacto['telefono'] ?? '').isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => WhatsAppService.enviarMensaje(contacto['telefono'], 'Hola ${contacto['nombre']}, soy Williams de Real Estate.'),
                    icon: const Icon(Icons.message, size: 14),
                    label: const Text('WhatsApp', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 6)),
                  ),
                ),
              if ((contacto['telefono'] ?? '').isNotEmpty) const SizedBox(width: 8),
              if ((contacto['email'] ?? '').isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.email, size: 14),
                    label: const Text('Email', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 6)),
                  ),
                ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ContactosService.incrementarOperaciones(contacto['id']);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Operación registrada con ${contacto['nombre']}'), backgroundColor: const Color(0xFF10B981)));
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('+ Operación', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoContacto({Map<String, dynamic>? contacto}) {
    final nombreCtrl = TextEditingController(text: contacto?['nombre'] ?? '');
    final empresaCtrl = TextEditingController(text: contacto?['empresa'] ?? '');
    final telefonoCtrl = TextEditingController(text: contacto?['telefono'] ?? '');
    final emailCtrl = TextEditingController(text: contacto?['email'] ?? '');
    final especialidadCtrl = TextEditingController(text: contacto?['especialidad'] ?? '');
    final zonaCtrl = TextEditingController(text: contacto?['zona'] ?? '');
    String categoria = contacto?['categoria'] ?? _categoriaSeleccionada;
    double calificacion = (contacto?['calificacion'] ?? 5).toDouble();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text(contacto == null ? 'Nuevo Contacto' : 'Editar Contacto', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: empresaCtrl, decoration: const InputDecoration(labelText: 'Empresa', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                  items: ContactosService.categorias.map((c) => DropdownMenuItem<String>(value: c['id'] as String, child: Text('${c['icono']} ${c['nombre']}'))).toList(),
                  onChanged: (value) => setState(() => categoria = value ?? 'notario'),
                ),
                const SizedBox(height: 8),
                TextField(controller: especialidadCtrl, decoration: const InputDecoration(labelText: 'Especialidad', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: zonaCtrl, decoration: const InputDecoration(labelText: 'Zona de cobertura', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Calificación:'),
                    const SizedBox(width: 8),
                    ...List.generate(5, (i) => IconButton(
                          icon: Icon(i < calificacion ? Icons.star : Icons.star_border, color: const Color(0xFFF59E0B)),
                          onPressed: () => setState(() => calificacion = i + 1.0),
                        )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.isNotEmpty) {
                  final datos = {
                    'nombre': nombreCtrl.text,
                    'empresa': empresaCtrl.text,
                    'telefono': telefonoCtrl.text,
                    'email': emailCtrl.text,
                    'categoria': categoria,
                    'especialidad': especialidadCtrl.text,
                    'zona': zonaCtrl.text,
                    'calificacion': calificacion,
                  };
                  if (contacto == null) {
                    ContactosService.agregarContacto(datos);
                  } else {
                    ContactosService.actualizarContacto(contacto['id'], datos);
                  }
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> contacto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar contacto?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: Text('¿Estás seguro de eliminar "${contacto['nombre']}"?', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              ContactosService.eliminarContacto(contacto['id']);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}