import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test_cark/core/utils/text_manager.dart';
///DONE

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final IconData prefixIcon;
  final String hintText;
  final bool obscureText;
  final String? Function(String)? validator;
  final bool isRequired;
  final bool enablePasswordToggle;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.prefixIcon,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.isRequired = true,
    this.enablePasswordToggle = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: (value) {
        return defaultValidator(value) ?? widget.validator?.call(value!);
      },
      decoration: InputDecoration(
        prefixIcon: Icon(widget.prefixIcon),
        hintText: widget.hintText.tr(),
        suffixIcon: widget.enablePasswordToggle
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }

  String? defaultValidator(String? value) {
    if (widget.isRequired && value!.isEmpty) {
      return TextManager.fieldIsRequired.tr();
    }
    return null;
  }
}
