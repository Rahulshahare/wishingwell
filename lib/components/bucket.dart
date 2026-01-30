import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:double_anchor/double_anchor.dart';
import 'game_scene.dart'; // for accessing global coin total

class BucketComponent extends SpriteComponent with HasGameRef<FlameGame>, Tapable {
  final UpgradeManager upgradeManager;
  final Paint _debugPaint = Paint()..color = Colors.redAccent.withOpacity(0.2);

  // State variables
  double _currentX = 0;                // Horizontal position inside well
  double get currentX => _currentX;
  int capacity = 5;                    // Default capacity
  int ropeLength = 5;                  // Default depth (meters)

  BucketComponent({required this.upgradeManager});

  @override
  void onLoad() {
    sprite = await Sprite.load('assets/bucket.png');
    size = Vector2(50, 70);
    anchor = Anchor.bottomCenter;
    position = Vector2(size.x / 2, gameRef.size.y); // start at bottom
  }

  // Swipe detection – left or right movement only
  @override
  void onPanUpdate(DragUpdateDetails details) async {
    if (details.delta.dx > 20) {
      _moveRight();
    } else if (details.delta.dx < -20) {
      _moveLeft();
    }
  }

  void _moveRight() {
    // Keep bucket inside well width (example: 300px)
    final maxX = gameRef.size.x - width;
    _currentX = (_currentX + 30).clamp(0.0, maxX);
    position.setFrom(_currentX, position.y);
  }

  void _moveLeft() {
    _currentX = (_currentX - 30).clamp(0.0, gameRef.size.x - width);
    position.setFrom(_currentX, position.y);
  }

  // Called when bucket reaches the top of the well
  void checkAscendComplete() {
    // When we hit the top, run ends and coins are banked
    final runCoins = /* coins collected during this drop */ 0;
    final game = gameRef as MyGame;
    game.globalCoins += runCoins;
    // Navigate to GameOver scene (simple transition)
    game.overlays.add('gameOver');
    game.pauseEngine();
  }

  // Visual feedback when coin is collected
  void onCoinCollected(int amount) {
    // Simple pop‑up effect – can be expanded later
    debugPrint('Collected $amount coins');
  }

  // Called by CoinSpawner when a coin is taken
  void collectCoin(int coinValue) {
    // Update global score via HUD
    final hud = findComponentByType<HUDComponent>();
    hud?.updateScore(runCoins: coinValue);
    onCoinCollected(coinValue);
  }

  // Upgrade button callbacks (exposed to HUD)
  void upgradeCapacity() {
    if (upgradeManager.canUpgradeCapacity()) {
      upgradeManager.upgradeCapacity();
    } else {
      debugPrint('Not enough coins for capacity upgrade');
    }
  }

  void upgradeRopeLength() {
    if (upgradeManager.canUpgradeRope()) {
      upgradeManager.upgradeRope();
    } else {
      debugPrint('Not enough coins for rope upgrade');
    }
  }
}