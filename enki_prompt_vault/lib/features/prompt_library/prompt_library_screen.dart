import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/prompt_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/search_bar_widget.dart';
import 'prompt_detail_screen.dart';
import 'prompt_edit_screen.dart';

class PromptLibraryScreen extends ConsumerStatefulWidget {
  const PromptLibraryScreen({super.key});

  @override
  ConsumerState<PromptLibraryScreen> createState() => _PromptLibraryScreenState();
}

class _PromptLibraryScreenState extends ConsumerState<PromptLibraryScreen> {
  final _searchController = TextEditingController();
  String? _filterCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(promptListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Prompt Library'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.textSecondary),
            color: AppColors.surface,
            onSelected: (value) {},
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'modified_at DESC', child: Text('Recently Modified')),
              const PopupMenuItem(value: 'created_at DESC', child: Text('Newest First')),
              const PopupMenuItem(value: 'title ASC', child: Text('A-Z')),
              const PopupMenuItem(value: 'rating DESC', child: Text('Highest Rated')),
              const PopupMenuItem(value: 'use_count DESC', child: Text('Most Used')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PromptEditScreen()),
          );
          if (created == true) refreshPrompts(ref);
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
              trailing: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
            ),
          ),
          if (_filterCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_filterCategory!),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _filterCategory = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildPromptList(prompts),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = ref.watch(searchResultsProvider);
    return results.when(
      data: (prompts) {
        if (prompts.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No results found',
            subtitle: 'Try different keywords',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: prompts.length,
          itemBuilder: (context, i) => PromptCard(
            prompt: prompts[i],
            animationIndex: i,
            onTap: () => _openDetail(prompts[i].id),
            onFavorite: () => _toggleFavorite(prompts[i].id),
            onCopy: () => _onCopy(prompts[i].id),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPromptList(AsyncValue<dynamic> prompts) {
    return prompts.when(
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.auto_awesome_rounded,
            title: 'No prompts yet',
            subtitle: 'Create your first prompt to get started',
            action: FilledButton.icon(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const PromptEditScreen()),
                );
                if (created == true) refreshPrompts(ref);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create Prompt'),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, i) => PromptCard(
            prompt: list[i],
            animationIndex: i,
            onTap: () => _openDetail(list[i].id),
            onFavorite: () => _toggleFavorite(list[i].id),
            onCopy: () => _onCopy(list[i].id),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _openDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailScreen(promptId: id)),
    ).then((_) => refreshPrompts(ref));
  }

  void _toggleFavorite(String id) {
    ref.read(promptRepositoryProvider).toggleFavorite(id);
    refreshPrompts(ref);
  }

  void _onCopy(String id) {
    ref.read(promptRepositoryProvider).incrementCopyCount(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.surfaceHigh,
      ),
    );
  }
}
