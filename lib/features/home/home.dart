import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:to_do_list/core/text_styles.dart';

import '../../core/app_colors.dart';
import '../addTarefa/addTarefaEditar.dart';
import '../addTarefa/listaPersonalizada/listaPersonalizada.dart';
import '../banner/anuncios.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          backgroundColor: AppColors.Colorblue,
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.8,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                    child: AddtarefaEditar(),
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),

      // ✅ AQUI FICA O BANNER
      bottomNavigationBar: const BannerAdWidget(),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 🔝 TÍTULO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TO DO LIST', style: AppTextStyles.bebas18Peach),
                  GestureDetector(
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/config');
                    },
                    child: SvgPicture.asset(
                      'assets/images/settings.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ACTIONLIST
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/pastas');
                    },
                    child: SvgPicture.asset(
                      'assets/images/bookL.svg',
                      width: 35,
                      height: 35,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(' ACTIONLIST', style: AppTextStyles.bebas19Peach),
                ],
              ),
              const SizedBox(height: 40),

              const Expanded(
                child: TodoListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
