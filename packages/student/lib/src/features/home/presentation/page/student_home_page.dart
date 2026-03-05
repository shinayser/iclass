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
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () => context.read<StudentHomeBloc>().logout(),
                  icon: Icon(Icons.logout),
                ),
              ],
              title: Center(child: Text('iClass')),
            ),
            body: _buildBody(context, state),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Nenhuma lição disponível no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
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
          return ListTile(
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
            trailing: lesson.answered ? null : const Icon(Icons.chevron_right),
            onTap: lesson.answered
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      StudentModule.answerLessonRoute,
                      arguments: lesson,
                    );
                  },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
