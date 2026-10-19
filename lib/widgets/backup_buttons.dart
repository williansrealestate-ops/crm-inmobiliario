import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/backup_service.dart';

class BackupButtons extends StatelessWidget {
  final VoidCallback? onBackupComplete;
  const BackupButtons({super.key, this.onBackupComplete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón Respaldar
        InkWell(
          onTap: () => _respaldar(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppTheme.success.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload, color: AppTheme.success, size: 16),
                SizedBox(width: 4),
                Text(
                  'Respaldar',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Botón Restaurar
        InkWell(
          onTap: () => _restaurar(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_download, color: AppTheme.primary, size: 16),
                SizedBox(width: 4),
                Text(
                  'Restaurar',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _respaldar(BuildContext context) async {
    const snackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text('Respaldando datos...'),
        ],
      ),
      backgroundColor: AppTheme.primary,
      duration: Duration(seconds: 30),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    final resultado = await BackupService.respaldarTodo();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['message'] ?? 'Completado'),
        backgroundColor:
            resultado['success'] == true ? AppTheme.success : AppTheme.danger,
        duration: const Duration(seconds: 5),
      ),
    );

    if (resultado['success'] == true && onBackupComplete != null) {
      onBackupComplete!();
    }
  }

  Future<void> _restaurar(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar datos'),
        content: const Text(
          '¿Estás seguro? Esto reemplazará todos los datos locales con los datos de Google Sheets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    const snackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text('Restaurando datos...'),
        ],
      ),
      backgroundColor: AppTheme.primary,
      duration: Duration(seconds: 30),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    final resultado = await BackupService.restaurarTodo();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['message'] ?? 'Completado'),
        backgroundColor:
            resultado['success'] == true ? AppTheme.success : AppTheme.danger,
        duration: const Duration(seconds: 5),
      ),
    );

    if (resultado['success'] == true) {
      // Recargar la app
      Future.delayed(const Duration(seconds: 2), () {
        // ignore: deprecated_member_use
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Scaffold()),
          (route) => false,
        );
      });
    }
  }
}
