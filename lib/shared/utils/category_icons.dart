import 'package:flutter/material.dart';

/// Maps the `iconKey` stored with each category to a constant icon, so
/// release builds can still tree shake the icon font.
class CategoryIcons {
  const CategoryIcons._();

  static const IconData fallback = Icons.category_rounded;

  static const Map<String, IconData> catalog = {
    'restaurant': Icons.restaurant_rounded,
    'car': Icons.directions_car_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'movie': Icons.movie_rounded,
    'subscriptions': Icons.subscriptions_rounded,
    'health': Icons.local_hospital_rounded,
    'home': Icons.home_rounded,
    'other': Icons.more_horiz_rounded,
    'work': Icons.work_rounded,
    'laptop': Icons.laptop_mac_rounded,
    'money': Icons.attach_money_rounded,
  };

  static IconData of(String key) => catalog[key] ?? fallback;
}
