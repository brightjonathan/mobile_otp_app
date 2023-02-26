import 'package:flutter/material.dart';

//custom button widget we use in all of all app
class CustomButton extends StatelessWidget {
  final String text;
  final onPressed;
  const CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: const MaterialStatePropertyAll(Colors.white),
        backgroundColor: const MaterialStatePropertyAll(Colors.blue),
        shape: MaterialStatePropertyAll(
          BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
}
