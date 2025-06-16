import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'models/game_state.dart';
import 'widgets/starfield_background.dart';
import 'widgets/themed_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '太空射擊',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Orbitron',
      ),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarfieldBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '太空射擊',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.cyan, blurRadius: 10),
                      Shadow(color: Colors.cyan, blurRadius: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 70),
                _buildLevelButton(
                  context,
                  GameLevel.easy,
                  '簡單',
                  '20個敵人 / 60秒 / 1倍分數',
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  context,
                  GameLevel.medium,
                  '中等',
                  '30個敵人 / 45秒 / 2倍分數',
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  context,
                  GameLevel.hard,
                  '困難',
                  '40個敵人 / 30秒 / 3倍分數',
                ),
                const SizedBox(height: 20),
                _buildLevelButton(
                  context,
                  GameLevel.expert,
                  '專家',
                  '50個敵人 / 20秒 / 4倍分數',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    GameLevel level,
    String title,
    String description,
  ) {
    return ThemedButton(
      title: title,
      description: description,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameScreen(initialLevel: level),
          ),
        );
      },
    );
  }
} 