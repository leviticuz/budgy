import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CreateTab extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController budgetController;
  final TextEditingController dateController;
  final DateTime selectedDate;
  final Function(DateTime) onDatePicked;
  final VoidCallback onSelectDate;

  CreateTab({
    required this.titleController,
    required this.budgetController,
    required this.dateController,
    required this.selectedDate,
    required this.onDatePicked,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: budgetController,
            decoration: InputDecoration(
              labelText: 'Budget (₱)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.numberWithOptions(signed: false),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Pick Date',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  readOnly: true,
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: onSelectDate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
