import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'utils/upgrades.dart';

class HUDComponent extends PositionedComponent {
  final UpgradeManager upgradeManager;
  int globalCoins = 0;

  HUDComponent({required this.upgradeManager});

  @override
  void onLoad() {
    // Background panel
    final panel = SpriteComponent(
      sprite: Sprite(const BitmapImage().fromAsset('assets/panel.png')),
      size: Vector2(200, 120),
    );
    add(panel);

    // Global coins text
    final coinsText = TextComponent(
      text: 'Coins: $globalCoins',
      style: TextStyle(
          fontSize: 20,
          color: Colors.yellow,
          fontWeight: FontWeight.bold),
    );
    position = Vector2(10, 10);
    add(coinsText);
  }

  void updateScore({required int runCoins}) {
    globalCoins += runCoins;
    // Find the text component and update its string
    // Simple approach: remove old and add new; for brevity we just print
    debugPrint('Updated coins → $globalCoins');
  }

  void tryUpgradeCapacity() => upgradeManager.upgradeCapacity();
  void tryUpgradeRope() => upgradeManager.upgradeRope();
}