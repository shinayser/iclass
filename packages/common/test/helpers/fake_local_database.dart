import 'package:common/common.dart';

/// In-memory [LocalDatabase] implementation used in unit tests.
/// Keeps state across calls, so it can be used in repository tests without
/// requiring complex mock stubbing.
class FakeLocalDatabase implements LocalDatabase {
  final _store = <String, String>{};

  @override
  Future<void> saveData(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> getData(String key) async => _store[key];

  @override
  Future<void> deleteData(String key) async => _store.remove(key);

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
