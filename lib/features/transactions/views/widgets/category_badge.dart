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

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: category.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 11, color: category.color),
            const SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: category.color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.color.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(category.icon, size: 12, color: category.color),
          ),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }
}

