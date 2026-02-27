import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._(); // impede criar instância



  static const TextStyle montserratLight15Dark = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.black,
    fontWeight: FontWeight.w300, // Light
  );

  static const TextStyle ButtonSing = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.blueFigma,
    fontWeight: FontWeight.w600 // Light
  );

  static const TextStyle config = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: AppColors.black,
      fontWeight: FontWeight.w300 // Light
  );
  static const TextStyle configDados = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: AppColors.blueFigma,
      fontWeight: FontWeight.w300 // Light
  );


  static const TextStyle ButtonAdd = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12,
      color: AppColors.white,
      fontWeight: FontWeight.w600 // Light
  );

  static const TextStyle montserratSingUp = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.Colorblue,
    fontWeight: FontWeight.w300, // Light
  );
  static const TextStyle montserratSingUp1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    color: AppColors.Colorblue,
    fontWeight: FontWeight.w600, // Light
  );

  static const TextStyle bebas18Peach = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.blueFigma,
    letterSpacing: 1.5,
  );
  static const TextStyle drawerLivros = TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    letterSpacing: 1.5,
    shadows: [
      Shadow(
        color: Colors.white,
        blurRadius: 4,
      ),
    ],
  );

  static const TextStyle Livrosadd = TextStyle(
    fontFamily: 'Bebas',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    letterSpacing: 1.5,
    shadows: [
      Shadow(
        color: Colors.white,
        blurRadius: 4,
      ),
    ],
  );
  static const TextStyle bebas18Peach1 = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.Colorblue,
    letterSpacing: 1.5,
  );
  static const TextStyle bebas19Peach = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.Colorblue,
    letterSpacing: 1.5,
  );

}
