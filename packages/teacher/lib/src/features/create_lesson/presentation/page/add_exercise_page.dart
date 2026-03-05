import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/add_exercise_bloc.dart';
import '../controller/add_exercise_state.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  static const kMinimumAmountOfAlternatives = 3;

  final _questionController = TextEditingController();
  final List<TextEditingController> _alternativeControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _alternativeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(int targetCount) {
    while (_alternativeControllers.length < targetCount) {
      _alternativeControllers.add(TextEditingController());
    }
    while (_alternativeControllers.length > targetCount) {
      _alternativeControllers.removeLast().dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddExerciseBloc>(
      create: (_) => Injection.get<AddExerciseBloc>(),
      child: BlocConsumer<AddExerciseBloc, AddExerciseState>(
        listener: (context, state) {
          if (state is AddExerciseDoneState) {
            Navigator.of(context).pop(state.form);
          }
          if (state is AddExerciseErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                ),
                behavior: .floating,
              ),
            );
          }
        },
        buildWhen: (_, current) => current is! AddExerciseDoneState,
        builder: (context, state) {
          final alternativeCount = switch (state) {
            AddExerciseFormState s => s.alternativeCount,
            AddExerciseErrorState s => s.alternativeCount,
            _ => kMinimumAmountOfAlternatives,
          };
          final correctIndex = switch (state) {
            AddExerciseFormState s => s.correctIndex,
            AddExerciseErrorState s => s.correctIndex,
            _ => null,
          };

          _syncControllers(alternativeCount);

          final bloc = context.read<AddExerciseBloc>();

          return Scaffold(
            appBar: AppBar(title: const Text('Adicionar Exercício')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(labelText: 'Questão'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alternativas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (alternativeCount < 5)
                        IconButton(
                          onPressed: bloc.addAlternative,
                          icon: const Icon(Icons.add_circle),
                          color: Theme.of(context).primaryColor,
                          tooltip: 'Adicionar alternativa',
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<int>(
                    groupValue: correctIndex ?? -1,
                    onChanged: (v) {
                      if (v != null) bloc.selectCorrectAnswer(v);
                    },
                    child: Column(
                      children: List.generate(alternativeCount, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Radio<int>(value: index),
                              Expanded(
                                child: TextFormField(
                                  controller: _alternativeControllers[index],
                                  decoration: InputDecoration(
                                    labelText:
                                        'Alternativa ${String.fromCharCode(65 + index)}',
                                  ),
                                ),
                              ),
                              if (alternativeCount >
                                  kMinimumAmountOfAlternatives)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      bloc.removeAlternative(index),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    child: const Text('Adicionar'),
                    onPressed: () => bloc.save(
                      _questionController.text,
                      _alternativeControllers.map((c) => c.text).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
