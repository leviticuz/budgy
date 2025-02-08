import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFF5BB7A6),
        title: Text(
          'Archive',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive, size: 80 , color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'You currently have no archive',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
