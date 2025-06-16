import 'package:flutter/material.dart';

enum EntityType {
  player,
  enemy,
  bullet,
  powerUp,
}

class GameEntity {
  final String id;
  final EntityType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double speed;
  final int health;
  final int points;
  bool isActive;
  bool isInvincible; // ADDED: For player invincibility after being hit

  GameEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    this.health = 1,
    this.points = 0,
    this.isActive = true,
    this.isInvincible = false, // ADDED
  });

  GameEntity copyWith({
    String? id,
    EntityType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? speed,
    int? health,
    int? points,
    bool? isActive,
    bool? isInvincible, // ADDED
  }) {
    return GameEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      health: health ?? this.health,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      isInvincible: isInvincible ?? this.isInvincible, // ADDED
    );
  }

  Color get color {
    switch (type) {
      case EntityType.player:
        // Change color when invincible
        return isInvincible ? Colors.blue.withOpacity(0.5) : Colors.blue;
      case EntityType.enemy:
        return Colors.red;
      case EntityType.bullet:
        return Colors.yellow;
      case EntityType.powerUp:
        return Colors.green;
    }
  }

  bool collidesWith(GameEntity other) {
    // Simple Axis-Aligned Bounding Box (AABB) collision detection
    return x < other.x + other.width &&
           x + width > other.x &&
           y < other.y + other.height &&
           y + height > other.y;
  }
}