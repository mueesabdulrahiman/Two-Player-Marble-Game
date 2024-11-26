enum MoveType { moveOwn, moveOpponent }

class Move {
  final String player;
  final MoveType type;
  final List<List<String?>> boardState;
  final List<int>? fromPosition;
  final List<int>? placedPosition;

  Move({
    required this.player, 
    required this.type,
    required this.boardState,
    this.fromPosition,
    this.placedPosition,
  });
}