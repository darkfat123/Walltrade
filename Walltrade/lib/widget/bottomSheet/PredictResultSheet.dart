import 'package:flutter/material.dart';
import 'makeDismissible.dart';

Widget buildPredictSheet({
  required String prediction,
  required BuildContext
      context, // เพิ่มพารามิเตอร์ context ที่รับค่า BuildContext
}) {
  return makeDismissible(
    child: DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            SizedBox(
              height: 24,
            ),
            Text(
              prediction,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    ),
    context: context,
  );
}
