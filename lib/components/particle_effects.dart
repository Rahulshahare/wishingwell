import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// Simple particle system that can be reused for **coin collect** and **hit**.
class ParticleEffect extends FlameCompositeComponent {
  final List<Particle> particles;
  final double duration; // seconds

  ParticleEffect({
    required this.particles,
    required this.duration,
  }) : super(child: ParticleComponent(particles: particles));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Apply a short life‑time to each particle
    for (final p in particles) {
      p.lifetime = duration;
    }
  }
}