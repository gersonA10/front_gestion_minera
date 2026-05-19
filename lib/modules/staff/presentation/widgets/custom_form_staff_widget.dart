import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../utils/constants/color.constant.dart';

class CustomFormStaffWidget extends StatelessWidget {
  final IconData icon;
  final String titleform;
  final String hint;
  final String extraText;
  final TextEditingController controller;
  final bool isOnlyRead;
  final VoidCallback? onTap;
  final TextInputType keyboradtype;
  final List<TextInputFormatter>? inputFormatters;
  const CustomFormStaffWidget({
    super.key,
    required this.icon,
    required this.titleform,
    required this.hint,
    this.extraText = '',
    required this.controller,
    this.isOnlyRead = false,
    this.onTap,
    this.keyboradtype = TextInputType.text, 
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 7),
            Text(
              titleform,
              style: TextStyle(
                color: TColors.appMainDarkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo requerido';
            }
            return null;
          },
          readOnly: isOnlyRead,
          keyboardType: keyboradtype,
          inputFormatters: inputFormatters,
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
          onTap: onTap,
        ),
      ],
    );
  }
}
