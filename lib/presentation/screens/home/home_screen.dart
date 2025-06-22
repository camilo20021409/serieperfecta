import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serieperfecta/presentation/screens/settings/settings_screen.dart';
import 'package:serieperfecta/providers/timer_provider.dart';
import 'package:serieperfecta/services/routine_service.dart';
import 'package:serieperfecta/presentation/screens/timer/timer_screen.dart';
import 'package:serieperfecta/presentation/screens/routines/routine_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds seg';
    } else {
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '$minutes min ${seconds > 0 ? '$seconds seg' : ''}'.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: Consumer<RoutineService>(
        builder: (context, routineService, child) {
          final routines = routineService.routines;

          if (routines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aún no tienes rutinas.\n¡Pulsa el botón "+" para crear tu primera rutina de entrenamiento!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              int totalRoutineDuration = routine.preparationDurationSeconds;
              for (var interval in routine.intervals) {
                totalRoutineDuration +=
                    (interval.activityDurationSeconds +
                        interval.restDurationSeconds) *
                    interval.repetitions;
              }

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                routine.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.play_circle_fill,
                                size: 40,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChangeNotifierProvider(
                                        create: (_) => TimerProvider(routine),
                                        builder: (providerContext, child) {
                                          return TimerScreen(routine: routine);
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                              tooltip: 'Iniciar rutina',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${routine.intervals.length} Intervalos',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        Text(
                          'Duración total: ${_formatDuration(totalRoutineDuration)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const Divider(height: 20, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.7),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RoutineDetailScreen(routine: routine),
                                  ),
                                );
                              },
                              tooltip: 'Editar rutina',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Eliminar Rutina'),
                                    content: Text(
                                      '¿Estás seguro de que quieres eliminar "${routine.name}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(
                                            ctx,
                                          ).pop();
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          routineService.deleteRoutine(
                                            routine.id,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Rutina "${routine.name}" eliminada.',
                                              ),
                                            ),
                                          );
                                          Navigator.of(
                                            ctx,
                                          ).pop();
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltip: 'Eliminar rutina',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoutineDetailScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear nueva rutina',
      ),
    );
  }
}
