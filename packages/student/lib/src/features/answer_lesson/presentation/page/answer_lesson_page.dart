import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/answer_lesson_bloc.dart';
import '../controller/answer_lesson_state.dart';

class AnswerLessonPage extends StatefulWidget {
  final Lesson lesson;

  const AnswerLessonPage({super.key, required this.lesson});

  @override
  State<AnswerLessonPage> createState() => _AnswerLessonPageState();
}

class _AnswerLessonPageState extends State<AnswerLessonPage> {
  late final List<List<String>> _shuffledAlternatives;

  @override
  void initState() {
    super.initState();
    _shuffledAlternatives = widget.lesson.exercises.map((exercise) {
      final alternatives = [
        exercise.correctAnswer,
        ...exercise.wrongAnswers,
      ]..shuffle();
      return alternatives;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnswerLessonBloc>(
      create: (_) => Injection.get()..init(widget.lesson),
      child: BlocConsumer<AnswerLessonBloc, AnswerLessonState>(
        listener: (context, state) {
          if (state is AnswerLessonDoneState) {
            Navigator.of(context).pop();
          }
          if (state is AnswerLessonErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        buildWhen: (_, current) => current is! AnswerLessonDoneState,
        builder: (context, state) {
          final selectedAnswers = switch (state) {
            AnswerLessonFormState s => s.selectedAnswers,
            AnswerLessonErrorState s => s.selectedAnswers,
            _ => <int, String>{},
          };

          final bloc = context.read<AnswerLessonBloc>();
          final exercises = widget.lesson.exercises;

          return Scaffold(
            appBar: AppBar(title: Text(widget.lesson.name)),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: exercises.length,
                      itemBuilder: (context, exerciseIndex) {
                        final exercise = exercises[exerciseIndex];
                        final alternatives =
                            _shuffledAlternatives[exerciseIndex];
                        final selected = selectedAnswers[exerciseIndex];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Questão ${exerciseIndex + 1}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  exercise.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: alternatives.map((alt) {
                                    return ListTile(
                                      leading: Radio<String>(
                                        value: alt,
                                        groupValue: selected,
                                        onChanged: (value) {
                                          if (value != null) {
                                            bloc.selectAnswer(
                                              exerciseIndex,
                                              value,
                                            );
                                          }
                                        },
                                      ),
                                      title: Text(alt),
                                      onTap: () =>
                                          bloc.selectAnswer(exerciseIndex, alt),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: bloc.conclude,
                        child: const Text('Concluir Lição'),
                      ),
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
