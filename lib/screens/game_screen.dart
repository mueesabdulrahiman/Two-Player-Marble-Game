import 'package:flutter/material.dart';
import 'package:orbito/provider/game_provider.dart';
import 'package:orbito/screens/game_history_screen.dart';
import 'package:orbito/widgets/player.dart';
import 'package:provider/provider.dart';

class TwoPlayerMarbleGame extends StatelessWidget {
  const TwoPlayerMarbleGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const GameScreen(),
        '/history': (context) => const GameHistoryScreen(),
      },
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Two-Player Counterclockwise Marble Game')),
      body: Column(
        children: [
          Text(gameProvider.isPlayerOneTurn
              ? "Player 1's Turn"
              : "Player 2's Turn"),
          Text(
            "Time Remaining: ${gameProvider.remainingTime} seconds",
            style: const TextStyle(color: Colors.red),
          ),
          for (int row = 0; row < 4; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int col = 0; col < 4; col++)
                  GestureDetector(
                    onTap: () {
                      if (gameProvider.isMovingOpponent) {
                        gameProvider.moveOpponentMarble(row, col);
                      } else {
                        gameProvider.placeMarble(context, row, col);
                      }
                    },
                    onLongPress: () {
                      gameProvider.startMoveOpponent(row, col);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            gameProvider.winningCells.contains('$row,$col') &&
                                    !gameProvider.simultaneousWin
                                ? Colors.green
                                : gameProvider.board[row][col] == null
                                    ? Colors.grey
                                    : gameProvider.isMovingOpponent &&
                                            gameProvider.selectedRow == row &&
                                            gameProvider.selectedCol == col
                                        ? gameProvider.board[row][col]!
                                                .startsWith('x')
                                            ? Colors.blue[800]
                                            : Colors.red[800]
                                        : gameProvider.board[row][col]!
                                                .startsWith('x')
                                            ? Colors.blue
                                            : Colors.red,
                        border: Border.all(color: Colors.black),
                        boxShadow: gameProvider.isMovingOpponent &&
                                gameProvider.selectedRow == row &&
                                gameProvider.selectedCol == col
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  blurRadius: 8.0,
                                  spreadRadius: 3.0,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          gameProvider.board[row][col] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
              onPressed: gameProvider.resetGame,
              child: const Text('Reset Game')),
          const SizedBox(
            height: 10.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            player('x', '1', Colors.blue),
            player('y', '2', Colors.red),
          ]),
        ],
      ),
    );
  }
}



