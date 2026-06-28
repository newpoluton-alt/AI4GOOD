import 'package:flutter/material.dart';

import '../../../../core/presentation/app_ui.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.label,
  });

  final bool isLoading;
  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxOverlayWidth = screenWidth < 560
        ? (screenWidth - 32).clamp(240.0, 520.0)
        : 520.0;

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.68),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxOverlayWidth),
                  child: AppSurface(
                    shadow: false,
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                          if (label != null) ...[
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                label!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
