import 'package:flutter/material.dart';
import '../services/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final l = AppLocalizations.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primaryContainer),
            child: Text(
              l.t('app_title'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _DrawerItem(
            icon: Icons.note_alt_outlined,
            title: l.t('feature_film_quick_note'),
            route: '/film_quick_note',
            selected: currentRoute == '/film_quick_note',
          ),
          _DrawerItem(
            icon: Icons.timer_outlined,
            title: l.t('feature_darkroom_clock'),
            route: '/darkroom_timer',
            selected: currentRoute == '/darkroom_timer',
          ),
          _DrawerItem(
            icon: Icons.flash_on_outlined,
            title: l.t('feature_flash_calculator'),
            route: '/flash_calculator',
            selected: currentRoute == '/flash_calculator',
          ),
          _DrawerItem(
            icon: Icons.camera_outlined,
            title: l.t('feature_depth_of_field'),
            route: '/dof_calculator',
            selected: currentRoute == '/dof_calculator',
          ),
          _DrawerItem(
            icon: Icons.exposure,
            title: l.t('feature_reciprocity'),
            route: '/reciprocity_calculator',
            selected: currentRoute == '/reciprocity_calculator',
          ),
          _DrawerItem(
            icon: Icons.wb_sunny_outlined,
            title: l.t('feature_light_meter'),
            route: '/light_meter',
            selected: currentRoute == '/light_meter',
          ),
          _DrawerItem(
            icon: Icons.lightbulb_outlined,
            title: l.t('feature_lightpad'),
            route: '/lightpad',
            selected: currentRoute == '/lightpad',
          ),
          _DrawerItem(
            icon: Icons.science_outlined,
            title: l.t('feature_chemical_mixer'),
            route: '/chemical_mixer',
            selected: currentRoute == '/chemical_mixer',
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.settings_outlined,
            title: l.t('feature_settings'),
            route: '/settings',
            selected: currentRoute == '/settings',
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final bool selected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      onTap: () {
        Navigator.pop(context);
        if (!selected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
