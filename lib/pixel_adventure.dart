import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';

// Clase principal del juego, extiende de FlameGame
class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks{
  // Define el color de fondo del juego
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Color oscuro

  // Componente de la cámara
  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = false;

  @override
  Future<void> onLoad() async {
    // Carga todas las imágenes en caché para optimizar el rendimiento
    await images.loadAllImages();

      // Mundo del juego, o niver que se carga
  final world = Level(
    player: player,
    levelName: 'Level-01',
  );

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

    if (showJoystick){
    addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick){
    updateJoystick();
    }
    super.update(dt);
  }
  
  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png'),
        ),
      ),
      background:  SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
      //Idle
        player.horizontalMovement = 0;
        break;
    }
  }
}
