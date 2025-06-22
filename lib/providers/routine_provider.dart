import 'package:flutter/material.dart';
import 'package:serieperfecta/models/routine.dart';

class RoutineProvider extends ChangeNotifier {
  final List<Routine> _routines = [];


  List<Routine> get routines => _routines;

  RoutineProvider() {
  }

  void addRoutine(Routine newRoutine) {
    _routines.add(newRoutine);
    notifyListeners();
  }

  void updateRoutine(Routine updatedRoutine) {
    final index = _routines.indexWhere((r) => r.id == updatedRoutine.id);
    if (index != -1) {
      _routines[index] = updatedRoutine;

      notifyListeners();
    }
  }

  void deleteRoutine(String routineId) {
    _routines.removeWhere((r) => r.id == routineId);
    notifyListeners();
  }
}
