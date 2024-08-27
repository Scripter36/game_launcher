import 'package:flutter/material.dart';

class ButtonStyles {
  static ButtonStyle get primary => TextButton.styleFrom(
        foregroundColor: Color(0xFF000000),
        backgroundColor: Color(0x99FFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        visualDensity: VisualDensity.standard,
        splashFactory: NoSplash.splashFactory,
      );

  static ButtonStyle get error => TextButton.styleFrom(
        foregroundColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0x99DA3737),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        visualDensity: VisualDensity.standard,
        splashFactory: NoSplash.splashFactory,
      );

  static ButtonStyle get secondary => TextButton.styleFrom(
        foregroundColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0x20FFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Paperlogy',
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        visualDensity: VisualDensity.standard,
        splashFactory: NoSplash.splashFactory,
      );
}
