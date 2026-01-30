import 'package:shared_preferences/shared_preferences.dart';

/// Simple wrapper around `SharedPreferences` to store / retrieve
/// the *global coin total* and upgrade‑related data.
class GamePersistence {
  static const String _coinsKey = 'global_coins';
  static const String _capacityKey = 'capacity';
  static const String _ropeLengthKey = 'rope_length';

  /// Loads persisted values; if none exist defaults are returned.
  static Future<(int coins, int capacity, int ropeLength)> load() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(_coinsKey) ?? 0;
    final capacity = prefs.getInt(_capacityKey) ?? 5;
    final ropeLength = prefs.getInt(_ropeLengthKey) ?? 5;
    return (coins, capacity, ropeLength);
  }

  /// Saves the three values back to storage.
  static Future<void> save({
    required int coins,
    required int capacity,
    required int ropeLength,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
    await prefs.setInt(_capacityKey, capacity);
    await prefs.setInt(_ropeLengthKey, ropeLength);
  }
}