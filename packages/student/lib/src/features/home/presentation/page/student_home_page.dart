import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student/student.dart';

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
            Navigator.of(context).pushReplacementNamed(CommonRoutes.login);
          }
        },
        buildWhen: (_, current) => current is! StudentHomeLoggedOutState,
        builder: (context, state) {
          final isSyncing = state is StudentHomeLoadedState && state.isSyncing;

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
                  onPressed: () => context.read<StudentHomeBloc>().logout(),
                  icon: Icon(Icons.logout),
                ),
              ],
              title: Center(child: Text('iClass')),
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
      return const Center(child: CircularProgressIndicator.adaptive());
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
        return Center(
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
              leading: lesson.answered
                  ? CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
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
                  : () {
                      Navigator.pushNamed(
                        context,
                        StudentModule.answerLessonRoute,
                        arguments: lesson,
                      ).then(
                        (value) {
                          if (context.mounted) {
                            context.read<StudentHomeBloc>().loadLessons();
                          }
                        },
                      );
                    },
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
