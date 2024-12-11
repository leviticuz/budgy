import 'package:flutter/material.dart';
import 'homePage.dart';
import 'homeTab.dart';
import 'package:firebase_core/firebase_core.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:GetStarted(),
    );
  }
}


class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:  Color(0xFFB1E8DE),
        child: Column(
          children: [
            SizedBox(height: 180),//80
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Budgy",
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF1BBEA1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: AssetImage('UpdatedLogo.png')
                ),
              ],
            ),
            SizedBox(height: 160),//90
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child:Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
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
          ],
        ),
      ),
    );
  }
}
