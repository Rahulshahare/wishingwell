import 'utils/persistence.dart';

/// Central manager that handles coin spending, upgrade logic, and persistence.
class UpgradeManager {
  int _coins = 0;
  int capacity = 5;
  int ropeLength = 5;

  // Cost constants (can be tweaked later)
  static const int _costCapacity = 50;
  static const int _costRope = 30;

  UpgradeManager() {
    // Load persisted state at start‑up
    GamePersistence.load().then((tuple) {
      _coins = tuple.coins;
      capacity = tuple.capacity;
      ropeLength = tuple.ropeLength;
    });
  }

  // ------------------- Persistence helpers -------------------
  Future<void> _persist() async => GamePersistence.save(
        coins: _coins,
        capacity: capacity,
        ropeLength: ropeLength,
      );

  // ------------------- Public API ---------------------------
  int get coins => _coins;

  void addCoins(int amount) {
    _coins += amount;
    // No immediate save – called explicitly in HUD after a run.
  }

  Future<void> saveLater() async => _persist();

  bool canUpgradeCapacity() => _coins >= _costCapacity;
  bool canUpgradeRope() => _coins >= _costRope;

  void spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
    } else {
      debugPrint('Insufficient coins for upgrade');
    }
  }

  void upgradeCapacity() {
    if (canUpgradeCapacity()) {
      spendCoins(_costCapacity);
      capacity += 5;
    }
    _persist(); // persist the new capacity immediately
  }

  void upgradeRope() {
    if (canUpgradeRope()) {
      spendCoins(_costRope);
      ropeLength += 5;
    }
    _persist(); // persist the new ropeLength immediately
  }

  // Helper used by HUD to show a cooldown counter (in seconds)
  int get _upgradeCooldownSeconds => 5; // simple static cooldown
}