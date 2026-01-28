import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/appInput.dart';
import '../../core/app_colors.dart';
import '../../core/text_styles.dart';
import 'cadastro/controllerCadastro.dart';
import 'loginController.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // 🔹 Controllers da UI
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  // 🔹 Controller de regra de negócio
  final CadastroController controller = CadastroController();

  late TapGestureRecognizer _signUpTap;

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _signUpTap = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushNamed(context, '/cadastro');
      };
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    _signUpTap.dispose();
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
            
                SvgPicture.asset(
                  'assets/images/Union.svg',
                  width: 187,
                  height: 180,
                ),
            
                const SizedBox(height: 180),
            
                // 🔹 EMAIL
                AppInput(
                  hint: 'Email',
                  controller: emailController,
                ),
            
                const SizedBox(height: 16),
            
                // 🔹 PASSWORD
                AppInput(
                  hint: 'Password',
                  controller: senhaController,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.lightGray,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
            
                const SizedBox(height: 8),
            
                // 🔹 FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/mudarSenha');
                    },
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.montserratLight15Dark,
                    ),
                  ),
                ),
            
                const SizedBox(height: 24),
            
                // 🔹 BOTÃO LOGIN
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
                      final controller = LoginController();

                      final sucesso = await controller.login(
                        emailController.text,
                        senhaController.text,
                      );

                      if (sucesso) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email ou senha inválidos')),
                        );
                      }
                    },

                    child: const Text(
                      'SIGN IN',
                      style: AppTextStyles.ButtonAdd,
                    ),
                  ),
                ),
            
                const SizedBox(height: 24),
            
                // 🔹 SIGN UP
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: AppColors.dark),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: AppTextStyles.montserratSingUp,
                        recognizer: _signUpTap,
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
