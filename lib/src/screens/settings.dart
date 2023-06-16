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

  @override
  void initState() {
    super.initState();
    _brightness = BOQSettingsProvider.instance.value?.brightness ?? Brightness.light;
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

  bool _brightnessToBool(final Brightness? brightness) => brightness == Brightness.dark;

  void _onTapSwitchTile() => _onSwitchChanged(!_brightnessToBool(_brightness));

  void _onSwitchChanged(final bool value) {
    if (mounted) {
      final Brightness brightness = value ? Brightness.dark : Brightness.light;
      BOQSettingsProvider.instance.set(brightness: brightness);
      setState(() => _brightness = brightness);
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
            onTap: _onTapSwitchTile,
            trailing: Switch(
              onChanged: _onSwitchChanged,
              value: _brightnessToBool(_brightness), 
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