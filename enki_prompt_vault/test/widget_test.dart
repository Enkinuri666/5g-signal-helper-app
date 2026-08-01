import 'package:flutter_test/flutter_test.dart';
import 'package:enki_prompt_vault/data/models/prompt_model.dart';
import 'package:enki_prompt_vault/data/models/collection_model.dart';
import 'package:enki_prompt_vault/data/models/category_model.dart';

void main() {
  group('PromptModel', () {
    test('serializes to and from map', () {
      final now = DateTime.now();
      final prompt = PromptModel(
        id: 'test-id',
        title: 'Test Prompt',
        body: 'This is a test prompt body',
        category: 'Programming',
        tags: 'python, testing',
        aiModels: 'ChatGPT, Claude',
        difficulty: 'Intermediate',
        createdAt: now,
        modifiedAt: now,
      );

      final map = prompt.toMap();
      final restored = PromptModel.fromMap(map);

      expect(restored.id, 'test-id');
      expect(restored.title, 'Test Prompt');
      expect(restored.body, 'This is a test prompt body');
      expect(restored.category, 'Programming');
      expect(restored.tags, 'python, testing');
      expect(restored.aiModels, 'ChatGPT, Claude');
    });

    test('parses tag list correctly', () {
      final prompt = PromptModel(
        id: '1',
        title: 'T',
        body: 'B',
        tags: 'react, hooks, optimization',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      expect(prompt.tagList, ['react', 'hooks', 'optimization']);
    });

    test('parses AI model list', () {
      final prompt = PromptModel(
        id: '1',
        title: 'T',
        body: 'B',
        aiModels: 'ChatGPT, Claude, Gemini',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      expect(prompt.aiModelList, ['ChatGPT', 'Claude', 'Gemini']);
    });

    test('parses variable map', () {
      final prompt = PromptModel(
        id: '1',
        title: 'T',
        body: 'B',
        variables: 'topic::The main topic || tone::Writing tone',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      expect(prompt.variableMap, {
        'topic': 'The main topic',
        'tone': 'Writing tone',
      });
    });

    test('handles empty tags gracefully', () {
      final prompt = PromptModel(
        id: '1',
        title: 'T',
        body: 'B',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      expect(prompt.tagList, isEmpty);
      expect(prompt.aiModelList, isEmpty);
      expect(prompt.variableMap, isEmpty);
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime.now();
      final prompt = PromptModel(
        id: 'orig',
        title: 'Original',
        body: 'Body',
        category: 'AI',
        rating: 4,
        isFavorite: true,
        createdAt: now,
        modifiedAt: now,
      );

      final updated = prompt.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.id, 'orig');
      expect(updated.body, 'Body');
      expect(updated.category, 'AI');
      expect(updated.rating, 4);
      expect(updated.isFavorite, true);
    });
  });

  group('CollectionModel', () {
    test('serializes to and from map', () {
      final now = DateTime.now();
      final collection = CollectionModel(
        id: 'col-1',
        name: 'My Collection',
        description: 'A test collection',
        isPinned: true,
        createdAt: now,
        modifiedAt: now,
      );

      final map = collection.toMap();
      final restored = CollectionModel.fromMap({...map, 'prompt_count': 5});

      expect(restored.id, 'col-1');
      expect(restored.name, 'My Collection');
      expect(restored.isPinned, true);
      expect(restored.promptCount, 5);
    });
  });

  group('CategoryModel', () {
    test('serializes to and from map', () {
      final cat = CategoryModel(
        id: 'cat-1',
        name: 'Programming',
        color: '7A5CFF',
        sortOrder: 1,
      );

      final map = cat.toMap();
      final restored = CategoryModel.fromMap({...map, 'prompt_count': 10});

      expect(restored.id, 'cat-1');
      expect(restored.name, 'Programming');
      expect(restored.color, '7A5CFF');
      expect(restored.promptCount, 10);
    });
  });
}
