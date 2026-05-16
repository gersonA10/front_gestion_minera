import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class CustomFormStaffWidget extends StatelessWidget {
  final IconData icon;
  final String titleform;
  final String hint;
  final String extraText;
  final TextEditingController controller;
  const CustomFormStaffWidget({
    super.key,
    required this.icon,
    required this.titleform,
    required this.hint,
    this.extraText = '',
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            Text(
              titleform,
              style: TextStyle(
                color: TColors.appMainDarkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: TColors.textFieldDisabledBorderDarkColor,
            ),
            suffixIcon: Align(
              alignment: Alignment.centerRight,
              widthFactor: 1.0,
              child: Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text(
                  extraText,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
