import 'package:flame/components.dart';
import 'bucket.dart';
import 'dart:math';
import 'particle_effects.dart';
import 'package:flutter/material.dart';

class RockSpawner extends Component with HasGameRef {
  final BucketComponent bucket;
  static const double rockSpeed = 150;
  double _spawnTimer = 0;
  static const double _spawnInterval = 2.0; // Spawn every 2 seconds

  final List<Rock> _rocks = [];

  RockSpawner({required this.bucket});

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnRock();
    }

    // Update rocks
    for (final rock in List<Rock>.from(_rocks)) {
      rock.position.x -= rockSpeed * dt;

      // Reset if off screen
      if (rock.position.x + rock.size.x < 0) {
        rock.position.x = gameRef.size.x;
        rock.position.y = Random().nextDouble() * (gameRef.size.y - rock.size.y);
      }

      // Collision detection with bucket
      if (rock.toRect().overlaps(bucket.toRect())) {
        // Hit!
        bucket.onHit();
        rock.position.x = gameRef.size.x;
        rock.position.y = Random().nextDouble() * (gameRef.size.y - rock.size.y);
      }
    }
  }

  void _spawnRock() {
    final rock = Rock();
    rock.position = Vector2(
      gameRef.size.x,
      Random().nextDouble() * (gameRef.size.y - 60),
    );
    _rocks.add(rock);
    add(rock);
  }
}

class Rock extends SpriteComponent with HasGameRef {
  Rock() : super(size: Vector2(60, 60), priority: 10);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('rock.png');
  }
}
