import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/core/app_colors.dart';

import '../../auth/models/user_model.dart';
import '../../core/text_styles.dart';
import '../login/loginController.dart';

class Configuracao extends StatefulWidget {
  const Configuracao({super.key});

  @override
  State<Configuracao> createState() => _ConfiguracaoState();
}

class _ConfiguracaoState extends State<Configuracao> {
  CadastroModel? usuario;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  Future<void> carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    final nome = prefs.getString('nome');
    final apelido = prefs.getString('email');
    final senha = prefs.getString('senha');

    if (nome != null && apelido != null && senha != null) {
      setState(() {
        usuario = CadastroModel(
          nome: nome,
          apelido: apelido,
          senha: senha,
          confirmarSenha: senha, // só para o model funcionar
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false,
                      );
                    },
                    child: Text(
                      'TO DO LIST',
                      style: AppTextStyles.bebas18Peach,
                    ),
                  ),

                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Center
                (child:
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35, // 25% da tela
                child: Image.asset(
                  'assets/images/StoryG.png',
                  fit: BoxFit.contain,
                ),
              )
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              // NOME
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NOME', style: AppTextStyles.config),
                  Text(
                    usuario?.nome ?? '-',
                    style: AppTextStyles.configDados,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // EMAIL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Apelido', style: AppTextStyles.config),
                  Text(
                    usuario?.apelido ?? '-',
                    style: AppTextStyles.configDados,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // PASSWORD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PASSWORD', style: AppTextStyles.config),
                  Text(
                    usuario != null ? '••••••••' : '-',
                    style: AppTextStyles.configDados,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // LOGOUT
              GestureDetector(
                onTap: () async {
                  final controller = LoginController();
                  await controller.logout();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false,
                  );
                },
                child: Container(
                  width: 327,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'LOG OUT',
                      style: AppTextStyles.ButtonAdd,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
