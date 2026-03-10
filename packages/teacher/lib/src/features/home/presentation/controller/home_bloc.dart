import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:teacher/src/features/home/presentation/controller/home_state.dart';

class TeacherHomeBloc extends Cubit<HomeState> {
  final FetchLessons _fetchLessons;
  final DeleteLesson _deleteLesson;
  final LogoutUseCase _loginUseCase;
  final SyncService _syncService;

  StreamSubscription<SyncState>? _syncSub;

  TeacherHomeBloc(
    this._fetchLessons,
    this._deleteLesson,
    this._loginUseCase,
    this._syncService,
  ) : super(HomeInitialState());

  Future<void> loadLessons() async {
    emit(HomeLoadingState());

    try {
      final lessons = await _fetchLessons.execute();

      emit(
        HomeLoadedState(
          lessons,
          isSyncing: _syncService.currentState == SyncState.syncing,
        ),
      );

      _syncSub?.cancel();
      _syncSub = _syncService.stateStream.listen((syncState) {
        final s = state;
        if (s is HomeLoadedState) {
          if (syncState != .syncing) {
            loadLessons();
          } else {
            emit(
              HomeLoadedState(
                s.lessons,
                isSyncing: syncState == SyncState.syncing,
              ),
            );
          }
        }
      });
    } catch (e) {
      emit(HomeErrorState('Erro ao carregar lições'));
    }
  }

  /// Triggers a sync of pending lessons and then reloads the list.
  Future<void> refresh() async {
    await _syncService.syncNow();
    await loadLessons();
  }

  Future<void> deleteLesson(int id) async {
    try {
      await _deleteLesson.execute(id);
      await loadLessons();
    } catch (e) {
      emit(HomeErrorState('Erro ao apagar lição'));
    }
  }

  Future<void> logout() async {
    await _loginUseCase.logout('', '');
    emit(HomeLoggedOutState());
  }

  @override
  Future<void> close() {
    _syncSub?.cancel();
    return super.close();
  }
}
