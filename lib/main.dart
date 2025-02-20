import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() {
  // para asegurar que los widgets de Flutter estén inicializados antes de ejecutar el juego
  WidgetsFlutterBinding.ensureInitialized();

  // Pone el juego en pantalla completa
  Flame.device.fullScreen();

  // para establecer la orientación del juego en modo horizontal 
  Flame.device.setLandscape();

  // Crea una instancia del juego
  PixelAdventure game = PixelAdventure();

  // Inicia el juego en un widget de Flutter
  runApp(
    GameWidget(
      game: kDebugMode ? PixelAdventure() : game, // Si está en modo debug, crea una nueva instancia
    ),
  );
}
