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
