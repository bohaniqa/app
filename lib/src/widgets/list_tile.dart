import 'package:boq/src/fonts/icons.dart';
import 'package:boq/src/theme.dart';
import 'package:flutter/material.dart';

class BOQListTile extends StatelessWidget {
  
  const BOQListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.linkIcon,
  });

  final String title;

  final String? subtitle;

  final Widget? trailing;

  final void Function()? onTap;

  final IconData? linkIcon;

  @override
  Widget build(final BuildContext context) => ListTile(
    tileColor: BOQColors.theme.accent1,
    title: Text(
      title,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: BOQColors.theme.background,
      ),
    ),
    subtitle: subtitle != null
      ? Text(
          subtitle!,
          style: TextStyle(
            color: BOQColors.theme.background,
            fontSize: 16.0,
          ),
        )
      : null,
    onTap: onTap,
    trailing: trailing ?? (onTap != null 
      ? Icon(
          linkIcon ?? BOQIcons.link, 
          color: BOQColors.theme.background,
        ) 
      : null),
  );
}