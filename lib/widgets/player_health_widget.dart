import 'package:flutter/material.dart';

class PlayerHealth extends StatelessWidget {
  final int health;

  const PlayerHealth({
    Key? key,
    required this.health,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'HP:',
            style: TextStyle(
              color: Colors.green[200],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < health ? Icons.favorite : Icons.favorite_border,
                color: index < health ? Colors.red : Colors.grey,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}