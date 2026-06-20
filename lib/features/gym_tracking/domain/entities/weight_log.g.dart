// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightLogAdapter extends TypeAdapter<WeightLog> {
  @override
  final int typeId = 2;

  List<int> _readReps(dynamic value) {
    if (value is List) {
      return value.whereType<num>().map((rep) => rep.toInt()).toList();
    }

    if (value is int) {
      return [value];
    }

    return const [];
  }

  @override
  WeightLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightLog(
      id: fields[0] as String,
      gymId: fields[1] as String,
      exerciseId: fields[2] as String,
      weight: fields[3] as double,
      sets: fields[4] as int,
      reps: _readReps(fields[5]),
      date: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeightLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gymId)
      ..writeByte(2)
      ..write(obj.exerciseId)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
