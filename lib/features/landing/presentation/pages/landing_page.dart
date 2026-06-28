import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/responsive.dart';
import '../widgets/home_view.dart';
import '../widgets/profile_view.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final responsive = AppResponsive.of(context);
    final navigationItems = [
      _NavigationItem(
        label: l10n.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      _NavigationItem(
        label: l10n.profile,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    return Scaffold(
      body: responsive.useNavigationRail
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    extended: MediaQuery.sizeOf(context).width >= 1240,
                    minExtendedWidth: 180,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    destinations: [
                      for (final item in navigationItems)
                        NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _LandingBody(selectedIndex: _selectedIndex)),
              ],
            )
          : _LandingBody(selectedIndex: _selectedIndex),
      bottomNavigationBar: responsive.useNavigationRail
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: [
                for (final item in navigationItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }
}

class _LandingBody extends StatelessWidget {
  const _LandingBody({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: const [HomeView(), ProfileView()],
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
