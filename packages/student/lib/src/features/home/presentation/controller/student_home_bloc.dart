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
      final lessons = await _fetchLessons.execute();
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
