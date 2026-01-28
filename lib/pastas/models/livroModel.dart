import 'package:hive/hive.dart';
import 'paginaModel.dart';

part 'livroModel.g.dart';

@HiveType(typeId: 0) // ✅ FIXO E ÚNICO
class LivroModel extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nome;

  @HiveField(2)
  final List<PaginaModel> paginas;

  @HiveField(3)
  final int cor;

  @HiveField(4)
  final int paginaAtual;

  LivroModel(
      this.id,
      this.nome,
      this.paginas,
      this.cor, {
        this.paginaAtual = 0,
      });
}
