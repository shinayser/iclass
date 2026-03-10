import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:teacher/teacher.dart';

import '../controller/home_bloc.dart';
import '../controller/home_state.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeacherHomeBloc>(
      create: (_) => Injection.get<TeacherHomeBloc>()..loadLessons(),
      child: BlocConsumer<TeacherHomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoggedOutState) {
            context.go(CommonRoutes.login);
          }
        },
        buildWhen: (_, current) => current is! HomeLoggedOutState,
        builder: (context, state) {
          final isSyncing = state is HomeLoadedState && state.isSyncing;

          return Scaffold(
            appBar: AppBar(
              actions: [
                if (isSyncing)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Sincronizando…',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  onPressed: () => context.read<TeacherHomeBloc>().logout(),
                  icon: Icon(Icons.logout),
                ),
              ],
              title: Center(
                child: ListTile(
                  title: Text('iClass'),
                  subtitle: Text('Área do professor'),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await context.push(TeacherModule.createLessonRoute);
                if (context.mounted) {
                  context.read<TeacherHomeBloc>().refresh();
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
              child: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoadingState || state is HomeInitialState) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }

    if (state is HomeErrorState) {
      return RefreshIndicator(
        onRefresh: () => context.read<TeacherHomeBloc>().refresh(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (state is HomeLoadedState) {
      final lessons = state.lessons;

      if (lessons.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => context.read<TeacherHomeBloc>().refresh(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: Center(
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
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<TeacherHomeBloc>().refresh(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${lesson.id}')),
                title: Text(lesson.name),
                subtitle: Text(
                  '${lesson.exercises.length} exercício(s)',
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
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareLesson(context, lesson),
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
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _shareLesson(BuildContext context, Lesson lesson) async {
    final url = 'https://iclass.com.br/student/home/lesson/${lesson.id}/answer';
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copiado para a área de transferência'),
          behavior: .floating,
        ),
      );
    } else {
      await Share.share(url);
    }
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
              context.read<TeacherHomeBloc>().deleteLesson(lesson.id);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }
}
