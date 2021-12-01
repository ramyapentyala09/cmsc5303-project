import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';

class GoogleMLController{

  static const MIN_CONFIDENCE = 0.5;

  static Future<List<String>> getImageLabels({
    required File photo,

  })async{
    var inputImage = InputImage.fromFile(photo);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final List<ImageLabel> imageLabels = await imageLabeler.processImage(inputImage);

    var results = <String>[];
    for (ImageLabel i in imageLabels) {
      if ( i.confidence >= MIN_CONFIDENCE) {
        results.add(i.label.toLowerCase());
        
      }
    }
    return results;
  }

  static Future<String> getImageText({
    required File photo,

  })async{
    var inputImage = InputImage.fromFile(photo);
    final textDetection = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText = await textDetection.processImage(inputImage);

    return recognisedText.text;
  }

  static Future<List<String>> getImageTextBlocks({
    required File photo,

  })async{
    var inputImage = InputImage.fromFile(photo);
    final textDetection = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText = await textDetection.processImage(inputImage);

    var results = <String>[];
    for (TextBlock block in recognisedText.blocks) {
      results.add(block.text);
    }

    return results;
  }
}