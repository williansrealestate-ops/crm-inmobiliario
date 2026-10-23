import 'dart:convert';
import 'dart:html' as html;
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
      final clientes = await _supabase.from('clientes').select('id');
      final asesores = await _supabase.from('asesores').select('id');
      final inmuebles = await _supabase.from('inmuebles').select('id');
      
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _crearRespaldo() async {
    setState(() => _loading = true);
    try {
      final clientes = await _supabase.from('clientes').select('*');
      final asesores = await _supabase.from('asesores').select('*');
      final inmuebles = await _supabase.from('inmuebles').select('*');

      final prefs = await SharedPreferences.getInstance();
      final finanzasData = {
        'ingresos': prefs.getString('finanzas_ingresos') ?? '[]',
        'gastos': prefs.getString('finanzas_gastos') ?? '[]',
        'operaciones': prefs.getString('finanzas_operaciones') ?? '[]',
        'negocios': prefs.getString('finanzas_negocios') ?? '[]',
        'metas': prefs.getString('finanzas_metas') ?? '{}',
      };

      final respaldo = {
        'version': '2.0',
        'fecha': DateTime.now().toIso8601String(),
        'datos': {
          'clientes': clientes,
          'asesores': asesores,
          'inmuebles': inmuebles,
          'finanzas': finanzasData,
        },
      };

      final jsonString = jsonEncode(respaldo);
      final bytes = utf8.encode(jsonString);

      if (mounted) {
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'respaldo_crm_${DateTime.now().millisecondsSinceEpoch}.json')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Respaldo creado: ${clientes.length} clientes, ${asesores.length} asesores'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _importarRespaldo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _loading = true);

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw Exception('No se pudieron leer los bytes del archivo');
      }
      
      final jsonString = utf8.decode(bytes);
      final respaldo = jsonDecode(jsonString);

      Map<String, dynamic> datos;
      if (respaldo.containsKey('datos')) {
        datos = respaldo['datos'];
      } else if (respaldo.containsKey('clientes') || respaldo.containsKey('asesores')) {
        datos = respaldo;
      } else {
        throw Exception('Estructura de respaldo no reconocida.');
      }

      int clientesImportados = 0;
      int asesoresImportados = 0;
      int inmueblesImportados = 0;

      if (datos['clientes'] != null) {
        final clientes = List<Map<String, dynamic>>.from(datos['clientes']);
        for (var cliente in clientes) {
          try {
            await _supabase.from('clientes').upsert(cliente);
            clientesImportados++;
          } catch (e) { print('Error cliente: $e'); }
        }
      }

      if (datos['asesores'] != null) {
        final asesores = List<Map<String, dynamic>>.from(datos['asesores']);
        for (var asesor in asesores) {
          try {
            await _supabase.from('asesores').upsert(asesor);
            asesoresImportados++;
          } catch (e) { print('Error asesor: $e'); }
        }
      }

      if (datos['inmuebles'] != null) {
        final inmuebles = List<Map<String, dynamic>>.from(datos['inmuebles']);
        for (var inmueble in inmuebles) {
          try {
            await _supabase.from('inmuebles').upsert(inmueble);
            inmueblesImportados++;
          } catch (e) { print('Error inmueble: $e'); }
        }
      }

      if (datos['finanzas'] != null) {
        final prefs = await SharedPreferences.getInstance();
        final finanzas = datos['finanzas'];
        if (finanzas['ingresos'] != null) await prefs.setString('finanzas_ingresos', finanzas['ingresos']);
        if (finanzas['gastos'] != null) await prefs.setString('finanzas_gastos', finanzas['gastos']);
        if (finanzas['operaciones'] != null) await prefs.setString('finanzas_operaciones', finanzas['operaciones']);
        if (finanzas['negocios'] != null) await prefs.setString('finanzas_negocios', finanzas['negocios']);
        if (finanzas['metas'] != null) await prefs.setString('finanzas_metas', finanzas['metas']);
      }

      await _cargarStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Importado: $clientesImportados clientes, $asesoresImportados asesores, $inmueblesImportados inmuebles'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // ✅ FONDO NEGRO FORZADO
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.cloud, color: Colors.white),
          SizedBox(width: 8),
          Text('Respaldo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarStats),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Respaldo y Restauración', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow('Clientes', _stats['clientes'] ?? 0),
                        _buildStatRow('Asesores', _stats['asesores'] ?? 0),
                        _buildStatRow('Inmuebles', _stats['inmuebles'] ?? 0),
                        _buildStatRow('Ingresos', _stats['ingresos'] ?? 0),
                        _buildStatRow('Gastos', _stats['gastos'] ?? 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _crearRespaldo,
                    icon: const Icon(Icons.download),
                    label: const Text('Crear Respaldo'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _importarRespaldo,
                    icon: const Icon(Icons.upload),
                    label: const Text('Importar Respaldo'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
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
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text('$count registros', style: TextStyle(color: count > 0 ? const Color(0xFF10B981) : Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}