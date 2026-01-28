// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginaModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaginaModelAdapter extends TypeAdapter<PaginaModel> {
  @override
  final int typeId = 1;

  @override
  PaginaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return PaginaModel(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaginaModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.conteudoJson);
  }
}
