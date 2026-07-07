import 'package:flutter/material.dart';

import 'actas_theme.dart';
import '../../../../utils/constants/color.constant.dart';

class FormEditMinutesMemosWidget extends StatelessWidget {
  final String hintTextform;
  final TextEditingController controller;
  final int maxLength;

  const FormEditMinutesMemosWidget({
    super.key,
    required this.hintTextform,
    required this.controller,
    this.maxLength = 150,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo requerido';
        }
        if (value.trim().length < 5) {
          return 'Debe tener al menos 5 caracteres';
        }
        return null;
      },

      decoration: InputDecoration(
        counterText: '',
        hintText: hintTextform,

        hintStyle: TextStyle(
          color: TColors.textFieldDisabledColor,
        ),

        filled: true,
        fillColor: TColors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AC.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AC.primary,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}