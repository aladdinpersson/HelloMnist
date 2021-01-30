import 'package:flutter/widgets.dart';
import 'package:mnist_net/utilities/constants.dart';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'package:image/image.dart' as img;

class Classifier {
  Classifier(); // Empty init/constructor

  classifyImage(PickedFile image) async {
    // Takes PickedFile image as input and returns an integer
    // of which integer it was (hopefully)!

    // Ugly boilerplate to get it to Uint8List
    var _file = io.File(image.path);
    img.Image imageTemp = img.decodeImage(_file.readAsBytesSync());
    img.Image resizedImg = img.copyResize(imageTemp,
        height: mnistSize, width: mnistSize);
    var imgBytes = resizedImg.getBytes();
    var imgAsList = imgBytes.buffer.asUint8List();

    // Everything "important" is done in getPred
    return getPred(imgAsList);
  }

  classifyDrawing(List<Offset> points) async {
    // Takes img as a List of Points from Drawing and returns Integer
    // of which digit it was (hopefully)!

    // Ugly boilerplate to get it to Uint8List
    final picture = toPicture(points); // convert List to Picture
    final image = await picture.toImage(mnistSize, mnistSize); // Picture to 28x28 Image
    ByteData imgBytes = await image.toByteData(); // Read this image
    var imgAsList = imgBytes.buffer.asUint8List();

    // Everything "important" is done in getPred
    return getPred(imgAsList);
  }

  Future<int> getPred(Uint8List imgAsList) async {
    // Takes img as a List as input and returns an Integer of which digit
    // the model predicts.

    // We need to convert Image which is in RGBA to Grayscale, first we can ignore
    // the alpha (opacity) and we can take the mean of R,G,B into a single channel
    final resultBytes = List(mnistSize*mnistSize);

    int index = 0;
    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i+1];
      final b = imgAsList[i+2];

      // Take the mean of R,G,B channel into single GrayScale
      resultBytes[index] = ((r + g + b) / 3.0) / 255.0;
      index++;
    }

    // Thanks for having inbuilt reshape in tflite flutter, this would much more
    // annoying otherwise :)
    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List(1*10).reshape([1, 10]);

    // Can be used to set GPUDelegate, NNAPI, parallel cores etc. We won't use
    // this, but can be good to know it exists.
    InterpreterOptions interpreterOptions = InterpreterOptions();

    // Track how long it took to do inference
    int startTime = new DateTime.now().millisecondsSinceEpoch;

    try {
      Interpreter interpreter = await Interpreter.fromAsset("model.tflite",
          options: interpreterOptions);
      interpreter.run(input, output);
    } catch (e) {
      print('Error loading or running model: ' + e.toString());
    }

    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime} ms");

    // Obtain the highest score from the output of the model
    double highestProb = 0;
    int digitPred;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        digitPred = i;
      }
    }
    return digitPred;
  }
}

ui.Picture toPicture(List<Offset> points) {
  // Obtain a Picture from a List of points
  // This Picture can then be converted to something
  // we can send to our model. Seems unnecessary to draw twice,
  // but couldn't find a way to record while using CustomPainter,
  // this is a future improvement to make.

  final _whitePaint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.white
    ..strokeWidth = strokeWidth;

  final _bgPaint = Paint()..color = Colors.black;
  final _canvasCullRect = Rect.fromPoints(Offset(0, 0),
      Offset(mnistSize.toDouble(), mnistSize.toDouble()));
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, _canvasCullRect)
    ..scale(mnistSize / canvasSize);

  canvas.drawRect(Rect.fromLTWH(0, 0, 28, 28), _bgPaint);

  for (int i = 0; i < points.length - 1; i++) {
    if (points[i] != null && points[i + 1] != null) {
      canvas.drawLine(points[i], points[i + 1], _whitePaint);
    }
  }

  return recorder.endRecording();
}
