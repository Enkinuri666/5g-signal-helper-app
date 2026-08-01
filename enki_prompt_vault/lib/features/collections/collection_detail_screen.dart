import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/prompt_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/collection_model.dart';
import '../../data/models/prompt_model.dart';
import '../prompt_library/prompt_detail_screen.dart';

final _collectionPromptsProvider =
    FutureProvider.autoDispose.family<List<PromptModel>, String>((ref, collectionId) async {
  return ref.watch(promptRepositoryProvider).getByCollection(collectionId);
});

class CollectionDetailScreen extends ConsumerWidget {
  final CollectionModel collection;
  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(_collectionPromptsProvider(collection.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(collection.name),
      ),
      body: prompts.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'Empty collection',
              subtitle: 'Add prompts to this collection from the prompt editor',
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
              ),
              onFavorite: () {
                ref.read(promptRepositoryProvider).toggleFavorite(list[i].id);
                refreshPrompts(ref);
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
