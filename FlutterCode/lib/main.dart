import 'package:flutter/material.dart';
import 'pages/drawing_page.dart';
import 'package:mnist_net/pages/upload_page.dart';
import 'package:mnist_net/utilities/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List tabs = [
      UploadImage(),
      DrawPage(),
    ];
    return Scaffold(
      body: tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        iconSize: iconSize,
        selectedFontSize: selectedFontSize,
        unselectedFontSize: unselectedFontSize,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Image"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bubble_chart), label: "Draw"),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
