import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/text_styles.dart';
import 'controllers/Pagina.dart';
import 'controllers/abas.dart';
import 'models/livroModel.dart';
import 'models/paginaModel.dart';

class Pastas extends StatefulWidget {
  const Pastas({super.key});

  @override
  State<Pastas> createState() => _PastasState();
}

class _PastasState extends State<Pastas> with TickerProviderStateMixin {
  TabController? livrosController;

  late Box<LivroModel> livrosBox;
  late Box configBox;

  final List<Aba> livros = [];
  Timer? _saveTimer;

  File? fotoSelecionada;
  final ImagePicker _picker = ImagePicker();
  File? wallpaperDrawer;


  final List<Color> coresLivros = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  final List<String> wallpapers = [
    'assets/images/cor.jpg',
    'assets/images/ave.jpg',
    'assets/images/ceu.jpg',
    'assets/images/agua.jpg',
  ];

  String? wallpaperSelecionado;


  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    livrosBox = await Hive.openBox<LivroModel>('livros');
    configBox = await Hive.openBox('config');

    final path = configBox.get('capaLivro');
    if (path != null && File(path).existsSync()) {
      fotoSelecionada = File(path);
    }

    carregarLivros();
    if (mounted) setState(() {});

    final wallpaper = configBox.get('wallpaper');

