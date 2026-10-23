import 'dart:convert';
import 'dart:io';
import 'dart:html' as html; // ✅ IMPORT AGREGADO PARA WEB
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _supabase = Supabase.instance.client;
  bool _loading = false;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    setState(() => _loading = true);
    try {
      // Leer datos reales de Supabase
      final clientes = await _supabase.from('clientes').select('id');
      final asesores = await _supabase.from('asesores').select('id');
      final inmuebles = await _supabase.from('inmuebles').select('id');
      
      // Leer datos de Finanzas de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final ingresosData = prefs.getString('finanzas_ingresos');
      final gastosData = prefs.getString('finanzas_gastos');
      final operacionesData = prefs.getString('finanzas_operaciones');
      final negociosData = prefs.getString('finanzas_negocios');
      
      List ingresos = ingresosData != null ? jsonDecode(ingresosData) : [];
      List gastos = gastosData != null ? jsonDecode(gastosData) : [];
      List operaciones = operacionesData != null ? jsonDecode(operacionesData) : [];
      List negocios = negociosData != null ? jsonDecode(negociosData) : [];

      setState(() {
        _stats = {
          'clientes': clientes.length,
          'asesores': asesores.length,
          'inmuebles': inmuebles.length,
          'ingresos': ingresos.length,
          'gastos': gastos.length,
          'operaciones': operaciones.length,
          'negocios': negocios.length,
        };
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _crearRespaldo() async {
    setState(() => _loading = true);
    try {
      // 1. Obtener datos de Supabase
      final clientes = await _supabase.from('clientes').select('*');
      final asesores = await _supabase.from('asesores').select('*');
      final inmuebles = await _supabase.from('inmuebles').select('*');

      // 2. Obtener datos de Finanzas de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final finanzasData = {
        'ingresos': prefs.getString('finanzas_ingresos') ?? '[]',
        'gastos': prefs.getString('finanzas_gastos') ?? '[]',
        'operaciones': prefs.getString('finanzas_operaciones') ?? '[]',
        'negocios': prefs.getString('finanzas_negocios') ?? '[]',
        'metas': prefs.getString('finanzas_metas') ?? '{}',
      };

      // 3. Crear objeto de respaldo completo
      final respaldo = {
        'version': '2.0',
        'fecha': DateTime.now().toIso8601String(),
        'datos': {
          'clientes': clientes,
          'asesores': asesores,
          'inmuebles': inmuebles,
          'finanzas': finanzasData,
        },
        'estadisticas': {
          'total_clientes': clientes.length,
          'total_asesores': asesores.length,
          'total_inmuebles': inmuebles.length,
        },
      };

      // 4. Convertir a JSON
      final jsonString = jsonEncode(respaldo);
      final bytes = utf8.encode(jsonString);

      // 5. Descargar archivo (para web)
      if (mounted) {
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'respaldo_crm_${DateTime.now().millisecondsSinceEpoch}.json')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Respaldo creado: ${clientes.length} clientes, ${asesores.length} asesores, ${inmuebles.length} inmuebles'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear respaldo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _importarRespaldo() async {
    try {
      // 1. Seleccionar archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() => _loading = true);

      // 2. Leer archivo
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final respaldo = jsonDecode(jsonString);

      // 3. Validar estructura
      if (!respaldo.containsKey('datos')) {
        throw Exception('Archivo de respaldo inválido');
      }

      final datos = respaldo['datos'];
      int clientesImportados = 0;
      int asesoresImportados = 0;
      int inmueblesImportados = 0;

      // 4. Importar Clientes a Supabase
      if (datos['clientes'] != null) {
        final clientes = List<Map<String, dynamic>>.from(datos['clientes']);
        for (var cliente in clientes) {
          try {
            await _supabase.from('clientes').upsert(cliente);
            clientesImportados++;
          } catch (e) {
            print('Error importando cliente: $e');
          }
        }
      }

      // 5. Importar Asesores a Supabase
      if (datos['asesores'] != null) {
        final asesores = List<Map<String, dynamic>>.from(datos['asesores']);
        for (var asesor in asesores) {
          try {
            await _supabase.from('asesores').upsert(asesor);
            asesoresImportados++;
          } catch (e) {
            print('Error importando asesor: $e');
          }
        }
      }

      // 6. Importar Inmuebles a Supabase
      if (datos['inmuebles'] != null) {
        final inmuebles = List<Map<String, dynamic>>.from(datos['inmuebles']);
        for (var inmueble in inmuebles) {
          try {
            await _supabase.from('inmuebles').upsert(inmueble);
            inmueblesImportados++;
          } catch (e) {
            print('Error importando inmueble: $e');
          }
        }
      }

      // 7. Importar Finanzas a SharedPreferences
      if (datos['finanzas'] != null) {
        final prefs = await SharedPreferences.getInstance();
        final finanzas = datos['finanzas'];
        
        if (finanzas['ingresos'] != null) await prefs.setString('finanzas_ingresos', finanzas['ingresos']);
        if (finanzas['gastos'] != null) await prefs.setString('finanzas_gastos', finanzas['gastos']);
        if (finanzas['operaciones'] != null) await prefs.setString('finanzas_operaciones', finanzas['operaciones']);
        if (finanzas['negocios'] != null) await prefs.setString('finanzas_negocios', finanzas['negocios']);
        if (finanzas['metas'] != null) await prefs.setString('finanzas_metas', finanzas['metas']);
      }

      // 8. Recargar estadísticas
      await _cargarStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Respaldo importado: $clientesImportados clientes, $asesoresImportados asesores, $inmueblesImportados inmuebles'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar respaldo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.cloud, color: Colors.white),
          SizedBox(width: 8),
          Text('Respaldo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Respaldo y Restauración',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Protege tus datos con copias de seguridad',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Información del Respaldo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222222)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF0066FF), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Información del Respaldo',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Clientes', _stats['clientes'] ?? 0),
                        _buildStatRow('Asesores', _stats['asesores'] ?? 0),
                        _buildStatRow('Inmuebles', _stats['inmuebles'] ?? 0),
                        _buildStatRow('Ingresos (Finanzas)', _stats['ingresos'] ?? 0),
                        _buildStatRow('Gastos (Finanzas)', _stats['gastos'] ?? 0),
                        _buildStatRow('Operaciones', _stats['operaciones'] ?? 0),
                        _buildStatRow('Negocios', _stats['negocios'] ?? 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Crear Respaldo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222222)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.download, color: Color(0xFF10B981), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Crear Respaldo',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Descarga un archivo JSON con todos tus datos',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          onPressed: _crearRespaldo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Importar Respaldo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222222)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.upload, color: Color(0xFF3B82F6), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Importar Respaldo',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Restaura datos desde un archivo JSON',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          onPressed: _importarRespaldo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nota importante
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nota Importante',
                                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'El respaldo incluye datos de Supabase (Clientes, Asesores, Inmuebles) y datos locales (Finanzas). Al importar, los datos existentes se actualizarán.',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: count > 0 ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count registros',
              style: TextStyle(
                color: count > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}