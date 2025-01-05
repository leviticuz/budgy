import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTab extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController budgetController;
  final TextEditingController dateController;
  final DateTime selectedDate;
  final Function(DateTime) onDatePicked;
  final VoidCallback onSelectDate;
  final bool isNewList;

  CreateTab({
    required this.titleController,
    required this.budgetController,
    required this.dateController,
    required this.selectedDate,
    required this.onDatePicked,
    required this.onSelectDate,
    required this.isNewList,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (isNewList) {
      titleController.clear();
      budgetController.clear();

    }


=======
>>>>>>> 0930f73bf366f6ce1bbd3518f5b9601a3dac6697
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(),
<<<<<<< HEAD
            Container(
              padding: EdgeInsets.all(19.0),
=======
            Container( //Note: Container for the card behind the text areasss -I<3
              padding: EdgeInsets.all(19.0),
              decoration: BoxDecoration(
                color: Color(0xFF5BB7A6),
                borderRadius: BorderRadius.circular(16),
              ),
>>>>>>> 0930f73bf366f6ce1bbd3518f5b9601a3dac6697
              child: Column(
                children: [
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
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
<<<<<<< HEAD
=======
                  SizedBox(height: 16),

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
                      controller: budgetController,
                      decoration: InputDecoration(
                        labelText: 'Budget (₱)',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7), // Note: Here is allowing up to 7 digits in setting budget -I<3 (para madaling makita pag inedit)
                      ],
                      onChanged: (value) {
                        String newValue = value.replaceAll(',', '');

                        if (newValue.isNotEmpty && int.tryParse(newValue) != null) { // Condition that it budget should at least 100 pesos -I<3
                          int parsedValue = int.parse(newValue);
                          if (parsedValue > 100 && parsedValue <= 9999999) {
                            budgetController.value = TextEditingValue(
                              text: newValue,
                              selection: TextSelection.collapsed(
                                offset: newValue.length,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 16),

>>>>>>> 0930f73bf366f6ce1bbd3518f5b9601a3dac6697
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
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: 'Pick Date',
                              border: InputBorder.none,
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
                  ),
<<<<<<< HEAD

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
                          controller: budgetController,
                          decoration: InputDecoration(
                            labelText: 'Budget (₱)',
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(7),
                          ],
                          onChanged: (value) {
                            String newValue = value.replaceAll(',', '');

                            if (newValue.isNotEmpty &&
                                int.tryParse(newValue) != null) {
                              int parsedValue = int.parse(newValue);
                              if (parsedValue >= 100) {
                                budgetController.value = TextEditingValue(
                                  text: newValue,
                                  selection: TextSelection.collapsed(
                                    offset: newValue.length,
                                  ),
                                );
                              } else {
                                budgetController.text = '100';
                              }
                            }
                          },
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

                  //--cards for predefined price--
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [100, 500, 1000, 5000, 8000, 10000].map((price) {
                      return GestureDetector(
                        onTap: () {
                          budgetController.text = price.toString();
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
=======
>>>>>>> 0930f73bf366f6ce1bbd3518f5b9601a3dac6697
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
