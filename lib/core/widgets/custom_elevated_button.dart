import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({super.key, required this.text, required this.onPressed});
  final String text ;
  final void Function()? onPressed ;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text.tr(),
          style: Theme.of(context).elevatedButtonTheme.style!.textStyle!.resolve({}),
        ),
      ),
    );
  }
}
