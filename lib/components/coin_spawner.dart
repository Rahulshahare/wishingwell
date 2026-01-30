import 'package:flame/components.dart';
import 'bucket.dart';
import 'dart:math';
import 'particle_effects.dart';
import 'package:flutter/material.dart';

class CoinSpawner extends Component with HasGameRef {
  final BucketComponent bucket;
  static const double coinSize = 32;
  static const double coinSpeed = 100;
  double _spawnTimer = 0;
  static const double _spawnInterval = 1.5; // Spawn every 1.5 seconds

  final List<Coin> _coins = [];

  CoinSpawner({required this.bucket});

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnCoin();
    }

    // Update coins
    for (final coin in List<Coin>.from(_coins)) {
      coin.position.y += coinSpeed * dt;

      // Reset if off screen
      if (coin.position.y > gameRef.size.y + coin.size.y) {
        coin.position.y = -coin.size.y;
        coin.position.x = bucket.position.x + Random().nextDouble() * 100 - 50;
      }

      // Collision with bucket
      if (coin.toRect().overlaps(bucket.toRect())) {
        final coinValue = bucket.computeCoinValue();
        bucket.collectCoin(coinValue);

        // Play collect particles
        final effect = ParticleEffect(
          particleCount: 6,
          color: Colors.amber,
          duration: 0.5,
        );
        effect.position = coin.position.clone();
        gameRef.add(effect);

        // Reset coin
        coin.position.y = -coin.size.y;
        coin.position.x = bucket.position.x + Random().nextDouble() * 100 - 50;
      }
    }
  }

  void _spawnCoin() {
    final coin = Coin();
    coin.position = Vector2(
      bucket.position.x + Random().nextDouble() * 100 - 50,
      -coin.size.y,
    );
    _coins.add(coin);
    add(coin);
  }
}

class Coin extends SpriteComponent with HasGameRef {
  Coin() : super(size: Vector2(CoinSpawner.coinSize, CoinSpawner.coinSize), priority: 5);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('coin.png');
  }
}
