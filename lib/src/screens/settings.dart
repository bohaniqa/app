import 'package:boq/src/consts.dart';
import 'package:boq/src/fonts/icons.dart';
import 'package:boq/src/providers/settings.dart';
import 'package:boq/src/screens/help.dart';
import 'package:boq/src/screens/screen.dart';
import 'package:boq/src/theme.dart';
import 'package:boq/src/widgets/list_tile.dart';
import 'package:boq/src/widgets/section_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:url_launcher/url_launcher.dart';

class BOQSettingsScreen extends StatefulWidget {

  const BOQSettingsScreen({
    super.key,
  });
  static const String routeName = '/settings';

  @override
  State<BOQSettingsScreen> createState() => _BOQSettingsScreenState();
}

class _BOQSettingsScreenState extends State<BOQSettingsScreen> {
  
  late Brightness _brightness;

  late bool _forceShift;

  @override
  void initState() {
    super.initState();
    _brightness = BOQSettingsProvider.instance.value?.brightness ?? Brightness.dark;
    _forceShift = BOQSettingsProvider.instance.value?.forceShift ?? false;
  }

  void _onHelp() {
    Navigator.push(
      context, 
      CupertinoPageRoute(
        builder: (_) => const BOQHelpScreen(),
      ),
    );
  }

  void _onDiscord() {
    launchUrl(Uri.https('discord.gg', 'Ht2g2fRQbs')).ignore();
  }

  void _onTwitter() {
    launchUrl(Uri.https('twitter.com', 'bohaniqa')).ignore();
  }

  bool _brightnessToBool(final Brightness? brightness) => brightness != Brightness.light;

  void _onTapBrightnessTile() => _onBrightnessChanged(!_brightnessToBool(_brightness));

  void _onBrightnessChanged(final bool value) {
    if (mounted) {
      final Brightness brightness = value ? Brightness.dark : Brightness.light;
      BOQSettingsProvider.instance.set(brightness: brightness);
      setState(() => _brightness = brightness);
    }
  }
  
  void _onTapForceShift() => _onForceShiftChanged(!_forceShift);

  void _onForceShiftChanged(final bool value) {
    if (mounted) {
      BOQSettingsProvider.instance.set(forceShift: value);
      setState(() => _forceShift = value);
    }
  }

  @override
  Widget build(final BuildContext context) {
    const double sectionSpacing = kSpacing * 2.0;
    return BOQScreen(
      title: 'SETTINGS', 
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const BOQSectionTitle(
            title: 'Brightness',
          ),
          const SizedBox(
            height: kSpacing,
          ),
          BOQListTile(
            title: 'Theme',
            subtitle: '${_brightness.name.capitalize()} Mode',
            onTap: _onTapBrightnessTile,
            trailing: Switch(
              onChanged: _onBrightnessChanged,
              value: _brightnessToBool(_brightness), 
              activeColor: BOQColors.theme.background,
            ),
          ),

          const SizedBox(
            height: kSpacing,
          ),
          const BOQSectionTitle(
            title: 'Shift',
          ),
          const SizedBox(
            height: kSpacing,
          ),
          BOQListTile(
            title: 'Clock-in',
            subtitle: 'Enable continuous clock-in.',
            onTap: _onTapForceShift,
            trailing: Switch(
              onChanged: _onForceShiftChanged,
              value: _forceShift, 
              activeColor: BOQColors.theme.background,
            ),
          ),

          const SizedBox(
            height: sectionSpacing,
          ),

          const BOQSectionTitle(
            title: 'Support',
          ),
          const SizedBox(
            height: kSpacing,
          ),
          BOQListTile(
            title: 'Help',
            onTap: _onHelp,
            linkIcon: BOQIcons.arrowright,
          ),

          const SizedBox(
            height: sectionSpacing,
          ),

          const BOQSectionTitle(
            title: 'Contact',
          ),
          const SizedBox(
            height: kSpacing,
          ),
          BOQListTile(
            title: 'Discord',
            onTap: _onDiscord,
          ),
          const SizedBox(
            height: kItemSpacing,
          ),
          BOQListTile(
            title: 'Twitter',
            onTap: _onTwitter,
          ),

          const SizedBox(
            height: sectionSpacing,
          ),

          const BOQSectionTitle(
            title: 'App Information',
          ),
          const SizedBox(
            height: kSpacing,
          ),
          BOQListTile(
            title: 'Version',
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                fontSize: 20,
                color: BOQColors.theme.background,
              ),
            ),
          ),
          const SizedBox(
            height: kItemSpacing,
          ),
          BOQListTile(
            title: 'Build Number',
            trailing: Text(
              '1', 
              style: TextStyle(
                fontSize: 20,
                color: BOQColors.theme.background,
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}