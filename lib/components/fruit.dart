// Importa las librerías necesarias
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Clase que representa una fruta coleccionable en el juego
class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  // Nombre de la fruta, por defecto es 'Apple'
  final String fruit;

  // Constructor de la fruta (puede especificar el nombre, posición y tamaño)
  Fruit({
    this.fruit = 'Apple', 
    position, 
    size,
  }) : super(
      position: position,
      size: size,
    );

  // Tiempo entre cuadros de la animación
  final double stepTime = 0.05;

  // Hitbox personalizada para detectar colisiones precisas
  final hitbox = CustomHitbox(
    offsetX: 10, 
    offsetY: 10, 
    width: 12, 
    height: 12,
  );

  // Indica si la fruta ya fue recolectada
  bool collected = false;

  // Método que se ejecuta cuando se carga el objeto en el juego
  @override
  FutureOr<void> onLoad() {
    //debugMode = true; // (Descomenta para ver las hitboxes)
    priority = -1; // Se dibuja detrás de otros objetos por defecto

    // Agrega un hitbox rectangular pasivo para la fruta
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive, // Solo detecta colisiones, no las causa
      ),
    );

    // Carga la animación de la fruta (sprite sheet de 17 cuadros, 32x32 px)
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,         // Cuadros de animación (por ejemplo, girando)
        stepTime: stepTime, // Tiempo por cuadro
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
  
  // Método que se llama cuando el jugador recoge la fruta
  void collidedWithPlayer() async {
    if (!collected) {
      collected = true; // Marca la fruta como recolectada
      // Reproduce sonido de colección, si están activados
      if (game.playSounds) FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);

      // Cambia la animación a la de fruta recogida (un efecto especial)
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,           // Animación de recoger fruta (6 cuadros)
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,         // No se repite
        ),
      );

      // Espera a que termine la animación de recoger y luego elimina la fruta de la escena
      await animationTicker?.completed;
      removeFromParent();
    }
  }
}
