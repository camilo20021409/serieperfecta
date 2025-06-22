// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_interval.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutIntervalAdapter extends TypeAdapter<WorkoutInterval> {
  @override
  final int typeId = 1;

  @override
  WorkoutInterval read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutInterval(
      id: fields[0] as String,
      activityDurationSeconds: fields[1] as int,
      restDurationSeconds: fields[2] as int,
      repetitions: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutInterval obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.activityDurationSeconds)
      ..writeByte(2)
      ..write(obj.restDurationSeconds)
      ..writeByte(3)
      ..write(obj.repetitions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutIntervalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
