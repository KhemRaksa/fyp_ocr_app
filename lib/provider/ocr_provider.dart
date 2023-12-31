import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_ocr_app/utils/image_helper.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

import '../model/result_model.dart';

class OcrProvider with ChangeNotifier {
  Result result = Result();
  List<File> crop = [];
  bool isLoading = false;
  Future<void> getOcrResult(XFile? imageFile) async {
    if (imageFile == null) {
      return;
    }

    isLoading = true;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://ocr.ngrok.app/recognize'),
    );

    print("here");

    // Create a file object from the picked image file path
    var image = await http.MultipartFile.fromPath('file', imageFile.path);

    // Add the image file to the request
    request.files.add(image);

    // Send the request and get the response
    var response = await request.send();

    // Check the response status
    File img = File(imageFile.path);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // File uploaded successfully
      var data = await http.Response.fromStream(response);
      dynamic body = jsonDecode(const Utf8Decoder().convert(data.bodyBytes));
      print("here");

      result = Result.fromJson(body);
      isLoading = false;
      print(result);
      notifyListeners();

      // for (var i = 0; i < result.bbox!.length; i++) {
      //   crop.add(await ImageHelper.cropImage(
      //     img,
      //     result.bbox?[i].x,
      //     result.bbox?[i].y,
      //     result.bbox?[i].w,
      //     result.bbox?[i].h,
      //   ));
      // }
    } else {
      // Error occurred while uploading the file
      print('Image upload failed!');
    }
  }
}
