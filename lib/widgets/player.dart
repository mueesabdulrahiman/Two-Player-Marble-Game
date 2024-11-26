import 'package:flutter/material.dart';

Column player(String playerType, String playerNumber, Color playerColor) {
    return Column(children: [
      Container(
          height: 40,
          width: 40,
          color: playerColor,
          child: Center(
            child: Text(
              playerType,
              style: const TextStyle(color: Colors.white),
            ),
          )),
      const SizedBox(
        height: 5.0,
      ),
      Text('Player $playerNumber')
    ]);
  }