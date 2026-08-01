import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/prompt_model.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';

class PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCopy;
  final int animationIndex;

  const PromptCard({
    super.key,
    required this.prompt,
    this.onTap,
    this.onFavorite,
    this.onCopy,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (prompt.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.push_pin, size: 14, color: AppColors.accentCyan),
                      ),
                    Expanded(
                      child: Text(
                        prompt.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        prompt.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: prompt.isFavorite ? AppColors.warning : AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                if (prompt.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    prompt.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _CategoryChip(label: prompt.category),
                    if (prompt.difficulty.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _DifficultyChip(difficulty: prompt.difficulty),
                    ],
                    const Spacer(),
                    Text(
                      prompt.modifiedAt.relative,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (prompt.tagList.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: prompt.tagList.take(4).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.accentPurple,
                          fontSize: 10,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (prompt.rating > 0) ...[
                      ...List.generate(5, (i) => Icon(
                        i < prompt.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14,
                        color: i < prompt.rating ? AppColors.warning : AppColors.textTertiary,
                      )),
                      const SizedBox(width: 8),
                    ],
                    if (prompt.aiModelList.isNotEmpty)
                      Text(
                        prompt.aiModelList.take(2).join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.accentCyan,
                          fontSize: 10,
                        ),
                      ),
                    const Spacer(),
                    _CopyButton(onCopy: onCopy, promptBody: prompt.body),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (animationIndex * 50).ms, duration: 300.ms)
        .slideX(begin: 0.02, end: 0, duration: 300.ms);
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.accentCyan,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  Color get _color {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.accentEmerald;
      case 'advanced':
        return AppColors.warning;
      case 'expert':
        return AppColors.error;
      default:
        return AppColors.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  final VoidCallback? onCopy;
  final String promptBody;
  const _CopyButton({this.onCopy, required this.promptBody});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.promptBody));
    widget.onCopy?.call();
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleCopy,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.accentEmerald.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _copied
                ? AppColors.accentEmerald.withValues(alpha: 0.3)
                : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 14,
              color: _copied ? AppColors.accentEmerald : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _copied ? 'Copied' : 'Copy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _copied ? AppColors.accentEmerald : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
