import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/prompt_model.dart';
import 'prompt_edit_screen.dart';

class PromptDetailScreen extends ConsumerStatefulWidget {
  final String promptId;
  const PromptDetailScreen({super.key, required this.promptId});

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedPromptIdProvider.notifier).state = widget.promptId;
      ref.read(promptRepositoryProvider).incrementUseCount(widget.promptId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final promptAsync = ref.watch(selectedPromptProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: promptAsync.when(
        data: (prompt) {
          if (prompt == null) {
            return const Center(child: Text('Prompt not found'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      prompt.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: prompt.isFavorite ? AppColors.warning : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      ref.read(promptRepositoryProvider).toggleFavorite(prompt.id);
                      refreshPrompts(ref);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      prompt.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: prompt.isPinned ? AppColors.accentCyan : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      ref.read(promptRepositoryProvider).togglePin(prompt.id);
                      refreshPrompts(ref);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
                    onPressed: () async {
                      final edited = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PromptEditScreen(prompt: prompt),
                        ),
                      );
                      if (edited == true) refreshPrompts(ref);
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                    color: AppColors.surface,
                    onSelected: (v) => _handleMenuAction(v, prompt),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      prompt.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    if (prompt.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        prompt.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildMetadataRow(prompt),
                    const SizedBox(height: 20),
                    _buildPromptBody(prompt),
                    if (prompt.variableMap.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildVariables(prompt),
                    ],
                    if (prompt.expectedOutput.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection('Expected Output', prompt.expectedOutput),
                    ],
                    if (prompt.example.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection('Example', prompt.example),
                    ],
                    if (prompt.notes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection('Notes', prompt.notes),
                    ],
                    if (prompt.personalNotes.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection('Personal Notes', prompt.personalNotes),
                    ],
                    const SizedBox(height: 20),
                    _buildInfoSection(prompt),
                    const SizedBox(height: 16),
                    _buildRating(prompt),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMetadataRow(PromptModel prompt) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _metaChip(prompt.category, AppColors.accentCyan),
        if (prompt.subcategory.isNotEmpty)
          _metaChip(prompt.subcategory, AppColors.accentCyan.withValues(alpha: 0.7)),
        if (prompt.difficulty.isNotEmpty)
          _metaChip(prompt.difficulty, AppColors.accentPurple),
        ...prompt.aiModelList.map((m) => _metaChip(m, AppColors.accentEmerald)),
        ...prompt.tagList.map((t) => _metaChip(t, AppColors.textTertiary)),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _metaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPromptBody(PromptModel prompt) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  'Prompt',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _copyPrompt(prompt.body),
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 16,
                    color: _copied ? AppColors.accentEmerald : AppColors.textSecondary,
                  ),
                  label: Text(
                    _copied ? 'Copied!' : 'Copy',
                    style: TextStyle(
                      color: _copied ? AppColors.accentEmerald : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: MarkdownBody(
              data: prompt.body,
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                code: TextStyle(
                  color: AppColors.accentCyan,
                  backgroundColor: AppColors.surfaceVariant,
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildVariables(PromptModel prompt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variables',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...prompt.variableMap.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '{{${e.key}}}',
                        style: TextStyle(
                          color: AppColors.accentPurple,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(PromptModel prompt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _infoRow('Created', prompt.createdAt.formatted),
          _infoRow('Modified', prompt.modifiedAt.relative),
          if (prompt.lastUsedAt != null) _infoRow('Last used', prompt.lastUsedAt!.relative),
          _infoRow('Times copied', prompt.copyCount.toString()),
          _infoRow('Times used', prompt.useCount.toString()),
          if (prompt.source.isNotEmpty) _infoRow('Source', prompt.source),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          Text(value, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRating(PromptModel prompt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(
            i < prompt.rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < prompt.rating ? AppColors.warning : AppColors.textTertiary,
            size: 28,
          ),
          onPressed: () {
            ref.read(promptRepositoryProvider).setRating(prompt.id, i + 1);
            refreshPrompts(ref);
          },
        );
      }),
    );
  }

  void _copyPrompt(String body) async {
    await Clipboard.setData(ClipboardData(text: body));
    ref.read(promptRepositoryProvider).incrementCopyCount(widget.promptId);
    setState(() => _copied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Prompt copied to clipboard'),
          backgroundColor: AppColors.surfaceHigh,
          duration: const Duration(seconds: 1),
        ),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  void _handleMenuAction(String action, PromptModel prompt) async {
    switch (action) {
      case 'duplicate':
        final repo = ref.read(promptRepositoryProvider);
        await repo.insert(prompt.copyWith(
          title: '${prompt.title} (Copy)',
          modifiedAt: DateTime.now(),
        ));
        refreshPrompts(ref);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt duplicated')),
          );
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Prompt'),
            content: Text('Delete "${prompt.title}"? This cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(promptRepositoryProvider).delete(prompt.id);
          refreshPrompts(ref);
          if (mounted) Navigator.pop(context);
        }
    }
  }
}
