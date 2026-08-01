import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/prompt_card.dart';
import '../../core/widgets/search_bar_widget.dart';
import '../prompt_library/prompt_detail_screen.dart';
import '../search/search_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptCount = ref.watch(promptCountProvider);
    final favoriteCount = ref.watch(favoriteCountProvider);
    final collectionCount = ref.watch(collectionCountProvider);
    final recentPrompts = ref.watch(recentPromptsProvider);
    final pinnedPrompts = ref.watch(pinnedPromptsProvider);
    final favoritePrompts = ref.watch(favoritePromptsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentCyan, AppColors.accentPurple],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Enki Vault',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SearchBarWidget(
                  readOnly: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatsRow(context, promptCount, favoriteCount, collectionCount),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  ref,
                  'Pinned',
                  Icons.push_pin_rounded,
                  pinnedPrompts,
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  ref,
                  'Favorites',
                  Icons.star_rounded,
                  favoritePrompts,
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  ref,
                  'Recently Used',
                  Icons.history_rounded,
                  recentPrompts,
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    AsyncValue<int> promptCount,
    AsyncValue<int> favoriteCount,
    AsyncValue<int> collectionCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Total Prompts',
            value: promptCount.when(
              data: (v) => v.toString(),
              loading: () => '...',
              error: (_, _) => '0',
            ),
            icon: Icons.auto_awesome_rounded,
            color: AppColors.accentCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Favorites',
            value: favoriteCount.when(
              data: (v) => v.toString(),
              loading: () => '...',
              error: (_, _) => '0',
            ),
            icon: Icons.star_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Collections',
            value: collectionCount.when(
              data: (v) => v.toString(),
              loading: () => '...',
              error: (_, _) => '0',
            ),
            icon: Icons.folder_rounded,
            color: AppColors.accentPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    AsyncValue<dynamic> data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accentCyan),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 12),
        data.when(
          data: (prompts) {
            if (prompts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No ${title.toLowerCase()} yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < prompts.length.clamp(0, 5); i++)
                  PromptCard(
                    prompt: prompts[i],
                    animationIndex: i,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromptDetailScreen(promptId: prompts[i].id),
                      ),
                    ),
                    onFavorite: () {
                      ref.read(promptRepositoryProvider).toggleFavorite(prompts[i].id);
                      refreshPrompts(ref);
                    },
                    onCopy: () {
                      ref.read(promptRepositoryProvider).incrementCopyCount(prompts[i].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Prompt copied to clipboard'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.surfaceHigh,
                        ),
                      );
                    },
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}
