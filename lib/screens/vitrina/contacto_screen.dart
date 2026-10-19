import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ContactoScreen extends StatefulWidget {
  final Map<String, dynamic> config;

  const ContactoScreen({super.key, required this.config});

  @override
  State<ContactoScreen> createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  String _tipoConsulta = 'Información de propiedad';

  void _enviarFormulario() {
    if (_formKey.currentState!.validate()) {
      final email = widget.config['email'] ?? 'willians.realestate@gmail.com';
      final asunto = Uri.encodeComponent('Consulta: $_tipoConsulta - ${_nombreCtrl.text}');
      final cuerpo = Uri.encodeComponent(
        'Nombre: ${_nombreCtrl.text}\n'
        'Email: ${_emailCtrl.text}\n'
        'Teléfono: ${_telefonoCtrl.text}\n'
        'Tipo de consulta: $_tipoConsulta\n\n'
        'Mensaje:\n${_mensajeCtrl.text}',
      );
      html.window.open('mailto:$email?subject=$asunto&body=$cuerpo', '_blank');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mensaje enviado. Te contactaremos pronto.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      
      _formKey.currentState!.reset();
      _nombreCtrl.clear();
      _emailCtrl.clear();
      _telefonoCtrl.clear();
      _mensajeCtrl.clear();
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
          'Contáctanos',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Tienes alguna pregunta?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estamos aquí para ayudarte. Completa el formulario y te contactaremos en menos de 24 horas.',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Información de contacto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nombreCtrl,
                            decoration: InputDecoration(
                              labelText: 'Nombre completo *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Ingresa tu email';
                              if (!v.contains('@')) return 'Email no válido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefonoCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _tipoConsulta,
                            decoration: InputDecoration(
                              labelText: 'Tipo de consulta',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: [
                              'Información de propiedad',
                              'Agendar visita',
                              'Financiamiento',
                              'Asesoría personalizada',
                              'Otro',
                            ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => _tipoConsulta = v!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mensajeCtrl,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Mensaje *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Escribe tu mensaje' : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _enviarFormulario,
                              icon: const Icon(Icons.send, size: 20),
                              label: const Text('Enviar mensaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Información de contacto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                            const SizedBox(height: 20),
                            _buildInfoItem(Icons.phone, 'Teléfono', widget.config['telefono'] ?? '993-214-9996'),
                            const SizedBox(height: 12),
                            _buildInfoItem(Icons.chat, 'WhatsApp', widget.config['whatsapp'] ?? '529932149996'),
                            const SizedBox(height: 12),
                            _buildInfoItem(Icons.email, 'Email', widget.config['email'] ?? 'willians.realestate@gmail.com'),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text('Horario de atención', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                            const SizedBox(height: 8),
                            const Text('Lunes a Viernes: 9:00 - 18:00', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                            const Text('Sábados: 10:00 - 14:00', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.chat, color: Colors.white, size: 48),
                            const SizedBox(height: 12),
                            const Text('¿Prefieres WhatsApp?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            const Text('Respuesta inmediata', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final mensaje = 'Hola, quiero más información sobre sus propiedades';
                                  final whatsapp = widget.config['whatsapp'] ?? '529932149996';
                                  html.window.open('https://wa.me/$whatsapp?text=${Uri.encodeComponent(mensaje)}', '_blank');
                                },
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: const Text('Abrir WhatsApp', style: TextStyle(fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF128C7E),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icono, String label, String valor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, size: 18, color: const Color(0xFF0066FF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }
}