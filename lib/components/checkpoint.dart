import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Clase que representa un checkpoint (punto de control) en el juego
class Checkpoint extends SpriteAnimationComponent 
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  // Constructor: recibe la posición y el tamaño del checkpoint
  Checkpoint({
    position,
    size
  }) : super(
    position: position,
    size: size,
  );

  // Se ejecuta al cargar el checkpoint en el juego
  @override
  FutureOr<void> onLoad() {
    // Agrega un hitbox rectangular para detectar colisiones con el jugador
    add(RectangleHitbox(
      position: Vector2(18, 56),         // Desplazamiento del hitbox respecto al sprite
      size: Vector2(12, 8),              // Tamaño del hitbox
      collisionType: CollisionType.passive, // Solo detecta, no bloquea
    ));

    // Carga la animación inicial: checkpoint sin bandera
    animation = SpriteAnimation.fromFrameData(
      game.images
        .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(
        amount: 1,                     // Solo 1 frame (sin animación)
        stepTime: 1,                   // Tiempo por frame (irrelevante con solo 1 frame)
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  // Se ejecuta cuando empieza una colisión con otro objeto
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) _reachedCheckpoint(); // Si el jugador toca el checkpoint, llama a la función correspondiente
    super.onCollisionStart(intersectionPoints, other);
  }

  // Método que se llama cuando el jugador llega al checkpoint
  void _reachedCheckpoint() async {
    // Cambia la animación para mostrar la bandera saliendo
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,           // Animación de la bandera saliendo (26 cuadros)
        stepTime: 0.05,       // Velocidad de la animación
        textureSize: Vector2.all(64),
        loop: false,          // No se repite, ocurre una sola vez
      ),
    );

    await animationTicker?.completed;   // Espera que termine la animación

    // Cambia a la animación "idle" de la bandera ondeando
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 10,         // Animación de la bandera ondeando (10 cuadros)
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
