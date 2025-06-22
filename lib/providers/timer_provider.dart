// lib/providers/timer_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serieperfecta/models/routine.dart';
import 'package:serieperfecta/models/workout_interval.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';


enum TimerPhase {
  setup,
  preparation,
  activity,
  rest,
  finished,
}

class TimerProvider extends ChangeNotifier {
  Routine? _currentRoutine;
  Timer? _timer;
  int _currentIntervalIndex = 0;
  int _currentRepetition = 1;
  int _timeRemaining = 0;
  TimerPhase _currentPhase = TimerPhase.setup;
  bool _isRunning = false;
  int _totalPhaseDuration =
      1;

  late AudioPlayer _bipPlayer;
  late AudioPlayer _warningPlayer;
  late AudioPlayer _dingPlayer;
  late AudioPlayer _shortBeepPlayer;

  Routine? get currentRoutine => _currentRoutine;
  int get currentIntervalIndex => _currentIntervalIndex;
  int get currentRepetition => _currentRepetition;
  int get timeRemaining => _timeRemaining;
  TimerPhase get currentPhase => _currentPhase;
  bool get isRunning => _isRunning;

  int get totalPhaseDuration => _totalPhaseDuration; 


  TimerProvider(this._currentRoutine) {
    _bipPlayer = AudioPlayer();
    _warningPlayer = AudioPlayer();
    _dingPlayer = AudioPlayer();
    _shortBeepPlayer = AudioPlayer();
    _loadAllSounds();
  }

  Future<void> _loadAllSounds() async {
    try {
      await _bipPlayer.setAsset('assets/sounds/bip.mp3');
      await _warningPlayer.setAsset('assets/sounds/warning.mp3');
      await _dingPlayer.setAsset('assets/sounds/ding.mp3');
      await _shortBeepPlayer.setAsset('assets/sounds/short_beep.mp3');
    } catch (e) {
      debugPrint("ERROR: Error al pre-cargar sonidos: $e");
    }
  }

  void _playBipSound({bool vibrate = true}) async {
    try {
      _bipPlayer.seek(Duration.zero);
      await _bipPlayer.play();
      if (vibrate && await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      debugPrint("ERROR: Error al reproducir sonido Bip: $e");
    }
  }

  void _playWarningSound({bool vibrate = true}) async {
    try {
      _warningPlayer.seek(Duration.zero);
      await _warningPlayer.play();
      if (vibrate && await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      debugPrint("ERROR: Error al reproducir sonido Warning: $e");
    }
  }

  void _playDingSound({bool vibrate = true}) async {
    try {
      _dingPlayer.seek(Duration.zero);
      await _dingPlayer.play();
      if (vibrate && await Vibration.hasCustomVibrationsSupport() == true) {
        Vibration.vibrate(duration: 500);
      }
    } catch (e) {
      debugPrint("ERROR: Error al reproducir sonido Ding: $e");
    }
  }

  void _playShortBeepSound() async {
    try {
      _shortBeepPlayer.seek(Duration.zero);
      await _shortBeepPlayer.play();
    } catch (e) {
      debugPrint("ERROR: Error al reproducir sonido Short Beep: $e");
    }
  }

  void _stopAllTransitionSounds() {
    _bipPlayer.stop();
    _warningPlayer.stop();
    _shortBeepPlayer.stop();
  }

  void _playAnticipationSound() {
    if (_currentRoutine == null) return;

    switch (_currentPhase) {
      case TimerPhase.preparation:
      case TimerPhase.rest:
        _playBipSound();
        break;
      case TimerPhase.activity:
        final currentInterval =
            _currentRoutine!.intervals[_currentIntervalIndex];
        if (currentInterval.restDurationSeconds > 0) {
          _playWarningSound();
        }
        break;
      case TimerPhase.finished:
      case TimerPhase.setup:
        break;
    }
  }


  void startRoutine(Routine routine) {
    if (_isRunning) return;

    _currentRoutine = routine;
    _currentIntervalIndex = 0;
    _currentRepetition = 1;
    _isRunning = true;


    if (routine.preparationDurationSeconds > 0) {
      _currentPhase = TimerPhase.preparation;
      _timeRemaining = routine.preparationDurationSeconds;
      _totalPhaseDuration = routine.preparationDurationSeconds;
    } else {

      if (routine.intervals.isNotEmpty) {
        _currentPhase = TimerPhase.activity;
        _timeRemaining = routine.intervals.first.activityDurationSeconds;
        _totalPhaseDuration = _timeRemaining;
      } else {
        _finishRoutine();
        return;
      }
    }

    _startTimer();
    notifyListeners();
  }

  void pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    _stopAllTransitionSounds();
    notifyListeners();
  }

  void resumeTimer() {
    if (_currentRoutine == null ||
        _currentPhase == TimerPhase.finished ||
        _isRunning)
      return;
    _isRunning = true;
    _startTimer();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _stopAllTransitionSounds();
    _currentRoutine = null;
    _currentIntervalIndex = 0;
    _currentRepetition = 1;
    _timeRemaining = 0;
    _currentPhase = TimerPhase.setup;
    _isRunning = false;
    _totalPhaseDuration = 1;
    notifyListeners();
  }

  void skipToNextPhase() {
    if (_currentRoutine == null || _currentPhase == TimerPhase.finished) return;

    _timer?.cancel();
    _stopAllTransitionSounds();
    _timeRemaining = 0;

    _moveToNextPhaseLogic();
    notifyListeners();
  }


  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }


