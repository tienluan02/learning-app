import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/modules/widgets/animations/custom_switch.dart';

class SettingTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String icon;
  final bool isSwitch;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;
  const SettingTile({
    required this.title,
    required this.icon,
    this.switchValue,
    this.onChanged,
    this.subtitle,
    this.onTap,
    this.isSwitch = false,
    super.key,
  });

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: widget.onTap,
      leading: SvgPicture.asset(widget.icon),
      title: Text(widget.title, style: AppTypography.kBold16),
      subtitle: widget.isSwitch
          ? null
          : widget.subtitle != null
              ? Text(widget.subtitle!, style: AppTypography.kLight14)
              : null,
      trailing: widget.isSwitch
          ? CustomSwitch(
              value: widget.switchValue!,
              activeColor: isDarkMode(context)
                  ? Colors.black
                  : AppColors.kPrimary,
              onChanged: widget.onChanged!,
            )
          : SvgPicture.asset(
              AppAssets.kArrowBackForward,
              colorFilter: ColorFilter.mode(
                AppColors.kSecondary.withValues(alpha: 0.4),
                BlendMode.srcIn,
              ),
            ),
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
    );
  }
}
