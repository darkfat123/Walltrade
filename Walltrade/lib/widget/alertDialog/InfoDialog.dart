import 'package:flutter/material.dart';

class InfoAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  InfoAlertDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.amber,
              size: 72,
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Color(0xFFEC5B5B)),padding:MaterialStatePropertyAll(EdgeInsets.all(12))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'ออก',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
