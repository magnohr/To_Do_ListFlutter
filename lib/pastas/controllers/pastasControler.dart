import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';

import '../controllers/abas.dart';
import '../controllers/Pagina.dart';
import '../models/livroModel.dart';
import '../models/paginaModel.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PastaController {
  // ================= HIVE =================
  late Box<LivroModel> livrosBox;
  late Box configBox;

  // ================= ESTADO =================
  final List<Aba> livros = [];
  TabController? livrosController;
  Timer? _saveTimer;

  // Drawer
  File? fotoSelecionada;
  String? wallpaperSelecionado;

  VoidCallback? onLivroChanged;

  // ================= CONSTANTES =================
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

  // ================= INIT =================
  // ================= INIT =================
  Future<void> init(TickerProvider vsync) async {
    livrosBox = await Hive.openBox<LivroModel>('livros');
    configBox = await Hive.openBox('config');

    final capa = configBox.get('capaLivro');
    if (capa != null && File(capa).existsSync()) {
      fotoSelecionada = File(capa);
    }
    wallpaperSelecionado = configBox.get('wallpaper');

    _carregarLivros(vsync);
  }



  // ================= LOAD =================
  void _carregarLivros(TickerProvider vsync) {
    final livroSelecionado = configBox.get('livroSelecionado', defaultValue: 0);

    livros.clear(); // ⭐ SEMPRE limpa antes de carregar

    for (final livro in livrosBox.values) {
      final paginas = livro.paginas.map((p) {
        final pagina = Pagina(titulo: p.titulo, json: p.conteudoJson);
        _adicionarListenerPagina(pagina);
        return pagina;
      }).toList();

      livros.add(
        Aba(
          livro.id,
          livro.nome,
          livro.cor,
          vsync,
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
          vsync,
          onSalvar: salvarComDelay,
        ),
      );
    }

    _criarTabController(vsync);
    livrosController!.index = livroSelecionado.clamp(0, livros.length - 1);
  }
  // ================= TAB CONTROLLER =================
  void _criarTabController(TickerProvider vsync) {
    livrosController?.dispose();

    livrosController = TabController(length: livros.length, vsync: vsync);

    livrosController!.addListener(() {
      if (!livrosController!.indexIsChanging) {
        salvarLivros();
        onLivroChanged?.call();
      }
    });
  }

  // ================= LISTENER AUTOMÁTICO =================
  void _adicionarListenerPagina(Pagina pagina) {
    pagina.controller.addListener(() {
      salvarComDelay();
    });
  }

  // ================= LIVROS =================
  void criarLivro(String nome, TickerProvider vsync) {
    final cor = coresLivros[livros.length % coresLivros.length].value;

    livros.add(
      Aba(
        DateTime.now().millisecondsSinceEpoch.toString(),
        nome,
        cor,
        vsync,
        onSalvar: salvarComDelay,
      ),
    );

    _criarTabController(vsync);
    livrosController!.index = livros.length - 1;

    salvarLivros();
  }

  void confirmarExcluirLivro(
      BuildContext context, int index, TickerProvider vsync, VoidCallback refresh) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir livro'),
        content: Text('Deseja excluir "${livros[index].nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              excluirLivro(index, vsync);
              refresh();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void excluirLivro(int index, TickerProvider vsync) {
    livros.removeAt(index);

    if (livros.isEmpty) {
      livros.add(
        Aba(
          DateTime.now().millisecondsSinceEpoch.toString(),
          'Livro 1',
          coresLivros.first.value,
          vsync,
          onSalvar: salvarComDelay,
        ),
      );
    }

    _criarTabController(vsync);
    livrosController!.index = (index - 1).clamp(0, livros.length - 1);

    salvarLivros();
  }

  // ================= PÁGINAS =================
  void adicionarPagina(TickerProvider vsync) {
    final livroAtual = livros[livrosController!.index];

    final novaPagina = Pagina(titulo: 'Nova Página', json: '[]');
    _adicionarListenerPagina(novaPagina); // ✅ listener automático

    livroAtual.paginas.add(novaPagina);

    // Dispose do antigo e cria um novo TabController
    livroAtual.paginasController.dispose();
    livroAtual.paginasController = TabController(
      length: livroAtual.paginas.length,
      vsync: vsync,
    );

    // Vai para a nova página
    livroAtual.paginasController.index = livroAtual.paginas.length - 1;

    salvarLivros();
  }

  void dialogOpcoesPagina(BuildContext context, int index, VoidCallback refresh) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Renomear página'),
            onTap: () {
              Navigator.pop(context);
              dialogRenomearPagina(context, index, refresh);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Excluir página', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              excluirPagina(index);
              refresh();
            },
          ),
        ],
      ),
    );
  }

  void dialogRenomearPagina(BuildContext context, int index, VoidCallback refresh) {
    final livroAtual = livros[livrosController!.index];
    final txt = TextEditingController(text: livroAtual.paginas[index].titulo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renomear página'),
        content: TextField(controller: txt),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              livroAtual.paginas[index].titulo = txt.text.trim();
              salvarLivros();
              refresh();
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void excluirPagina(int index) {
    final livroAtual = livros[livrosController!.index];

    if (livroAtual.paginas.length > 1) {
      livroAtual.paginas.removeAt(index);
      livroAtual.paginasController.index = (index - 1).clamp(0, livroAtual.paginas.length - 1);
    } else {
      livroAtual.paginas[0].titulo = 'Página 1';
      livroAtual.paginas[0].controller = QuillController.basic();
    }

    salvarLivros();
  }

  // ================= DRAWER / IMAGENS =================
  Future<void> escolherFoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    fotoSelecionada = File(img.path);
    configBox.put('capaLivro', img.path);
  }

  void escolherWallpaper(String asset) {
    wallpaperSelecionado = asset;
    configBox.put('wallpaper', asset);
  }

  // ================= SALVAR AUTOMÁTICO =================
  void salvarComDelay() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 900), salvarLivros);
  }

  Future<void> salvarLivros() async {
    final Map<int, LivroModel> mapa = {};

    for (int i = 0; i < livros.length; i++) {
      final l = livros[i];

      mapa[i] = LivroModel(
        l.id,
        l.nome,
        l.paginas.map((p) => PaginaModel(
          p.titulo,
          jsonEncode(p.controller.document.toDelta().toJson()),
        )).toList(),
        l.cor,
        paginaAtual: l.paginasController.index,
      );
    }

    await livrosBox.clear(); // ⭐ ESSA LINHA RESOLVE
    await livrosBox.putAll(mapa);

    await configBox.put('livroSelecionado', livrosController!.index);
  }


  // ================= SALVAR TUDO ANTES DE SAIR =================
  Future<void> salvarTudoAntesDeSair() async {
    salvarLivros();

    if (fotoSelecionada != null) {
      configBox.put('capaLivro', fotoSelecionada!.path);
    }

    if (wallpaperSelecionado != null) {
      configBox.put('wallpaper', wallpaperSelecionado);
    }
  }

  // ================= GERAR PDF =================
  // 📄 GERADOR DE PDF OTIMIZADO
  Future<void> gerarPdf(BuildContext context) async {
    // 1. Pega o livro que está aberto no momento
    if (livrosController == null || livros.isEmpty) return;
    final livroAtual = livros[livrosController!.index];

    // 2. Mostra um alerta de "Gerando..." para o usuário
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text("Gerando PDF do livro...", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final pdf = pw.Document();

      // Carrega uma fonte que suporte acentuação corretamente
      final font = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      // Lista de widgets que serão colocados no PDF
      List<pw.Widget> content = [];

      for (var p in livroAtual.paginas) {
        // Título da Página
        content.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20, bottom: 10),
            child: pw.Text(
              p.titulo.toUpperCase(),
              style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.green),
            ),
          ),
        );

        // Conteúdo da Página (Texto simples extraído do Quill)
        final plainText = p.controller.document.toPlainText();

        content.add(
          pw.Paragraph(
            text: plainText,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              lineSpacing: 4, // ↔️ No PDF usamos lineSpacing para dar espaço entre as linhas
              color: PdfColors.black, // 🔴 Seu texto em vermelho
            ),
            textAlign: pw.TextAlign.justify,
          ),
        );

        // Adiciona uma linha separadora entre páginas, exceto na última
        if (livroAtual.paginas.last != p) {
          content.add(pw.Divider(thickness: 0.5, color: PdfColors.grey300));
        }
      }

      // 3. Monta o documento com suporte a múltiplas páginas automáticas
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => content,
        ),
      );

      // 4. Fecha o diálogo de loading
      if (Navigator.canPop(context)) Navigator.pop(context);

      // 5. Abre a pré-visualização de impressão/salvamento
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Livro_${livroAtual.nome}.pdf',
      );

    } catch (e) {
      // Caso ocorra erro, fecha o loading e avisa
      if (Navigator.canPop(context)) Navigator.pop(context);
      debugPrint("Erro ao gerar PDF: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao gerar PDF: $e"), backgroundColor: Colors.red),
      );
    }
  }
  void selecionarECopiarTudo(
      BuildContext context,
      QuillController controller,
      ) {
    final texto = controller.document.toPlainText().trim();

    if (texto.isEmpty) return;

    controller.updateSelection(
      TextSelection(baseOffset: 0, extentOffset: texto.length),
      ChangeSource.local,
    );

    Clipboard.setData(ClipboardData(text: texto));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado!'),
        duration: Duration(seconds: 2),
      ),
    );
  }



}
