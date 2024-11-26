import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, {bool? isLoading}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
          if (isLoading ?? false) ...[
            const SizedBox(width: 10.0),
            const SizedBox(
                height: 20,
                width: 20,
                child:  CircularProgressIndicator(strokeWidth: 3.0,)),
          ],
        ],
      ),
      backgroundColor: Colors.white,
    ),
  );
}
