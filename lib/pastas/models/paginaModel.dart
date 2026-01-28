
import 'package:hive/hive.dart';

part 'paginaModel.g.dart';

@HiveType(typeId: 1) // ✅ DIFERENTE DO LIVRO
class PaginaModel {

  @HiveField(0)
  final String titulo;

  @HiveField(1)
  final String conteudoJson;

  PaginaModel(this.titulo, this.conteudoJson);
}

