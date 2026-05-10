import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class TextTitleCardWidget extends StatelessWidget {
  final String title;
  const TextTitleCardWidget({
    super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: TColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16
      ),
    );
  }
}