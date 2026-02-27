import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/models/user_model.dart';

class CadastroController {
  // 🔹 CADASTRAR
  Future<bool> cadastrar(CadastroModel cadastro) async {
    if (!cadastro.dadosValidos) return false;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nome', cadastro.nome);
    await prefs.setString('email', cadastro.apelido);
    await prefs.setString('senha', cadastro.senha);

    return true;
  }

  // 🔹 LOGIN
  Future<bool> autenticar(String email, String senha) async {
    final prefs = await SharedPreferences.getInstance();

    final emailSalvo = prefs.getString('email');
    final senhaSalva = prefs.getString('senha');

    return email == emailSalvo && senha == senhaSalva;
  }

  // 🔹 BUSCAR DADOS (opcional, mas útil)
  Future<CadastroModel?> buscarCadastro() async {
    final prefs = await SharedPreferences.getInstance();

    final nome = prefs.getString('nome');
    final apelido = prefs.getString('apelido');
    final senha = prefs.getString('senha');

    if (nome == null || apelido == null || senha == null) {
      return null;
    }

    return CadastroModel(
      nome: nome,
      apelido: apelido,
      senha: senha,
      confirmarSenha: senha,
    );
  }


  Future<bool> atualizarSenha(String novaSenha) async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('email');

    if (email == null) return false;

    await prefs.setString('senha', novaSenha);

    return true;
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
