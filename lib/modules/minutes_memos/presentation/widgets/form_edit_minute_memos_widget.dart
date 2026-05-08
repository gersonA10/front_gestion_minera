import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class FormEditMinutesMemosWidget
    extends StatelessWidget {

  final String hintTextform;

  final TextEditingController?
      controller;

  final int maxLength;

  const FormEditMinutesMemosWidget({
    super.key,
    required this.hintTextform,
    this.controller,
    this.maxLength = 150,
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(

      controller: controller,

      maxLength: maxLength,

      validator: (value) {

        if (value == null ||
            value.trim().isEmpty) {

          return 'Campo requerido';
        }

        return null;
      },

      decoration: InputDecoration(

        counterText: '',

        hintText: hintTextform,

        hintStyle: TextStyle(
          color:
              TColors.textFieldDisabledColor,
        ),

        filled: true,

        fillColor: TColors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide: BorderSide(
            color:
                TColors.textFieldDisabledColor,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),

          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}