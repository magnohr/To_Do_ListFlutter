import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../auth/models/user_model.dart';
import '../../../core/appInput.dart';
import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';

import 'controllerCadastro.dart';


class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  // 🔹 Controllers da UI
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  // 🔹 Controller de regra de negócio
  final CadastroController controller = CadastroController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    nomeController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 104),

                Image.asset(
                  'assets/images/StoryG.png',
                  width: 250,  // largura opcional
                  height: 250, // altura opcional
                  fit: BoxFit.contain, // melhor que cover
                ),
            
                const SizedBox(height: 64),
            
                AppInput(
                  hint: 'Apelido',
                  controller: emailController,
                ),
                const SizedBox(height: 10),
            
                AppInput(
                  hint: 'Nome',
                  controller: nomeController,
                ),
                const SizedBox(height: 10),
            
                AppInput(
                  hint: 'Password',
                  controller: senhaController,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
            
                const SizedBox(height: 10),
            
                AppInput(
                  hint: 'Confirme Password',
                  controller: confirmarSenhaController,
                  obscureText: obscurePassword,
                ),
            
                const SizedBox(height: 12),
            
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.Colorblue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final cadastro = CadastroModel(
                        nome: nomeController.text.trim(),
                        apelido: emailController.text.trim(),
                        senha: senhaController.text.trim(),
                        confirmarSenha: confirmarSenhaController.text.trim(),
                      );
            
                      String? erro;
            
                      if (cadastro.nome.isEmpty) {
                        erro = 'Nome é obrigatório';
                      } else if (!cadastro.apelidoValido) {
                        erro = 'Apelido inválido';
                      } else if (!cadastro.senhaValida) {
                        erro = 'Senha deve ter no mínimo 6 caracteres';
                      } else if (!cadastro.senhasIguais) {
                        erro = 'As senhas não conferem';
                      }
            
                      if (erro != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(erro)),
                        );
                        return;
                      }
            
                      final sucesso = await controller.cadastrar(cadastro);
            
                      if (sucesso) {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
            
                    child: const Text(
                      'SIGN IN',
                      style: AppTextStyles.ButtonSing,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
            
                RichText(
                  text: TextSpan(
                    text: 'Have an account? ',
                    style: TextStyle(color: AppColors.blueFigma),
                    children: [
                      TextSpan(
                        text: 'Log in',
                        style: AppTextStyles.montserratSingUp,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
