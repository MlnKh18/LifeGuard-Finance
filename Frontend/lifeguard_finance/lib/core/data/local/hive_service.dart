import 'package:hive_ce_flutter/hive_flutter.dart';
import 'local_keys.dart';

class HiveService {
  late Box _box;

  /// Initializes Hive database and opens the default box.
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(LocalKeys.boxName);
  }

  /// Saves any data format (e.g. Map, String, int, bool) to Hive under the specified key.
  Future<void> saveData<T>(String key, T value) async {
    await _box.put(key, value);
  }

  /// Retrieves data from Hive under the specified key.
  T? getData<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Deletes data from Hive under the specified key.
  Future<void> deleteData(String key) async {
    await _box.delete(key);
  }

  /// Clears all keys and values in the current box.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
