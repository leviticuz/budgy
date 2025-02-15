import 'package:flutter/material.dart';
import 'homePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAGO_gr7T22z7PM-g8PiHMp4FHS4IBiU3A",
      authDomain: "dti-srp.firebaseapp.com",
      databaseURL: "https://dti-srp-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "dti-srp",
      storageBucket: "dti-srp.firebasestorage.app",
      messagingSenderId: "821902090102",
      appId: "1:821902090102:web:c66858657bcc1adcfc2457",
      measurementId: "G-NMWYLMX8BL",
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  await _cleanOldData(prefs); // ✅ Auto-delete old lists

  logSharedPreferencesContents(prefs);
  final seenGetStarted = prefs.getBool('seenGetStarted') ?? false;

  runApp(MyApp(seenGetStarted: seenGetStarted));
}

Future<void> _cleanOldData(SharedPreferences prefs) async {
  final now = DateTime.now();
  final thresholdDate = now.subtract(Duration(days: 5 * 365)); // 5 years ago

  // ✅ Process `itemList` (stored as a JSON string)
  final String? itemListJson = prefs.getString('itemList');
  if (itemListJson != null) {
    List<dynamic> itemList = jsonDecode(itemListJson);
    itemList = itemList.where((item) {
      DateTime creationDate = DateTime.parse(item['creationdate']);
      return creationDate.isAfter(thresholdDate);
    }).toList();

    prefs.setString('itemList', jsonEncode(itemList));
  }

  // ✅ Process `archivedItems` (stored as a List<String>)
  final List<String>? archivedItems = prefs.getStringList('archivedItems');
  if (archivedItems != null) {
    List<String> updatedArchivedItems = archivedItems.where((itemJson) {
      Map<String, dynamic> item = jsonDecode(itemJson);
      DateTime creationDate = DateTime.parse(item['creationdate']);
      return creationDate.isAfter(thresholdDate);
    }).toList();

    prefs.setStringList('archivedItems', updatedArchivedItems);
  }

  print("Old financial data cleaned up!");
}

void logSharedPreferencesContents(SharedPreferences prefs) {
  final allPrefs = prefs.getKeys();
  if (allPrefs.isEmpty) {
    print("SharedPreferences is empty.");
  } else {
    print("SharedPreferences contents:");
    for (var key in allPrefs) {
      print("Key: $key, Value: ${prefs.get(key)}");
    }
  }
}

class MyApp extends StatelessWidget {
  final bool seenGetStarted;

  const MyApp({super.key, required this.seenGetStarted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: seenGetStarted ? LoadingScreen() : GetStarted(),
    );
  }
}

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Logo8.png'),
              SizedBox(height: 160),
              ElevatedButton(
                child: Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seenGetStarted', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1BBEA1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(293, 53),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
    return Scaffold(
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 25),
              LottieBuilder.asset(
                "assets/lottie/cart_loading.json",
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
