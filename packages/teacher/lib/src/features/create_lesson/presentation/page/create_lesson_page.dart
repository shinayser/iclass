import 'package:common/common.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';
import 'package:teacher/teacher.dart';

import '../controller/create_lesson_bloc.dart';
import '../controller/create_lesson_state.dart';

class CreateLessonPage extends StatefulWidget {
  const CreateLessonPage({super.key});

  @override
  State<CreateLessonPage> createState() => _CreateLessonPageState();
}

class _CreateLessonPageState extends State<CreateLessonPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateLessonBloc>(
      create: (_) => Injection.get<CreateLessonBloc>(),
      child: BlocConsumer<CreateLessonBloc, CreateLessonState>(
        listener: (context, state) {
          if (state is CreateLessonDoneState) {
            context.pop();
          }
          if (state is CreateLessonErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: .floating,
                content: Text(state.errorMessage),
              ),
            );
          }
        },
        buildWhen: (_, current) => current is! CreateLessonDoneState,
        builder: (context, state) {
          final exercises = switch (state) {
            CreateLessonFormState s => s.exercises,
            CreateLessonErrorState s => s.exercises,
            _ => <ExerciseFormData>[],
          };

          final imagePath = switch (state) {
            CreateLessonFormState s => s.imagePath,
            CreateLessonErrorState s => s.imagePath,
            _ => null,
          };

          return Scaffold(
            appBar: AppBar(title: const Text('Nova lição')),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Título',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Descrição (opcional)',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _ImagePickerSection(
                            imagePath: imagePath,
                            bloc: context.read<CreateLessonBloc>(),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Exercícios',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                onPressed: () => _addExercise(
                                  context.read<CreateLessonBloc>(),
                                ),
                                icon: const Icon(Icons.add_circle),
                                color: Theme.of(context).primaryColor,
                                tooltip: 'Adicionar exercício',
                              ),
                            ],
                          ),
                          const Divider(),
                          exercises.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum exercício adicionado.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: exercises.length,
                                  separatorBuilder: (_, _) => const Divider(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final exercise = exercises[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        exercise.question,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${exercise.alternatives.length} alternativas',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                        ),
                                        onPressed: () => context
                                            .read<CreateLessonBloc>()
                                            .removeExercise(index),
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                _finish(context.read<CreateLessonBloc>()),
                            child: const Text('Concluir'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addExercise(CreateLessonBloc bloc) async {
    final result = await context.push<ExerciseFormData>(
      TeacherModule.addExerciseRoute,
    );

    if (result != null) {
      bloc.addExercise(result);
    }
  }

  void _finish(CreateLessonBloc bloc) {
    bloc.conclude(
      _titleController.text,
      _descriptionController.text,
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final String? imagePath;
  final CreateLessonBloc bloc;

  const _ImagePickerSection({required this.imagePath, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto de capa (opcional)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (imagePath != null) ...[
          Stack(
            children: [
              LessonImage(
                localImagePath: imagePath,
                width: double.infinity,
                height: 180,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filled(
                  onPressed: bloc.removeImage,
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => bloc.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => bloc.pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Câmera'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
