import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._(); // impede criar instância



  static const TextStyle montserratLight15Dark = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.dark,
    fontWeight: FontWeight.w300, // Light
  );

  static const TextStyle ButtonSing = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12,
    color: AppColors.peach,
    fontWeight: FontWeight.w600 // Light
  );

  static const TextStyle config = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: AppColors.dark,
      fontWeight: FontWeight.w300 // Light
  );
  static const TextStyle configDados = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: AppColors.peach,
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
    color: AppColors.coral,
    fontWeight: FontWeight.w300, // Light
  );
  static const TextStyle montserratSingUp1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 16,
    color: AppColors.coral,
    fontWeight: FontWeight.w600, // Light
  );

  static const TextStyle bebas18Peach = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.peach,
    letterSpacing: 1.5,
  );
  static const TextStyle drawerLivros = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    letterSpacing: 1.5,
  );
  static const TextStyle bebas18Peach1 = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.coral,
    letterSpacing: 1.5,
  );
  static const TextStyle bebas19Peach = const TextStyle(
    fontFamily: 'Bebas',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.coral,
    letterSpacing: 1.5,
  );

}
