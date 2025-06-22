import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:serieperfecta/models/routine.dart';
import 'package:serieperfecta/models/workout_interval.dart';
import 'package:serieperfecta/providers/routine_provider.dart';


const uuid = Uuid();

class RoutineFormScreen extends StatefulWidget {
  final Routine? routine;

  const RoutineFormScreen({super.key, this.routine});

  @override
  State<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends State<RoutineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController
  _preparationDurationSecondsController;
  final List<WorkoutInterval> _intervals = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _preparationDurationSecondsController = TextEditingController(
      text: '10',
    );

    if (widget.routine != null) {
      _isEditing = true;
      _nameController.text = widget.routine!.name;
      _preparationDurationSecondsController.text = widget
          .routine!
          .preparationDurationSeconds
          .toString();
      _intervals.addAll(
        widget.routine!.intervals.map(
          (i) => WorkoutInterval.fromMap(i.toMap()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _preparationDurationSecondsController.dispose();
    super.dispose();
  }

  void _showIntervalDialog({
    WorkoutInterval? intervalToEdit,
    int? indexToEdit,
  }) {
    final TextEditingController activityController = TextEditingController(
      text: intervalToEdit?.activityDurationSeconds.toString() ?? '30',
    );
    final TextEditingController restController = TextEditingController(
      text: intervalToEdit?.restDurationSeconds.toString() ?? '15',
    );
    final TextEditingController repetitionsController = TextEditingController(
      text: intervalToEdit?.repetitions.toString() ?? '1',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            intervalToEdit == null ? 'Añadir Intervalo' : 'Editar Intervalo',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: activityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo de Actividad (segundos)',
                  ),
                ),
                TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo de Descanso (segundos)',
                  ),
                ),
                TextField(
                  controller: repetitionsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final activityDurationSeconds =
                    int.tryParse(activityController.text) ?? 0;
                final restDurationSeconds =
                    int.tryParse(restController.text) ?? 0;
                final repetitions =
                    int.tryParse(repetitionsController.text) ?? 0;

                if (activityDurationSeconds > 0 && repetitions > 0) {
                  final newInterval = WorkoutInterval(

                    id:
                        intervalToEdit?.id ??
                        uuid.v4(),
                    activityDurationSeconds:
                        activityDurationSeconds,
                    restDurationSeconds:
                        restDurationSeconds,
                    repetitions: repetitions,
                  );

                  setState(() {
                    if (indexToEdit != null) {
                      _intervals[indexToEdit] = newInterval;
                    } else {
                      _intervals.add(newInterval);
                    }
                  });
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, ingresa valores válidos para Actividad y Repeticiones.',
                      ),
                    ),
                  );
                }
              },
              child: Text(intervalToEdit == null ? 'Añadir' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final routineProvider = Provider.of<RoutineProvider>(
        context,
        listen: false,
      );

      final newRoutine = Routine(
        id:
            widget.routine?.id ??
            uuid.v4(),
        name: _nameController.text,
        preparationDurationSeconds:
            int.tryParse(_preparationDurationSecondsController.text) ??
            10,
        intervals: _intervals,
      );

      if (_isEditing) {
        routineProvider.updateRoutine(newRoutine);
      } else {
        routineProvider.addRoutine(newRoutine);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Rutina' : 'Crear Rutina',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Rutina',
                  hintText: 'Ej: Rutina de Fuerza Express',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre para la rutina';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              TextFormField(
                controller:
                    _preparationDurationSecondsController, 
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tiempo de Preparación (segundos)',
                  hintText: '10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 0) {
                    return 'Ingresa un número válido de segundos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              Text(
                'Intervalos:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              if (_intervals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No hay intervalos. ¡Añade uno!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _intervals.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _intervals.removeAt(oldIndex);
                    _intervals.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final interval = _intervals[index];
                  return Card(
                    key: ValueKey(
                      interval.id,
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Intervalo ${index + 1}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Actividad: ${interval.activityDurationSeconds}s | Descanso: ${interval.restDurationSeconds}s | Repeticiones: ${interval.repetitions}', // Propiedades corregidas
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 24),
                                color: Theme.of(context).colorScheme.secondary,
                                onPressed: () => _showIntervalDialog(
                                  intervalToEdit: interval,
                                  indexToEdit: index,
                                ),
                                tooltip: 'Editar Intervalo',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 24),
                                color: Colors.red.shade700,
                                onPressed: () {
                                  setState(() {
                                    _intervals.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Intervalo eliminado.'),
                                    ),
                                  );
                                },
                                tooltip: 'Eliminar Intervalo',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _showIntervalDialog,
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  label: const Text(
                    'Añadir Nuevo Intervalo',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveRoutine,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Guardar Cambios' : 'Crear Rutina',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
