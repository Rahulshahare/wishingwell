import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'scenes/game_scene.dart';
import 'scenes/game_over.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.initialize();
  runApp(const MyGame());
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wish-ing-Well-I',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidgetWrapper(),
      ),
    );
  }
}

class GameWidgetWrapper extends StatefulWidget {
  @override
  State<GameWidgetWrapper> createState() => _GameWidgetWrapperState();
}

class _GameWidgetWrapperState extends State<GameWidgetWrapper> {
  late GameScene _gameScene;

  @override
  void initState() {
    super.initState();
    _gameScene = GameScene();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _gameScene,
      overlayBuilderMap: {
        'gameOver': (context, game) => GameOverScreen(
              gameScene: _gameScene,
              finalScore: 0,
            ),
      },
    );
  }
}
