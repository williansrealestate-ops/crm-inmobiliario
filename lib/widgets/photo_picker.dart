import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../config/theme.dart';

class PhotoPicker extends StatefulWidget {
  final String? currentPhoto;
  final Function(String base64) onPhotoSelected;
  final Function() onPhotoRemoved;

  const PhotoPicker({super.key, this.currentPhoto, required this.onPhotoSelected, required this.onPhotoRemoved});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  String? _photoBase64;
  final html.FileUploadInputElement _uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';

  @override
  void initState() {
    super.initState();
    _photoBase64 = widget.currentPhoto;
    _setupFileListener();
  }

  void _setupFileListener() {
    _uploadInput.onChange.listen((e) {
      final file = _uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          if (result is String) {
            setState(() {
              _photoBase64 = result;
            });
            widget.onPhotoSelected(result);
          }
        });
        reader.readAsDataUrl(file);
      }
    });
  }

  void _pickImage() {
    _uploadInput.click();
  }

  void _removePhoto() {
    setState(() {
      _photoBase64 = null;
    });
    widget.onPhotoRemoved();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Foto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border), image: _photoBase64 != null ? DecorationImage(image: NetworkImage(_photoBase64!), fit: BoxFit.cover) : null), child: _photoBase64 == null ? Icon(Icons.person, size: 40, color: AppTheme.textSecondary) : null),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.upload, size: 18), label: const Text('Subir foto'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white)),
          if (_photoBase64 != null) ...[const SizedBox(height: 8), TextButton.icon(onPressed: _removePhoto, icon: const Icon(Icons.delete, size: 16), label: const Text('Quitar foto', style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(foregroundColor: AppTheme.danger))],
        ]),
      ]),
    ]);
  }
}