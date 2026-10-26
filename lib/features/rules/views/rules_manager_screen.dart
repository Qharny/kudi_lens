import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/category.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/rules_provider.dart';

class RulesManagerScreen extends ConsumerWidget {
  const RulesManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        title: const Text('Learned Categorization Rules'),
      ),
      body: rules.isEmpty
          ? Center(
              child: Text(
                'No learned rules yet.\nRules are created as you categorize alerts.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                final category = CategoryItem.findByName(rule.category);

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Matches ${rule.matchType}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: palette.textSecondary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded,
                                size: 18, color: palette.textPrimary),
                            onPressed: () {
                              ref
                                  .read(rulesProvider.notifier)
                                  .deleteRule(rule.id);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${rule.matchValue}"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: palette.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.arrow_forward_rounded,
                              size: 14, color: palette.textPrimary),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(category.icon,
                                  size: 16, color: palette.textPrimary),
                              const SizedBox(width: 5),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: palette.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${rule.confirmations} confirmations',
                            style: TextStyle(
                              fontSize: 11,
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: palette.border),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Auto-confirm without asking',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                          Switch(
                            value: rule.autoConfirm,
                            activeColor: AppColors.primary,
                            onChanged: (_) {
                              ref
                                  .read(rulesProvider.notifier)
                                  .toggleAutoConfirm(rule.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
