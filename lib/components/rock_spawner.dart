import 'package:flame/components.dart';
import 'package:flame/tween.dart';
import 'bucket.dart';
import '../components/particle_effects.dart';

class RockSpawner extends PositionedComponent {
  final BucketComponent bucket;
  static const double rockSpeed = 150;

  RockSpawner({required this.bucket});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/rock.png');
    size = Vector2(60, 60);
    position = Vector2(gameRef.size.x, Random().nextDouble() * (gameRef.size.y - height));
    priority = 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = position + Vector2(-rockSpeed * dt, 0);
    if (position.x + width < 0) {
      position = Vector2(gameRef.size.x, Random().nextDouble() * (gameRef.size.y - height));
    }

    // Collision detection (still simple AABB)
    if (position.x < bucket.position.x + bucket.width &&
        position.x + width > bucket.position.x &&
        position.y < bucket.position.y + bucket.height &&
        position.y + height > bucket.position.y) {
      // Play hit effect & end run
      bucket.collectCoin(0); // dummy value – actual coins handled by hit effect
      bucket.checkAscendComplete();
      removeFromParent();
    }
  }
}