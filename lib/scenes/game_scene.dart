import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../components/bucket.dart';
import '../components/rock_spawner.dart';
import '../components/coin_spawner.dart';
import '../components/hud.dart';
import '../utils/upgrades.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class GameScene extends FlameGame {
  final UpgradeManager upgradeManager = UpgradeManager();

  // Current well height (world size) – starts at 5 m.
  double _wellHeight = 5.0; // metres → will be scaled to pixels later

  @override
  Future<void> onLoad() async {
    camera.viewport.size = Vector2(360, 690);

    // Background
    final bgSprite = await Sprite.load('background.png');
    world.add(SpriteComponent(
      sprite: bgSprite,
      size: camera.viewport.size,
      position: Vector2.zero,
    ));

    // HUD
    final hud = HUDComponent(upgradeManager: upgradeManager);
    hud.key = ComponentKey.named('hud');
    world.add(hud);

    // Bucket (player)
    final bucket = BucketComponent(upgradeManager: upgradeManager);
    world.add(bucket);

    // Rocks & Coins
    final rockSpawner = RockSpawner(bucket: bucket);
    world.add(rockSpawner);
    final coinSpawner = CoinSpawner(bucket: bucket);
    world.add(coinSpawner);
  }

  void _onUpgrade() async {
    // When capacity or rope length changes, increase well height by 5 m.
    _wellHeight += 5;
    // Adjust world size (the well area) – we simply enlarge the canvas height.
    camera.viewport.size = Vector2(camera.viewport.size.x, camera.viewport.size.y + 100);
    // Re-position bucket to stay anchored at the new bottom.
    final bucket = world.children.whereType<BucketComponent>().firstOrNull;
    if (bucket != null) {
      bucket.position = Vector2(bucket.position.x, camera.viewport.size.y - bucket.size.y);
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
    world.removeAll(world.children);
    onLoad();
  }
}
