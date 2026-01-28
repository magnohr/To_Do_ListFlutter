// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livroModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LivroModelAdapter extends TypeAdapter<LivroModel> {
  @override
  final int typeId = 0; // ✅ IGUAL AO MODEL

  @override
  LivroModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return LivroModel(
      fields[0] as String,
      fields[1] as String,
      (fields[2] as List).cast<PaginaModel>(),
      fields[3] as int,
      paginaAtual: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LivroModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.paginas)
      ..writeByte(3)
      ..write(obj.cor)
      ..writeByte(4)
      ..write(obj.paginaAtual);
  }
}
