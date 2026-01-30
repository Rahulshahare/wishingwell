import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'utils/upgrades.dart';

class HUDComponent extends PositionedComponent {
  final UpgradeManager upgradeManager;
  late TextComponent _coinsText;
  int _globalCoins = 0;
  String _lastUpgrade = '';
  DateTime _lastUpgradeTime = DateTime.now();

  HUDComponent({required this.upgradeManager});

  @override
  void onLoad() {
    // Background panel (placeholder)
    final panel = SpriteComponent(
      sprite: Sprite(SolidColor(color: Colors.black45)),
      size: Vector2(220, 140),
    );
    add(panel);

    // Coins counter
    _coinsText = TextComponent(
      text: 'Coins: 0',
      style: TextStyle(
        fontSize: 22,
        color: Colors.yellowAccent,
        fontWeight: FontWeight.bold,
      ),
    );
    position = Vector2(12, 12);
    add(_coinsText);
  }

  void updateScore({required int runCoins}) {
    _globalCoins += runCoins;
    // Persist immediately (or call saveLater from GameScene)
    // For demo we just update UI
    _coinsText.text = 'Coins: $_globalCoins';
  }

  // ------------ Upgrade UI ----------
  void showUpgradeButton(String type) {
    final btn = PositionedComponent(
      left: 10,
      bottom: 10,
      child: GestureDetector(
        onTap: () async {
          if (_lastUpgrade == type && 
              DateTime.now().difference(_lastUpgradeTime).inSeconds <
                  const Duration(seconds: 2)) {
            // Cool‑down still active → ignore tap
            return;
          }
          _lastUpgrade = type;
          _lastUpgradeTime = DateTime.now();

          if (type == 'capacity') {
            upgradeManager.upgradeCapacity();
          } else {
            upgradeManager.upgradeRope();
          }
          // Refresh UI after upgrade attempt
          _refreshCoinsDisplay();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white70, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type == 'capacity' ? Icons.grain : Icons.swimming_pool,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                type == 'capacity'
                    ? 'Upgrade Capacity (+5)'
                    : 'Upgrade Rope (+5)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    add(btn);
  }

  // Simple visual cue when upgrade button is pressed (scale pulse)
  void _upgradeVisualCue() {
    // This method could be called from the bucket after successful upgrade
    // Example: flash the HUD background briefly
    debugPrint('Upgrade visual cue triggered');
  }

  void _refreshCoinsDisplay() {
    _coinsText.text = 'Coins: $_globalCoins';
  }
}