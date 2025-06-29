import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_cark/core/utils/text_manager.dart';

class ImageUploadWidget extends StatefulWidget {
  final String label;
  final IconData icon;
  final Function(File?) onImageSelected;

  const ImageUploadWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.onImageSelected,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget.onImageSelected(_selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.camera),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: Colors.black54),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedImage != null ? TextManager.upload.tr(): widget.label,
                style: TextStyle(
                  color: _selectedImage != null ? Colors.green : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
