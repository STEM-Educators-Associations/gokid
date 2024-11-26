import 'package:flutter/services.dart';

class HashTagFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {

    if (newValue.text.length <= oldValue.text.length) {
      return newValue;
    }


    int cursorPosition = newValue.selection.end;
    if (cursorPosition == 0) {
      return newValue;
    }

    String lastChar = newValue.text.substring(cursorPosition - 1, cursorPosition);

    if (lastChar == ' ') {
      String beforeCursor = newValue.text.substring(0, cursorPosition);
      String afterCursor = newValue.text.substring(cursorPosition);

      String updatedText = beforeCursor + '#' + afterCursor;

      int newCursorPosition = cursorPosition + 1;

      return TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
    }

    return newValue;
  }
}
