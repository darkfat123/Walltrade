import 'package:flutter/material.dart';

import 'makeDismissible.dart';

Widget buildSheet({
  required String title,
  required String description,
  required String imageUrl,
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
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(30), // ปรับค่าตามความโค้งที่คุณต้องการ
              child: Image.network(imageUrl),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 12,
            ),
            Text(description),
          ],
        ),
      ),
    ),
    context: context,
  );
}
