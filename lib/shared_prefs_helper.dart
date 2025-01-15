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

  static Future<void> saveSpending(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    // String monthKey = _generateMonthKey(selectedDate);
    // await prefs.setDouble("$monthKey$_spendingKey", spending);

    String? jsonString = prefs.getString('itemList');

    if (jsonString != null) {
      List<dynamic> itemList = jsonDecode(jsonString);

      for (var item in itemList) {
        String title = item['title']; // Access the title
        double budget = item['budget']; // Access the budget
        String date = item['date']; // Access the date
        List<dynamic> items = item['items']; // Access the items list

        // Loop through the items list to access item properties
        for (var individualItem in items) {
          String name = individualItem['name']; // Access item name
          int quantity = individualItem['quantity']; // Access item quantity
          bool isChecked = individualItem['isChecked']; // Access isChecked status
          double price = individualItem['price']; // Access item price


        }
      }
    }

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
