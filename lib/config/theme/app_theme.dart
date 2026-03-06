import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/custom_themes/appbar.theme.dart';
import 'package:front_gestion_minera/config/theme/custom_themes/text.theme.dart';
import 'package:front_gestion_minera/config/theme/custom_themes/text_button.theme.dart';
import 'package:front_gestion_minera/config/theme/custom_themes/text_field.theme.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';


// Light & Dark App Theme
class TAppTheme {
  TAppTheme._(); // To avoid creating instances

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light().copyWith(
      primary: TColors.appMainColor,
      secondary: TColors.appMainDarkColor,
    ),
    textTheme: TTextTheme.lightTextTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    scaffoldBackgroundColor: TColors.appBackgroundColor,
    textButtonTheme: TTextButtonTheme.lightTextButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  // Dark Theme
  static ThemeData dartTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: TColors.appMainColor,
      secondary: TColors.appMainDarkColor,
    ),
    textTheme: TTextTheme.darkTextTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    textButtonTheme: TTextButtonTheme.darkTextButtonTheme,
    scaffoldBackgroundColor: TColors.appBackgroundDarkColor,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}
