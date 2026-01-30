import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'components/bucket.dart';
import 'components/rock_spawner.dart';
import 'components/coin_spawner.dart';
import 'components/hud.dart';
import 'utils/upgrades.dart';
import 'package:flutter/material.dart';

class GameScene extends FlameGame {
  final UpgradeManager _upgradeManager = UpgradeManager();

  @override
  Future<void> onLoad() async {
    // World size – you can change it to match your preferred viewport
    size = Vector2(360, 690);

    // Add background
    await add(PositionedComponent(
      position: Vector2.zero,
      child: SpriteComponent(
        sprite: await Sprite.load('assets/background.png'),
        size: size,
      ),
    ));

    // Add HUD (global coins & upgrade buttons)
    final hud = HUDComponent(upgradeManager: _upgradeManager);
    add(hud);

    // Bucket (player)
    final bucket = BucketComponent(upgradeManager: _upgradeManager);
    add(bucket);

    // Rocks (obstacles)
    final rockSpawner = RockSpawner(bucket: bucket);
    add(rockSpawner);

    // Coins (collectibles)
    final coinSpawner = CoinSpawner(bucket: bucket);
    add(coinSpawner);
  }
}