    if (wallpaper != null) {
      wallpaperSelecionado = wallpaper;
    }

  }

  void escolherWallpaper(String path) {
    setState(() {
      wallpaperSelecionado = path;
    });

    configBox.put('wallpaper', path);
  }

  void dialogEscolherWallpaper() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: wallpapers.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            Navigator.pop(context);
            escolherWallpaper(wallpapers[i]);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              wallpapers[i],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }



  // ================= SAVE =================
  void salvarComDelay() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), salvarLivros);
  }

  // ================= LOAD =================
  void carregarLivros() {
    final int livroSelecionado =
    configBox.get('livroSelecionado', defaultValue: 0);

    livros.clear();

    for (final livro in livrosBox.values) {
      final paginas = livro.paginas.map((p) {
        final pagina = Pagina(titulo: p.titulo, json: p.conteudoJson);
        pagina.controller.addListener(salvarComDelay);
        return pagina;
      }).toList();

      livros.add(
        Aba(
          livro.id,
          livro.nome,
          livro.cor,
          this,
          paginasSalvas: paginas,
          paginaInicial: livro.paginaAtual,
          onSalvar: salvarComDelay,
        ),
      );
    }

    if (livros.isEmpty) {
      livros.add(
        Aba(
          DateTime.now().millisecondsSinceEpoch.toString(),
          'Livro 1',
          coresLivros.first.value,
          this,
          onSalvar: salvarComDelay,
        ),
      );
    }

    _recriarLivrosController();
    livrosController!.index =
        livroSelecionado.clamp(0, livros.length - 1);
  }

  void confirmarExcluirLivro(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir livro'),
        content: Text(
          'Tem certeza que deseja excluir "${livros[index].nome}"?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              excluirLivro(index);
            },
          ),
        ],
      ),
    );
  }

  void excluirLivro(int index) {
    setState(() {
      livros.removeAt(index);

      // nunca ficar sem livro
      if (livros.isEmpty) {
        livros.add(
          Aba(
            DateTime.now().millisecondsSinceEpoch.toString(),
            'Livro 1',
            coresLivros.first.value,
            this,
            onSalvar: salvarComDelay,
          ),
        );
      }

      _recriarLivrosController();
      livrosController!.index =
          (index - 1).clamp(0, livros.length - 1);
    });

    salvarLivros();
  }

  void dialogCriarLivro() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo livro'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome do livro',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Criar'),
            onPressed: () {
              final nome = controller.text.trim();

              if (nome.isNotEmpty) {
                Navigator.pop(context);
                criarLivro(nome);
              }
            },
          ),
        ],
      ),
    );
  }

  void confirmarExcluirPagina(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir página'),
        content: const Text('Tem certeza que deseja excluir esta página?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              excluirPagina(index);
            },
          ),
        ],
      ),
    );
  }

  void excluirPagina(int index) {
    final livroAtual = livros[livrosController!.index];

    setState(() {
      livroAtual.paginas.removeAt(index);

      // nunca deixar livro sem página
      if (livroAtual.paginas.isEmpty) {
        livroAtual.adicionarPagina();
      }

      livroAtual.paginasController.index =
          (index - 1).clamp(0, livroAtual.paginas.length - 1);
    });

    salvarLivros();
  }


  void dialogOpcoesPagina(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Renomear página'),
            onTap: () {
              Navigator.pop(context);
              dialogRenomearPagina(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Excluir página',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              confirmarExcluirPagina(index);
            },
          ),
        ],
      ),
    );
  }

  void dialogRenomearPagina(int index) {
    final controller =
    TextEditingController(text: livros[livrosController!.index].paginas[index].titulo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renomear página'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome da página',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () {
              final nome = controller.text.trim();
              if (nome.isNotEmpty) {
                setState(() {
                  livros[livrosController!.index]
                      .paginas[index]
                      .titulo = nome;
                });
                salvarLivros();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }


  // ================= CONTROLLER =================
  void _recriarLivrosController() {
    livrosController?.dispose();

    livrosController = TabController(
      length: livros.length,
      vsync: this,
    );

    livrosController!.addListener(() {
      if (!livrosController!.indexIsChanging) {
        salvarLivros();
        setState(() {});
      }
    });
  }

  // ================= CAPA =================
  Future<void> escolherFoto() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      fotoSelecionada = File(img.path);
    });

    configBox.put('capaLivro', img.path);

  }

  // ================= LIVRO =================
  void criarLivro(String nome) {
    final cor = coresLivros[livros.length % coresLivros.length].value;

    setState(() {
      livros.add(
        Aba(
          DateTime.now().millisecondsSinceEpoch.toString(),
          nome,
          cor,
          this,
          onSalvar: salvarComDelay,
        ),
      );

      _recriarLivrosController();
      livrosController!.index = livros.length - 1;
    });

    salvarLivros();
  }

  // ================= PAGE =================
  void adicionarPagina() {
    final livroAtual = livros[livrosController!.index];
    livroAtual.adicionarPagina();
    salvarLivros();
    setState(() {});
  }

  // ================= SAVE =================
  void salvarLivros() {
    livrosBox.clear();

    for (int i = 0; i < livros.length; i++) {
      final l = livros[i];
      livrosBox.put(
        i,
        LivroModel(
          l.id,
          l.nome,
          l.paginas
              .map((p) => PaginaModel(
            p.titulo,
            jsonEncode(
                p.controller.document.toDelta().toJson()),
          ))
              .toList(),
          l.cor,
          paginaAtual: l.paginasController.index,
        ),
      );
    }

    configBox.put('livroSelecionado', livrosController!.index);
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (livrosController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final livroAtual = livros[livrosController!.index];
    if (livroAtual.paginas.isEmpty) livroAtual.adicionarPagina();

    final paginaAtual =
    livroAtual.paginas[livroAtual.paginasController.index];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Livros',
            style: AppTextStyles.bebas18Peach1,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: TabBar(
              controller: livrosController,
              isScrollable: true,
              indicatorColor: Colors.transparent,
              tabs: livros.map((livro) {
                final ativo =
                    livrosController!.index == livros.indexOf(livro);
                return GestureDetector(
                  onLongPress: () {
                    confirmarExcluirLivro(livros.indexOf(livro));
                  },
                  child: Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: livro.color,
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(14),
                          bottom: Radius.circular(ativo ? 0 : 14),
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


        // 🔥 LAYOUT DO ANTIGO
        body: Column(
          children: [
            // ===== ABAS DE PÁGINAS =====
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: livroAtual.paginas.asMap().entries.map((e) {
                        final selecionada =
                            e.key == livroAtual.paginasController.index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              livroAtual.paginasController.index = e.key;
                            });
                          },
                          onLongPress: () {
                            dialogOpcoesPagina(e.key);
                          },

                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selecionada
                                  ? AppColors.coral.withOpacity(0.25)
                                  : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(e.value.titulo),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: adicionarPagina,
                  ),
                ],
              ),
            ),

            // ===== TOOLBAR DO QUILL (AQUI 👇) =====
            QuillSimpleToolbar(
              controller: paginaAtual.controller,
              config: const QuillSimpleToolbarConfig(
                multiRowsDisplay: false, // deixa mais clean
                showAlignmentButtons: true,
                showFontFamily: false,
                showFontSize: false,
              ),
            ),

            const Divider(height: 1),

            // ===== EDITOR =====
            Expanded(
              child: TabBarView(
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


        drawer: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: Drawer(
            child: Stack(
              children: [
                // 🔹 FUNDO DO DRAWER (papel de parede)
                Container(
                  decoration: BoxDecoration(
                    image: wallpaperSelecionado != null
                        ? DecorationImage(
                      image: AssetImage(wallpaperSelecionado!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                ),

                // 🔹 CONTEÚDO
                Column(
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        image: fotoSelecionada != null
                            ? DecorationImage(
                          image: FileImage(fotoSelecionada!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onTap: escolherFoto,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              fotoSelecionada == null ? 'Adicionar capa' : 'Livros',
                              style: AppTextStyles.drawerLivros,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: livros.length,
                          itemBuilder: (_, i) => ListTile(
                            leading: const Icon(
                              Icons.book,
                              color: AppColors.coral,
                            ),
                            title: Text(
                              livros[i].nome,
                              style: const TextStyle(
                                color: Colors.black, // garante contraste
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              livrosController!.index = i;
                              Navigator.pop(context);
                            },
                            onLongPress: () {
                              Navigator.pop(context);
                              confirmarExcluirLivro(i);
                            },
                          ),
                        ),
                      ),
                    ),


                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: Colors.white.withOpacity(0.6),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: const [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.coral,
                                      child: Icon(Icons.add, color: Colors.white, size: 18),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Criar livro',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 🔹 WALLPAPER
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: dialogEscolherWallpaper,
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.coral,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.wallpaper,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


