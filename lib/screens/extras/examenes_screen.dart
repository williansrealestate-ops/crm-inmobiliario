import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/examenes_service.dart';
import '../../services/gamificacion_service.dart';

class ExamenesScreen extends StatefulWidget {
  const ExamenesScreen({super.key});

  @override
  State<ExamenesScreen> createState() => _ExamenesScreenState();
}

class _ExamenesScreenState extends State<ExamenesScreen> {
  int? _examenSeleccionado;
  int _preguntaActual = 0;
  List<int> _respuestas = [];
  bool _mostrandoResultado = false;
  int _puntaje = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.quiz, color: Colors.white), SizedBox(width: 8), Text('Exámenes y Certificaciones')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _examenSeleccionado == null ? _buildListaExamenes() : _buildExamen(),
    );
  }

  Widget _buildListaExamenes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ExamenesService.examenes.length,
      itemBuilder: (context, index) {
        final examen = ExamenesService.examenes[index];
        final mejor = ExamenesService.getMejorResultado(examen['id']);
        final color = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981)][index % 3];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.quiz, color: Color(0xFF3B82F6), size: 24))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(examen['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(examen['descripcion'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('${examen['duracion']} min', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(width: 16),
                  const Icon(Icons.help, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('${examen['preguntas'].length} preguntas', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const Spacer(),
                  if (mejor != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('Mejor: ${(mejor['porcentaje'] as double).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _iniciarExamen(index),
                  style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: Text(mejor != null ? 'Repetir examen' : 'Iniciar examen'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _iniciarExamen(int index) {
    setState(() {
      _examenSeleccionado = index;
      _preguntaActual = 0;
      _respuestas = List.filled(ExamenesService.examenes[index]['preguntas'].length, -1);
      _mostrandoResultado = false;
      _puntaje = 0;
    });
  }

  Widget _buildExamen() {
    if (_mostrandoResultado) return _buildResultado();
    
    final examen = ExamenesService.examenes[_examenSeleccionado!];
    final preguntas = examen['preguntas'] as List;
    final pregunta = preguntas[_preguntaActual];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _examenSeleccionado = null)),
              Expanded(child: Text(examen['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: (_preguntaActual + 1) / preguntas.length, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)), minHeight: 8),
          const SizedBox(height: 8),
          Text('Pregunta ${_preguntaActual + 1} de ${preguntas.length}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 24),
          Text(pregunta['pregunta'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ...List.generate((pregunta['opciones'] as List).length, (i) {
            final seleccionada = _respuestas[_preguntaActual] == i;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _respuestas[_preguntaActual] = i),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: seleccionada ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: seleccionada ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: seleccionada ? const Color(0xFF3B82F6) : const Color(0xFF64748B))), child: seleccionada ? const Center(child: Icon(Icons.check, size: 16, color: Color(0xFF3B82F6))) : null),
                      const SizedBox(width: 12),
                      Expanded(child: Text(pregunta['opciones'][i], style: TextStyle(fontSize: 14, fontWeight: seleccionada ? FontWeight.w600 : FontWeight.normal))),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Row(
            children: [
              if (_preguntaActual > 0)
                Expanded(
                  child: OutlinedButton(onPressed: () => setState(() => _preguntaActual--), child: const Text('Anterior')),
                ),
              if (_preguntaActual > 0) const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _respuestas[_preguntaActual] == -1 ? null : () {
                    if (_preguntaActual < preguntas.length - 1) {
                      setState(() => _preguntaActual++);
                    } else {
                      _calcularResultado();
                    }
                  },
                  child: Text(_preguntaActual < preguntas.length - 1 ? 'Siguiente' : 'Finalizar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _calcularResultado() {
    final examen = ExamenesService.examenes[_examenSeleccionado!];
    final preguntas = examen['preguntas'] as List;
    int correctas = 0;
    for (var i = 0; i < preguntas.length; i++) {
      if (_respuestas[i] == preguntas[i]['correcta']) correctas++;
    }
    final porcentaje = (correctas / preguntas.length) * 100;
    final aprobado = porcentaje >= 70;

    ExamenesService.guardarResultado({
      'examenId': examen['id'],
      'examenTitulo': examen['titulo'],
      'correctas': correctas,
      'total': preguntas.length,
      'porcentaje': porcentaje,
      'aprobado': aprobado,
    });

    if (aprobado) {
      GamificacionService.agregarPuntos(50, 'Aprobó examen: ${examen['titulo']}');
    }

    setState(() {
      _puntaje = correctas;
      _mostrandoResultado = true;
    });
  }

  Widget _buildResultado() {
    final examen = ExamenesService.examenes[_examenSeleccionado!];
    final preguntas = examen['preguntas'] as List;
    final porcentaje = (_puntaje / preguntas.length) * 100;
    final aprobado = porcentaje >= 70;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(aprobado ? Icons.emoji_events : Icons.school, color: aprobado ? const Color(0xFFF59E0B) : const Color(0xFF64748B), size: 80),
          const SizedBox(height: 16),
          Text(aprobado ? '¡Felicidades!' : 'Sigue practicando', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: aprobado ? const Color(0xFFF59E0B) : const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Text(examen['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: aprobado ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text('${porcentaje.toStringAsFixed(0)}%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: aprobado ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                const SizedBox(height: 8),
                Text('$_puntaje de ${preguntas.length} correctas', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(aprobado ? '✅ APROBADO' : '❌ NO APROBADO (mín. 70%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: aprobado ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (aprobado)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFF59E0B), size: 32),
                  SizedBox(width: 12),
                  Expanded(child: Text('+50 puntos de gamificación', style: TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _examenSeleccionado = null), child: const Text('Volver'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () => _iniciarExamen(_examenSeleccionado!), child: const Text('Repetir'))),
            ],
          ),
        ],
      ),
    );
  }
}