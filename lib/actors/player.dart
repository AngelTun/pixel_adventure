import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Enum para definir los estados del jugador
enum PlayerState { idle, running }

//Enum para definir los movimientos del jugador
enum PlayerDirection {left, right, none}

class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure> {
  
  // Nombre del personaje (puede haber diferentes skins o modelos)
  String character;

  // Constructor de la clase Player
  Player({position, required this.character}) : super(position: position);

  // Variables para almacenar las animaciones del personaje
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;

  // Tiempo entre cada cuadro de la animación
  final double stepTime = 0.05;
  
  //Para establecer la velocidad de movimiento del jugador
  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  //Para controlar las direcciones x, y
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    // Carga todas las animaciones al inicializar el personaje
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  //Para actualizar el movimiento del jugador
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  // Método para cargar todas las animaciones del personaje
  void _loadAllAnimations() {
    // Se crean las animaciones para cada estado del personaje
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);

    // Asigna las animaciones al mapa de animaciones del personaje
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

    // Establece la animación inicial en 'idle'
    current = PlayerState.idle;
  }

  // Método que carga una animación desde los archivos de imágenes en caché
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      // Obtiene la imagen desde la caché del juego según el estado y el personaje
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount, // Número de cuadros de la animación
        stepTime: stepTime, // Tiempo entre cada cuadro
        textureSize: Vector2.all(32), // Tamaño de cada cuadro en píxeles (32x32)
      ),
    );
  }
  
void _updatePlayerMovement(double dt) {
  // Inicializa la variable dirX con un valor de 0.0, indicando que el jugador no se moverá horizontalmente por defecto.
  double dirX = 0.0;
  
  // Revisa la dirección del jugador almacenada en playerDirection y realiza la acción correspondiente.
  switch (playerDirection) {
    
    // Si la dirección es hacia la izquierda
    case PlayerDirection.left:
      // Cambia el estado del jugador a "corriendo"
      current = PlayerState.running;
      // Indica que el jugador se moverá a la izquierda con la velocidad de movimiento
      dirX -= moveSpeed;
      break;
    
    // Si la dirección es hacia la derecha
    case PlayerDirection.right:
      // Cambia el estado del jugador a "corriendo"
      current = PlayerState.running;
      // Indica que el jugador se moverá a la derecha con la velocidad de movimiento (moveSpeed)
      dirX += moveSpeed;
      break;
    
    // Si no hay movimiento el playerDirection es none
    case PlayerDirection.none:
      // Cambia el estado del jugador a "inactivo"
      current = PlayerState.idle;
      break;
    default:
  }

  // Actualiza la velocidad del jugador en el eje X con el valor de dirX 
  velocity = Vector2(dirX, 0.0);
  
  // Actualiza la posición del jugador multiplicando la velocidad por el tiempo transcurrido para asegurar un movimiento suave
  position += velocity * dt;


  }
}
