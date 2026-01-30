import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'game_scene.dart';
import 'hud.dart';
import '../utils/upgrades.dart';
import '../components/particle_effects.dart';
import 'dart:math';

class BucketComponent extends SpriteComponent 
    with HasGameRef<FlameGame>, Tapable {
  final UpgradeManager upgradeManager;
  final ParticleEffect _collectEffect = ParticleEffect(
    particles: [], // will be filled at runtime
    duration: 0.5,
  );
  final ParticleEffect _hitEffect = ParticleEffect(
    particles: [], // will be filled at runtime
    duration: 0.6,
  );

  double _currentX = 0;
  int baseCapacity = 5;
  int baseRopeLength = 5;

  BucketComponent({required this.upgradeManager});

  @override
  void onLoad() async {
    sprite = await Sprite.load('assets/bucket.png');
    size = Vector2(50, 70);
    anchor = Anchor.bottomCenter;
    position = Vector2(size.x / 2, gameRef.size.y);
    // Populate simple pop‑up particles for collect effect
    _collectParticles();
    // Populate flash particles for hit effect
    _hitParticles();
  }

  // ---------- particle helpers ----------
  void _collectParticles() {
    // Example: a burst of yellow sparkles
    _collectEffect.particles = List<Particle>.generating(12, (_) {
      returnParticle.withTextures(
        texture: await Sprite.load('assets/particle.png'), // placeholder
        position: Vector2(0, 0),
        velocity: Vector2(
          (Random().nextDouble() - 0.5) * 200,
          (Random().nextDouble() - 0.5) * 200,
        ),
        color: Colors.yellow,
        size: 8,
      );
    });
  }

  void _hitParticles() {
    _hitEffect.particles = List<Particle>.generating(8, (_) {
      returnParticle.withTextures(
        texture: await Sprite.load('assets/particle.png'),
        position: Vector2(0, 0),
        velocity: Vector2(
          (Random().nextDouble() - 0.5) * 150,
          (Random().nextDouble() - 0.5) * 150,
        ),
        color: Colors.redAccent,
        size: 6,
      );
    });
  }

  // ---------- movement ----------
  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 20) _moveRight();
    else if (details.delta.dx < -20) _moveLeft();
  }

  void _moveRight() {
    final maxX = gameRef.size.x - width;
    _currentX = (_currentX + 30).clamp(0.0, maxX);
    position.setFrom(_currentX, position.y);
  }

  void _moveLeft() {
    _currentX = (_currentX - 30).clamp(0.0, gameRef.size.x - width);
    position.setFrom(_currentX, position.y);
  }

  // ---------- coin collection ----------
  void collectCoin(int coinValue) {
    // Update HUD score & play collect particles
    final hud = findComponentByType<HUDComponent>();
    hud?.updateScore(runCoins: coinValue);
    // Play particle burst at the coin's position (we’ll pass it from spawner)
    add(_collectEffect);
    // Simple visual cue – flash the bucket for 0.1 s
    FlashEffect('collect').trigger(this);

    debugPrint('Collected $coinValue coins');
  }

  // ---------- hit handling ----------
  void checkAscendComplete() async {
    // When bucket reaches top → end run
    // Play hit particles
    add(_hitEffect);
    FlashEffect('hit').trigger(this);
    // Save coins to persistence and show Game Over overlay
    final game = gameRef as MyGame;
    await game._upgradeManager.saveLater(); // persist final coin count
    game.overlays.add('gameOver');
    game.pauseEngine();
  }

  // ---------- visual upgrade cues ----------
  void triggerUpgradeVisual(String type) {
    // Simple scale‑pulse to indicate a successful upgrade
    final scaleTween = Tween<double>(begin: 1.0, end: 1.3);
    final go = GoToScale(scaleTween.end, duration: 0.2);
    go.onComplete = () => GoToScale(1.0, duration: 0.2);
    add(go);
    // Change tint for a short moment
    color = type == 'capacity' ? Colors.green : Colors.blue;
    afterDelay(const Duration(milliseconds: 300), () => color = null);
  }

  // Helper to compute coin value (matches $capacity * ropeLength$)
  int computeCoinValue() {
    return baseCapacity * baseRopeLength;
  }
}