import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/appInput.dart';
import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
import '../cadastro/controllerCadastro.dart';

class MudarSenha extends StatefulWidget {
  const MudarSenha({super.key});

  @override
  State<MudarSenha> createState() => _MudarSenhaState();
}

class _MudarSenhaState extends State<MudarSenha> {
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController =
  TextEditingController();

  final CadastroController controller = CadastroController();

  bool obscureSenha = true;
  bool obscureConfirmar = true;

  @override
  void dispose() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 104),

              SvgPicture.asset(
                'assets/images/Union.svg',
                width: 187,
                height: 180,
              ),

              const SizedBox(height: 120),

              // 🔹 NOVA SENHA
              AppInput(
                hint: 'Nova senha',
                controller: senhaController,
                obscureText: obscureSenha,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureSenha
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.lightGray,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureSenha = !obscureSenha;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 CONFIRMAR SENHA
              AppInput(
                hint: 'Confirmar senha',
                controller: confirmarSenhaController,
                obscureText: obscureConfirmar,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmar
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.lightGray,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureConfirmar = !obscureConfirmar;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 BOTÃO
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.peach,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final senha = senhaController.text;
                    final confirmar = confirmarSenhaController.text;

                    if (senha.length < 6) {
                      _mostrarErro('A senha deve ter no mínimo 6 caracteres');
                      return;
                    }

                    if (senha != confirmar) {
                      _mostrarErro('As senhas não coincidem');
                      return;
                    }

                    final sucesso =
                    await controller.atualizarSenha(senha);

                    if (!sucesso) {
                      _mostrarErro('Erro ao atualizar senha');
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Senha alterada com sucesso'),
                      ),
                    );

                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'ALTERAR SENHA',
                    style: AppTextStyles.ButtonSing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
