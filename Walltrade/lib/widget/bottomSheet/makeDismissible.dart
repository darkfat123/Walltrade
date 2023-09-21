import 'package:flutter/material.dart';

Widget makeDismissible({
  required Widget child,
  required BuildContext context,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      Navigator.of(context).pop();
    },
    child: GestureDetector(onTap: () {}, child: child),
  );
}
