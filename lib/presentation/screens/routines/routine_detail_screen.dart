import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:serieperfecta/models/routine.dart';
import 'package:serieperfecta/models/workout_interval.dart';
import 'package:serieperfecta/services/routine_service.dart';

const uuid = Uuid();
class WorkoutIntervalCard extends StatelessWidget {
  final int index;
  final GlobalKey<FormState> formKey;
  final TextEditingController activityController;
  final TextEditingController restController;
  final TextEditingController repetitionsController;
  final VoidCallback onRemove;

  const WorkoutIntervalCard({
    super.key,
    required this.index,
    required this.formKey,
    required this.activityController,
    required this.restController,
    required this.repetitionsController,
    required this.onRemove,
  });

  String? _validateInt(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    final int? num = int.tryParse(value);
    if (num == null) {
      return 'Solo números enteros';
    }
    if (num < 0) {
      return 'No negativos';
    }
    return null;
  }

  String? _validateRepetitions(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    final int? num = int.tryParse(value);
    if (num == null) {
      return 'Solo números enteros';
    }
    if (num <= 0) {
      return 'Mínimo 1 repetición';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Intervalo ${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: colors.error),
                    onPressed: onRemove,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: activityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración Actividad (segundos)',
                  hintText: 'ej. 30',
                ),
                validator: _validateInt,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración Descanso (segundos)',
                  hintText: 'ej. 10',
                ),
                validator: _validateInt,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: repetitionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repeticiones de este Intervalo',
                  hintText: 'ej. 3',
                ),
                validator: _validateRepetitions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoutineDetailScreen extends StatefulWidget {
  final Routine? routine;

  const RoutineDetailScreen({super.key, this.routine});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _preparationController;

  final List<TextEditingController> _activityControllers = [];
  final List<TextEditingController> _restControllers = [];
  final List<TextEditingController> _repetitionsControllers = [];

  final List<GlobalKey<FormState>> _intervalFormKeys = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.routine?.name ?? '');
    _preparationController = TextEditingController(
      text: widget.routine?.preparationDurationSeconds.toString() ?? '5',
    );

    if (widget.routine != null) {
      for (var interval in widget.routine!.intervals) {
        _activityControllers.add(
          TextEditingController(
            text: interval.activityDurationSeconds.toString(),
          ),
        );
        _restControllers.add(
          TextEditingController(text: interval.restDurationSeconds.toString()),
        );
        _repetitionsControllers.add(
          TextEditingController(text: interval.repetitions.toString()),
        );
        _intervalFormKeys.add(GlobalKey<FormState>());
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _preparationController.dispose();
    for (var controller in _activityControllers) {
      controller.dispose();
    }
    for (var controller in _restControllers) {
      controller.dispose();
    }
    for (var controller in _repetitionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addInterval() {
    setState(() {
      _activityControllers.add(TextEditingController(text: '30'));
      _restControllers.add(TextEditingController(text: '10'));
      _repetitionsControllers.add(TextEditingController(text: '1'));
      _intervalFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeInterval(int index) {
    setState(() {
      _activityControllers[index].dispose();
      _restControllers[index].dispose();
      _repetitionsControllers[index].dispose();

      _activityControllers.removeAt(index);
      _restControllers.removeAt(index);
      _repetitionsControllers.removeAt(index);
      _intervalFormKeys.removeAt(index);
    });
  }

  void _saveRoutine() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el nombre de la rutina.'),
        ),
      );
      return;
    }
    final int? preparationDuration = int.tryParse(_preparationController.text);
    if (preparationDuration == null || preparationDuration < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un tiempo de preparación válido.'),
        ),
      );
      return;
    }

    if (_activityControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, añade al menos un intervalo a la rutina.'),
        ),
      );
      return;
    }

    bool allIntervalsValid = true;
    for (var key in _intervalFormKeys) {
      if (!(key.currentState?.validate() ?? false)) {
        allIntervalsValid = false;
        break;
      }
    }

    if (!allIntervalsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, corrige los errores en los intervalos antes de guardar.',
          ),
        ),
      );
      return;
    }

    List<WorkoutInterval> intervalsToSave = [];
    for (int i = 0; i < _activityControllers.length; i++) {
      intervalsToSave.add(
        WorkoutInterval(
          id: uuid.v4(),
          activityDurationSeconds:
              int.tryParse(_activityControllers[i].text) ?? 0,
          restDurationSeconds: int.tryParse(_restControllers[i].text) ?? 0,
          repetitions: int.tryParse(_repetitionsControllers[i].text) ?? 1,
        ),
      );
    }

    final routineService = Provider.of<RoutineService>(context, listen: false);

    final String? routineId = widget.routine?.id;

    final newRoutine = Routine(
      id: routineId,
      name: _nameController.text,
      intervals: intervalsToSave,
      preparationDurationSeconds: preparationDuration!,
    );

    routineService.saveRoutine(newRoutine);

    if (widget.routine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rutina "${_nameController.text}" creada exitosamente.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rutina "${_nameController.text}" actualizada exitosamente.',
          ),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routine == null ? 'Crear Nueva Rutina' : 'Editar Rutina',
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Rutina',
                    hintText: 'ej. HIIT Mañanero, Rutina de Brazos',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la rutina es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _preparationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo de Preparación (segundos)',
                    hintText: 'ej. 5',
                    suffixText: 'segundos',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    final int? num = int.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Ingrese un número válido (0 o más)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Intervalos de Ejercicio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: _addInterval,
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir Intervalo'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activityControllers.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final activityItem = _activityControllers.removeAt(
                        oldIndex,
                      );
                      final restItem = _restControllers.removeAt(oldIndex);
                      final repetitionsItem = _repetitionsControllers.removeAt(
                        oldIndex,
                      );
                      final keyItem = _intervalFormKeys.removeAt(oldIndex);

                      _activityControllers.insert(newIndex, activityItem);
                      _restControllers.insert(newIndex, restItem);
                      _repetitionsControllers.insert(newIndex, repetitionsItem);
                      _intervalFormKeys.insert(newIndex, keyItem);
                    });
                  },
                  itemBuilder: (context, index) {
                    return WorkoutIntervalCard(
                      key: ObjectKey(_activityControllers[index]),
                      formKey: _intervalFormKeys[index],
                      index: index,
                      activityController: _activityControllers[index],
                      restController: _restControllers[index],
                      repetitionsController: _repetitionsControllers[index],
                      onRemove: () {
                        _removeInterval(index);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: ElevatedButton(
                    onPressed: _saveRoutine,
                    child: Text(
                      widget.routine == null
                          ? 'Guardar Rutina'
                          : 'Actualizar Rutina',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
