import 'package:flutter/material.dart';
import 'package:orbito/provider/game_provider.dart';
import 'package:provider/provider.dart';

void showResultDialog(BuildContext context, String? winner, bool gameDraw) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(gameDraw
            ? 'It\'s a Draw!'
            : '${winner == 'x' ? 'Player 1' : 'Player 2'} Wins!'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false).resetGame();
              Navigator.of(context).pop();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              final gameProvider =
                  Provider.of<GameProvider>(context, listen: false);
              gameProvider.progressIndicator();
              navigator.pushNamed('/history',
                  arguments: gameProvider.gameHistory);
            },
            child: const Text('Game History'),
          ),
        ],
      ),
    );
  }
