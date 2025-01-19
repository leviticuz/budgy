import 'package:flutter/material.dart';
import 'package:Budgy/dummyItems.dart';
import 'package:Budgy/user_db.dart'; // Ensure you import your DatabaseService

class EditItemScreen extends StatefulWidget {
  final Item item; // The item to be edited

  EditItemScreen({required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current item data
    _nameController = TextEditingController(text: widget.item.item_name);
    _priceController = TextEditingController(text: widget.item.item_price?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Save the edited item to SQLite
  Future<void> saveChanges() async {
    final updatedItem = Item(
      item_name: _nameController.text,
      item_price: double.tryParse(_priceController.text),
      category_name: widget.item.category_name,
      item_unit: widget.item.item_unit,
      item_cost: widget.item.item_cost, // Assuming item_cost exists for the item
    );

    try {
      await DatabaseService.instance.updateItem(updatedItem); // Update item in SQLite
      Navigator.pop(context, updatedItem); // Go back to the previous screen
    } catch (e) {
      // Handle errors, maybe show an alert to the user
      print("Error saving changes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5BB7A6),
        title: Text("Edit Item", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: EdgeInsets.all(19.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
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
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (₱)',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back without saving changes
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: saveChanges,
                  child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
