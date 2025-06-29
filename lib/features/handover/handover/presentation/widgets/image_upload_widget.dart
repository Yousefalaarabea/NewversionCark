import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../../config/themes/app_colors.dart';

class ImageUploadWidget extends StatelessWidget {
  final String? imagePath;
  final Function(ImageSource) onImagePicked;
  final String title;

  const ImageUploadWidget({
    Key? key,
    this.imagePath,
    required this.onImagePicked,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null) ...[
          // Show uploaded image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
        
        // Upload buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(context, ImageSource.camera),
                icon: Icon(Icons.camera_alt, color: Colors.white),
                label: Text('الكاميرا'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(context, ImageSource.gallery),
                icon: Icon(Icons.photo_library, color: Colors.white),
                label: Text('المعرض'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context, ImageSource source) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر مصدر الصورة'),
          content: Text('هل تريد استخدام ${source == ImageSource.camera ? 'الكاميرا' : 'المعرض'}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onImagePicked(source);
              },
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
} 