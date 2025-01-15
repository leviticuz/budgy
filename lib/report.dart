import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialReportGenerator {
  Future<void> showFinancialReport(BuildContext context) async {
    // Step 1: Retrieve the data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');
    if (itemListJson == null) {
      print("No data found in SharedPreferences.");
      return;
    }

    final itemList = jsonDecode(itemListJson) as List<dynamic>;

    // Step 2: Format the data into a readable string
    String reportContent = "Financial Report\n\n";

    for (var item in itemList) {
      final title = item['title'];
      final budget = item['budget'];
      final date = DateTime.parse(item['date']);
      final items = item['items'] as List<dynamic>;

      reportContent += "Title: $title\n";
      reportContent += "Budget: \$${budget.toStringAsFixed(2)}\n";
      reportContent += "Date: ${date.toLocal().toString().split(' ')[0]}\n";
      reportContent += "Items:\n";

      for (var subItem in items) {
        reportContent += "  - Name: ${subItem['name']}, Quantity: ${subItem['quantity']}, Price: \$${subItem['price']}, Checked: ${subItem['isChecked']}\n";
      }

      reportContent += "\n---------------------------------------\n";
    }

    // Step 3: Show the data in a popup dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Budgy Financial Report"),
          content: SingleChildScrollView(
            child: Text(reportContent, style: TextStyle(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
