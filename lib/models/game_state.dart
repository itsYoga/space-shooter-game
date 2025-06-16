import 'dart:math';
import 'package:flutter/material.dart';
import 'game_entity.dart';

enum GameLevel {
  easy,
  medium,
  hard,
  expert,
}

class LevelConfig {
  final int timeLimit;
  final int enemyCount;
  final double enemySpeed;
  final double enemySpawnRate;
  final int scoreMultiplier;

  const LevelConfig({
    required this.timeLimit,
    required this.enemyCount,
    required this.enemySpeed,
    required this.enemySpawnRate,
    required this.scoreMultiplier,
  });

  static const Map<GameLevel, LevelConfig> configs = {
    GameLevel.easy: LevelConfig(
      timeLimit: 60,
      enemyCount: 10, // Adjusted for better initial gameplay
      enemySpeed: 1.0,
      enemySpawnRate: 2.0,
      scoreMultiplier: 1,
    ),
    GameLevel.medium: LevelConfig(
      timeLimit: 45,
      enemyCount: 15,
      enemySpeed: 1.5,
      enemySpawnRate: 1.5,
      scoreMultiplier: 2,
    ),
    GameLevel.hard: LevelConfig(
      timeLimit: 30,
      enemyCount: 20,
      enemySpeed: 2.0,
      enemySpawnRate: 1.0,
      scoreMultiplier: 3,
    ),
    GameLevel.expert: LevelConfig(
      timeLimit: 20,
      enemyCount: 25,
      enemySpeed: 2.5,
      enemySpawnRate: 0.8,
      scoreMultiplier: 4,
    ),
  };
}

class GameState {
  final List<GameEntity> entities;
  final int score;
  final int timeLeft;
  final int combo;
  final int maxCombo;
  final int enemiesDestroyed;
  final GameLevel currentLevel;
  final bool isGameOver;
  final bool isPaused;

  GameState({
    required this.entities,
    required this.score,
    required this.timeLeft,
    required this.combo,
    required this.maxCombo,
    required this.enemiesDestroyed,
    required this.currentLevel,
    this.isGameOver = false,
    this.isPaused = false,
  });

  factory GameState.initial(GameLevel level) {
    final config = LevelConfig.configs[level]!;
    final random = Random();
    final entities = <GameEntity>[];

    // Add player
    entities.add(GameEntity(
      id: 'player',
      type: EntityType.player,
      x: 0.45, // Centered
      y: 0.9, // Bottom of screen
      width: 0.1,
      height: 0.1,
      speed: 0.005,
      health: 3, // Player starts with 3 health
    ));

    // Add initial enemies
    for (var i = 0; i < config.enemyCount; i++) {
      entities.add(GameEntity(
        id: 'enemy_$i',
        type: EntityType.enemy,
        x: random.nextDouble() * 0.9, // 0.0 to 0.9
        y: random.nextDouble() * -0.5, // Spawn off-screen from the top
        width: 0.08,
        height: 0.08,
        speed: config.enemySpeed * 0.001,
        points: 10,
      ));
    }

    return GameState(
      entities: entities,
      score: 0,
      timeLeft: config.timeLimit,
      combo: 0,
      maxCombo: 0,
      enemiesDestroyed: 0,
      currentLevel: level,
    );
  }

  GameState copyWith({
    List<GameEntity>? entities,
    int? score,
    int? timeLeft,
    int? combo,
    int? maxCombo,
    int? enemiesDestroyed,
    GameLevel? currentLevel,
    bool? isGameOver,
    bool? isPaused,
  }) {
    return GameState(
      entities: entities ?? this.entities,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      enemiesDestroyed: enemiesDestroyed ?? this.enemiesDestroyed,
      currentLevel: currentLevel ?? this.currentLevel,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  String get levelName {
    switch (currentLevel) {
      case GameLevel.easy: return '簡單';
      case GameLevel.medium: return '中等';
      case GameLevel.hard: return '困難';
      case GameLevel.expert: return '專家';
    }
  }

  int calculateScore() {
    final config = LevelConfig.configs[currentLevel]!;
    return score * config.scoreMultiplier;
  }

  // MODIFIED: Return a nullable entity and be safer.
  GameEntity? get player {
    try {
      return entities.firstWhere((entity) => entity.type == EntityType.player);
    } catch (e) {
      return null;
    }
  }
}