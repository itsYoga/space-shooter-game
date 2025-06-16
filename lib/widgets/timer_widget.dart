import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timeLeft;

  const TimerWidget({
    Key? key,
    required this.timeLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = timeLeft ~/ 60;
    final seconds = timeLeft % 60;
    final isLowTime = timeLeft <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.withOpacity(0.5) : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isLowTime ? Colors.red : Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isLowTime ? Colors.red : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}