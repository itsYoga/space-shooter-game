import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final int score;
  final int combo;

  const ScoreBoard({
    Key? key,
    required this.score,
    required this.combo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '分數: $score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            child: Text(
              '連擊: $combo',
              key: ValueKey<int>(combo), // Important for AnimatedSwitcher
              style: TextStyle(
                color: combo > 0 ? Colors.yellow : Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}