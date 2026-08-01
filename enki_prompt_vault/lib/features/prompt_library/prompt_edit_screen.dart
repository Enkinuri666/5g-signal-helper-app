import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../data/models/prompt_model.dart';

class PromptEditScreen extends ConsumerStatefulWidget {
  final PromptModel? prompt;
  const PromptEditScreen({super.key, this.prompt});

  @override
  ConsumerState<PromptEditScreen> createState() => _PromptEditScreenState();
}

class _PromptEditScreenState extends ConsumerState<PromptEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _aiModelsCtrl;
  late final TextEditingController _variablesCtrl;
  late final TextEditingController _expectedOutputCtrl;
  late final TextEditingController _exampleCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _personalNotesCtrl;
  late final TextEditingController _sourceCtrl;

  String _category = 'General AI';
  String _subcategory = '';
  String _difficulty = 'Intermediate';
  bool _isSaving = false;

  bool get _isEditing => widget.prompt != null;

  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

  @override
  void initState() {
    super.initState();
    final p = widget.prompt;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _bodyCtrl = TextEditingController(text: p?.body ?? '');
    _tagsCtrl = TextEditingController(text: p?.tags ?? '');
    _aiModelsCtrl = TextEditingController(text: p?.aiModels ?? '');
    _variablesCtrl = TextEditingController(text: p?.variables ?? '');
    _expectedOutputCtrl = TextEditingController(text: p?.expectedOutput ?? '');
    _exampleCtrl = TextEditingController(text: p?.example ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _personalNotesCtrl = TextEditingController(text: p?.personalNotes ?? '');
    _sourceCtrl = TextEditingController(text: p?.source ?? '');
    _category = p?.category ?? 'General AI';
    _subcategory = p?.subcategory ?? '';
    _difficulty = p?.difficulty ?? 'Intermediate';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _bodyCtrl.dispose();
    _tagsCtrl.dispose();
    _aiModelsCtrl.dispose();
    _variablesCtrl.dispose();
    _expectedOutputCtrl.dispose();
    _exampleCtrl.dispose();
    _notesCtrl.dispose();
    _personalNotesCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(_isEditing ? 'Edit Prompt' : 'New Prompt'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isEditing ? 'Save' : 'Create',
                    style: const TextStyle(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField('Title', _titleCtrl, required: true),
            _buildField('Description', _descriptionCtrl, maxLines: 2),
            _buildField('Prompt Body', _bodyCtrl, required: true, maxLines: 8, monospace: true),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            _buildDifficultyDropdown(),
            const SizedBox(height: 12),
            _buildField('Tags', _tagsCtrl, hint: 'Comma-separated: react, hooks, optimization'),
            _buildField('AI Models', _aiModelsCtrl, hint: 'Comma-separated: ChatGPT, Claude, Gemini'),
            _buildField('Variables', _variablesCtrl, hint: 'name::description || name2::description2', maxLines: 3),
            _buildField('Expected Output', _expectedOutputCtrl, maxLines: 3),
            _buildField('Example', _exampleCtrl, maxLines: 3),
            _buildField('Notes', _notesCtrl, maxLines: 3),
            _buildField('Personal Notes', _personalNotesCtrl, maxLines: 3),
            _buildField('Source', _sourceCtrl, hint: 'URL, book, course, etc.'),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
    String? hint,
    bool monospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: monospace ? 'monospace' : null,
          fontSize: monospace ? 13 : 14,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categoriesAsync = ref.watch(allCategoryNamesProvider);
    return categoriesAsync.when(
      data: (categories) {
        final rootCategories = categories.toSet().toList();
        if (!rootCategories.contains(_category)) {
          rootCategories.insert(0, _category);
        }
        return DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category'),
          dropdownColor: AppColors.surface,
          items: rootCategories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _category = v);
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => TextField(
        decoration: const InputDecoration(labelText: 'Category'),
        onChanged: (v) => _category = v,
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _difficulty,
      decoration: const InputDecoration(labelText: 'Difficulty'),
      dropdownColor: AppColors.surface,
      items: _difficulties
          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _difficulty = v);
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(promptRepositoryProvider);
      final now = DateTime.now();

      if (_isEditing) {
        await repo.update(widget.prompt!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          category: _category,
          subcategory: _subcategory,
          tags: _tagsCtrl.text.trim(),
          aiModels: _aiModelsCtrl.text.trim(),
          difficulty: _difficulty,
          variables: _variablesCtrl.text.trim(),
          expectedOutput: _expectedOutputCtrl.text.trim(),
          example: _exampleCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          personalNotes: _personalNotesCtrl.text.trim(),
          source: _sourceCtrl.text.trim(),
          modifiedAt: now,
        ));
      } else {
        await repo.insert(PromptModel(
          id: const Uuid().v4(),
          title: _titleCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          category: _category,
          subcategory: _subcategory,
          tags: _tagsCtrl.text.trim(),
          aiModels: _aiModelsCtrl.text.trim(),
          difficulty: _difficulty,
          variables: _variablesCtrl.text.trim(),
          expectedOutput: _expectedOutputCtrl.text.trim(),
          example: _exampleCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          personalNotes: _personalNotesCtrl.text.trim(),
          source: _sourceCtrl.text.trim(),
          createdAt: now,
          modifiedAt: now,
        ));
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
