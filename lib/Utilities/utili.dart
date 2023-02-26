import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//snackbar reuseable widget
void showSnaskBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: Colors.red,
    ),
  );
}

//imge picker functionality ....
Future<File?> pickImage(BuildContext context) async {
  //
  File? image;

  //image picker funct...
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnaskBar(context, e.toString());
  }
  return image;
}
