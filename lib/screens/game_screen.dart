import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/game_entity.dart';
import '../widgets/entity_widget.dart';
import '../widgets/player_health_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/timer_widget.dart';

class GameScreen extends StatefulWidget {
  final GameLevel initialLevel;

  const GameScreen({
    Key? key,
    required this.initialLevel,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  Timer? _gameLoopTimer;
  Timer? _countdownTimer;
  Timer? _enemySpawnTimer;

  // REMOVED: Unused animation controllers

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }
  
  void _initializeGame() {
    setState(() {
       _gameState = GameState.initial(widget.initialLevel);
    });
    _startGameTimers();
  }

  @override
  void dispose() {
    _stopGameTimers();
    super.dispose();
  }

  void _startGameTimers() {
    final config = LevelConfig.configs[_gameState.currentLevel]!;
    
    // Main game loop timer (60 FPS)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_gameState.isGameOver || _gameState.isPaused) return;
      _updateGameState();
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (_gameState.isGameOver || _gameState.isPaused) return;
      
      if (_gameState.timeLeft <= 0) {
        _endGame('時間到!');
        return;
      }
      setState(() {
        _gameState = _gameState.copyWith(timeLeft: _gameState.timeLeft - 1);
      });
    });

    // Enemy spawn timer
    _enemySpawnTimer = Timer.periodic(
      Duration(milliseconds: (config.enemySpawnRate * 1000).round()),
      (timer) {
        if (_gameState.isGameOver || _gameState.isPaused) return;
        _spawnEnemy();
      },
    );
  }
  
  void _stopGameTimers() {
    _gameLoopTimer?.cancel();
    _countdownTimer?.cancel();
    _enemySpawnTimer?.cancel();
  }


  void _spawnEnemy() {
    final random = math.Random();
    final config = LevelConfig.configs[_gameState.currentLevel]!;
    final newEnemy = GameEntity(
      id: 'enemy_${DateTime.now().millisecondsSinceEpoch}',
      type: EntityType.enemy,
      x: random.nextDouble() * 0.9,
      y: -0.1, // Start just off-screen
      width: 0.08,
      height: 0.08,
      speed: config.enemySpeed * 0.0015,
      points: 10,
    );

    setState(() {
      _gameState = _gameState.copyWith(
        entities: [..._gameState.entities, newEnemy],
      );
    });
  }

  void _updateGameState() {
    if (_gameState.isGameOver) return;

    List<GameEntity> updatedEntities = [];
    final screenHeight = MediaQuery.of(context).size.height;

    // 1. Update positions and filter out-of-bounds entities
    for (var entity in _gameState.entities) {
      var newY = entity.y;
      if (entity.type == EntityType.enemy) newY += entity.speed;
      if (entity.type == EntityType.bullet) newY -= entity.speed;
      
      // Keep entity if it's on screen
      if (newY < 1.1 && newY > -0.2) {
         updatedEntities.add(entity.copyWith(y: newY));
      }
    }

    // 2. Collision Detection
    final bullets = updatedEntities.where((e) => e.type == EntityType.bullet).toList();
    final enemies = updatedEntities.where((e) => e.type == EntityType.enemy).toList();
    GameEntity? player = updatedEntities.firstWhere(
      (e) => e.type == EntityType.player,
      orElse: () => throw Exception('Player not found'),
    );

    final Set<String> collidedEntityIds = {};
    int scoreGained = 0;
    int enemiesHit = 0;

    // Check Bullet-Enemy collisions
    for (final bullet in bullets) {
      for (final enemy in enemies) {
        if (bullet.collidesWith(enemy)) {
          collidedEntityIds.add(bullet.id);
          collidedEntityIds.add(enemy.id);
          scoreGained += enemy.points;
          enemiesHit++;
        }
      }
    }
    
    // Check Player-Enemy collisions
    if (player != null && !player.isInvincible) {
        for (final enemy in enemies) {
            if (!collidedEntityIds.contains(enemy.id) && player!.collidesWith(enemy)) {
                collidedEntityIds.add(enemy.id);
                player = player.copyWith(health: player.health - 1, isInvincible: true);
                if (player.health <= 0) {
                    _endGame('玩家陣亡!');
                    return;
                }
                // Reset combo on hit
                _gameState = _gameState.copyWith(combo: 0);
                
                // Start invincibility timer
                Timer(const Duration(seconds: 2), () {
                   setState(() {
                      final currentPlayer = _gameState.player;
                      if(currentPlayer != null) {
                         _gameState = _gameState.copyWith(entities: _gameState.entities.map((e) => e.id == 'player' ? e.copyWith(isInvincible: false) : e).toList());
                      }
                   });
                });
            }
        }
    }
    
    // Update player instance in the list
    updatedEntities = updatedEntities.map((e) => e.id == 'player' ? player! : e).toList();


    // 3. Update game state and remove collided entities
    if (collidedEntityIds.isNotEmpty) {
      updatedEntities.removeWhere((e) => collidedEntityIds.contains(e.id));
      
      final newCombo = _gameState.combo + enemiesHit;
      
      setState(() {
         _gameState = _gameState.copyWith(
           entities: updatedEntities,
           score: _gameState.score + scoreGained,
           enemiesDestroyed: _gameState.enemiesDestroyed + enemiesHit,
           combo: newCombo,
           maxCombo: math.max(newCombo, _gameState.maxCombo),
         );
      });
    } else {
       // If no collisions, just update the entities
       setState(() {
         _gameState = _gameState.copyWith(entities: updatedEntities);
       });
    }
  }


  void _handlePlayerMove(DragUpdateDetails details) {
    final player = _gameState.player;
    if (player == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    
    // Clamp player position to stay within the screen bounds
    final newX = (player.x + details.delta.dx / screenWidth).clamp(0.0, 1.0 - player.width);

    setState(() {
      _gameState = _gameState.copyWith(
        entities: _gameState.entities.map((e) {
          if (e.id == player.id) {
            return e.copyWith(x: newX);
          }
          return e;
        }).toList(),
      );
    });
  }

  void _shoot() {
    final player = _gameState.player;
    if (player == null) return;

    final bullet = GameEntity(
      id: 'bullet_${DateTime.now().millisecondsSinceEpoch}',
      type: EntityType.bullet,
      x: player.x + player.width / 2 - 0.01, // Center of player
      y: player.y,
      width: 0.02,
      height: 0.04,
      speed: 0.015,
    );

    setState(() {
      _gameState = _gameState.copyWith(
        entities: [..._gameState.entities, bullet],
      );
    });
  }

  void _endGame(String title) {
    _stopGameTimers();
    if (_gameState.isGameOver) return;
    
    setState(() {
      _gameState = _gameState.copyWith(isGameOver: true);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最終分數: ${_gameState.calculateScore()}'),
            Text('最大連擊: ${_gameState.maxCombo}'),
            Text('擊敗敵人: ${_gameState.enemiesDestroyed}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to main menu
            },
            child: const Text('返回主選單'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _initializeGame();
            },
            child: const Text('重新開始'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = _gameState.player;

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: _handlePlayerMove,
        onTap: _shoot,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ Colors.blue.shade900, Colors.black, ],
            ),
          ),
          child: Stack(
            children: [
              // Game entities
              ..._gameState.entities.map((entity) => EntityWidget(entity: entity)),

              // UI elements
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScoreBoard(
                      score: _gameState.calculateScore(),
                      combo: _gameState.combo,
                    ),
                    Column(
                       children: [
                           TimerWidget(
                             timeLeft: _gameState.timeLeft,
                           ),
                           const SizedBox(height: 10),
                           if (player != null) PlayerHealth(health: player.health),
                       ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}