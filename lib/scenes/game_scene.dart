import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'components/bucket.dart';
import 'components/rock_spawner.dart';
import 'components/coin_spawner.dart';
import 'components/hud.dart';
import 'utils/upgrades.dart';
import 'dart:async';

class GameScene extends FlameGame {
  final UpgradeManager upgradeManager = UpgradeManager();

  // Current well height (world size) – starts at 5 m.
  double _wellHeight = 5.0; // metres → will be scaled to pixels later

  @override
  Future<void> onLoad() async {
    size = Vector2(360, 690); // initial canvas size

    // Background (placeholder)
    await add(PositionedComponent(
      position: Vector2.zero,
      child: SpriteComponent(
        sprite: await Sprite.load('assets/background.png'),
        size: size,
      ),
    ));

    // HUD
    final hud = HUDComponent(upgradeManager: upgradeManager);
    add(hud);

    // Bucket (player)
    final bucket = BucketComponent(upgradeManager: upgradeManager);
    add(bucket);

    // Rocks & Coins
    final rockSpawner = RockSpawner(bucket: bucket);
    add(rockSpawner);
    final coinSpawner = CoinSpawner(bucket: bucket);
    add(coinSpawner);

    // Listen for upgrades that change well height
    upgradeManager.addListener(_onUpgrade);
  }

  void _onUpgrade() async {
    // When capacity or rope length changes, increase well height by 5 m.
    // $wellHeight += 5$  (block math)
    _wellHeight += 5;
    // Adjust world size (the well area) – we simply enlarge the canvas height.
    size = Vector2(size.x, size.y + 100);
    // Re‑position bucket to stay anchored at the new bottom.
    final bucket = findComponentByType<BucketComponent>() as BucketComponent;
    bucket.position = Vector2(bucket.position.x, size.y - bucket.size.y);
    // Optionally respawn rocks/coins at the new top (skipped for simplicity).
    // Persist new well height if needed.
    // Save the updated world dimensions to SharedPreferences later if desired.
  }
}