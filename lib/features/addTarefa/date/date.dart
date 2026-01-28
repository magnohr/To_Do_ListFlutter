import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;

    // remove qualquer coisa que não seja número
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // limita em 8 números (DDMMYYYY)
    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      // adiciona /
      if (i == 1 || i == 3) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.length,
      ),
    );
  }
}
