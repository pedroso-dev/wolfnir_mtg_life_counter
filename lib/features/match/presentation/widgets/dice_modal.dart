import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/strings.dart';

class DiceModal extends StatefulWidget {
  const DiceModal({super.key});

  @override
  State<DiceModal> createState() => _DiceModalState();
}

class _DiceModalState extends State<DiceModal> {
  String? _singleResult;
  int? _p1Result;
  int? _p2Result;
  final _random = Random();

  void _rollD6() {
    setState(() {
      _singleResult = null;
      _p1Result = _random.nextInt(6) + 1;
      _p2Result = _random.nextInt(6) + 1;
    });
  }

  void _rollD20() {
    setState(() {
      _singleResult = null;
      _p1Result = _random.nextInt(20) + 1;
      _p2Result = _random.nextInt(20) + 1;
    });
  }

  void _flipCoin() {
    setState(() {
      _p1Result = null;
      _p2Result = null;
      final isHeads = _random.nextBool();
      _singleResult = isHeads ? AppStrings.heads : AppStrings.tails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppStrings.rollDice,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Display the result
          Container(
            height: 100,
            alignment: Alignment.center,
            child: _buildResultDisplay(),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionCard(
                title: AppStrings.coinFlip,
                icon: Icons.monetization_on,
                onTap: _flipCoin,
              ),
              _ActionCard(
                title: AppStrings.rollD6,
                icon: Icons.casino,
                onTap: _rollD6,
              ),
              _ActionCard(
                title: AppStrings.rollD20,
                icon: Icons.star,
                onTap: _rollD20,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    // Se for moeda, mostra um resultado único
    if (_singleResult != null) {
      return Text(
        _singleResult!,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.amberAccent,
        ),
      );
    }
    // Se for dado, mostra o placar duplo
    else if (_p1Result != null && _p2Result != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PlayerScore(
            label: AppStrings.player1,
            score: _p1Result!,
            color: Colors.blue.shade400,
          ),
          const Text(
            'VS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          _PlayerScore(
            label: AppStrings.player2,
            score: _p2Result!,
            color: Colors.red.shade400,
          ),
        ],
      );
    }

    // Estado inicial
    return const Text(
      '...',
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.amberAccent,
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _PlayerScore({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
