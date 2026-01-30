import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Simple particle system for coin collect and hit effects
class ParticleEffect extends PositionComponent {
  final int particleCount;
  final Color color;
  final double duration;
  final double speed;
  final double particleSize;

  ParticleEffect({
    required this.particleCount,
    required this.color,
    this.duration = 0.5,
    this.speed = 150,
    this.particleSize = 6,
  });

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      final velocity = Vector2(
        cos(angle) * speed * (0.5 + Random().nextDouble() * 0.5),
        sin(angle) * speed * (0.5 + Random().nextDouble() * 0.5),
      );
      add(Particle(
        velocity: velocity,
        color: color,
        size: particleSize,
        duration: duration,
      ));
    }
  }
}

/// Individual particle component
class Particle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double duration;
  double _elapsed = 0;

  Particle({
    required this.velocity,
    required this.color,
    required double size,
    required this.duration,
  }) {
    this.size = Vector2.all(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    _elapsed += dt;

    // Fade out effect by reducing opacity
    final opacity = 1.0 - (_elapsed / duration);
    if (opacity <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (_elapsed / duration)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
