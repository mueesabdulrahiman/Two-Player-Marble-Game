import 'package:flutter/material.dart';
import 'package:orbito/screens/game_screen.dart';
import 'package:orbito/provider/game_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const TwoPlayerMarbleGame(),
    ),
  );
}

