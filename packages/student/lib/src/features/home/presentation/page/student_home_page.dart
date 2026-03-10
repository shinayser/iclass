import 'package:common/common.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controller/student_home_bloc.dart';
import '../controller/student_home_state.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StudentHomeBloc>(
      create: (_) => Injection.get<StudentHomeBloc>()..loadLessons(),
      child: BlocConsumer<StudentHomeBloc, StudentHomeState>(
        listener: (context, state) {
          if (state is StudentHomeLoggedOutState) {
            context.go(CommonRoutes.login);
          }
        },
        buildWhen: (_, current) => current is! StudentHomeLoggedOutState,
        builder: (context, state) {
          final isSyncing = state is StudentHomeLoadedState && state.isSyncing;

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
                  onPressed: () => context.read<StudentHomeBloc>().logout(),
                  icon: Icon(Icons.logout),
                ),
              ],
              title: Center(
                child: ListTile(
                  title: Text('iClass'),
                  subtitle: Text('Área do aluno'),
                ),
              ),
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

  Widget _buildBody(BuildContext context, StudentHomeState state) {
    if (state is StudentHomeLoadingState || state is StudentHomeInitialState) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      );
    }

    if (state is StudentHomeErrorState) {
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

    if (state is StudentHomeLoadedState) {
      final lessons = state.lessons;

      if (lessons.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => context.read<StudentHomeBloc>().loadLessons(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nenhuma lição disponível no momento.',
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
        onRefresh: () => context.read<StudentHomeBloc>().loadLessons(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final hasImage = lesson.imageUrl != null ||
                lesson.localImagePath != null;

            return Card(
              child: ListTile(
                leading: lesson.answered
                    ? hasImage
                        ? _AnsweredImageLeading(
                            imageUrl: lesson.imageUrl,
                            localImagePath: lesson.localImagePath,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          )
                    : hasImage
                        ? LessonImage(
                            imageUrl: lesson.imageUrl,
                            localImagePath: lesson.localImagePath,
                            width: 48,
                            height: 48,
                          )
                        : CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                title: Text(lesson.name),
                subtitle: Text(
                  '${lesson.exercises.length} exercício(s)',
                ),
                trailing: lesson.answered
                    ? null
                    : lesson.syncStatus == SyncStatus.pending
                    ? const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.orange,
                        size: 18,
                      )
                    : const Icon(Icons.chevron_right),
                onTap: lesson.answered
                    ? null
                    : () async {
                        final route = '/student/home/lesson/${lesson.id}/answer';
                        await context.push(route);
                        if (context.mounted) {
                          context.read<StudentHomeBloc>().loadLessons();
                        }
                      },
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _AnsweredImageLeading extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;

  const _AnsweredImageLeading({this.imageUrl, this.localImagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        LessonImage(
          imageUrl: imageUrl,
          localImagePath: localImagePath,
          width: 48,
          height: 48,
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }
}
