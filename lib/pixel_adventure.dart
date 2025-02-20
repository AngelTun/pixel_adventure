import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/levels/level.dart';

// Clase principal del juego, extiende de FlameGame
class PixelAdventure extends FlameGame {
  // Define el color de fondo del juego
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Color oscuro

  // Componente de la cámara
  late final CameraComponent cam;

  // Mundo del juego, o niver que se carga
  final world = Level(
    levelName: 'Level-02',
  );

  @override
  Future<void> onLoad() async {
    // Carga todas las imágenes en caché para optimizar el rendimiento
    await images.loadAllImages();

    // Configuración de la cámara con una resolución fija de 640x360
    cam = CameraComponent.withFixedResolution(
      world: world, // Se asigna el mundo (nivel) a la cámara
      width: 640, 
      height: 360,
    );

    // Ancla la cámara en la esquina superior izquierda
    cam.viewfinder.anchor = Anchor.topLeft;

    // Agrega la cámara y el mundo al juego
    addAll([cam, world]);

    return super.onLoad();
  }
}
