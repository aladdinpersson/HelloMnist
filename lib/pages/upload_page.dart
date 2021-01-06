import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnist_net/utilities/constants.dart';
import 'package:mnist_net/dl_model/classifier.dart';
import 'dart:io';

class UploadImage extends StatefulWidget {
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final picker = ImagePicker();
  Classifier classifier = Classifier();
  PickedFile image;
  int digit = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.camera_alt_outlined),
        onPressed: () async {
          image = await picker.getImage(
            source: ImageSource.gallery,
            maxHeight: 300,
            maxWidth: 300,
            imageQuality: 100,
          );
          digit = await classifier.classifyImage(image);
          setState(() {});
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("Best digit recognizer in the world"),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Text(
              "Image will be shown below",
                style: TextStyle(fontSize: 20)
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: canvasSize + borderSize*2,
              height: canvasSize + borderSize*2,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: borderSize),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: digit == -1 ? AssetImage('assets/white_background.jpg')
                      : FileImage(File(image.path)),
                ),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            Text(
              "Current Prediction:",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              digit == -1 ? "" : "$digit",
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }
}
