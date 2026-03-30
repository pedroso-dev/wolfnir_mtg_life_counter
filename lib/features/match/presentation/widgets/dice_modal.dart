import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/match_cubit.dart';

class DiceModal extends StatefulWidget {
  const DiceModal({super.key});

  @override
  State<DiceModal> createState() => _DiceModalState();
}

class _DiceModalState extends State<DiceModal> {
  final _random = Random();
  final Map<String, int> _results = {};
  bool _isRolling = false;

  // Rola o dado para todos os IDs presentes na partida
  void _rollDice(List<String> playerIds) async {
    setState(() => _isRolling = true);

    for (int i = 0; i < 12; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() {
        for (var id in playerIds) {
          _results[id] = _random.nextInt(20) + 1;
        }
      });
    }

    setState(() => _isRolling = false);
  }

  Color _getPlayerColor(String id) {
    switch (id) {
      case 'player_1':
        return Colors.blue.shade400;
      case 'player_2':
        return Colors.red.shade400;
      case 'player_3':
        return Colors.green.shade400;
      case 'player_4':
        return Colors.purple.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Buscamos os jogadores atuais do estado do Cubit
    final playerIds = context.read<MatchCubit>().state.players.keys.toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "ROLAR DADOS (D20)",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Grid dinâmico que se ajusta a 2, 3 ou 4 jogadores
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: playerIds.map((id) {
              final result = _results[id] ?? 20;
              final color = _getPlayerColor(id);

              return Column(
                children: [
                  Text(
                    id.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                      color: color.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: _isRolling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "$result",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isRolling ? null : () => _rollDice(playerIds),
              icon: const Icon(Icons.casino),
              label: const Text(
                "ROLAR PARA TODOS",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
