import 'package:flutter/material.dart';
import 'package:orbito/models/move.dart';
import 'package:orbito/provider/game_provider.dart';
import 'package:provider/provider.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        leading: IconButton(
          icon: const 
           Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            gameProvider.resetGame();
          },
        ),
        actions: [
          Text('Total Moves: ${gameProvider.gameHistory.length}'),
          const SizedBox(width: 5.0),
        ],
      ),
      body: gameProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: gameProvider.gameHistory.length,
              itemBuilder: (context, index) {
                final move = gameProvider.gameHistory[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                            "${move.player} - ${move.type == MoveType.moveOwn ? 'Moved Own Marble' : 'Moved Opponent Marble'}"),
                        Text(move.type == MoveType.moveOpponent
                            ? "Took From - Row: ${move.fromPosition![0]} & Column: ${move.fromPosition![1]} \n  Placed To - Row: ${move.placedPosition![0]} Column: ${move.placedPosition![1]}"
                            : "Placed To - Row: ${move.placedPosition![0]} & Column: ${move.placedPosition![1]}"),
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                            ),
                            itemBuilder: (context, gridIndex) {
                              int row = gridIndex ~/ 4;
                              int col = gridIndex % 4;
                              return Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: move.placedPosition != null &&
                                          move.placedPosition![0] == row &&
                                          move.placedPosition![1] == col
                                      ? Colors.yellow
                                      : Colors.grey[300],
                                  border: move.type == MoveType.moveOpponent &&
                                          move.fromPosition![0] == row &&
                                          move.fromPosition![1] == col
                                      ? Border.all(
                                          color: Colors.green, width: 2)
                                      : Border.all(color: Colors.black),
                                ),
                                child: Center(
                                  child: Text(move.boardState[row][col] ?? ''),
                                ),
                              );
                            },
                            itemCount: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
