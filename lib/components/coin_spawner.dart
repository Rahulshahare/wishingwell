import 'package:flame/components.dart';
import 'bucket.dart';
import 'dart:math';

class CoinSpawner extends PositionedComponent {
  final BucketComponent bucket;
  static const double coinSize = 32;
  static const double coinSpeed = 100; // downward speed

  CoinSpawner({required this.bucket});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/coin.png');
    size = Vector2(coinSize, coinSize);
    // Random spawn horizontally within bucket width
    position = Vector2(
        Random().nextDouble() * (bucket.currentX * 2), -height);
    priority = 5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move downwards (bucket is moving up automatically)
    position = position + Vector2(0, coinSpeed * dt);
    if (position.y > gameRef.size.y + height) {
      // Coin left the screen, recycle
      position = Vector2(
          Random().nextDouble() * (bucket.currentX * 2), -height);
    }

    // Check collection
    final bucketBox = bucketHitbox();
    if (bucketBox.overlaps(Rect.fromLTWH(position.x, position.y, size.x, size.y))) {
      final coinValue = _calculateCoinValue();
      bucket.collectCoin(coinValue);
      removeFromParent(); // coin disappears after collection
    }
  }

  int _calculateCoinValue() {
    // $coinValue = capacity * depth$  (inline formula)
    final depth = bucket.ropeLength;
    final cap = bucket.capacity;
    final value = cap * depth;
    return value;
  }

  Rect bucketHitbox() {
    return Rect.fromLTWH(
        bucket.position.x, bucket.position.y, bucket.size.x, bucket.size.y);
  }
}