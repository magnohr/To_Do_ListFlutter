import 'package:flutter/material.dart';
import 'Pagina.dart';

class Aba {
  final String id;
  String nome;
  int cor;
  final TickerProvider _vsync;

  // 🔥 callback de salvamento
  final VoidCallback onSalvar;

  List<Pagina> paginas;
  late TabController paginasController;

  Color get color => Color(cor);

  Aba(
      this.id,
      this.nome,
      this.cor,
      this._vsync, {
        required this.onSalvar,
        List<Pagina>? paginasSalvas,
        int paginaInicial = 0,
      }) : paginas = paginasSalvas ?? [Pagina(titulo: 'Página 1')] {
    // 🔥 adiciona listener em TODAS as páginas carregadas
    for (final p in paginas) {
      p.controller.addListener(onSalvar);
    }

    paginasController = TabController(
      length: paginas.length,
      vsync: _vsync,
      initialIndex: paginaInicial.clamp(0, paginas.length - 1),
    );
  }

  // ================= ADD PAGE =================
  void adicionarPagina() {
    final pagina = Pagina(titulo: 'Página ${paginas.length + 1}');

    // 🔥 salva automaticamente ao digitar
    pagina.controller.addListener(onSalvar);

    paginas.add(pagina);
    _recriarController(paginas.length - 1);

    onSalvar(); // 🔥 salva imediatamente ao criar página
  }

  // ================= REMOVE PAGE =================
  void removerPagina(int index) {
    if (paginas.length <= 1) return;

    final pagina = paginas[index];

    pagina.controller.removeListener(onSalvar);
    pagina.controller.dispose();
    paginas.removeAt(index);

    _recriarController(
      index.clamp(0, paginas.length - 1),
    );

    onSalvar(); // 🔥 salva após remover
  }

  // ================= RECRIAR CONTROLLER =================
  void _recriarController(int novoIndex) {
    paginasController.dispose();

    paginasController = TabController(
      length: paginas.length,
      vsync: _vsync,
      initialIndex: novoIndex,
    );
  }

  // ================= DISPOSE =================
  void dispose() {
    paginasController.dispose();

    for (final p in paginas) {
      p.controller.removeListener(onSalvar);
      p.controller.dispose();
    }
  }
}
