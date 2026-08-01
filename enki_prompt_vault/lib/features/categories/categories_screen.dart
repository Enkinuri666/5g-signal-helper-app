import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/prompt_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/category_model.dart';
import '../prompt_library/prompt_detail_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(rootCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Categories'),
      ),
      body: categories.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.category_rounded,
              title: 'No categories',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => _CategoryTile(
              category: list[i],
              index: i,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(category: list[i]),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.index,
    required this.onTap,
  });

  Color get _color {
    if (category.color.isEmpty) return AppColors.accentCyan;
    return Color(int.parse('FF${category.color}', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder_rounded, color: _color, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                if (category.promptCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${category.promptCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 30).ms, duration: 250.ms)
        .slideX(begin: 0.02, end: 0);
  }
}

class CategoryDetailScreen extends ConsumerWidget {
  final CategoryModel category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategories = ref.watch(subcategoriesProvider(category.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(category.name),
      ),
      body: CustomScrollView(
        slivers: [
          // Subcategories
          subcategories.when(
            data: (subs) {
              if (subs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Subcategories',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        );
                      }
                      final sub = subs[i - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: AppColors.surfaceVariant,
                          leading: const Icon(Icons.subdirectory_arrow_right_rounded,
                              size: 16, color: AppColors.textTertiary),
                          title: Text(sub.name),
                          trailing: sub.promptCount > 0
                              ? Text('${sub.promptCount}',
                                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 12))
                              : null,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state = sub.name;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _SubcategoryPromptsScreen(name: sub.name),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: subs.length + 1,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
          ),
          // Prompts in this category
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Prompts',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
          _PromptsByCategorySliver(categoryName: category.name),
        ],
      ),
    );
  }
}

class _SubcategoryPromptsScreen extends ConsumerWidget {
  final String name;
  const _SubcategoryPromptsScreen({required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(promptsByCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(name),
      ),
      body: prompts.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notes_rounded,
              title: 'No prompts in this category',
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
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

final _categoryPromptsProvider =
    FutureProvider.autoDispose.family<List<dynamic>, String>((ref, category) async {
  return ref.watch(promptRepositoryProvider).getByCategory(category);
});

class _PromptsByCategorySliver extends ConsumerWidget {
  final String categoryName;
  const _PromptsByCategorySliver({required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(_categoryPromptsProvider(categoryName));

    return prompts.when(
      data: (list) {
        if (list.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No prompts yet', style: TextStyle(color: AppColors.textTertiary)),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => PromptCard(
                prompt: list[i],
                animationIndex: i,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PromptDetailScreen(promptId: list[i].id),
                  ),
                ),
              ),
              childCount: list.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
    );
  }
}
