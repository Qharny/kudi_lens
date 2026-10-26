import 'package:flutter/material.dart';
import '../../../../core/models/category.dart';

class CategoryBadge extends StatelessWidget {
  final String? categoryName;
  final bool compact;

  const CategoryBadge({
    super.key,
    required this.categoryName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryItem.findByName(categoryName);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          category.icon,
          size: compact ? 13 : 16,
          color: textColor,
        ),
        const SizedBox(width: 5),
        Text(
          category.name,
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

