import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppUtils {
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: symbol);
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'receipt': return Icons.receipt;
      case 'movie': return Icons.movie;
      case 'home': return Icons.home;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'pets': return Icons.pets;
      case 'fitness_center': return Icons.fitness_center;
      case 'school': return Icons.school;
      case 'medical_services': return Icons.medical_services;
      case 'flight': return Icons.flight;
      case 'computer': return Icons.computer;
      case 'sports_esports': return Icons.sports_esports;
      case 'fastfood': return Icons.fastfood;
      case 'local_cafe': return Icons.local_cafe;
      case 'monetization_on': return Icons.monetization_on;
      case 'train': return Icons.train;
      case 'build': return Icons.build;
      default: return Icons.attach_money;
    }
  }

  static const List<String> availableIcons = [
    'restaurant', 'directions_car', 'shopping_bag', 'receipt', 'movie',
    'home', 'local_grocery_store', 'pets', 'fitness_center', 'school',
    'medical_services', 'flight', 'computer', 'sports_esports', 'fastfood',
    'local_cafe', 'monetization_on', 'train', 'build', 'attach_money',
  ];
}
