import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:teacher/src/features/home/presentation/controller/home_state.dart';

class HomeBloc extends Cubit<HomeState> {
  final FetchLessons _fetchLessons;

  HomeBloc(this._fetchLessons) : super(HomeInitialState());

  Future<void> loadLessons() async {
    emit(HomeLoadingState());

    try {
      final lessons = await _fetchLessons.execute();
      emit(HomeLoadedState(lessons));
    } catch (e) {
      emit(HomeErrorState('Erro ao carregar lições'));
    }
  }
}
