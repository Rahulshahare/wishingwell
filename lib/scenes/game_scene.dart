import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../components/bucket.dart';
import '../components/rock_spawner.dart';
import '../components/coin_spawner.dart';
import '../components/hud.dart';
import '../utils/upgrades.dart';
import 'game_over.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class GameScene extends FlameGame {
  final UpgradeManager upgradeManager = UpgradeManager();

  // Current well height (world size) – starts at 5 m.
  double _wellHeight = 5.0; // metres → will be scaled to pixels later

  @override
  Future<void> onLoad() async {
    size = Vector2(360, 690); // initial canvas size

    // Background
    final bgSprite = await Sprite.load('background.png');
    add(SpriteComponent(
      sprite: bgSprite,
      size: size,
      position: Vector2.zero,
    ));

    // HUD
    final hud = HUDComponent(upgradeManager: upgradeManager);
    hud.keyName = 'hud';
    add(hud);

    // Bucket (player)
    final bucket = BucketComponent(upgradeManager: upgradeManager);
    add(bucket);

    // Rocks & Coins
    final rockSpawner = RockSpawner(bucket: bucket);
    add(rockSpawner);
    final coinSpawner = CoinSpawner(bucket: bucket);
    add(coinSpawner);
  }

  void _onUpgrade() async {
    // When capacity or rope length changes, increase well height by 5 m.
    _wellHeight += 5;
    // Adjust world size (the well area) – we simply enlarge the canvas height.
    size = Vector2(size.x, size.y + 100);
    // Re-position bucket to stay anchored at the new bottom.
    final bucket = children.whereType<BucketComponent>().firstOrNull;
    if (bucket != null) {
      bucket.position = Vector2(bucket.position.x, size.y - bucket.size.y);
    }
  }

  void showGameOver() {
    overlays.add('gameOver');
    pauseEngine();
  }

  void resetGame() {
    overlays.remove('gameOver');
    resumeEngine();
    // Reset game state
    removeAll(children);
    onLoad();
  }
}
