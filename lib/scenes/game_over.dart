// `lib/scenes/game_over.dart`
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:wish_well_i/utils/persistence.dart';

/// A simple overlay that appears when the player runs out of lives / rope.
class GameOver extends StatelessWidget {
  final double finalScore;

  const GameOver({
    Key? key,
    required this.finalScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Center everything on the screen.
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎉 Big title
            Text(
              'Game Over',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 20),

            // Final score
            Text(
              'Score: ${finalScore.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // Best‑score badge
            StreamBuilder<double>(
              stream: ScoreStorage.bestScoreStream,
              builder: (_, snapshot) {
                final best = snapshot.data ?? 0;
                return Text(
                  'Best Score: ${best.toInt().toString()}',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.lightBlueAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Retry button
            ElevatedButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                primary: Colors.greenAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),

            // Quit button
            TextButton.icon(
              onPressed: _onQuit,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Quit'),
              style: TextStyle(color: Colors.grey[200]),
            ),
          ],
        ),
      ),
    );
  }

  void _onRetry() {
    // Reload the current game scene (Flame helper)
    FlameGame.instance.resetGame();
  }

  void _onQuit() {
    // Close the Flutter application
    FlameGame.instance.exit();
  }
}