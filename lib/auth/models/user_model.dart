class CadastroModel {
  final String nome;
  final String email;
  final String senha;
  final String confirmarSenha;

  CadastroModel({
    required this.nome,
    required this.email,
    required this.senha,
    required this.confirmarSenha,
  });

  bool get emailValido => email.contains('@');

  bool get senhaValida => senha.length >= 6;

  bool get senhasIguais => senha == confirmarSenha;

  bool get dadosValidos {
    print('nome="$nome"');
    print('email="$email"');
    print('emailValido=$emailValido');
    print('senhaValida=$senhaValida');
    print('senhasIguais=$senhasIguais');

    return nome.trim().isNotEmpty &&
        emailValido &&
        senhaValida &&
        senhasIguais;
  }
}
