import 'package:flutter/material.dart';

class SentimentDot extends StatelessWidget {
  final double sentiment;
  final double size;

  const SentimentDot({super.key, required this.sentiment, this.size = 8.0});

  Color _getColor() {
    if (sentiment < -0.15) return const Color(0xFFFF4757); // Negative
    if (sentiment > 0.15) return const Color(0xFF00D4AA); // Positive
    return const Color(0xFFF5A623); // Neutral
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getColor().withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class SubjectivityDot extends StatelessWidget {
  final double subjectivity;
  final double size;

  const SubjectivityDot({super.key, required this.subjectivity, this.size = 8.0});

  Color _getColor() {
    if (subjectivity > 0.15) return const Color(0xFFFF4757); // High Subjectivity / Opinionated (Red)
    if (subjectivity < -0.15) return const Color(0xFF00D4AA); // Low Subjectivity / Factual (Green)
    return const Color(0xFFF5A623); // Moderate (Amber)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getColor().withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class SentimentBar extends StatelessWidget {
  final double sentiment;
  final double width;
  final double height;

  const SentimentBar({
    super.key,
    required this.sentiment,
    this.width = 60.0,
    this.height = 4.0,
  });

  Color _getColor() {
    if (sentiment < -0.3) return const Color(0xFFFF4757); // Negative
    if (sentiment > 0.3) return const Color(0xFF00D4AA); // Positive
    return const Color(0xFFF5A623); // Neutral
  }

  @override
  Widget build(BuildContext context) {
    // Normalize -1 to 1 into 0.0 to 1.0 for fill percentage
    final double fillPercentage = (sentiment + 1) / 2;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fillPercentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 1,
              height: height,
              color: const Color(0xFF141414), // Center tick
            ),
          ),
        ],
      ),
    );
  }
}
