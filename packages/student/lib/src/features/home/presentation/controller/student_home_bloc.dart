import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:student/src/features/home/presentation/controller/student_home_state.dart';

class StudentHomeBloc extends Cubit<StudentHomeState> {
  final FetchLessons _fetchLessons;
  final LogoutUseCase _loginUseCase;

  StudentHomeBloc(this._fetchLessons, this._loginUseCase)
    : super(StudentHomeInitialState());

  Future<void> loadLessons() async {
    emit(StudentHomeLoadingState());

    try {
      var lessons = await _fetchLessons.execute();
      lessons.sort(
        (a, b) => a.answered == b.answered ? 0 : (a.answered ? 1 : -1),
      );
      emit(StudentHomeLoadedState(lessons));
    } catch (_) {
      emit(StudentHomeErrorState('Erro ao carregar lições'));
    }
  }

  Future<void> logout() async {
    await _loginUseCase.logout('', '');
    emit(StudentHomeLoggedOutState());
  }
}
