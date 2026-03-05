import 'dart:async';

import 'package:common/common.dart';

enum SyncState { idle, syncing, error }

abstract interface class SyncService {
  /// Current sync state (latest value).
  SyncState get currentState;

  /// Broadcasts state changes to listeners.
  Stream<SyncState> get stateStream;

  /// Manually triggers a sync of all pending lessons.
  Future<void> syncNow();
}

class SyncServiceImpl implements SyncService {
  final LessonsRepository _repository;
  final ConnectivityService _connectivity;

  final _controller = StreamController<SyncState>.broadcast();
  SyncState _currentState = SyncState.idle;
  bool _wasOnline = false;
  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySub;

  SyncServiceImpl(this._repository, this._connectivity);

  /// Must be called once after construction (e.g. inside [CommonModule.init]).
  Future<void> init() async {
    _wasOnline = await _connectivity.isOnline();
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      (isOnline) async {
        if (isOnline && !_wasOnline) {
          // Device just reconnected — flush pending edits.
          await syncNow();
        }
        _wasOnline = isOnline;
      },
    );
  }

  @override
  SyncState get currentState => _currentState;

  @override
  Stream<SyncState> get stateStream => _controller.stream;

  @override
  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _emit(SyncState.syncing);
    try {
      await _repository.syncPending();
      _emit(SyncState.idle);
    } catch (_) {
      _emit(SyncState.error);
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _controller.close();
  }

  void _emit(SyncState state) {
    _currentState = state;
    if (!_controller.isClosed) _controller.add(state);
  }
}
