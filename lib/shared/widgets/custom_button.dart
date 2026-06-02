import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

enum CustomButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leadingWidget;
  final CustomButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isOutlined;
  final bool isDestroy;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.leadingWidget,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isOutlined = false,
    this.isDestroy = false,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Determine dimensions based on size
    final double height;
    final double horizontalPadding;
    final double fontSize;
    final double iconSize;
    final double borderRadius;

    switch (size) {
      case CustomButtonSize.small:
        height = 32;
        horizontalPadding = 12;
        fontSize = 12;
        iconSize = 16;
        borderRadius = 8;
        break;
      case CustomButtonSize.medium:
        height = 40;
        horizontalPadding = 24;
        fontSize = 12;
        iconSize = 24;
        borderRadius = 10;
        break;
      case CustomButtonSize.large:
        height = 48;
        horizontalPadding = 32;
        fontSize = 12;
        iconSize = 24;
        borderRadius = 12;
        break;
    }

    final baseColor =
        backgroundColor ?? (isDestroy ? AppColors.red500 : AppColors.sky500);
    final effectiveBackgroundColor = isOutlined
        ? Colors.transparent
        : baseColor;
    final effectiveTextColor =
        textColor ?? (isOutlined ? baseColor : Colors.white);

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return isOutlined
                      ? Colors.transparent
                      : effectiveBackgroundColor.withValues(alpha: 0.25);
                }
                return effectiveBackgroundColor;
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                return effectiveTextColor;
              }),
              side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
                if (!isOutlined) return BorderSide.none;
                if (states.contains(WidgetState.disabled)) {
                  return BorderSide(
                    color: baseColor.withValues(alpha: 0.25),
                    width: 1,
                  );
                }
                return BorderSide(color: baseColor, width: 1);
              }),
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return isOutlined
                      ? baseColor.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.15);
                }
                return null;
              }),
            ),
        child: isLoading
            ? SizedBox(
                height: iconSize,
                width: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingWidget != null) ...[
                    leadingWidget!,
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTextStyles.semiBold(fontSize),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
