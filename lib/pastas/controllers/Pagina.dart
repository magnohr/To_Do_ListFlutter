import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class Pagina {
  String titulo;
  late QuillController controller;
  final FocusNode focusNode = FocusNode();

  Pagina({
    required this.titulo,
    String? json,
  }) {
    try {
      controller = QuillController(
        document: json != null && json.isNotEmpty
            ? Document.fromJson(jsonDecode(json))
            : Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      controller = QuillController.basic();
    }
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
