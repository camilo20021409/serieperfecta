import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'workout_interval.g.dart';

const _uuid = Uuid();

@HiveType(
  typeId: 1,
)
class WorkoutInterval extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int activityDurationSeconds;
  @HiveField(2)
  final int restDurationSeconds;
  @HiveField(3)
  final int repetitions;

  WorkoutInterval({
    required this.id,
    required this.activityDurationSeconds,
    required this.restDurationSeconds,
    required this.repetitions,
  });

  factory WorkoutInterval.fromMap(Map<String, dynamic> map) {
    return WorkoutInterval(
      id: map['id'] as String,
      activityDurationSeconds: map['activityDurationSeconds'] as int,
      restDurationSeconds: map['restDurationSeconds'] as int,
      repetitions: map['repetitions'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityDurationSeconds': activityDurationSeconds,
      'restDurationSeconds': restDurationSeconds,
      'repetitions': repetitions,
    };
  }

  WorkoutInterval copyWith({
    String? id,
    int? activityDurationSeconds,
    int? restDurationSeconds,
    int? repetitions,
  }) {
    return WorkoutInterval(
      id: id ?? this.id,
      activityDurationSeconds:
          activityDurationSeconds ?? this.activityDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      repetitions: repetitions ?? this.repetitions,
    );
  }
}
