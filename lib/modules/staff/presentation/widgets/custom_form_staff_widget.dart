import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'staff_ui.dart';

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
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: StaffUi.textSecondary),
            const SizedBox(width: 7),
            Text(
              titleform,
              style: const TextStyle(
                color: StaffUi.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo requerido';
            }
            return null;
          },
          readOnly: isOnlyRead,
          keyboardType: keyboradtype,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 14,
            color: StaffUi.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: StaffUi.muted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: StaffUi.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: extraText.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: Text(
                      extraText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                  ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            enabledBorder: border(StaffUi.border),
            focusedBorder: border(StaffUi.primary, 1.4),
            errorBorder: border(const Color(0xFFEF4444)),
            focusedErrorBorder: border(const Color(0xFFEF4444), 1.4),
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
