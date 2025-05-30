import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Enum que define los posibles estados de la gallina (enemigo)
enum State { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  // Rango de movimiento a la izquierda (negativo) y derecha (positivo)
  final double offNeg;
  final double offPos;

  // Constructor, permite definir posición, tamaño y rangos de movimiento
  Chicken({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  // Constantes para animación, físicas y tamaño
  static const stepTime = 0.05;     // Tiempo entre frames de animación
  static const tileSize = 16;       // Tamaño de un tile para el rango
  static const runSpeed = 80;       // Velocidad de movimiento
  static const _bounceHeight = 260.0; // Rebote del jugador al pisar la gallina
  final textureSize = Vector2(32, 34); // Tamaño de cada frame de animación

  Vector2 velocity = Vector2.zero(); // Velocidad del enemigo
  double rangeNeg = 0;               // Límite izquierdo de movimiento
  double rangePos = 0;               // Límite derecho de movimiento
  double moveDirection = 1;          // Dirección actual del movimiento
  double targetDirection = -1;       // Dirección hacia la que "apunta" para moverse
  bool gotStomped = false;           // ¿La gallina fue pisada por el jugador?

  // Referencia al jugador (para saber si está cerca)
  late final Player player;
  // Animaciones de la gallina para cada estado
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;

  // Se ejecuta al cargar la gallina al juego
  @override
  FutureOr<void> onLoad() {
    // debugMode = true; // Descomenta para ver la hitbox
    player = game.player;

    // Agrega un hitbox rectangular para colisiones con el jugador
    add(
      RectangleHitbox(
        position: Vector2(4, 6),
        size: Vector2(24, 26),
      ),
    );
    _loadAllAnimations(); // Carga todas las animaciones
    _calculateRange();    // Calcula el rango de movimiento permitido
    return super.onLoad();
  }

  // Actualiza el estado del enemigo en cada frame
  @override
  void update(double dt) {
    if (!gotStomped) {
      _updateState();   // Actualiza animación y dirección visual
      _movement(dt);    // Mueve la gallina si el jugador está en rango
    }
    super.update(dt);
  }

  // Carga las animaciones de idle, correr y ser golpeada
  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 15)..loop = false;

    animations = {
      State.idle: _idleAnimation,
      State.run: _runAnimation,
      State.hit: _hitAnimation,
    };

    current = State.idle;
  }

  // Helper para crear una animación desde los archivos del enemigo
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  // Calcula el rango permitido de movimiento de la gallina
  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  // Controla el movimiento de la gallina (solo persigue al jugador si está en rango)
  void _movement(dt) {
    velocity.x = 0; // Resetea la velocidad horizontal

    // Cálculos para corregir la detección según dirección visual del jugador y gallina
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    // Si el jugador está en el rango definido, persigue
    if (playerInRange()) {
      // Determina hacia qué dirección moverse
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    // Suaviza el cambio de dirección para que no sea brusco
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    // Actualiza la posición en X usando la velocidad y el tiempo
    position.x += velocity.x * dt;
  }

  // Verifica si el jugador está dentro del rango horizontal y vertical del enemigo
  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  // Actualiza el estado visual (animación) de la gallina y su dirección
  void _updateState() {
    current = (velocity.x != 0) ? State.run : State.idle;

    // Cambia la dirección del sprite si cambia de lado (para que "mire" al jugador)
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  // Método llamado cuando el jugador colisiona con la gallina
  void collidedWithPlayer() async {
    // Si el jugador cae sobre la gallina (velocidad en Y positiva y cae desde arriba)
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume); // Sonido de rebote
      }
      gotStomped = true;        // Marca a la gallina como derrotada
      current = State.hit;      // Cambia la animación a golpeada
      player.velocity.y = -_bounceHeight; // Rebota al jugador hacia arriba
      await animationTicker?.completed;   // Espera que termine la animación de hit
      removeFromParent();      // Elimina a la gallina del juego
    } else {
      // Si el jugador la toca de lado, el jugador muere o recibe daño
      player.collidedwithEnemy();
    }
  }
}
