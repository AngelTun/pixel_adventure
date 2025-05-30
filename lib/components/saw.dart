// Importación de librerías necesarias
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Clase Saw, representa una sierra que puede moverse horizontal o verticalmente
class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  // Indica si la sierra se mueve en vertical (true) o horizontal (false)
  final bool isVertical;
  // Offset negativo para determinar el rango de movimiento (hacia atrás)
  final double offNeg;
  // Offset positivo para determinar el rango de movimiento (hacia adelante)
  final double offPos;

  // Constructor, recibe si es vertical, los offsets, posición y tamaño
  Saw({
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
    position, 
    size,
  }) : super(
      position: position, 
      size: size,
    );

  // Constantes para velocidad de animación y movimiento, y el tamaño del tile
  static const double sawSpeed = 0.03;  // Velocidad de animación de la sierra
  static const moveSpeed = 50;          // Velocidad de movimiento de la sierra
  static const tileSize = 16;           // Tamaño de cada tile

  double moveDirection = 1;   // Dirección actual de movimiento (1 o -1)
  double rangeNeg = 0;        // Límite negativo de movimiento
  double rangePos = 0;        // Límite positivo de movimiento

  // Método que se ejecuta cuando la sierra se carga en el juego
  @override
  FutureOr<void> onLoad() {
    priority = -1;           // Prioridad de renderizado (dibuja por detrás)
    add(CircleHitbox());     // Agrega un hitbox circular para detectar colisiones

    // Calcula los límites del movimiento dependiendo si es vertical u horizontal
    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    // Carga la animación de la sierra desde las imágenes en caché
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'), 
      SpriteAnimationData.sequenced(
        amount: 8,           // Número de frames de la animación
        stepTime: sawSpeed,  // Tiempo entre cada frame
        textureSize: Vector2.all(38), // Tamaño de cada frame
      )
    );
    return super.onLoad();
  }

  // Método de actualización por frame
  @override
  void update(double dt) {
    // Si es vertical, mueve la sierra en el eje Y; si no, en el eje X
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }
  
  // Movimiento vertical de la sierra (sube y baja entre límites)
  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1; // Cambia de dirección al llegar al límite superior
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;  // Cambia de dirección al llegar al límite inferior
    }
    position.y += moveDirection * moveSpeed * dt; // Actualiza posición en Y
  }
  
  // Movimiento horizontal de la sierra (va y viene entre límites)
  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1; // Cambia de dirección al llegar al extremo derecho
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;  // Cambia de dirección al llegar al extremo izquierdo
    }
    position.x += moveDirection * moveSpeed * dt; // Actualiza posición en X
  }
}
