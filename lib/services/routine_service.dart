import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serieperfecta/models/routine.dart';
import 'package:uuid/uuid.dart';

class RoutineService extends ChangeNotifier {
  static const String _routineBoxName =
      'routines';
  late Box<Routine> _routineBox;
  final Uuid _uuid = const Uuid();

  RoutineService() {
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_routineBoxName)) {
      _routineBox = await Hive.openBox<Routine>(_routineBoxName);
    } else {
      _routineBox = Hive.box<Routine>(_routineBoxName);
    }
    notifyListeners();
  }

  List<Routine> get routines {
    if (!Hive.isBoxOpen(_routineBoxName)) {
      return [];
    }
    return _routineBox.values.toList();
  }

  Future<void> saveRoutine(Routine routine) async {
    if (!Hive.isBoxOpen(_routineBoxName)) {
      await _initHive();
    }

    if (routine.id == null || routine.id!.isEmpty) {
      final newRoutine = routine.copyWith(id: _uuid.v4());
      await _routineBox.put(newRoutine.id, newRoutine);
    } else {
      await _routineBox.put(routine.id, routine);
    }
    notifyListeners();
  }

  Future<void> deleteRoutine(String? id) async {
    if (id == null || id.isEmpty)
      return;

    if (!Hive.isBoxOpen(_routineBoxName)) {
      await _initHive();
    }
    await _routineBox.delete(id);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
