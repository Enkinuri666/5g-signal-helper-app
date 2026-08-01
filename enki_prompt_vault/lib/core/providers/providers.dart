import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database_helper.dart';
import '../../data/repositories/prompt_repository.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/models/prompt_model.dart';
import '../../data/models/collection_model.dart';
import '../../data/models/category_model.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

final promptRepositoryProvider = Provider<PromptRepository>((ref) {
  return PromptRepository(ref.watch(databaseProvider));
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(ref.watch(databaseProvider));
});

// Prompt list providers
final promptListProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getAll();
});

final favoritePromptsProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getFavorites();
});

final pinnedPromptsProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getPinned();
});

final recentPromptsProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getRecent();
});

final frequentPromptsProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getFrequentlyUsed();
});

final promptCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.count();
});

final favoriteCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.favoriteCount();
});

final categoryStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.categoryStats();
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(promptRepositoryProvider);
  return repo.search(query);
});

// Category by filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final promptsByCategoryProvider = FutureProvider.autoDispose<List<PromptModel>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  if (category == null) return [];
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getByCategory(category);
});

// Collections
final collectionListProvider = FutureProvider.autoDispose<List<CollectionModel>>((ref) async {
  final repo = ref.watch(collectionRepositoryProvider);
  ref.watch(_collectionRefreshProvider);
  return repo.getAll();
});

final collectionCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(collectionRepositoryProvider);
  ref.watch(_collectionRefreshProvider);
  return repo.count();
});

// Categories
final rootCategoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getRootCategories();
});

final subcategoriesProvider =
    FutureProvider.autoDispose.family<List<CategoryModel>, String>((ref, parentId) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getSubcategories(parentId);
});

final allCategoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getAllCategoryNames();
});

// Refresh triggers
final _promptRefreshProvider = StateProvider<int>((ref) => 0);
final _collectionRefreshProvider = StateProvider<int>((ref) => 0);

void refreshPrompts(WidgetRef ref) {
  ref.read(_promptRefreshProvider.notifier).state++;
}

void refreshPromptsFromRef(Ref ref) {
  ref.read(_promptRefreshProvider.notifier).state++;
}

void refreshCollections(WidgetRef ref) {
  ref.read(_collectionRefreshProvider.notifier).state++;
}

// Theme
final themeModeProvider = StateProvider<bool>((ref) => true); // true = dark

// Prompt detail
final selectedPromptIdProvider = StateProvider<String?>((ref) => null);

final selectedPromptProvider = FutureProvider.autoDispose<PromptModel?>((ref) async {
  final id = ref.watch(selectedPromptIdProvider);
  if (id == null) return null;
  final repo = ref.watch(promptRepositoryProvider);
  ref.watch(_promptRefreshProvider);
  return repo.getById(id);
});
