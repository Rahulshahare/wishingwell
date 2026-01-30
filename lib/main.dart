import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/collisions.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(const MaterialApp(home: GameWithOverlay()));
}

class GameWithOverlay extends StatefulWidget {
  const GameWithOverlay({super.key});

  @override
  State<GameWithOverlay> createState() => _GameWithOverlayState();
}

class _GameWithOverlayState extends State<GameWithOverlay> {
  late final WishingWellGame game;

  @override
  void initState() {
    super.initState();
    game = WishingWellGame(onTotalCoinsChanged: (coins) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: game.upgradeBucket,
                    child: Text('Bucket (+3) - ${game.bucketCapacity}'),
                  ),
                  ElevatedButton(
                    onPressed: game.upgradeRope,
                    child: Text('Rope (+300m) - ${game.maxDepth.toInt()}m'),
                  ),
                ],
              ),
            ),
          ),
          if (game.showFailOverlay)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'ROCK HIT!\nRun Failed\nCoins Lost',
                  style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Coins: ${game.totalCoins}', style: const TextStyle(color: Colors.white, fontSize: 24)),
                  Text('Run Coins: ${game.currentRunCoins}', style: const TextStyle(color: Colors.yellow, fontSize: 20)),
                  Text('Depth: ${game.depth.toStringAsFixed(0)}m', style: const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WishingWellGame extends FlameGame with PanDetector, HasCollisionDetection {
  late Bucket bucket;
  double depth = 0;
  double maxDepth = 800;
  int bucketCapacity = 8;
  int totalCoins = 0;
  int currentRunCoins = 0;
  bool isDescending = true;
  bool showFailOverlay = false;
  final Random random = Random();
  late ParallaxComponent parallax;

  final ValueChanged<int>? onTotalCoinsChanged;

  WishingWellGame({this.onTotalCoinsChanged});

  @override
  Future<void> onLoad() async {
    // Load sounds
    await FlameAudio.audioCache.loadAll(['collect.mp3', 'hit.mp3']);
    FlameAudio.bgm.play('bg_music.mp3', volume: 0.4);

    // Load parallax background (cave layers)
    parallax = await loadParallaxComponent(
      [
        ParallaxImageData('cave_layer1.png'),
        ParallaxImageData('cave_layer2.png'),
        ParallaxImageData('cave_layer3.png'),
      ],
      baseVelocity: Vector2(0, 30),
      velocityMultiplierDelta: Vector2(1.2, 1.5),
    );
    add(parallax);

    // Bucket
    bucket = Bucket(position: Vector2(size.x / 2, 120));
    add(bucket);

    // Load saved coins
    final prefs = await SharedPreferences.getInstance();
    totalCoins = prefs.getInt('totalCoins') ?? 0;
    onTotalCoinsChanged?.call(totalCoins);

    spawnItems();
  }

  void spawnItems() {
    for (double y = 200; y < maxDepth + size.y * 2; y += 100 + random.nextDouble() * 80) {
      if (random.nextDouble() < 0.55) {
        final coin = GoldCoin(position: Vector2(random.nextDouble() * (size.x - 80) + 40, y));
        add(coin);
      }
      if (random.nextDouble() < 0.25) {
        final rock = Rock(position: Vector2(random.nextDouble() * (size.x - 100) + 50, y));
        add(rock);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (showFailOverlay) return;

    if (isDescending) {
      depth += 180 * dt;
      parallax.parallax?.baseVelocity.y = 180;
      if (depth >= maxDepth) {
        isDescending = false;
      }
    } else {
      depth -= 250 * dt;
      parallax.parallax?.baseVelocity.y = -250;
      if (depth <= 0) {
        _finishRun(success: true);
      }
    }

    // Clean up items that went off screen top during ascent
    children.whereType<PositionComponent>().forEach((c) {
      if (c.y < -100 && c is Collectible) c.removeFromParent();
    });
  }

  void _finishRun({required bool success}) {
    if (success) {
      totalCoins += currentRunCoins;
      SharedPreferences.getInstance().then((p) => p.setInt('totalCoins', totalCoins));
      onTotalCoinsChanged?.call(totalCoins);
    }
    currentRunCoins = 0;
    depth = 0;
    isDescending = true;
    children.whereType<Collectible>().forEach((c) => c.removeFromParent());
    spawnItems();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    bucket.position.x += info.delta.global.x * 2.0;
    bucket.position.x = bucket.position.x.clamp(50, size.x - 50);
  }

  void upgradeBucket() {
    bucketCapacity += 3;
  }

  void upgradeRope() {
    maxDepth += 400;
  }

  void triggerFail() {
    currentRunCoins = 0;
    showFailOverlay = true;
    FlameAudio.play('hit.mp3');
    Future.delayed(const Duration(seconds: 3), () {
      showFailOverlay = false;
      _finishRun(success: false);
    });
  }
}

class Bucket extends SpriteComponent with CollisionCallbacks {
  Bucket({required Vector2 position})
      : super(position: position, size: Vector2(90, 90), anchor: Anchor.center);

  int collected = 0;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bucket.png');
    add(CircleHitbox(radius: 40));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    final game = findGame() as WishingWellGame;

    if (other is GoldCoin) {
      if (collected < game.bucketCapacity) {
        collected++;
        final value = 10 + (game.depth ~/ 80).clamp(0, 50);
        game.currentRunCoins += value;
        FlameAudio.play('collect.mp3');
        other.showCollectEffect(game);
        other.removeFromParent();
      }
    } else if (other is Rock) {
      game.triggerFail();
      other.removeFromParent();
    }
  }
}

// Fixed: Added constructor to forward parameters to SpriteComponent
abstract class Collectible extends SpriteComponent with CollisionCallbacks {
  Collectible({super.position, super.size, super.anchor});
}

class GoldCoin extends Collectible {
  GoldCoin({required Vector2 position})
      : super(position: position, size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('coin.png');
    add(CircleHitbox());
  }

  void showCollectEffect(WishingWellGame game) {
    final random = Random();
    final particle = ParticleSystemComponent(
      particle: Particle.generate(
        count: 18,
        lifespan: 0.8,
        generator: (i) => AcceleratedParticle(
          speed: Vector2((random.nextDouble() - 0.5) * 300, (random.nextDouble() - 0.5) * 300),
          acceleration: Vector2(0, 400),
          position: Vector2.zero(),
          child: CircleParticle(
            radius: 4.0 + random.nextDouble() * 5.0,
            paint: Paint()..color = Colors.yellow.withValues(alpha: 0.9),
          ),
        ),
      ),
      position: position.clone(),
    );
    game.add(particle);
  }
}

class Rock extends Collectible {
  Rock({required Vector2 position})
      : super(position: position, size: Vector2(70, 70), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('rock.png');
    add(RectangleHitbox());
  }
}
