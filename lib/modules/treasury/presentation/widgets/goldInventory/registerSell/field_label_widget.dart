import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';


class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: TColors.appMainTextColor,
        letterSpacing: -0.1,
      ),
    );
  }
}