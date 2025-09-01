import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.iconSize = Sizes.iconSm,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final String title, subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: iconSize,),
      title: Text(title, style:  Theme.of(context).textTheme.labelMedium),
      subtitle: Text(subTitle, style: Theme.of(context).textTheme.labelSmall),
      trailing: trailing,
      onTap: onTap,
    );
  }
}