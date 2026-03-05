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
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(onPressed: () {}, icon: Icon(Icons.logout)),
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
            body: _buildBody(state),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Nenhuma lição cadastrada.\nToque no botão para criar uma nova lição.',
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
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(lesson.name),
            subtitle: Text(
              '${lesson.exercises.length} exerc\u00edcio(s)',
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
