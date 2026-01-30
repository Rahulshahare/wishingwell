import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'scenes/game_scene.dart';

void main() async {
  // Ensure Flame is initialized before runApp
  await Flame.initialize();
  runApp(const MyGame());
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wish‑ing‑Well‑I',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameScene(),
      ),
    );
  }
}