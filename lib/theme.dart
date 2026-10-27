import 'package:flutter/material.dart';

// Palette: ink green for text and headers, teal for actions,
// amber only for the winner, mint-grey for the page background.
const Color kInk = Color(0xFF0E2F2B);
const Color kTeal = Color(0xFF0F766E);
const Color kAmber = Color(0xFFF59E0B);
const Color kPage = Color(0xFFF2F6F4);

const List<Color> kAvatarColors = [
  Color(0xFF0F766E),
  Color(0xFF6D28D9),
  Color(0xFFEA580C),
  Color(0xFF2563EB),
  Color(0xFFBE185D),
];

Color avatarColor(int index) => kAvatarColors[index % kAvatarColors.length];

// One shared look for every white card in the app.
BoxDecoration cardBox() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3)),
      ],
    );

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.fromSeed(seedColor: kTeal),
    scaffoldBackgroundColor: kPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: kPage,
      foregroundColor: kInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: kInk,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kTeal, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kTeal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}