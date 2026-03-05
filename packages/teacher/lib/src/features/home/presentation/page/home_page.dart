import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher/teacher.dart';

import '../controller/home_bloc.dart';
import '../controller/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => Injection.get<HomeBloc>()..loadLessons(),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoggedOutState) {
            Navigator.of(context).pushReplacementNamed(CommonRoutes.login);
          }
        },
        buildWhen: (_, current) => current is! HomeLoggedOutState,
        builder: (context, state) {
          final isSyncing = state is HomeLoadedState && state.isSyncing;

          return Scaffold(
            appBar: AppBar(
              actions: [
                if (isSyncing)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Sincronizando…',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  onPressed: () => context.read<HomeBloc>().logout(),
                  icon: Icon(Icons.logout),
                ),
              ],
              title: Center(child: Text('iClass')),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  TeacherModule.createLessonRoute,
                );
                if (context.mounted) {
                  context.read<HomeBloc>().loadLessons();
                }
              },
              child: Icon(Icons.add),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(HomeState state) {
    if (state is HomeLoadingState || state is HomeInitialState) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state is HomeErrorState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    if (state is HomeLoadedState) {
      final lessons = state.lessons;

      if (lessons.isEmpty) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nenhuma lição cadastrada.\nToque no botão para criar uma nova lição.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(lesson.name),
              subtitle: Text(
                '${lesson.exercises.length} exerc\u00edcio(s)',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lesson.syncStatus == SyncStatus.pending)
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.orange,
                      size: 18,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, lesson),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _confirmDelete(BuildContext context, Lesson lesson) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar lição'),
        content: Text('Deseja realmente apagar a lição "${lesson.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HomeBloc>().deleteLesson(lesson.id);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }
}
