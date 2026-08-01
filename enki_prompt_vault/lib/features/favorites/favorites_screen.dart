import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/prompt_card.dart';
import '../../core/widgets/empty_state.dart';
import '../prompt_library/prompt_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePromptsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Favorites'),
      ),
      body: favorites.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.star_outline_rounded,
              title: 'No favorites yet',
              subtitle: 'Star prompts to add them here',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => PromptCard(
              prompt: list[i],
              animationIndex: i,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PromptDetailScreen(promptId: list[i].id),
                ),
              ).then((_) => refreshPrompts(ref)),
              onFavorite: () {
                ref.read(promptRepositoryProvider).toggleFavorite(list[i].id);
                refreshPrompts(ref);
              },
              onCopy: () {
                ref.read(promptRepositoryProvider).incrementCopyCount(list[i].id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Copied to clipboard'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.surfaceHigh,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
