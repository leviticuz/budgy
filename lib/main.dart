import 'package:flutter/material.dart';
import 'homePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final seenGetStarted = prefs.getBool('seenGetStarted') ?? false;

  runApp(MyApp(seenGetStarted: seenGetStarted));
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
    Future.delayed(Duration(seconds: 2), () {
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
              Image.asset('assets/Logo8.png'),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
