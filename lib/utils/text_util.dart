import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  ///non-bold titles in green
  static TextStyle mainStyleBlue25(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.blue,
    fontSize: 25,
    fontWeight: FontWeight.w400,
  );

  static TextStyle mainStyleBlue22Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleBlue12Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleBlue20Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      );

  ///titles in bold green
  static TextStyle mainStyleBlue25Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleBlue35Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      );

  static TextStyle mainStyleBlue16(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.blue,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleBlue18Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleBlue18(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.blue,
    fontSize: 18,
  );
  static TextStyle mainStyleBlue14Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleBlue14(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.blue,
    fontSize: 14,
  );
  static TextStyle mainStyleBlue12(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.blue,
    fontSize: 12,
  );
  static TextStyle mainStyleBlue10Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleBlue10(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.blue,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleBlue16Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.blue,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleWhite16(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleWhite16Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyle16Bold(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyleWhite14Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleWhite14(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.white,
    fontSize: 14,
    //fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyleWhite12(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.white,
    fontSize: 12,
    //fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyleWhite12Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleWhite10Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );

  ///non-bold titles in white
  static TextStyle mainStyleWhite25(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.white,
    fontSize: 25,
    fontWeight: FontWeight.w400,
  );

  ///bold titles in white
  static TextStyle mainStyleWhite25Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      );

  ///header text
  static TextStyle mainStyle20Bold(BuildContext context) =>
      GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold);
  static TextStyle mainStyleWhite20Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleWhite18(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.white,
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleWhite18Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleGrey14(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.grey,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleGrey12(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.grey,
    fontSize: 12,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleGrey10(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.grey,
    fontSize: 10,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleGrey14Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.grey,
        fontSize: 14,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyleGrey12Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.grey,
        fontSize: 12,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
      );
  static TextStyle mainStyle12Bold(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 12,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyle12(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 12,
    fontStyle: FontStyle.normal,
  );
  static TextStyle mainStyle10(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 10,
    fontStyle: FontStyle.normal,
  );
  static TextStyle mainStyle11Bold(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 11,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyle10Bold(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 10,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyle25Bold(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 25,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyle14Bold(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );
  static TextStyle mainStyle14(BuildContext context) => GoogleFonts.inter(
    //color: Theme.of(context).colorScheme.grey,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );
  static TextStyle mainStyleRed10Bold(BuildContext context) =>
      GoogleFonts.inter(
        color: Theme.of(context).colorScheme.red,
        fontSize: 10,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
      );

  static TextStyle? mainStyleBlack14(BuildContext context) => GoogleFonts.inter(
    color: Theme.of(context).colorScheme.black,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
  );
}
