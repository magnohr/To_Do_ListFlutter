import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../core/app_colors.dart';
import '../core/text_styles.dart';

import '../features/banner/anuncios.dart';
import '../features/clipToDo/clipArt.dart';
import 'controllers/pastasControler.dart';

class Pastas extends StatefulWidget {
  const Pastas({super.key});

  @override
  State<Pastas> createState() => _PastasState();
}

class _PastasState extends State<Pastas> with TickerProviderStateMixin {
  final PastaController controller = PastaController();
  late final TickerProvider _vsync; // ⚡ variável de instância para vsync

  Set<int> paginasSelecionadas = {};
  bool selecionandoPaginas = false;

  @override
  void initState() {
    super.initState();
    controller.init(this);

    controller.onLivroChanged = () {
      if (mounted) setState(() {});
    };

    controller.init(this).then((_) {
      if (mounted) setState(() {});
    });
  }


  @override
  void dispose() {
    controller.livrosController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.livrosController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final livroAtual =
    controller.livros[controller.livrosController!.index];

    if (livroAtual.paginas.isEmpty) {
      livroAtual.adicionarPagina();
    }

    final paginaAtual =
    livroAtual.paginas[livroAtual.paginasController.index];


    void selecionarTextoTodo(QuillController controller) {
      final tamanho = controller.document.length;

      controller.updateSelection(
        TextSelection(baseOffset: 0, extentOffset: tamanho),
        ChangeSource.local,
      );
    }


    void dialogCriarLivro() {
      final txt = TextEditingController();

      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: const Text('Novo livro'),
              content: TextField(
                controller: txt,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Nome do livro',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final nome = txt.text.trim();
                    if (nome.isNotEmpty) {
                      Navigator.pop(context);
                      controller.criarLivro(nome, this);
                      setState(() {});
                    }
                  },
                  child: const Text('Criar'),
                ),
              ],
            ),
      );
    }

    void dialogEscolherWallpaper() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) =>
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.wallpapers.length,
              itemBuilder: (_, i) =>
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      controller.escolherWallpaper(controller.wallpapers[i]);
                      setState(() {});
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        controller.wallpapers[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            ),
      );
    }


    return SafeArea(
      child: PopScope(
        canPop: false, // 🚫 impede voltar
        onPopInvoked: (didPop) {
          // opcional: você pode mostrar um aviso aqui
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Livros',
              style: AppTextStyles.bebas18Peach1,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.select_all),

                onPressed: () {
                  setState(() {
                    if (paginasSelecionadas.length ==
                        livroAtual.paginas.length) {
                      paginasSelecionadas.clear();
                    } else {
                      paginasSelecionadas = Set.from(
                          List.generate(livroAtual.paginas.length, (i) => i));
                    }
                  });
                },
              ),

              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'Exportar PDF',
                onPressed: () {
                  controller.gerarPdf(context);
                },
              ),

              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  controller.selecionarECopiarTudo(
                    context,
                    paginaAtual.controller,
                  );
                },
              ),


              // 🔹 BOTÃO HOME
              IconButton(
                icon:GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Image.asset(
                    'assets/images/casa.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                tooltip: 'Voltar para Home',
                onPressed: () async {
                  // 1️⃣ Força salvar todos os textos ativos no Quill
                  for (var livro in controller.livros) {
                    for (var pagina in livro.paginas) {
                      // Atualiza o delta do Hive
                      pagina.controller.document
                          .toDelta(); // garante que o delta está atualizado
                    }
                  }

                  // 2️⃣ Salva tudo no Hive (livros, páginas, capa, wallpaper)
                  await controller.salvarTudoAntesDeSair();

                  // 3️⃣ Navega para a home
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),

            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: TabBar(
                controller: controller.livrosController,
                isScrollable: true,
                indicatorColor: Colors.transparent,
                tabs: controller.livros.map((livro) {
                  final ativo =
                      controller.livrosController!.index ==
                          controller.livros.indexOf(livro);

                  return GestureDetector(
                    onLongPress: () {
                      controller.confirmarExcluirLivro(
                        context,
                        controller.livros.indexOf(livro),
                        this,
                            () => setState(() {}),
                      );
                    },
                    child: Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(livro.cor),
                          borderRadius: BorderRadius.vertical(
                            top: const Radius.circular(14),
                            bottom: Radius.circular(ativo ? 0 : 14),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6), // ⭐ contorno branco opaco
                            width: 2,
                          ),
                        ),
                        child: Text(
                          livro.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          ),
          bottomNavigationBar: const BannerAdWidget(),
          // ================= BODY =================
          body: Column(
            children: [
              // ===== ABAS DE PÁGINAS =====
              SizedBox(
                height: 46,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // 📚 LISTA DE PÁGINAS
                        Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 12, top: 6),
                            itemCount: livroAtual.paginas.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final pagina = livroAtual.paginas[index];
                              final selecionada = selecionandoPaginas
                                  ? paginasSelecionadas.contains(index)
                                  : index == livroAtual.paginasController.index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selecionandoPaginas) {
                                      // Alterna seleção da página
                                      if (paginasSelecionadas.contains(index)) {
                                        paginasSelecionadas.remove(index);
                                        if (paginasSelecionadas.isEmpty) {
                                          selecionandoPaginas = false;
                                        }
                                      } else {
                                        paginasSelecionadas.add(index);
                                      }
                                    } else {
                                      // Seleciona a página normalmente
                                      livroAtual.paginasController.index =
                                          index;
                                    }
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    // Ativa modo seleção e marca a página
                                    selecionandoPaginas = true;
                                    paginasSelecionadas.add(index);
                                  });
                                },
                                child: Stack(
                                  children: [
                                    // 📄 CONTAINER DA PÁGINA
                                    ClipPath(
                                      clipper: ClipInclinadoEsquerda(),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selecionada
                                              ? AppColors.Colorblue
                                              : Colors.grey.shade200,
                                          boxShadow: selecionada
                                              ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.15),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                              : [],
                                        ),
                                        child: Text(
                                          pagina.titulo,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: selecionada ? FontWeight
                                                .w600 : FontWeight.w500,
                                            color: selecionada
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ✏️ BOTÃO RENOMEAR (canto superior direito da página)
                                    if (!selecionandoPaginas)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            final txtController = TextEditingController(
                                                text: pagina.titulo);
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  AlertDialog(
                                                    title: const Text(
                                                        'Renomear página'),
                                                    content: TextField(
                                                      controller: txtController,
                                                      autofocus: true,
                                                      decoration: const InputDecoration(
                                                          hintText: 'Novo título'),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancelar'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          final novoTitulo = txtController
                                                              .text.trim();
                                                          if (novoTitulo
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              pagina.titulo =
                                                                  novoTitulo;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Renomear'),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                          child: const Icon(
                                              Icons.edit, size: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 6),

                        // ➕ BOTÃO ADD PÁGINA (fixo à direita)
                        Padding(
                          padding: const EdgeInsets.only(right: 12, top: 6),
                          child: GestureDetector(
                            onTap: () {
                              controller.adicionarPagina(
                                  this); // passa o vsync do State
                              setState(() {}); // rebuild pra mostrar a nova aba
                            },
                            child: ClipPath(
                              clipper: ClipInclinadoEsquerda(),
                              child: Container(
                                width: 42,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.Colorblue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                    Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                    // 🔹 BOTÃO DELETAR (aparece apenas no modo seleção)
                    if (selecionandoPaginas)
                      Positioned(
                        right: 16,
                        bottom: 0,
                        child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              final indices = paginasSelecionadas.toList()
                                ..sort((a, b) => b.compareTo(a));
                              for (var i in indices) {
                                controller.excluirPagina(i);
                              }
                              paginasSelecionadas.clear();
                              selecionandoPaginas = false;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),


              // ===== TOOLBAR =====
              QuillSimpleToolbar(
                controller: paginaAtual.controller,
                config: const QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showAlignmentButtons: true,
                  showFontFamily: false,
                  showFontSize: false,
                ),
              ),

              const Divider(height: 1),

              // ===== EDITOR =====
              Expanded(
                child: TabBarView(
                  key: ValueKey(livroAtual.id), // 🔥 AQUI
                  controller: livroAtual.paginasController,
                  children: livroAtual.paginas.map((p) {
                    return QuillEditor(
                      controller: p.controller,
                      focusNode: p.focusNode,
                      scrollController: ScrollController(),
                      config: const QuillEditorConfig(
                        expands: true,
                        padding: EdgeInsets.all(12),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // ================= DRAWER =================
          drawer: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: Drawer(
              child: Stack(
                children: [
                  // ===== WALLPAPER =====
                  if (controller.wallpaperSelecionado != null)
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(controller.wallpaperSelecionado!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  // ===== CONTEÚDO =====
                  Column(
                    children: [
                      // 🔹 HEADER COM CAPA
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: AppColors.Colorblue,
                          image: controller.fotoSelecionada != null
                              ? DecorationImage(
                            image: FileImage(controller.fotoSelecionada!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: InkWell(
                            onTap: () async {
                              // chama o ImagePicker
                              await controller.escolherFoto();
                              if (mounted) setState(() {}); // atualiza a capa
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                controller.fotoSelecionada == null
                                    ? 'Adicionar capa'
                                    : 'Livros',
                                style: AppTextStyles.drawerLivros,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== LISTA DE LIVROS =====
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: controller.livros.length,
                          itemBuilder: (_, i) =>
                              ListTile(
                                leading: const Icon(
                                    Icons.book, color: AppColors.blueFigma),
                                title: Text(
                                  controller.livros[i].nome,
                                  style: AppTextStyles.Livrosadd,
                                ),
                                onTap: () {
                                  controller.livrosController!.index = i;
                                  Navigator.pop(context);
                                },
                                onLongPress: () {
                                  Navigator.pop(context);
                                  controller.confirmarExcluirLivro(
                                    context,
                                    i,
                                    this,
                                        () => setState(() {}),
                                  );
                                },
                              ),
                        ),
                      ),

                      const SizedBox(height: 80), // espaço para bottom
                    ],
                  ),

                  // ===== BOTTOM FIXO =====
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 🔹 CRIAR LIVRO
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                Navigator.pop(context);
                                dialogCriarLivro();
                              },
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.Colorblue,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Criar livro',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),


                          // 🔹 WALLPAPER
                          InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: dialogEscolherWallpaper,
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.Colorblue,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.wallpaper,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ),
      ),
    );
  }
}
