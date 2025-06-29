import 'package:flutter/material.dart';

import '../../../../../config/themes/app_colors.dart';

class HandoverNotesWidget extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String) onNotesChanged;
  final String? hintText;
  final int maxLines;

  const HandoverNotesWidget({
    Key? key,
    required this.title,
    this.initialValue,
    required this.onNotesChanged,
    this.hintText,
    this.maxLines = 4,
  }) : super(key: key);

  @override
  State<HandoverNotesWidget> createState() => _HandoverNotesWidgetState();
}

class _HandoverNotesWidgetState extends State<HandoverNotesWidget> {
  late TextEditingController _controller;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _currentValue = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.note_add,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Notes text field
          TextField(
            controller: _controller,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'أضف ملاحظاتك هنا...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.all(12),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
              widget.onNotesChanged(value);
            },
          ),

          SizedBox(height: 8),

          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${_currentValue.length} حرف',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 