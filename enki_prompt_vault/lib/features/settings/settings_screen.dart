import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../backup/backup_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final promptCount = ref.watch(promptCountProvider);
    final collectionCount = ref.watch(collectionCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Appearance'),
          _settingsTile(
            context,
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: isDark ? 'Enabled' : 'Disabled',
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
              activeTrackColor: AppColors.accentCyan,
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Data'),
          _settingsTile(
            context,
            icon: Icons.backup_rounded,
            title: 'Backup & Restore',
            subtitle: 'Manage your data backups',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackupScreen()),
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.file_upload_rounded,
            title: 'Import Prompts',
            subtitle: 'JSON, CSV, Markdown, TXT',
            onTap: () => _importPrompts(context, ref),
          ),
          _settingsTile(
            context,
            icon: Icons.file_download_rounded,
            title: 'Export Prompts',
            subtitle: 'Export all prompts',
            onTap: () => _showExportDialog(context, ref),
          ),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Storage'),
          _statsCard(context, promptCount, collectionCount),
          const SizedBox(height: 20),
          _sectionTitle(context, 'About'),
          _settingsTile(
            context,
            icon: Icons.auto_awesome_rounded,
            title: AppConstants.appName,
            subtitle: 'Version ${AppConstants.appVersion}',
          ),
          _settingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Architecture',
            subtitle: 'Flutter + SQLite + Riverpod\nOffline-first, local-only',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.accentCyan,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String subtitle = '',
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                )
              : null,
          trailing: trailing ??
              (onTap != null
                  ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary)
                  : null),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _statsCard(
    BuildContext context,
    AsyncValue<int> promptCount,
    AsyncValue<int> collectionCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _statRow(
            context,
            'Total Prompts',
            promptCount.when(data: (v) => '$v', loading: () => '...', error: (_, _) => '0'),
          ),
          const Divider(height: 20),
          _statRow(
            context,
            'Collections',
            collectionCount.when(data: (v) => '$v', loading: () => '...', error: (_, _) => '0'),
          ),
          const Divider(height: 20),
          _statRow(context, 'Database', AppConstants.dbName),
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _importPrompts(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv', 'md', 'txt', 'markdown'],
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    try {
      final backupRepo = ref.read(backupRepositoryProvider);
      final promptRepo = ref.read(promptRepositoryProvider);
      List prompts;

      if (path.endsWith('.json')) {
        prompts = await backupRepo.importJson(path);
      } else if (path.endsWith('.csv')) {
        prompts = await backupRepo.importCsv(path);
      } else if (path.endsWith('.md') || path.endsWith('.markdown')) {
        prompts = await backupRepo.importMarkdown(path);
      } else {
        prompts = await backupRepo.importTxt(path);
      }

      if (prompts.isNotEmpty) {
        await promptRepo.bulkInsert(prompts.cast());
        refreshPrompts(ref);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${prompts.length} prompts')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('JSON'),
              onTap: () => _exportAs(ctx, ref, 'json'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded),
              title: const Text('CSV'),
              onTap: () => _exportAs(ctx, ref, 'csv'),
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('Markdown'),
              onTap: () => _exportAs(ctx, ref, 'md'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportAs(BuildContext ctx, WidgetRef ref, String format) async {
    Navigator.pop(ctx);
    try {
      final promptRepo = ref.read(promptRepositoryProvider);
      final backupRepo = ref.read(backupRepositoryProvider);
      final prompts = await promptRepo.getAll(limit: 999999);

      String path;
      switch (format) {
        case 'json':
          path = await backupRepo.exportJson(prompts);
        case 'csv':
          path = await backupRepo.exportCsv(prompts);
        default:
          path = await backupRepo.exportMarkdown(prompts);
      }

      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Exported to: $path')),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
