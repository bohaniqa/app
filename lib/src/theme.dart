import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';
import 'consts.dart';

class BOQColors {

  const BOQColors._({  
    required this.background,
    required this.tile,
    required this.text,
    required this.subtext,
    required this.placeholder,
    required this.divider,
  });
  
  static BOQColors theme = _light();

  final Color accent1 = const Color(0xFF3778FA);
  final Color accent2 = const Color(0xFFFA375C);
  final Color background;
  final Color tile;
  final Color text;
  final Color subtext;
  final Color placeholder;
  final Color divider;

  static set(final Brightness brightness)
    => theme = brightness == Brightness.light ? _light() : _dark();

  static _light() => const BOQColors._(
    background: Color(0xFFFFFFFF), 
    tile: Color(0xFFF7F8FA), 
    text: Color(0xFF141414), 
    subtext: Color(0xFF78797A), 
    placeholder: Color(0xFFB4B6B8), 
    divider: Color(0xFFF2F3F5),
  );

  static _dark() => const BOQColors._(
    background: Color(0xFF141414), 
    tile: Color(0xFF292929), 
    text: Color(0xFFFFFFFF), 
    subtext: Color(0xFF8C8D8F), 
    placeholder: Color(0xFFA0A2A3), 
    divider: Color(0xFF282929),
  );
}

TextStyle createTextStyle(
  final double size, {
  final FontWeight weight = FontWeight.normal,
  final Color? color,
}) => TextStyle(
  fontFamily: kFontFamily,
  fontWeight: weight,
  color: color,
);

ColorScheme createColorScheme(
  final Brightness brightness,
  final BOQColors themeColors,
) {
  return brightness == Brightness.light
    ? ColorScheme.light(
        primary: themeColors.background,
        background: themeColors.background,
        secondary: themeColors.accent1,
        tertiary: themeColors.text,
        surfaceTint: themeColors.placeholder,
      )
    : ColorScheme.dark(
        primary: themeColors.background,
        background: themeColors.background,
        secondary: themeColors.accent1,
        tertiary: themeColors.text,
        surfaceTint: themeColors.placeholder,
      );
}

ThemeData createThemeData(final Brightness brightness) {
  
  BOQColors.set(brightness);
  final themeColors = BOQColors.theme;

  final contrastBrightness = brightness == Brightness.light ? Brightness.dark : Brightness.light;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: themeColors.background,
      statusBarIconBrightness: contrastBrightness,
      systemNavigationBarColor: themeColors.background,
      systemNavigationBarIconBrightness: contrastBrightness,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  final primaryButtonStyle = TextButton.styleFrom(
    backgroundColor: themeColors.accent1,
    disabledBackgroundColor: themeColors.placeholder,
    minimumSize: const Size.square(48.0),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(
      horizontal: kSpacing,
    ),
  );
  return ThemeData(
    scaffoldBackgroundColor: themeColors.background,
    colorScheme: createColorScheme(brightness, themeColors),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: themeColors.accent1,
    ),
    dividerTheme: DividerThemeData(
      indent: 0.0,
      endIndent: 0.0,
      thickness: 1.5,
      space: 1.5,
      color: themeColors.divider,
    ),
    indicatorColor: themeColors.accent1,
    sliderTheme: SliderThemeData(
      overlayShape: SliderComponentShape.noOverlay,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8.0),
      ),
      hintStyle: TextStyle(
        color: themeColors.placeholder,
      ),
      contentPadding: const EdgeInsets.all(kSpacing),
      filled: true,
    ),
    tooltipTheme: TooltipThemeData(
      padding: const EdgeInsets.all(kSpacing),
      preferBelow: false,
      textStyle: createTextStyle(
        14.0, 
        color: themeColors.placeholder,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: themeColors.background,
      )
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: themeColors.tile,
      collapsedBackgroundColor: themeColors.tile,
      textColor: themeColors.text,
      collapsedTextColor: themeColors.text,
      iconColor: themeColors.text,
      collapsedIconColor: themeColors.text,
      tilePadding: const EdgeInsets.all(kSpacing),
      childrenPadding: const EdgeInsets.all(0.0),
      expandedAlignment: Alignment.centerLeft,
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: const EdgeInsets.all(kSpacing),
      tileColor: themeColors.tile,
      horizontalTitleGap: 16.0,
      minVerticalPadding: 0.0,
      dense: true,
      visualDensity: VisualDensity.compact,
    ),
    textTheme: TextTheme(
      bodySmall: createTextStyle(14.0),
      bodyMedium: createTextStyle(16.0),
      bodyLarge: createTextStyle(18.0),
    ),
    textButtonTheme: TextButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: themeColors.accent1,
        minimumSize: const Size.square(48.0),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: 0.0,
        ),
        side: BorderSide(
          width: 4.0, 
          color: themeColors.background,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    cardTheme: CardTheme(
      elevation: 0.0,
      margin: EdgeInsets.zero,
      color: themeColors.tile,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSpacing / 3),
      ),
    ),
    extensions: [
      SolanaWalletThemeExtension(
        primaryButtonStyle: primaryButtonStyle,
        cardTheme: SolanaWalletModalCardTheme(
          color: themeColors.background,
        ),
      ),
    ],
  );
}