import 'package:flutter/material.dart';

class InfoAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  InfoAlertDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      content: Text(
        content,
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
