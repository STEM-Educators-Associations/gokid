import 'package:flutter/material.dart';

void showNormalAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmButtonText,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('iptal'),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(confirmButtonText),
        ),
      ],
    ),
  );
}