      if (_timeRemaining > 0 && _timeRemaining <= 3 && _timeRemaining > 1) {
        _playShortBeepSound();
      }

      if (_timeRemaining == 2 &&
          (_currentPhase == TimerPhase.preparation ||
              _currentPhase == TimerPhase.activity ||
              _currentPhase == TimerPhase.rest)) {
        _playAnticipationSound();
      }

      if (_timeRemaining > 0) {
        _timeRemaining--;
      } else {
        _timer?.cancel();
        _stopAllTransitionSounds();
        _moveToNextPhaseLogic();
      }
      notifyListeners();
    });
  }

  void _moveToNextPhaseLogic() {
    if (_currentRoutine == null) {
      _finishRoutine();
      return;
    }

    final int numIntervals = _currentRoutine!.intervals.length;
    WorkoutInterval? currentIntervalData =
        (numIntervals > 0 && _currentIntervalIndex < numIntervals)
        ? _currentRoutine!.intervals[_currentIntervalIndex]
        : null;

    switch (_currentPhase) {
      case TimerPhase.setup:
        if (_currentRoutine!.preparationDurationSeconds > 0) {
          _currentPhase = TimerPhase.preparation;
          _timeRemaining = _currentRoutine!.preparationDurationSeconds;
          _totalPhaseDuration = _timeRemaining;
        } else {
          if (numIntervals > 0) {
            _currentPhase = TimerPhase.activity;
            _timeRemaining = currentIntervalData!.activityDurationSeconds;
            _totalPhaseDuration = _timeRemaining;
          } else {
            _finishRoutine();
            return;
          }
        }
        break;

      case TimerPhase.preparation:
        if (numIntervals > 0) {
          _currentPhase = TimerPhase.activity;
          _timeRemaining = currentIntervalData!.activityDurationSeconds;
          _totalPhaseDuration = _timeRemaining;
        } else {
          _finishRoutine();
          return;
        }
        break;

      case TimerPhase.activity:
        if (currentIntervalData!.restDurationSeconds > 0) {
          _currentPhase = TimerPhase.rest;
          _timeRemaining = currentIntervalData.restDurationSeconds;
          _totalPhaseDuration = _timeRemaining;
        } else {
          _currentRepetition++;
          if (_currentRepetition > currentIntervalData.repetitions) {
            _currentIntervalIndex++;
            _currentRepetition = 1;
            if (_currentIntervalIndex >= numIntervals) {
              _finishRoutine();
              return;
            }
            currentIntervalData =
                _currentRoutine!.intervals[_currentIntervalIndex];
            _currentPhase = TimerPhase.activity;
            _timeRemaining = currentIntervalData.activityDurationSeconds;
            _totalPhaseDuration = _timeRemaining;
          } else {
            _currentPhase = TimerPhase.activity;
            _timeRemaining = currentIntervalData.activityDurationSeconds;
            _totalPhaseDuration = _timeRemaining;
          }
        }
        break;

      case TimerPhase.rest:
        _currentRepetition++;
        if (_currentRepetition > currentIntervalData!.repetitions) {
          _currentIntervalIndex++;
          _currentRepetition = 1;
          if (_currentIntervalIndex >= numIntervals) {
            _finishRoutine();
            return;
          }
          currentIntervalData =
              _currentRoutine!.intervals[_currentIntervalIndex];
          _currentPhase = TimerPhase.activity;
          _timeRemaining = currentIntervalData.activityDurationSeconds;
          _totalPhaseDuration = _timeRemaining;
        } else {
          _currentPhase = TimerPhase.activity;
          _timeRemaining = currentIntervalData.activityDurationSeconds;
          _totalPhaseDuration = _timeRemaining;
        }
        break;

      case TimerPhase.finished:
        return;
    }


    if (_timeRemaining == 0 && _currentPhase != TimerPhase.finished) {
      _moveToNextPhaseLogic();
      return;
    }

    if (_isRunning) {
      _startTimer();
    }
  }

  void _finishRoutine() {
    _timer?.cancel();
    _stopAllTransitionSounds();
    _currentPhase = TimerPhase.finished;
    _isRunning = false;
    _timeRemaining = 0;
    _playDingSound();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bipPlayer.dispose();
    _warningPlayer.dispose();
    _dingPlayer.dispose();
    _shortBeepPlayer.dispose();
    super.dispose();
  }
}
