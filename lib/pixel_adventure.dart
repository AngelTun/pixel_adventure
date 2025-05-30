// Importación de librerías y componentes necesarios para el juego
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';

// Clase principal del juego PixelAdventure
class PixelAdventure extends FlameGame 
    with 
      HasKeyboardHandlerComponents, // Permite manejar entradas de teclado
      DragCallbacks,                // Permite manejar eventos de arrastre
      HasCollisionDetection,        // Permite detectar colisiones
      TapCallbacks {                // Permite manejar eventos de toque (tap)
  
  // Color de fondo del juego
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Color oscuro de fondo

  // Declaración de la cámara del juego
  late CameraComponent cam;
  // Instancia del jugador, usando el personaje 'Mask Dude'
  Player player = Player(character: 'Mask Dude');
  // Componente del joystick virtual
  late JoystickComponent joystick;
  // Mostrar controles en pantalla (móvil)
  bool showControls = false;
  // Controla si los sonidos están activos
  bool playSounds = true;
  // Volumen de los sonidos
  double soundVolume = 1.0;
  // Lista de nombres de los niveles
  List<String> levelNames = ['Level-01', 'Level-01'];
  // Índice del nivel actual
  int currentLevelIndex = 0;

  // Método que se ejecuta cuando el juego termina de cargar
  @override
  Future<void> onLoad() async {
    // Carga todas las imágenes en caché para optimizar el rendimiento
    await images.loadAllImages();

    // Carga el nivel actual
    _loadLevel();

    // Si se activan los controles táctiles, agrega el joystick y el botón de salto
    if (showControls){
      addJoystick();
      add(JumpButton());
    }

    // Llama al método onLoad de la clase padre
    return super.onLoad();
  }

  // Método que actualiza el estado del juego en cada frame
  @override
  void update(double dt) {
    // Si están activos los controles, actualiza el joystick
    if (showControls){
      updateJoystick();
    }
    // Llama al método update de la clase padre
    super.update(dt);
  }
  
  // Método para agregar el joystick virtual al juego
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
      margin: const EdgeInsets.only(left: 32, bottom: 32), // Margen del joystick
    );

    add(joystick); // Agrega el joystick a la escena del juego
  }
  
  // Método para actualizar la dirección del joystick y mover al jugador
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1; // Movimiento hacia la izquierda
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1; // Movimiento hacia la derecha
        break;
      default:
        // Cuando el joystick está en reposo
        player.horizontalMovement = 0;
        break;
    }
  }

  // Método para cargar el siguiente nivel
  void loadNextLevel() {
    if(currentLevelIndex <levelNames.length - 1) {
      currentLevelIndex++; // Pasa al siguiente nivel
      _loadLevel();
    } else {
      // Si no hay más niveles, regresa al primero
      currentLevelIndex = 0;
      _loadLevel();
    }
  }
  
  // Método privado para cargar el nivel actual
  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), (){ // Espera 1 segundo antes de cargar el nivel
      // Crea el mundo del juego (nivel actual)
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      // Configuración de la cámara con resolución fija 640x360
      cam = CameraComponent.withFixedResolution(
        world: world, // Asigna el mundo a la cámara
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
