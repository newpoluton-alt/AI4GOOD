import 'package:flutter/material.dart';

import '../../../../core/presentation/app_ui.dart';

void showAppSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  final width = MediaQuery.sizeOf(context).width;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: width > 620 ? 560 : null,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : AppColors.success,
        content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
      ),
    );
}
