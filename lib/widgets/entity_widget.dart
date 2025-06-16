import 'package:flutter/material.dart';
import '../models/game_entity.dart';

class EntityWidget extends StatelessWidget {
  final GameEntity entity;

  const EntityWidget({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Hide inactive entities (they will be removed in the next frame)
    if (!entity.isActive) return const SizedBox.shrink();

    return Positioned(
      left: entity.x * screenSize.width,
      top: entity.y * screenSize.height,
      child: Container(
        width: entity.width * screenSize.width,
        height: entity.height * screenSize.height,
        decoration: BoxDecoration(
          color: entity.color,
          shape: entity.type == EntityType.bullet ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: entity.type == EntityType.bullet ? BorderRadius.circular(5) : null,
          boxShadow: [
            BoxShadow(
              color: entity.color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _buildEntityContent(),
      ),
    );
  }

  Widget _buildEntityContent() {
    switch (entity.type) {
      case EntityType.player:
        return const Icon(Icons.rocket_launch, color: Colors.white, size: 20);
      case EntityType.enemy:
        return const Icon(Icons.public, color: Colors.white, size: 20);
      case EntityType.bullet:
        return const SizedBox.shrink(); // The container itself is the visual
      case EntityType.powerUp:
        return const Icon(Icons.star, color: Colors.white, size: 20);
    }
  }
}