import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'shared_prefs_helper.dart';
import 'item_details.dart';

class CreateTab extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController budgetController;
  final TextEditingController dateController;
  final DateTime selectedDate;
  final Function(DateTime) onDatePicked;
  final VoidCallback onSelectDate;
  final bool isNewList;
  final bool isWeekly;

  CreateTab({
    required this.titleController,
    required this.budgetController,
    required this.dateController,
    required this.selectedDate,
    required this.onDatePicked,
    required this.onSelectDate,
    required this.isNewList,
    required this.isWeekly,
  });

  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  double totalBudget = 0.0;
  double totalSpending = 0.0;
  bool _isWeekly = false; // Toggle bool

  @override
  void initState() {
    super.initState();
    _isWeekly = widget.isWeekly;
    if (!widget.isNewList) {
      _loadData();
    } else {
      widget.titleController.clear();
      widget.budgetController.clear();
    }
  }

  void _loadData() async {
    final budget = await SharedPrefsHelper.getBudget(widget.selectedDate);
    final spending = await SharedPrefsHelper.getSpending(widget.selectedDate);

    setState(() {
      totalBudget = budget;
      totalSpending = spending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isNewList
          ? null
          : AppBar(
        title: Text('Edit List'),
        backgroundColor: Color(0xFF5BB7A6),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (widget.titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Title cannot be empty')),
                );
                return;
              }
              if (widget.budgetController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget cannot be empty')),
                );
                return;
              }
              final updatedItem = Item(
                title: widget.titleController.text,
                budget: double.tryParse(widget.budgetController.text) ?? 0.0,
                date: widget.selectedDate,
                items: [],
                selectedDate: DateTime.now(),
                creationDate: DateTime.now(),
                weekly: _isWeekly,
              );

              Navigator.pop(context, updatedItem);
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFB1E8DE),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(19.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Title Input Field
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: widget.titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    // Date Input Field
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.dateController,
                              decoration: InputDecoration(
                                labelText: 'Pick Date',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                              style: widget.isNewList
                                  ? TextStyle(color: Colors.black)
                                  : TextStyle(color: Colors.grey),
                            ),
                          ),
                          if (widget.isNewList)
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime today = DateTime.now();
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: today,
                                  firstDate: today,
                                  lastDate: DateTime(today.year + 7),
                                );
                                if (selectedDate != null &&
                                    selectedDate != widget.selectedDate) {
                                  widget.dateController.text =
                                  "${selectedDate.toLocal()}".split(' ')[0];
                                  widget.onDatePicked(selectedDate);
                                }
                              },
                            ),
                        ],
                      ),
                    ),

                    // Toggle Switch for Weekly
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isWeekly ? "Repeat weekly" : "Never repeat",
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isNewList ? Colors.black : Colors.grey, // Make text gray if read-only
                            ),
                          ),
                          IgnorePointer(
                            ignoring: !widget.isNewList, // Disable switch if it's not a new list
                            child: Opacity(
                              opacity: widget.isNewList ? 1.0 : 0.5, // Reduce opacity when disabled
                              child: Switch(
                                value: _isWeekly,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isWeekly = value;
                                  });
                                },
                                activeColor: widget.isNewList ? Colors.teal : Colors.grey, // Gray color when disabled
                                trackColor: WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    return widget.isNewList ? Colors.teal.withOpacity(0.5) : Colors.grey;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Budget Input Field
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: widget.budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget (₱)',
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                            ],
                          ),
                          Text(
                            'Minimum budget is ₱100',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Predefined Budget Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [100, 500, 1000, 5000, 8000, 10000].map((price) {
                        return GestureDetector(
                          onTap: () {
                            widget.budgetController.text = price.toString();
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              width: 125,
                              child: Center(
                                child: Text(
                                  '₱$price',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
