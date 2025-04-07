import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedNotifications = prefs.getString('notifications');
    if (storedNotifications != null) {
      setState(() {
        notifications = List<Map<String, dynamic>>.from(jsonDecode(storedNotifications));
      });
    } else {
      notifications = [
        {
          "title": "DTI Price Adjustment Notice",
          "message": "The Department of Trade and Industry (DTI) has announced new price adjustments on select commodities.",
          "details": "Click to view",
          "read": false
        },
        {
          "title": "DTI Notice",
          "message": "New pricing guidelines have been implemented.",
          "details": "Click to view",
          "read": false
        },
        {
          "title": "Holy Week Price Update",
          "message": "Expect changes in prices of essential items in local supermarkets during Holy Week.",
          "details": "Click to view",
          "read": false
        }

      ];
      _saveNotifications();
    }
  }

  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notifications', jsonEncode(notifications));
  }

  void _showNotificationDetails(int index) {
    setState(() {
      notifications[index]["details"] = "";
      notifications[index]["read"] = true;
      _saveNotifications();
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Notification"),
          content: Text(notifications[index]["message"]!),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
      _saveNotifications();
    });
  }

  void _markAsUnread(int index) {
    setState(() {
      notifications[index]["read"] = false;
      notifications[index]["details"] = "Click to view details.";
      _saveNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFF5BB7A6),
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'You currently have no notifications',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(notifications[index]["title"]!),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteNotification(index);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => _showNotificationDetails(index),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notifications[index]["title"]!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (String choice) {
                              if (choice == 'Delete') {
                                _deleteNotification(index);
                              } else if (choice == 'Mark as Unread') {
                                _markAsUnread(index);
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                              PopupMenuItem<String>(
                                value: 'Mark as Unread',
                                child: Text('Mark as Unread'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        notifications[index]["message"]!,
                        style: TextStyle(fontSize: 16),
                      ),
                      if (notifications[index]["details"]!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            notifications[index]["details"]!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}