import 'package:flutter/material.dart';

class Utility {
  static const Color _backgroundColor = Color.fromARGB(255, 46, 73, 107);
  static Color getBackGroundColor() {
    return _backgroundColor;
  }

  // displays an error message to the screen
  static displayAlertMessage(
      BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: Utility.getBackGroundColor(),
              title: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            )));
  }
}
