import 'package:flutter/material.dart';

class ClipInclinadoEsquerda extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(12, 0);                // topo esquerdo inclinado
    path.lineTo(size.width, 0);        // topo direito
    path.lineTo(size.width - 12, size.height); // base direita inclinada
    path.lineTo(0, size.height);       // base esquerda
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
