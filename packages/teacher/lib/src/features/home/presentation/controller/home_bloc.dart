import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:teacher/src/features/home/presentation/controller/home_state.dart';

class HomeBloc extends Cubit<HomeState> {
  final FetchLessons _fetchLessons;
  final LogoutUseCase _loginUseCase;
  final SyncService _syncService;

  StreamSubscription<SyncState>? _syncSub;

  HomeBloc(this._fetchLessons, this._loginUseCase, this._syncService)
    : super(HomeInitialState());

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
