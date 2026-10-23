import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/backup_service.dart';
import '../../widgets/ios_widgets.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _cargando = false;
  Map<String, int> _conteo = {};
  int _tamanoTotal = 0;

  @override
  void initState() {
    super.initState();
    _cargarInfo();
  }

  Future<void> _cargarInfo() async {
    setState(() => _cargando = true);
    _conteo = await BackupService.getConteoRegistros();
    _tamanoTotal = await BackupService.getTamanoRespaldo();
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.cloud_upload, color: Colors.white), SizedBox(width: 8), Text('Respaldo y Restauración')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarInfo,
            tooltip: 'Actualizar información',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const IOSLargeTitle(
                  title: 'Respaldo',
                  subtitle: 'Protege tus datos con copias de seguridad',
                ),

                IOSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: IOSColors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text('Información del Respaldo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Tamaño total', _formatearTamano(_tamanoTotal)),
                      const Divider(height: 20),
                      ..._conteo.entries.map((e) => _buildInfoRow(_nombreSeccion(e.key), '${e.value} registros')),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                IOSCard(
                  onTap: _crearRespaldo,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: IOSColors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.download, color: IOSColors.green, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Crear Respaldo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                            const SizedBox(height: 2),
                            const Text('Descarga un archivo JSON con todos tus datos', style: const TextStyle(fontSize: 13, color: IOSColors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: isDark ? IOSColors.textTertiary : IOSColors.textTertiary),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                IOSCard(
                  onTap: _importarRespaldo,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: IOSColors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload, color: IOSColors.blue, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Importar Respaldo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                            const SizedBox(height: 2),
                            const Text('Restaura datos desde un archivo JSON', style: const TextStyle(fontSize: 13, color: IOSColors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: isDark ? IOSColors.textTertiary : IOSColors.textTertiary),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                IOSCard(
                  onTap: _confirmarLimpieza,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: IOSColors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline, color: IOSColors.red, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Limpiar Todos los Datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                            const SizedBox(height: 2),
                            const Text('Elimina todos los datos de la aplicación', style: const TextStyle(fontSize: 13, color: IOSColors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: isDark ? IOSColors.textTertiary : IOSColors.textTertiary),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                IOSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.help_outline, color: IOSColors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text('Instrucciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInstruccion('1', 'Crear respaldo regularmente', 'Haz clic en "Crear Respaldo" para descargar un archivo JSON con todos tus datos.'),
                      const SizedBox(height: 12),
                      _buildInstruccion('2', 'Guardar el archivo en lugar seguro', 'Guarda el archivo en tu computadora, Google Drive, Dropbox o USB.'),
                      const SizedBox(height: 12),
                      _buildInstruccion('3', 'Importar cuando sea necesario', 'Si pierdes datos o cambias de navegador, usa "Importar Respaldo" para restaurar.'),
                      const SizedBox(height: 12),
                      _buildInstruccion('4', 'Frecuencia recomendada', 'Crea respaldos semanalmente o después de cambios importantes.'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context))),
          Text(valor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getTextColor(context))),
        ],
      ),
    );
  }

  Widget _buildInstruccion(String numero, String titulo, String descripcion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: IOSColors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(numero, style: const TextStyle(color: IOSColors.orange, fontSize: 13, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
              const SizedBox(height: 2),
              Text(descripcion, style: const TextStyle(fontSize: 12, color: IOSColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  String _nombreSeccion(String clave) {
    const nombres = {
      'asesores': 'Asesores',
      'asesores_grupos': 'Grupos de Asesores',
      'clientes': 'Clientes',
      'clientes_tipos': 'Tipos de Clientes',
      'inmuebles': 'Inmuebles',
      'inmuebles_tipos': 'Tipos de Inmuebles',
      'ventas': 'Ventas',
    };
    return nombres[clave] ?? clave;
  }

  String _formatearTamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  Future<void> _crearRespaldo() async {
    try {
      await BackupService.crearRespaldo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('✅ Respaldo creado exitosamente')]),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  // ✅ CORREGIDO: Importar respaldo con recarga automática
  Future<void> _importarRespaldo() async {
    try {
      final datos = await BackupService.importarRespaldo();
      if (datos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ No se seleccionó archivo'), backgroundColor: Color(0xFFF59E0B)),
          );
        }
        return;
      }

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: const Text('¿Restaurar respaldo?'),
          content: const Text('Esto reemplazará todos los datos actuales con los del archivo de respaldo. ¿Continuar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: IOSColors.blue),
              child: const Text('Restaurar'),
            ),
          ],
        ),
      );

      if (confirmar == true) {
        // Mostrar indicador de carga
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(child: CircularProgressIndicator()),
          );
        }

        // Restaurar datos
        await BackupService.restaurarDesdeArchivo(datos);
        
        // Actualizar información mostrada
        await _cargarInfo();
        
        // Cerrar indicador de carga
        if (mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('✅ Respaldo restaurado. Recargando app...')]),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
          
          // ✅ FORZAR RECARGA DE LA PÁGINA WEB
          await Future.delayed(const Duration(seconds: 1));
          html.window.location.reload();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar indicador si hay error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  Future<void> _confirmarLimpieza() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: const Text('⚠️ ¿Eliminar todos los datos?'),
        content: const Text('Esta acción eliminará TODOS los datos de la aplicación. Esta acción NO se puede deshacer. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: IOSColors.red),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await BackupService.limpiarTodo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('🗑️ Todos los datos eliminados')]),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        await _cargarInfo();
      }
    }
  }
}