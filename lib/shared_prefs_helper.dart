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

  Future<double> saveSpending(double spending, DateTime selectedDate) async {
    String monthKey = _generateMonthKey(selectedDate);
    double checkedItemPrices = await getCheckedItemPricesByDate(monthKey);

    // Add the total checked item prices to the existing spending (or use it as the new spending)
    spending += checkedItemPrices;


    return spending;
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


  Future<double> getCheckedItemPricesByDate(String selectedDate) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from SharedPreferences
    String? jsonString = prefs.getString('itemList');

    // Return 0 if no itemList is found
    if (jsonString == null) {
      return 0;
    }

    // Decode the JSON string into a list of maps (each map representing an item)
    List<dynamic> itemList = jsonDecode(jsonString);

    // Variable to store the total price of checked items
    double totalCheckedPrice = 0;

    // Loop through the itemList to filter by date and check 'isChecked'
    for (var item in itemList) {
      String dateString = item['date'];
      String thisDate = dateString.split('T')[0];


      // Check if the date matches the selected date (ignoring time)
      if (thisDate == selectedDate) {
        // Loop through the 'items' list to filter checked items
        for (var individualItem in item['items']) {
          if (individualItem['isChecked'] == true) {
            // Add the price of checked item to the totalCheckedPrice
            totalCheckedPrice += individualItem['price'];
          }
        }
      }
    }

    // Return the total price of checked items for the selected date
    return totalCheckedPrice;
  }

}
