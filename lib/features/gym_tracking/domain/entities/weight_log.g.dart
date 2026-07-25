// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightLogAdapter extends TypeAdapter<WeightLog> {
  @override
  final int typeId = 2;

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
      weight: _parseDouble(fields[3]),
      sets: _parseInt(fields[4]),
      reps: _parseReps(fields[5]),
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

double _parseDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

List<int> _parseReps(dynamic repsValue) {
  if (repsValue == null) return [];
  if (repsValue is List) {
    return repsValue.map<int>((e) {
      if (e is int) return e;
      if (e is double) return e.toInt();
      if (e is String) return int.tryParse(e) ?? 0;
      return 0;
    }).toList();
  }
  if (repsValue is int) return [repsValue];
  if (repsValue is double) return [repsValue.toInt()];
  if (repsValue is String) return [int.tryParse(repsValue) ?? 0];
  return [];
}
