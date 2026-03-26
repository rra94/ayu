import 'package:flutter/material.dart';

/// Ayu "Lotus" theme — navy depth + gold warmth
/// Logo: gold lotus on dark navy #0D1B2A, accent gold #D4A843

// ── Brand colors ──
const ayuNavy = Color(0xFF1B3A5C);
const ayuNavyDark = Color(0xFF0D1B2A);
const ayuGold = Color(0xFFD4A843);
const ayuGoldLight = Color(0xFFE8C46C);
const ayuGoldMuted = Color(0xFFBF8A30);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: ayuNavy,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD4E3F5),
  onPrimaryContainer: Color(0xFF0A1929),
  secondary: ayuGoldMuted,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFF0D4),
  onSecondaryContainer: Color(0xFF3D2800),
  tertiary: Color(0xFF4A6741),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFCCEEBE),
  onTertiaryContainer: Color(0xFF082004),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFF8F9FC),
  onSurface: Color(0xFF1A1C1E),
  surfaceContainerHighest: Color(0xFFECEEF4),
  onSurfaceVariant: Color(0xFF44474E),
  outline: Color(0xFF74777F),
  onInverseSurface: Color(0xFFF1F0F4),
  inverseSurface: Color(0xFF2F3033),
  inversePrimary: Color(0xFFA8C8F0),
  shadow: Color(0xFF000000),
  surfaceTint: ayuNavy,
  outlineVariant: Color(0xFFD0D2DA),
  scrim: Color(0xFF000000),
);

// ── Semantic status colors ──
// These adapt to light/dark but keep semantic meaning (green=good, red=bad, etc.)
extension AyuSemanticColors on ColorScheme {
  // Status
  Color get success => brightness == Brightness.light
      ? const Color(0xFF2E7D32) : const Color(0xFF81C784);
  Color get successContainer => brightness == Brightness.light
      ? const Color(0xFFE8F5E9) : const Color(0xFF1B5E20);
  Color get warning => brightness == Brightness.light
      ? const Color(0xFFE65100) : const Color(0xFFFFB74D);
  Color get warningContainer => brightness == Brightness.light
      ? const Color(0xFFFFF3E0) : const Color(0xFF4E2600);
  Color get caution => brightness == Brightness.light
      ? const Color(0xFFF9A825) : const Color(0xFFFFD54F);

  // Charts & data
  Color get chartGreen => brightness == Brightness.light
      ? const Color(0xFF43A047) : const Color(0xFF81C784);
  Color get chartOrange => brightness == Brightness.light
      ? const Color(0xFFEF6C00) : const Color(0xFFFFB74D);
  Color get chartRed => brightness == Brightness.light
      ? const Color(0xFFD32F2F) : const Color(0xFFEF9A9A);
  Color get chartPurple => brightness == Brightness.light
      ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8);
  Color get chartBrown => brightness == Brightness.light
      ? const Color(0xFF5D4037) : const Color(0xFFBCAAA4);
  Color get chartAmber => brightness == Brightness.light
      ? const Color(0xFFFFA000) : const Color(0xFFFFD54F);
  Color get chartBlue => brightness == Brightness.light
      ? const Color(0xFF1565C0) : const Color(0xFF90CAF9);
  Color get chartTeal => brightness == Brightness.light
      ? const Color(0xFF00796B) : const Color(0xFF80CBC4);
  Color get chartDeepOrange => brightness == Brightness.light
      ? const Color(0xFFBF360C) : const Color(0xFFFF8A65);
  Color get chartPink => brightness == Brightness.light
      ? const Color(0xFFC2185B) : const Color(0xFFF48FB1);
  Color get chartCyan => brightness == Brightness.light
      ? const Color(0xFF00838F) : const Color(0xFF80DEEA);
  Color get chartIndigo => brightness == Brightness.light
      ? const Color(0xFF283593) : const Color(0xFF9FA8DA);
  Color get chartGrey => brightness == Brightness.light
      ? const Color(0xFF616161) : const Color(0xFFBDBDBD);
  Color get chartDeepPurple => brightness == Brightness.light
      ? const Color(0xFF512DA8) : const Color(0xFFB39DDB);
}

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA8C8F0),
  onPrimary: Color(0xFF0A2240),
  primaryContainer: ayuNavy,
  onPrimaryContainer: Color(0xFFD4E3F5),
  secondary: ayuGoldLight,
  onSecondary: Color(0xFF3D2800),
  secondaryContainer: Color(0xFF5A3F10),
  onSecondaryContainer: Color(0xFFFFF0D4),
  tertiary: Color(0xFFB0D2A4),
  onTertiary: Color(0xFF1D3616),
  tertiaryContainer: Color(0xFF334E2B),
  onTertiaryContainer: Color(0xFFCCEEBE),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: ayuNavyDark,
  onSurface: Color(0xFFE3E2E6),
  surfaceContainerHighest: Color(0xFF142438),
  onSurfaceVariant: Color(0xFFC4C6CF),
  outline: Color(0xFF8E9099),
  onInverseSurface: Color(0xFF1A1C1E),
  inverseSurface: Color(0xFFE3E2E6),
  inversePrimary: ayuNavy,
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFA8C8F0),
  outlineVariant: Color(0xFF44474E),
  scrim: Color(0xFF000000),
);
