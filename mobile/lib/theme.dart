import 'package:flutter/material.dart';

import 'theme_tokens.g.dart';

/// Spacious density of the shared token theme: 16px body, 52px primary controls.
/// Colours come from tokens/colors.json via theme_tokens.g.dart; never use Colors.* in screens.
class Ds extends ThemeExtension<Ds> {
  const Ds(this.c);
  final DsColors c;
  static Ds of(BuildContext context) => Theme.of(context).extension<Ds>()!;

  static const space1 = 4.0, space2 = 8.0, space3 = 12.0, space4 = 16.0, space6 = 24.0, space8 = 32.0, space12 = 48.0;
  static const radiusButton = 8.0, radiusCard = 12.0, radiusBadge = 999.0;
  static const controlLg = 52.0, controlMd = 44.0;
  static const fast = Duration(milliseconds: 150), base = Duration(milliseconds: 200);

  @override
  Ds copyWith({DsColors? c}) => Ds(c ?? this.c);
  @override
  Ds lerp(ThemeExtension<Ds>? other, double t) => t < 0.5 ? this : (other as Ds);
}

ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.dark ? DsColors.dark : DsColors.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: c.actionPrimary, onPrimary: c.textOnAction,
    primaryContainer: c.interactiveSelectedBg, onPrimaryContainer: c.textPrimary,
    secondary: c.actionSecondary, onSecondary: c.textPrimary,
    error: c.actionDestructive, onError: c.textOnAction,
    errorContainer: c.feedbackErrorBg, onErrorContainer: c.feedbackErrorText,
    surface: c.surfacePage, onSurface: c.textPrimary,
    surfaceContainerLowest: c.surfaceCard, surfaceContainerLow: c.surfaceCard, surfaceContainer: c.surfaceSunken,
    surfaceContainerHigh: c.surfaceRaised, surfaceContainerHighest: c.surfaceRaised,
    onSurfaceVariant: c.textSecondary, outline: c.borderStrong, outlineVariant: c.borderDefault,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Ds.radiusButton));
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: b);
  final text = base.textTheme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary).copyWith(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w600, height: 1.05, letterSpacing: -1, color: c.textPrimary),
    displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, height: 1.1, letterSpacing: -0.8, color: c.textPrimary),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.4, color: c.textPrimary),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.25, color: c.textPrimary),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: c.textPrimary),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: c.textPrimary),
    bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: c.textPrimary),
    bodySmall: TextStyle(fontSize: 14, height: 1.45, color: c.textSecondary),
    labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4, color: c.textSecondary),
  );
  return base.copyWith(
    extensions: [Ds(c)],
    textTheme: text,
    scaffoldBackgroundColor: c.surfacePage,
    dividerColor: c.borderDefault,
    appBarTheme: AppBarTheme(backgroundColor: c.surfacePage, foregroundColor: c.textPrimary, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, titleTextStyle: text.titleLarge),
    cardTheme: CardThemeData(color: c.surfaceCard, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Ds.radiusCard), side: BorderSide(color: c.borderDefault))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(Ds.controlLg), shape: shape, textStyle: text.labelLarge)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(Ds.controlLg), shape: shape, side: BorderSide(color: c.borderStrong), foregroundColor: c.textPrimary, textStyle: text.labelLarge)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(Ds.controlMd, Ds.controlMd), shape: shape, foregroundColor: c.textLink, textStyle: text.labelLarge)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: c.surfaceCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Ds.radiusButton), borderSide: BorderSide(color: c.borderStrong)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Ds.radiusButton), borderSide: BorderSide(color: c.borderStrong)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Ds.radiusButton), borderSide: BorderSide(color: c.borderFocus, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: Ds.space4, vertical: Ds.space4),
      labelStyle: text.bodySmall,
    ),
    listTileTheme: ListTileThemeData(contentPadding: const EdgeInsets.symmetric(horizontal: Ds.space4), titleTextStyle: text.titleMedium, subtitleTextStyle: text.bodySmall, iconColor: c.textSecondary),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: c.surfaceCard, indicatorColor: c.actionPrimary, elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.textOnAction : c.textSecondary)),
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall!.copyWith(color: c.textPrimary))),
    snackBarTheme: SnackBarThemeData(backgroundColor: c.textPrimary, contentTextStyle: TextStyle(color: c.surfacePage, fontSize: 16), behavior: SnackBarBehavior.floating, shape: shape),
    dialogTheme: DialogThemeData(backgroundColor: c.surfaceCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Ds.radiusCard))),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.surfaceCard, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Ds.radiusCard)))),
    chipTheme: ChipThemeData(backgroundColor: c.surfaceSunken, side: BorderSide.none, labelStyle: text.bodySmall!.copyWith(color: c.textPrimary), shape: const StadiumBorder()),
    switchTheme: SwitchThemeData(thumbColor: WidgetStatePropertyAll(c.surfaceCard), trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.actionPrimary : c.borderStrong)),
    dividerTheme: DividerThemeData(color: c.borderDefault, thickness: 1, space: 1),
  );
}
