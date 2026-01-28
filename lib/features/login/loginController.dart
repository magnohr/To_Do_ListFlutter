import 'package:shared_preferences/shared_preferences.dart';

import 'cadastro/controllerCadastro.dart';

class LoginController {
  Future<bool> login(String email, String senha) async {
    final cadastroController = CadastroController();

    final valido =
    await cadastroController.autenticar(email.trim(), senha.trim());

    if (valido) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logado', true);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logado', false);
  }
}

