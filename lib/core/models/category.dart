import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF97316),
    ),
    CategoryItem(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF3B82F6),
    ),
    CategoryItem(
      id: 'airtime',
      name: 'Data & Airtime',
      icon: Icons.phone_android_rounded,
      color: Color(0xFFEAB308),
    ),
    CategoryItem(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt_rounded,
      color: Color(0xFF06B6D4),
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899),
    ),
    CategoryItem(
      id: 'health',
      name: 'Health',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF10B981),
    ),
    CategoryItem(
      id: 'rent',
      name: 'Rent & Housing',
      icon: Icons.home_rounded,
      color: Color(0xFF8B5CF6),
    ),
    CategoryItem(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF6366F1),
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFA855F7),
    ),
    CategoryItem(
      id: 'bank_fees',
      name: 'Bank Fees',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF7C3AED),
    ),
    CategoryItem(
      id: 'transfers',
      name: 'Transfers',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF0284C7),
    ),
    CategoryItem(
      id: 'salary',
      name: 'Salary & Income',
      icon: Icons.payments_rounded,
      color: Color(0xFF16A34A),
    ),
    CategoryItem(
      id: 'other',
      name: 'Other',
      icon: Icons.category_rounded,
      color: Color(0xFF64748B),
    ),
  ];

  static CategoryItem findByName(String? name) {
    if (name == null) return defaultCategories.last;
    return defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase() || c.id.toLowerCase() == name.toLowerCase(),
      orElse: () => defaultCategories.last,
    );
  }
}
