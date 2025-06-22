import 'package:hive/hive.dart';
import 'package:serieperfecta/models/workout_interval.dart';
part 'routine.g.dart';

@HiveType(typeId: 0)
class Routine extends HiveObject {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int preparationDurationSeconds;
  @HiveField(3)
  final List<WorkoutInterval> intervals;

  Routine({
    this.id,
    required this.name,
    required this.preparationDurationSeconds,
    required this.intervals,
  });

  Routine copyWith({
    String? id,
    String? name,
    int? preparationDurationSeconds,
    List<WorkoutInterval>? intervals,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      preparationDurationSeconds:
          preparationDurationSeconds ?? this.preparationDurationSeconds,
      intervals: intervals ?? this.intervals,
    );
  }

  int calculateTotalDuration() {
    int totalDuration =
        preparationDurationSeconds;
    for (var interval in intervals) {
      totalDuration +=
          (interval.activityDurationSeconds + interval.restDurationSeconds) *
          interval.repetitions;
    }
    return totalDuration;
  }

}
