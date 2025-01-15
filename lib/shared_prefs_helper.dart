import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static const String _budgetKey = "_budget";
  static const String _spendingKey = "_spending";

  static Future<void> saveBudget(double budget, DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String monthKey = _generateMonthKey(selectedDate);

    double existingBudget = prefs.getDouble("$monthKey$_budgetKey") ?? 0.0;

    double newBudget = existingBudget + budget;

    await prefs.setDouble("$monthKey$_budgetKey", newBudget);
  }

  static Future<void> saveSpending(double spending, DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    // String monthKey = _generateMonthKey(selectedDate);
    // await prefs.setDouble("$monthKey$_spendingKey", spending);
    String monthKey = _generateMonthKey(selectedDate);

    double existingSpending = prefs.getDouble("$monthKey$_spendingKey") ?? 0.0;

    double newSpending = existingSpending + spending;

    await prefs.setDouble("$monthKey$_spendingKey", newSpending);

  }

  static Future<double> getBudget(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String monthKey = _generateMonthKey(selectedDate);
    return prefs.getDouble("$monthKey$_budgetKey") ?? 0.0;
  }

  static Future<double> getSpending(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String monthKey = _generateMonthKey(selectedDate);
    return prefs.getDouble("$monthKey$_spendingKey") ?? 0.0;
  }

  static String _generateMonthKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }



}
