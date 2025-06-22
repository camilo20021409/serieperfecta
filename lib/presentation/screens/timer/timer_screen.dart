import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serieperfecta/models/routine.dart';
import 'package:serieperfecta/providers/timer_provider.dart';

class TimerScreen extends StatefulWidget {
  final Routine routine;

  const TimerScreen({super.key, required this.routine});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimerProvider>(
        context,
        listen: false,
      ).startRoutine(widget.routine);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getPhaseBackgroundColor(TimerPhase phase, ColorScheme colorScheme) {
    switch (phase) {
      case TimerPhase.preparation:
        return Colors.blueGrey.shade800;
      case TimerPhase.activity:
        return Colors.green.shade800;
      case TimerPhase.rest:
        return Colors.deepOrange.shade800;
      case TimerPhase.finished:
        return colorScheme.primary;
      case TimerPhase.setup:
      default:
        return colorScheme.surface;
    }
  }

  Color _getPhaseForegroundColor(TimerPhase phase, ColorScheme colorScheme) {
    return Colors.white;
  }

  String _getPhaseMessage(TimerProvider timerProvider) {
    switch (timerProvider.currentPhase) {
      case TimerPhase.preparation:
        return 'PREPÁRATE';
      case TimerPhase.activity:
        return '¡ACTIVO!';
      case TimerPhase.rest:
        return 'DESCANSO';
      case TimerPhase.finished:
        return '¡RUTINA TERMINADA!';
      case TimerPhase.setup:
      default:
        return 'INICIANDO...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final currentRoutine = timerProvider.currentRoutine ?? widget.routine;
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final bool isFinished =
            timerProvider.currentPhase == TimerPhase.finished;

        double progressValue =
            (timerProvider.totalPhaseDuration > 0 && !isFinished)
            ? (timerProvider.totalPhaseDuration - timerProvider.timeRemaining) /
                  timerProvider.totalPhaseDuration
            : 0.0;

        return Scaffold(
          backgroundColor: _getPhaseBackgroundColor(
            timerProvider.currentPhase,
            colorScheme,
          ),
          appBar: AppBar(
            title: Text(
              currentRoutine.name,
              style: TextStyle(
                color: _getPhaseForegroundColor(
                  timerProvider.currentPhase,
                  colorScheme,
                ),
              ),
            ),
            backgroundColor: _getPhaseBackgroundColor(
              timerProvider.currentPhase,
              colorScheme,
            ),
            foregroundColor: _getPhaseForegroundColor(
              timerProvider.currentPhase,
              colorScheme,
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                timerProvider.resetTimer();
                Navigator.pop(context);
              },
            ),
          ),
          body: WillPopScope(
            onWillPop: () async {
              timerProvider.resetTimer();
              return true;
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _getPhaseMessage(timerProvider),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: _getPhaseForegroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 60),

     
                    Center(
                      child: Column(
                        children: [

                          SizedBox(
                            width:
                                120,
                            height: 120,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: _animationController.value,
                                end: progressValue.isNaN ? 0.0 : progressValue,
                              ),
                              duration: const Duration(milliseconds: 950),
                              builder: (context, value, child) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth:
                                      10,
                                  backgroundColor: _getPhaseForegroundColor(
                                    timerProvider.currentPhase,
                                    colorScheme,
                                  ).withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    timerProvider.currentPhase ==
                                            TimerPhase.activity
                                        ? Colors.greenAccent
                                        : timerProvider.currentPhase ==
                                              TimerPhase.rest
                                        ? Colors.orangeAccent
                                        : Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          Text(
                            _formatTime(timerProvider.timeRemaining),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 100,
                                  color: _getPhaseForegroundColor(
                                    timerProvider.currentPhase,
                                    colorScheme,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (!isFinished &&
                        currentRoutine.intervals.isNotEmpty &&
                        timerProvider.currentPhase != TimerPhase.setup &&
                        timerProvider.currentPhase != TimerPhase.preparation)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                        ),
                        child: Text(
                          'INTERVALO ${timerProvider.currentIntervalIndex + 1} / ${currentRoutine.intervals.length} | REPETICIÓN ${timerProvider.currentRepetition} / ${currentRoutine.intervals[timerProvider.currentIntervalIndex].repetitions}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: _getPhaseForegroundColor(
                                  timerProvider.currentPhase,
                                  colorScheme,
                                ).withOpacity(0.7),
                                fontSize: 16,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const Spacer(),

                    if (!isFinished)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlCircleButton(
                            context,
                            icon: Icons.refresh,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Reiniciar Rutina'),
                                  content: const Text(
                                    '¿Estás seguro de que quieres reiniciar la rutina?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        timerProvider.resetTimer();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Reiniciar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            backgroundColor: _getPhaseForegroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ).withOpacity(0.2),
                            iconColor: _getPhaseForegroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ),
                            size: 60,
                          ),
                          _buildControlCircleButton(
                            context,
                            icon: timerProvider.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            onPressed: () {
                              if (timerProvider.currentPhase ==
                                  TimerPhase.setup)
                                return;
                              timerProvider.isRunning
                                  ? timerProvider.pauseTimer()
                                  : timerProvider.resumeTimer();
                            },
                            backgroundColor: _getPhaseForegroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ),
                            iconColor: _getPhaseBackgroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ),
                            size: 80,
                          ),
                          _buildControlCircleButton(
                            context,
                            icon: Icons.skip_next,
                            onPressed: () {
                              if (timerProvider.currentPhase ==
                                  TimerPhase.setup)
                                return;
                              timerProvider.skipToNextPhase();
                            },
                            backgroundColor: _getPhaseForegroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ).withOpacity(0.2),
                            iconColor: _getPhaseForegroundColor(
                              timerProvider.currentPhase,
                              colorScheme,
                            ),
                            size: 60,
                          ),
                        ],
                      ),
                    if (isFinished)
                      ElevatedButton.icon(
                        onPressed: () {
                          timerProvider.resetTimer();
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Rutina Completada - Volver',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlCircleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Icon(icon, size: size * 0.5, color: iconColor),
      ),
    );
  }
}
