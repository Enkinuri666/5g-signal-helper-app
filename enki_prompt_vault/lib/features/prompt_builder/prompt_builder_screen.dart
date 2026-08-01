import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class PromptBuilderScreen extends StatefulWidget {
  const PromptBuilderScreen({super.key});

  @override
  State<PromptBuilderScreen> createState() => _PromptBuilderScreenState();
}

class _PromptBuilderScreenState extends State<PromptBuilderScreen> {
  final _templateCtrl = TextEditingController();
  final _variableControllers = <String, TextEditingController>{};
  String _generatedPrompt = '';
  List<String> _detectedVars = [];
  bool _copied = false;

  @override
  void dispose() {
    _templateCtrl.dispose();
    for (final c in _variableControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _detectVariables() {
    final pattern = RegExp(r'\{\{(\w+)\}\}');
    final matches = pattern.allMatches(_templateCtrl.text);
    final vars = matches.map((m) => m.group(1)!).toSet().toList();

    setState(() {
      _detectedVars = vars;
      for (final v in vars) {
        _variableControllers.putIfAbsent(v, () => TextEditingController());
      }
      _variableControllers.removeWhere((k, _) => !vars.contains(k));
    });
  }

  void _generatePrompt() {
    var result = _templateCtrl.text;
    for (final entry in _variableControllers.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value.text);
    }
    setState(() => _generatedPrompt = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Prompt Builder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Template',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _templateCtrl,
            maxLines: 6,
            onChanged: (_) => _detectVariables(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: 'Write your template using {{variable_name}} for placeholders...\n\n'
                  'Example: Write a {{tone}} blog post about {{topic}} for {{audience}}',
            ),
          ),
          const SizedBox(height: 20),
          if (_detectedVars.isNotEmpty) ...[
            Text(
              'Variables',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ).animate().fadeIn(duration: 200.ms),
            const SizedBox(height: 12),
            ..._detectedVars.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _variableControllers[entry.value],
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: entry.value,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '{{}}',
                            style: TextStyle(
                              color: AppColors.accentPurple,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                  ),
                ).animate().fadeIn(delay: (entry.key * 80).ms, duration: 250.ms)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _generatePrompt,
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Generate Prompt'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          if (_generatedPrompt.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Generated Prompt',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _copyGenerated,
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
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
              ),
              child: SelectableText(
                _generatedPrompt,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
          ],
          if (_detectedVars.isEmpty && _templateCtrl.text.isEmpty) ...[
            const SizedBox(height: 32),
            _buildPresetTemplates(),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPresetTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Templates',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _templatePreset(
          'Blog Post',
          'Write a {{tone}} blog post about {{topic}} targeting {{audience}}. '
              'The post should be {{length}} words and formatted in {{format}}.',
        ),
        _templatePreset(
          'Code Review',
          'Review this {{language}} code for {{focus_area}}. '
              'Provide specific suggestions for improvement with examples.',
        ),
        _templatePreset(
          'Marketing Copy',
          'Create {{type}} marketing copy for {{business_name}} in the {{industry}} industry. '
              'Target audience: {{audience}}. Tone: {{tone}}. Include a call to action.',
        ),
        _templatePreset(
          'Research Analysis',
          'Analyze {{topic}} from the perspective of {{field}}. '
              'Include key findings, methodology critique, and practical implications. '
              'Audience: {{audience}}. Depth: {{depth}}.',
        ),
      ],
    );
  }

  Widget _templatePreset(String name, String template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            _templateCtrl.text = template;
            _detectVariables();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_rounded, size: 16, color: AppColors.accentEmerald),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        template,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyGenerated() async {
    await Clipboard.setData(ClipboardData(text: _generatedPrompt));
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
}
