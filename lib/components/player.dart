// Importación de librerías y componentes necesarios
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Enum para definir los diferentes estados del jugador
enum PlayerState { idle, running, jumping, falling, hit, appearing, disappearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  // Nombre del personaje (permite tener diferentes skins)
  String character;

  // Constructor que permite establecer posición inicial y nombre del personaje
  Player({
    position,
    this.character = 'Ninja Frog',
  }) : super(position: position);

  // Tiempo entre cuadros de las animaciones
  final double stepTime = 0.05;

  // Animaciones para cada estado del jugador
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  // Variables físicas y de movimiento
  final double _gravity = 9.8;          // Gravedad que afecta al jugador
  final double _jumpForce = 260;        // Fuerza de salto
  final double _terminalVelocity = 300; // Velocidad máxima de caída
  double horizontalMovement = 0;        // Movimiento horizontal (-1 izquierda, 1 derecha)
  double moveSpeed = 100;               // Velocidad de movimiento del jugador
  Vector2 startingPosition = Vector2.zero(); // Posición inicial del jugador
  Vector2 velocity = Vector2.zero();    // Velocidad actual (x, y)

  // Estados lógicos del jugador
  bool isOnGround = false;       // ¿Está en el suelo?
  bool hasJumped = false;        // ¿Ha saltado?
  bool gotHit = false;           // ¿Recibió daño?
  bool reachedCheckpoint = false;// ¿Llegó a un checkpoint?

  // Colisiones y hitbox personalizada
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  // Variables para controlar el fixed time step (update estable)
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  // Se ejecuta al cargar el componente en el juego
  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); // Carga todas las animaciones del personaje

    // Guarda la posición de inicio para futuros respawns
    startingPosition = Vector2(position.x, position.y);

    // Agrega un hitbox rectangular para detectar colisiones
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    // Llama al método onLoad de la clase padre
    return super.onLoad();
  }

  // Actualiza el jugador cada frame, usando fixed time step
  @override
  void update(double dt) {
    accumulatedTime += dt;

    // Bucle para actualizar usando pasos fijos
    while (accumulatedTime >= fixedDeltaTime) {
      // Solo se mueve y detecta colisiones si no fue golpeado y no alcanzó checkpoint
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  // Maneja eventos de teclado (para PC)
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    // Detecta teclas de movimiento a la izquierda (A o flecha izquierda)
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    // Detecta teclas de movimiento a la derecha (D o flecha derecha)
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    // Ajusta la dirección de movimiento
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    // Detecta salto con barra espaciadora
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  // Detecta el inicio de una colisión con otro componente
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();     // Toca una fruta
      if (other is Saw) _respawn();                       // Toca una sierra
      if (other is Chicken) other.collidedWithPlayer();   // Toca un enemigo pollo
      if (other is Checkpoint) _reachedCheckpoint();      // Llega a un checkpoint
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  // Carga y configura todas las animaciones del jugador
  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    // Asigna todas las animaciones al componente
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Estado inicial: quieto
    current = PlayerState.idle;
  }

  // Método para crear una animación a partir de los sprites de un estado
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount, // Cuadros de la animación
        stepTime: stepTime, // Tiempo por cuadro
        textureSize: Vector2.all(32), // Tamaño del sprite (32x32)
      ),
    );
  }

  // Animaciones especiales, por ejemplo aparecer/desaparecer
  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  // Actualiza el estado visual (animación) del jugador según su movimiento
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    // Cambia la dirección visual del sprite si cambia de lado
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    // Animación de correr si se está moviendo horizontalmente
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    // Animación de caer si está bajando
    if (velocity.y > 0) playerState = PlayerState.falling;
    // Animación de salto si está subiendo
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  // Actualiza la posición y velocidad horizontal del jugador
  void _updatePlayerMovement(double dt) {
    // Realiza el salto si está en el suelo y se presionó saltar
    if (hasJumped && isOnGround) _playerJump(dt);

    // Actualiza la velocidad horizontal
    velocity.x = horizontalMovement * moveSpeed;
    // Actualiza la posición horizontal según la velocidad y el tiempo
    position.x += velocity.x * dt;
  }

  // Aplica la lógica de salto del jugador
  void _playerJump(double dt) {
    if (game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);
    velocity.y = -_jumpForce;        // Da un impulso hacia arriba
    position.y += velocity.y * dt;   // Ajusta la posición inmediatamente
    isOnGround = false;              // Ya no está en el suelo
    hasJumped = false;               // Resetea el estado de salto
  }

  // Revisa colisiones horizontales con los bloques
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
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

  // Aplica la gravedad al jugador en el eje Y
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity); // Limita la velocidad máxima de caída
    position.y += velocity.y * dt;
  }

  // Revisa colisiones verticales con los bloques y plataformas
  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
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

  // Hace reaparecer al jugador en su posición inicial tras recibir daño
  void _respawn() async {
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;

    // Espera a que termine la animación de hit
    await animationTicker?.completed;
    animationTicker?.reset();

    // Reaparece con efecto de aparición
    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    // Espera a que termine la animación de aparición
    await animationTicker?.completed;
    animationTicker?.reset();

    // Restablece posición y estado
    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  // Lógica cuando llega a un checkpoint
  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    if (game.playSounds) FlameAudio.play('disappear.wav', volume: game.soundVolume);
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    // Espera animación
    await animationTicker?.completed;
    animationTicker?.reset();
    reachedCheckpoint = false;
    position = Vector2.all(-640);

    // Espera 3 segundos y carga el siguiente nivel
    const waitToChangeDuration = Duration(seconds: 3);
    Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
  }

  // Si colisiona con un enemigo, reaparece
  void collidedwithEnemy() {
    _respawn();
  }
}
