import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';

// Clase principal del juego, extiende de FlameGame
class PixelAdventure extends FlameGame 
    with 
      HasKeyboardHandlerComponents, 
      DragCallbacks, 
      HasCollisionDetection, 
      TapCallbacks {
  // Define el color de fondo del juego
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Color oscuro

  // Componente de la cámara
  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showControls = false;
  bool playSounds = true;
  double soundVolume = 1.0;
  List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  Future<void> onLoad() async {
    // Carga todas las imágenes en caché para optimizar el rendimiento
    await images.loadAllImages();

    _loadLevel();

    if (showControls){
    addJoystick();
    add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls){
    updateJoystick();
    }
    super.update(dt);
  }
  
  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
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

  void loadNextLevel() {
    if(currentLevelIndex <levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      //No mas niveles
      currentLevelIndex = 0;
      _loadLevel();
    }
  }
  
  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), (){
  // Mundo del juego, o niver que se carga
  Level world = Level(
    player: player,
    levelName: levelNames[currentLevelIndex],
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
    });

  }
}
