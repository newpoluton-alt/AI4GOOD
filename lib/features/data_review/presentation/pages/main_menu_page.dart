import 'package:flutter/material.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../data_review_strings.dart';
import 'data_select_page.dart';
import 'data_upload_page.dart';
import 'my_data_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    final actions = _workflowActions(strings);

    return SafeArea(
      child: ColoredBox(
        color: AppColors.background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                responsive.horizontalPadding,
                responsive.verticalPadding,
                responsive.horizontalPadding,
                responsive.verticalPadding + 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HomeHeader(),
                      SizedBox(height: compact ? 18 : 26),
                      _HeroPanel(
                        title: strings.welcome,
                        subtitle: strings.analysisSubtitle,
                      ),
                      const SizedBox(height: 18),
                      _WorkflowOverview(actions: actions, compact: compact),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 430;
    final logoHeight = compact ? 42.0 : 54.0;

    return Row(
      children: [
        AppBrandLogo(height: logoHeight, width: logoHeight * 2.62),
        SizedBox(width: compact ? 10 : 16),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'MadAInsight',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurface(
      padding: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.primary, width: 5)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.mutedText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowOverview extends StatelessWidget {
  const _WorkflowOverview({required this.actions, required this.compact});

  final List<_WorkflowAction> actions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          for (final action in actions) ...[
            _OverviewTile(action: action),
            if (action != actions.last) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final action in actions) ...[
          Expanded(child: _OverviewTile(action: action)),
          if (action != actions.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({required this.action});

  final _WorkflowAction action;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      shadow: false,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: action.pageBuilder)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconTile(icon: action.icon, color: action.color, size: 38),
                const SizedBox(height: 14),
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkflowAction {
  const _WorkflowAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pageBuilder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder pageBuilder;
}

List<_WorkflowAction> _workflowActions(DataReviewStrings strings) {
  return [
    _WorkflowAction(
      title: strings.dataUpload,
      subtitle: strings.uploadSubtitle,
      icon: Icons.upload_file_rounded,
      color: AppColors.primary,
      pageBuilder: (_) => const DataUploadPage(),
    ),
    _WorkflowAction(
      title: strings.myData,
      subtitle: strings.myDataSubtitle,
      icon: Icons.folder_open_rounded,
      color: const Color(0xFF2457D6),
      pageBuilder: (_) => const MyDataPage(),
    ),
    _WorkflowAction(
      title: strings.aiDataAnalysis,
      subtitle: strings.analysisSubtitle,
      icon: Icons.auto_awesome_rounded,
      color: AppColors.warning,
      pageBuilder: (_) => const DataSelectPage(),
    ),
  ];
}
