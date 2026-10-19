import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../config/theme.dart';

class MultiPhotoPicker extends StatefulWidget {
  final List<String> currentPhotos;
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;

  const MultiPhotoPicker({
    super.key,
    required this.currentPhotos,
    required this.onPhotosChanged,
    this.maxPhotos = 8,
  });

  @override
  State<MultiPhotoPicker> createState() => _MultiPhotoPickerState();
}

class _MultiPhotoPickerState extends State<MultiPhotoPicker> {
  late List<String> _photos;
  final html.FileUploadInputElement _uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = true
    ..style.display = 'none';

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.currentPhotos);
    _setupFileListener();
  }

  void _setupFileListener() {
    _uploadInput.onChange.listen((e) {
      final files = _uploadInput.files;
      if (files != null && files.isNotEmpty) {
        int remainingSlots = widget.maxPhotos - _photos.length;
        int filesToProcess = files.length > remainingSlots ? remainingSlots : files.length;

        for (int i = 0; i < filesToProcess; i++) {
          final file = files[i];
          if (file.size > 2 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('⚠️ ${file.name} es muy grande. Máximo 2MB')),
              );
            }
            continue;
          }
          final reader = html.FileReader();
          reader.onLoadEnd.listen((e) {
            final result = reader.result;
            if (result is String && mounted) {
              setState(() {
                _photos.add(result);
              });
              widget.onPhotosChanged(List<String>.from(_photos));
            }
          });
          reader.readAsDataUrl(file);
        }

        if (files.length > remainingSlots && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Solo se agregaron $remainingSlots fotos (máximo ${widget.maxPhotos})'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  void _pickImages() {
    _uploadInput.click();
  }

  void _removePhoto(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _photos.removeAt(index);
              });
              widget.onPhotosChanged(List<String>.from(_photos));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, item);
    });
    widget.onPhotosChanged(List<String>.from(_photos));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Galería de Fotos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            Text(
              '${_photos.length}/${widget.maxPhotos}',
              style: TextStyle(
                fontSize: 12,
                color: _photos.length >= widget.maxPhotos 
                    ? AppTheme.danger 
                    : AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Grid de fotos
        if (_photos.isNotEmpty)
          Container(
            constraints: BoxConstraints(maxHeight: isMobile ? 300 : 400),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _photos.length,
              onReorder: _reorderPhotos,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Container(
                  key: ValueKey('photo_$index'),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.getBorderColor(context)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.network(
                          photo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Foto ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.getTextPrimaryColor(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Arrastra para reordenar',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.getTextSecondaryColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                        onPressed: () => _removePhoto(index),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.drag_handle, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        // Botón agregar más
        if (_photos.length < widget.maxPhotos)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                _photos.isEmpty 
                    ? 'Agregar fotos' 
                    : 'Agregar más fotos (${widget.maxPhotos - _photos.length} disponibles)',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppTheme.primary),
                foregroundColor: AppTheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}