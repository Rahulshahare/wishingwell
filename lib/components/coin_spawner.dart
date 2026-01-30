import 'package:flame/components.dart';
import 'bucket.dart';
import 'dart:math';
import '../components/particle_effects.dart';

class CoinSpawner extends PositionedComponent {
  final BucketComponent bucket;
  static const double coinSize = 32;
  static const double coinSpeed = 100;

  CoinSpawner({required this.bucket});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/coin.png');
    size = Vector2(coinSize, coinSize);
    // Random spawn horizontally; for demo we just use bucket.x +/- 50
    position = Vector2(bucket.position.x + Random().nextDouble() * 100 - 50, -height);
    priority = 5;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = position + Vector2(0, coinSpeed * dt);
    if (position.y > gameRef.size.y + height) {
      position = Vector2(bucket.position.x + Random().nextDouble() * 100 - 50, -height);
    }

    // Interaction with bucket
    final bucketBox = Rect.fromLTWH(
        bucket.position.x, bucket.position.y, bucket.size.x, bucket.size.y);
    if (bucketBox.overlaps(Rect.fromLTWH(position.x, position.y, size.x, size.y))) {
      final coinValue = bucket.computeCoinValue(); // $capacity * ropeLength$
      bucket.collectCoin(coinValue);
      // Play collect particles here as well
      add(ParticleEffect(
        particles: List<Particle>.generating(6, (_) {
          return Particle.withTextures(
            texture: await Sprite.load('assets/particle.png'),
            position: Vector2(0, 0),
            velocity: Vector2((Random().nextDouble() - 0.5) * 150,
                               (Random().nextDouble() - 0.5) * 150),
            color: Colors.amber,
            size: 6,
          );
        }),
        duration: 0.5,
      ));
      removeFromParent();
    }
  }
}