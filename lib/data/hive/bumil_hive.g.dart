// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bumil_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BumilHiveAdapter extends TypeAdapter<BumilHive> {
  @override
  final int typeId = 0;

  @override
  BumilHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BumilHive(
      namaIbu: fields[0] as String,
      namaSuami: fields[1] as String,
      alamat: fields[2] as String,
      noHp: fields[3] as String,
      agamaIbu: fields[4] as String,
      agamaSuami: fields[5] as String,
      bloodIbu: fields[6] as String,
      bloodSuami: fields[7] as String,
      jobIbu: fields[8] as String,
      jobSuami: fields[9] as String,
      nikIbu: fields[10] as String,
      nikSuami: fields[11] as String,
      kkIbu: fields[12] as String,
      kkSuami: fields[13] as String,
      pendidikanIbu: fields[14] as String,
      pendidikanSuami: fields[15] as String,
      birthdateIbu: fields[16] as DateTime,
      birthdateSuami: fields[17] as DateTime,
      idBidan: fields[18] as String,
      createdAt: fields[19] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BumilHive obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.namaIbu)
      ..writeByte(1)
      ..write(obj.namaSuami)
      ..writeByte(2)
      ..write(obj.alamat)
      ..writeByte(3)
      ..write(obj.noHp)
      ..writeByte(4)
      ..write(obj.agamaIbu)
      ..writeByte(5)
      ..write(obj.agamaSuami)
      ..writeByte(6)
      ..write(obj.bloodIbu)
      ..writeByte(7)
      ..write(obj.bloodSuami)
      ..writeByte(8)
      ..write(obj.jobIbu)
      ..writeByte(9)
      ..write(obj.jobSuami)
      ..writeByte(10)
      ..write(obj.nikIbu)
      ..writeByte(11)
      ..write(obj.nikSuami)
      ..writeByte(12)
      ..write(obj.kkIbu)
      ..writeByte(13)
      ..write(obj.kkSuami)
      ..writeByte(14)
      ..write(obj.pendidikanIbu)
      ..writeByte(15)
      ..write(obj.pendidikanSuami)
      ..writeByte(16)
      ..write(obj.birthdateIbu)
      ..writeByte(17)
      ..write(obj.birthdateSuami)
      ..writeByte(18)
      ..write(obj.idBidan)
      ..writeByte(19)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BumilHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
