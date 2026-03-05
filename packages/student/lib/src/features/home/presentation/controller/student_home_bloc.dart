import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:student/src/features/home/presentation/controller/student_home_state.dart';

class StudentHomeBloc extends Cubit<StudentHomeState> {
  final FetchLessons _fetchLessons;
  final LogoutUseCase _loginUseCase;
  final SyncService _syncService;

  StreamSubscription<SyncState>? _syncSub;

  StudentHomeBloc(this._fetchLessons, this._loginUseCase, this._syncService)
    : super(StudentHomeInitialState());

  Future<void> loadLessons() async {
    emit(StudentHomeLoadingState());

    try {
      var lessons = await _fetchLessons.execute();
      lessons.sort(
        (a, b) => a.answered == b.answered ? 0 : (a.answered ? 1 : -1),
      );

      emit(
        StudentHomeLoadedState(
          lessons,
          isSyncing: _syncService.currentState == SyncState.syncing,
        ),
      );

      _syncSub?.cancel();
      _syncSub = _syncService.stateStream.listen((syncState) {
        final s = state;
        if (s is StudentHomeLoadedState) {
          emit(
            StudentHomeLoadedState(
              s.lessons,
              isSyncing: syncState == SyncState.syncing,
            ),
          );
        }
      });
    } catch (_) {
      emit(StudentHomeErrorState('Erro ao carregar lições'));
    }
  }

  Future<void> logout() async {
    await _loginUseCase.logout('', '');
    emit(StudentHomeLoggedOutState());
  }

  @override
  Future<void> close() {
    _syncSub?.cancel();
    return super.close();
  }
}
