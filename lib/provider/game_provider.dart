import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orbito/models/move.dart';
import 'package:orbito/widgets/dialogbox.dart';

class GameProvider extends ChangeNotifier {

  List<List<String?>> board = List.generate(4, (_) => List.filled(4, null));
  bool _isPlayerOneTurn = true;
  String? _winner;
  bool _simultaneousWin = false;
  bool _gameDraw = false;
  int _playerOneMarble = 1;
  int _playerTwoMarble = 1;
  bool _isMovingOpponent = false;
  int? _selectedRow, _selectedCol;
  String? _selectedValue;
  Set<String> _winningCells = {};
  Timer? _timer;
  int _remainingTime = 30;
  List<Move> _gameHistory = [];
  int _moveCount = 0;
  bool _isLoading = false;

  bool get isPlayerOneTurn => _isPlayerOneTurn;
  int? get remainingTime => _remainingTime;
  bool get isMovingOpponent => _isMovingOpponent;
  Set<String> get winningCells => _winningCells;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  List<Move> get gameHistory => _gameHistory;
  bool get isLoading => _isLoading;
  bool get simultaneousWin => _simultaneousWin;

  GameProvider() {
    startTimer();
  }

  // timer

  void startTimer() {
    _timer?.cancel();
    _remainingTime = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_remainingTime > 0) {
        _remainingTime--;
      } else {
        t.cancel();
        switchTurn();
      }
      notifyListeners();
    });
  }

  void switchTurn() {
    _isPlayerOneTurn = !_isPlayerOneTurn;
    startTimer();
    notifyListeners();
  }

  

  void placeMarble(BuildContext context, int row, int col) {
    if (board[row][col] == null &&
        !_gameDraw &&
        (_playerOneMarble <= 8 || _playerTwoMarble <= 8)) {
      board[row][col] =
          _isPlayerOneTurn ? 'x$_playerOneMarble' : 'y$_playerTwoMarble';
      _isPlayerOneTurn ? _playerOneMarble++ : _playerTwoMarble++;
      _moveCount++;
      _gameHistory.add(
        Move(
          player: _isPlayerOneTurn ? "Player 1" : "Player 2",
          type: MoveType.moveOwn,
          boardState: _copyBoard(),
          placedPosition: [row, col],
        ),
      );
      _timer?.cancel();
      rotateMarblesCounterClockwise(context);
      if (_winner == null && !_gameDraw) switchTurn();
      notifyListeners();
    }
  }

  List<List<String?>> _copyBoard() {
    return List.generate(4, (i) => List.from(board[i]));
  }

  void startMoveOpponent(int row, int col) {
    if (board[row][col] != null &&
        board[row][col]!.startsWith(_isPlayerOneTurn ? 'y' : 'x')) {
      _selectedRow = row;
      _selectedCol = col;
      _selectedValue = board[row][col];
      _isMovingOpponent = true;
      notifyListeners();
    }
  }

  void moveOpponentMarble(int row, int col) {
    if (_isMovingOpponent && _selectedRow != null && _selectedCol != null) {
      if ((row == _selectedRow! &&
              (col == _selectedCol! - 1 || col == _selectedCol! + 1)) ||
          (col == _selectedCol! &&
              (row == _selectedRow! - 1 || row == _selectedRow! + 1))) {
        if (board[row][col] == null) {
          board[_selectedRow!][_selectedCol!] = null;
          board[row][col] = _selectedValue;

          // Save the move to game history
          _gameHistory.add(
            Move(
              player: _isPlayerOneTurn ? "Player 1" : "Player 2",
              type: MoveType.moveOpponent,
              boardState: _copyBoard(),
              fromPosition: [_selectedRow!, _selectedCol!],
              placedPosition: [row, col],
            ),
          );

          _isMovingOpponent = false;

          notifyListeners();
        }
      }
    }
  }

  void rotateMarblesCounterClockwise(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _rotateOuterRing();
      _rotateInnerRing();
      checkWin(context);
      notifyListeners();
    });
  }

  void _rotateOuterRing() {
    String? tempOuter = board[0][0];
    board[0][0] = board[0][1];
    board[0][1] = board[0][2];
    board[0][2] = board[0][3];
    board[0][3] = board[1][3];
    board[1][3] = board[2][3];
    board[2][3] = board[3][3];
    board[3][3] = board[3][2];
    board[3][2] = board[3][1];
    board[3][1] = board[3][0];
    board[3][0] = board[2][0];
    board[2][0] = board[1][0];
    board[1][0] = tempOuter;
  }

  void _rotateInnerRing() {
    String? tempInner = board[1][1];
    board[1][1] = board[1][2];
    board[1][2] = board[2][2];
    board[2][2] = board[2][1];
    board[2][1] = tempInner;
  }

  void checkWin(BuildContext context) {
    // Unified condition to check wins or simultaneous alignment
    String? player1 = 'x';
    String? player2 = 'y';

    bool player1Wins = _checkPlayerAlignment(player1);
    bool player2Wins = _checkPlayerAlignment(player2);

    if (player1Wins && player2Wins) {
      // Simultaneous alignment, so it's Draw
      _gameDraw = true;
      _simultaneousWin = true;
      showResultDialog(context, null, true);
    } else if (player1Wins) {
      // Player 1 wins
      _winner = player1;
      showResultDialog(context, player1, false);
    } else if (player2Wins) {
      // Player 2 wins
      _winner = player2;
      showResultDialog(context, player2, false);
    } else if (_winner == null && _moveCount == 16) {
      // All moves are made, and it's a draw
      _gameDraw = true;
      showResultDialog(context, null, true);
    }
  }

  bool _checkPlayerAlignment(String player) {
    // Check rows
    for (int i = 0; i < 4; i++) {
      if (board[i][0]?[0] == player &&
          board[i][1]?[0] == player &&
          board[i][2]?[0] == player &&
          board[i][3]?[0] == player) {
        _winningCells.addAll(['$i,0', '$i,1', '$i,2', '$i,3']);
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 4; i++) {
      if (board[0][i]?[0] == player &&
          board[1][i]?[0] == player &&
          board[2][i]?[0] == player &&
          board[3][i]?[0] == player) {
        _winningCells.addAll(['0,$i', '1,$i', '2,$i', '3,$i']);
        return true;
      }
    }

    // Check main diagonal
    if (board[0][0]?[0] == player &&
        board[1][1]?[0] == player &&
        board[2][2]?[0] == player &&
        board[3][3]?[0] == player) {
      _winningCells.addAll(['0,0', '1,1', '2,2', '3,3']);
      return true;
    }

    // Check anti-diagonal
    if (board[0][3]?[0] == player &&
        board[1][2]?[0] == player &&
        board[2][1]?[0] == player &&
        board[3][0]?[0] == player) {
      _winningCells.addAll(['0,3', '1,2', '2,1', '3,0']);
      return true;
    }

    return false;
  }

  void resetGame() {
    _timer?.cancel();
    board = List.generate(4, (_) => List.filled(4, null));
    _isPlayerOneTurn = true;
    _winner = null;
    _simultaneousWin = false;
    _gameDraw = false;
    _moveCount = 0;
    _playerOneMarble = 1;
    _playerTwoMarble = 1;
    _winningCells = {};
    _remainingTime = 30;
    _gameHistory = [];

    startTimer();
    notifyListeners();
  }

  Future<void> progressIndicator() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }
}
