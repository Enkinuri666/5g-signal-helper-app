import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/prompt_library/prompt_library_screen.dart';
import 'features/collections/collections_screen.dart';
import 'features/categories/categories_screen.dart';
import 'features/search/search_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/prompt_builder/prompt_builder_screen.dart';
import 'features/settings/settings_screen.dart';

class EnkiApp extends ConsumerWidget {
  const EnkiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Enki Prompt Vault',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.dark : AppTheme.light,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    PromptLibraryScreen(),
    PromptBuilderScreen(),
    _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_rounded),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_rounded),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Builder',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        surfaceTintColor: Colors.transparent,
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuTile(context, Icons.folder_rounded, 'Collections', const CollectionsScreen()),
          _menuTile(context, Icons.category_rounded, 'Categories', const CategoriesScreen()),
          _menuTile(context, Icons.star_rounded, 'Favorites', const FavoritesScreen()),
          _menuTile(context, Icons.search_rounded, 'Search', const SearchScreen()),
          const Divider(height: 32),
          _menuTile(context, Icons.settings_rounded, 'Settings', const SettingsScreen()),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String title, Widget screen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: const Color(0xFF111214),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF8B8D98), size: 22),
          title: Text(
            title,
            style: const TextStyle(color: Color(0xFFF0F0F0), fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF5C5E6A)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        ),
      ),
    );
  }
}
