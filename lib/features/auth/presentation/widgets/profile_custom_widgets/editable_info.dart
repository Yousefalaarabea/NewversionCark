import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:test_cark/cark.dart';

///DONE

class EditableInfo extends StatelessWidget {
  final String title;
  final String value;

  const EditableInfo({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title.tr()),
      subtitle: Text(value),
    );
  }
}
