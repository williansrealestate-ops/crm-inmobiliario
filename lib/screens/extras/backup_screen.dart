import 'dart:convert';
import 'dart:html' as html; // ✅ Para descarga confiable en Web
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _registros = {
    'Clientes': 0,
    'Asesores': 0,
    'Inmuebles': 0,
    'Ingresos': 0,
    'Gastos': 0,
  };
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConteos();
  }

  Future<void> _cargarConteos() async {
    setState(() => _cargando = true);
    try {
      final clientes = await _firestore.collection('clientes').count().get();
      final asesores = await _firestore.collection('asesores').count().get();
      final inmuebles = await _firestore.collection('inmuebles').count().get();
      final ingresos = await _firestore.collection('ingresos').count().get();
      final gastos = await _firestore.collection('gastos').count().get();

      setState(() {
        _registros = {
          'Clientes': clientes.count ?? 0,
          'Asesores': asesores.count ?? 0,
          'Inmuebles': inmuebles.count ?? 0,
          'Ingresos': ingresos.count ?? 0,
          'Gastos': gastos.count ?? 0,
        };
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar conteos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _crearRespaldo() async {
    if (_cargando) return;
    setState(() => _cargando = true);

    try {
      final clientesSnap = await _firestore.collection('clientes').get();
      final asesoresSnap = await _firestore.collection('asesores').get();
      final inmueblesSnap = await _firestore.collection('inmuebles').get();
      final ingresosSnap = await _firestore.collection('ingresos').get();
      final gastosSnap = await _firestore.collection('gastos').get();

      final respaldo = {
        'fecha': DateTime.now().toIso8601String(),
        'version': '1.0',
        'clientes': clientesSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'asesores': asesoresSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'inmuebles': inmueblesSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'ingresos': ingresosSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        'gastos': gastosSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(respaldo);
      final bytes = utf8.encode(jsonString);

      // ✅ MÉTODO SEGURO PARA DESCARGAR EN FLUTTER WEB
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "respaldo_crm_${DateTime.now().millisecondsSinceEpoch}.json")
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Respaldo descargado exitosamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear respaldo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _importarRespaldo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.bytes == null) return;

      final fileBytes = result.files.single.bytes!;
      final jsonString = utf8.decode(fileBytes);
      final respaldo = jsonDecode(jsonString) as Map<String, dynamic>;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Importar Respaldo', style: TextStyle(color: Colors.white)),
          content: const Text(
            '⚠️ Esto reemplazará todos los datos actuales.\n\n¿Continuar?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Importar', style: TextStyle(color: Colors.orange))),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _cargando = true);
      final batch = _firestore.batch();

      // 1. Eliminar datos existentes
      final colecciones = ['clientes', 'asesores', 'inmuebles', 'ingresos', 'gastos'];
      for (final col in colecciones) {
        final snap = await _firestore.collection(col).get();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
      }

      // 2. Insertar nuevos datos
      for (final col in colecciones) {
        final datos = respaldo[col] as List? ?? [];
        for (final item in datos) {
          final data = Map<String, dynamic>.from(item as Map);
          final id = data.remove('id') as String?;
          
          // ✅ CORRECCIÓN: Usar batch.set() con referencia generada en lugar de batch.add()
          if (id != null && id.isNotEmpty) {
            batch.set(_firestore.collection(col).doc(id), data);
          } else {
            final newDocRef = _firestore.collection(col).doc(); // Genera ID automático
            batch.set(newDocRef, data);
          }
        }
      }

      await batch.commit();
      await _cargarConteos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Respaldo importado exitosamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _cargando = false);
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
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Respaldo y Restauración',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF222222)),
              ),
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
                  : Column(
                      children: _registros.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 16)),
                              Text(
                                '${entry.value} registros',
                                style: TextStyle(
                                  color: entry.value > 0 ? Colors.green : Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _cargando ? null : _crearRespaldo,
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  _cargando ? 'Creando respaldo...' : 'Crear Respaldo',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _cargando ? null : _importarRespaldo,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: Text(
                  _cargando ? 'Importando...' : 'Importar Respaldo',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}