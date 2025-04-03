import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Enum para definir los estados del jugador
enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent
  with HasGameRef<PixelAdventure>, KeyboardHandler{
  
  // Nombre del personaje (puede haber diferentes skins o modelos)
  String character;

  // Constructor de la clase Player
  Player({
   position,
   this.character = 'Ninja Frog',
   }) : super(position: position);

  // Tiempo entre cada cuadro de la animación
  final double stepTime = 0.05;
  // Variables para almacenar las animaciones del personaje
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  

  final double _gravity = 9.8;
  final double _jumpForce = 280;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;

  //Para establecer la velocidad de movimiento del jugador
  double moveSpeed = 100;
  //Para controlar las direcciones x, y
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  List <CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  FutureOr<void> onLoad() {
    // Carga todas las animaciones al inicializar el personaje
    _loadAllAnimations();
    //debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  //Para actualizar el movimiento del jugador
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA)||
      keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD)|| 
    keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;


    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);


    
    return super.onKeyEvent(event, keysPressed);
  }

  // Método para cargar todas las animaciones del personaje
  void _loadAllAnimations() {
    // Se crean las animaciones para cada estado del personaje
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);

    // Asigna las animaciones al mapa de animaciones del personaje
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
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

    void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x >0){
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }

    //Para comprobar si se esta moviendo, y poner la animación
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    //Para comprobar si esta configurada para caer
    if (velocity.y > 0) playerState = PlayerState.falling;

    //Para comprobar si salta
    if(velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }
  
void _updatePlayerMovement(double dt) {

  if (hasJumped && isOnGround) _playerJump(dt);

  //if(velocity.y > _gravity) isOnGround = false;
 
  // Actualiza la velocidad del jugador en el eje X con el valor de dirX
  velocity.x = horizontalMovement * moveSpeed;
  
  // Actualiza la posición del jugador multiplicando la velocidad por el tiempo transcurrido para asegurar un movimiento suave
  position.x += velocity.x * dt;


  }

    void _playerJump(double dt) {
      velocity.y = -_jumpForce;
      position.y += velocity.y * dt;
      isOnGround = false;
      hasJumped = false;
    }
  
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      //Manejar los limites
      if (!block.isPlatform) {
        if (checkCollision(this, block)){
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  void _checkVerticalCollisions() {
    for(final block in collisionBlocks) {
      if (block.isPlatform){
        if (checkCollision(this, block)){
          if(velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      }else {
        if (checkCollision(this, block)) {
          if(velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
}
