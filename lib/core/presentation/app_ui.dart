import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF4F7F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7FAFC);
  static const border = Color(0xFFDCE5E4);
  static const text = Color(0xFF172033);
  static const mutedText = Color(0xFF64706F);
  static const softText = Color(0xFF879391);
  static const primary = Color(0xFF0F8B8D);
  static const primaryDark = Color(0xFF075E61);
  static const success = Color(0xFF187A4D);
  static const warning = Color(0xFFB66016);
  static const danger = Color(0xFFC53232);
  static const info = Color(0xFF1F62D0);
}

class AppRadii {
  const AppRadii._();

  static const small = 6.0;
  static const medium = 8.0;
  static const large = 12.0;
}

class AppSpacing {
  const AppSpacing._();

  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderColor = AppColors.border,
    this.backgroundColor = AppColors.surface,
    this.clipBehavior = Clip.none,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color borderColor;
  final Color backgroundColor;
  final Clip clipBehavior;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: borderColor),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppInfoPill extends StatelessWidget {
  const AppInfoPill({
    super.key,
    required this.label,
    this.icon,
    this.color = const Color(0xFFEAF2FF),
    this.textColor = AppColors.info,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppSurface(
          shadow: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.35,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}

class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({
    super.key,
    this.height = 64,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  static const assetPath =
      'assets/branding/doctors_for_madagascar_logo_vector.svg';

  final double height;
  final double? width;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Doctors for Madagascar logo',
      child: SvgPicture.asset(
        assetPath,
        height: height,
        width: width,
        fit: BoxFit.contain,
        alignment: alignment,
      ),
    );
  }
}
