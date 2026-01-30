class UpgradeManager {
  int _globalCoins = 0;   // In‑memory store – can be persisted later
  int capacity = 5;       // Default capacity
  int ropeLength = 5;     // Default depth

  bool canUpgradeCapacity() => _globalCoins >= 50; // cost example
  bool canUpgradeRope() => _globalCoins >= 30;   // cost example

  void spendCoins(int amount) {
    _globalCoins -= amount;
  }

  void upgradeCapacity() {
    if (canUpgradeCapacity()) {
      spendCoins(50);
      capacity += 5;
    }
  }

  void upgradeRope() {
    if (canUpgradeRope()) {
      spendCoins(30);
      ropeLength += 5;
    }
  }

  // Helper to show current totals (useful for UI)
  void addCoins(int amount) => _globalCoins += amount;
}