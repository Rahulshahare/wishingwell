import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../scenes/game_scene.dart';
import 'hud.dart';
import '../utils/upgrades.dart';
import 'particle_effects.dart';
import 'dart:math';

class BucketComponent extends SpriteComponent
    with HasGameRef<GameScene>, DragCallbacks {
  final UpgradeManager upgradeManager;
  late ParticleEffect _collectEffect;
  late ParticleEffect _hitEffect;

  double _currentX = 0;
  int baseCapacity = 5;
  int baseRopeLength = 5;

  BucketComponent({required this.upgradeManager});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bucket.png');
    size = Vector2(50, 70);
    anchor = Anchor.bottomCenter;
    position = Vector2(gameRef.size.x / 2, gameRef.size.y);
    _currentX = position.x;

    // Initialize particle effects
    _collectEffect = ParticleEffect(
      particleCount: 12,
      color: Colors.yellow,
      duration: 0.5,
      speed: 200,
    );
    _hitEffect = ParticleEffect(
      particleCount: 8,
      color: Colors.redAccent,
      duration: 0.6,
      speed: 150,
    );
  }

  // ---------- movement ----------
  @override
  void onPanUpdate(DragUpdateEvent event) {
    final delta = event.delta;
    if (delta.x > 20) _moveRight();
    else if (delta.x < -20) _moveLeft();
  }

  void _moveRight() {
    final maxX = gameRef.size.x - width;
    _currentX = (_currentX + 30).clamp(0.0, maxX);
    position.x = _currentX;
  }

  void _moveLeft() {
    _currentX = (_currentX - 30).clamp(0.0, gameRef.size.x - width);
    position.x = _currentX;
  }

  // ---------- coin collection ----------
  void collectCoin(int coinValue) {
    // Update HUD score
    final hud = gameRef.findByKeyName<HUDComponent>('hud');
    hud?.updateScore(runCoins: coinValue);

    // Play particle burst
    final effect = ParticleEffect(
      particleCount: 12,
      color: Colors.yellow,
      duration: 0.5,
    );
    effect.position = position.clone();
    gameRef.add(effect);

    debugPrint('Collected $coinValue coins');
  }

  // ---------- hit handling ----------
  void onHit() async {
    // Play hit particles
    final effect = ParticleEffect(
      particleCount: 8,
      color: Colors.redAccent,
      duration: 0.6,
    );
    effect.position = position.clone();
    gameRef.add(effect);

    // Save coins to persistence and show Game Over overlay
    await upgradeManager.saveLater();
    gameRef.showGameOver();
  }

  // ---------- visual upgrade cues ----------
  void triggerUpgradeVisual(String type) {
    // Simple scale pulse using a sequence
    final originalSize = size.clone();
    final targetSize = originalSize * 1.3;

    // Create a simple animation effect
    size = targetSize;
    Future.delayed(const Duration(milliseconds: 200), () {
      size = originalSize;
    });

    // Change tint for a short moment
    // Note: Flame SpriteComponent doesn't have a direct color tint property
    // This would need a custom paint or shader for full implementation
  }

  // Helper to compute coin value
  int computeCoinValue() {
    return baseCapacity * baseRopeLength;
  }
}
