import 'package:flutter/material.dart';
import '../scenes/game_scene.dart';

class GameOverScreen extends StatelessWidget {
  final GameScene gameScene;
  final double finalScore;

  const GameOverScreen({
    super.key,
    required this.gameScene,
    required this.finalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big title
            const Text(
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
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // Retry button
            ElevatedButton.icon(
              onPressed: () => gameScene.resetGame(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),

            // Quit button
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.exit_to_app, color: Colors.white70),
              label: const Text(
                'Quit',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
