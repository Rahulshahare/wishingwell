import 'package:flame/components.dart';
import 'package:flame/tween.dart';
import 'bucket.dart';

class RockSpawner extends PositionedComponent {
  final BucketComponent bucket;
  static const double rockSpeed = 150; // px/s

  RockSpawner({required this.bucket});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/rock.png');
    size = Vector2(60, 60);
    // Start off‑screen on the right, then move left
    position = Vector2(gameRef.size.x, Random().nextDouble() * (gameRef.size.y - height));
    priority = 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move left across the screen
    position = position + Vector2(-rockSpeed * dt, 0);
    if (position.x + width < 0) {
      // Reset when it leaves the left side
      position = Vector2(gameRef.size.x, Random().nextDouble() * (gameRef.size.y - height));
    }

    // Collision detection with bucket
    if (position.x < bucket.position.x + bucket.width &&
        position.x + width > bucket.position.x &&
        position.y < bucket.position.y + bucket.height &&
        position.y + height > bucket.position.y) {
      // Hit! End the run
      bucket.collectCoin(0); // maybe play hit effect
      bucket.checkAscendComplete();
      removeFromParent();
    }
  }
}