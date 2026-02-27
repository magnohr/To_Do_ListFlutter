class CadastroModel {
  final String nome;
  final String apelido;
  final String senha;
  final String confirmarSenha;

  CadastroModel({
    required this.nome,
    required this.apelido,
    required this.senha,
    required this.confirmarSenha,
  });

  bool get apelidoValido => apelido.length >=1;

  bool get senhaValida => senha.length >= 6;

  bool get senhasIguais => senha == confirmarSenha;

  bool get dadosValidos {
    print('nome="$nome"');
    print('email="$apelido"');
    print('emailValido=$apelidoValido');
    print('senhaValida=$senhaValida');
    print('senhasIguais=$senhasIguais');

    return nome.trim().isNotEmpty &&
        apelidoValido &&
        senhaValida &&
        senhasIguais;
  }
}
