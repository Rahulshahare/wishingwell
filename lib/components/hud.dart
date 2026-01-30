import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/upgrades.dart';

class HUDComponent extends PositionComponent {
  final UpgradeManager upgradeManager;
  late TextComponent _coinsText;
  int _globalCoins = 0;
  String _lastUpgrade = '';
  DateTime _lastUpgradeTime = DateTime.now();

  HUDComponent({required this.upgradeManager});

  @override
  Future<void> onLoad() async {
    // Background panel
    final panel = RectangleComponent(
      size: Vector2(220, 140),
      paint: Paint()..color = Colors.black45,
    );
    add(panel);

    // Coins counter
    _coinsText = TextComponent(
      text: 'Coins: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          color: Colors.yellowAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _coinsText.position = Vector2(12, 12);
    add(_coinsText);

    // Upgrade buttons will be added as separate components
    add(UpgradeButton(
      type: 'capacity',
      upgradeManager: upgradeManager,
      position: Vector2(10, 60),
    ));
    add(UpgradeButton(
      type: 'rope',
      upgradeManager: upgradeManager,
      position: Vector2(10, 100),
    ));
  }

  void updateScore({required int runCoins}) {
    _globalCoins += runCoins;
    _coinsText.text = 'Coins: $_globalCoins';
  }
}

class UpgradeButton extends PositionComponent with TapCallbacks {
  final String type;
  final UpgradeManager upgradeManager;
  static DateTime? _lastTapTime;
  static const _cooldownSeconds = 2;

  UpgradeButton({
    required this.type,
    required this.upgradeManager,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(180, 32),
        );

  @override
  Future<void> onLoad() async {
    // Button background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.deepOrangeAccent,
    ));

    // Button text
    add(TextComponent(
      text: type == 'capacity' ? 'Upgrade Capacity (+5)' : 'Upgrade Rope (+5)',
      position: Vector2(8, 6),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds < _cooldownSeconds) {
      // Cooldown active
      return;
    }
    _lastTapTime = now;

    if (type == 'capacity') {
      upgradeManager.upgradeCapacity();
    } else {
      upgradeManager.upgradeRope();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(size.toRect(), borderPaint);
  }
}
