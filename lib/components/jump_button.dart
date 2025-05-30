// Importa librerías y dependencias necesarias
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Clase JumpButton: crea un botón táctil para saltar, visible en pantalla (útil en móvil)
class JumpButton extends SpriteComponent 
  with HasGameRef<PixelAdventure>, TapCallbacks {
  // Constructor vacío
  JumpButton();

  // Margen respecto al borde inferior-derecho de la pantalla
  final margin = 32;
  // Tamaño del botón en píxeles
  final butttonSize = 64;

  // Se ejecuta cuando el botón se carga en el juego
  @override
  FutureOr<void> onLoad() {
    // Carga el sprite (imagen) del botón desde la caché
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    // Posiciona el botón en la esquina inferior derecha, considerando el margen y tamaño
    position = Vector2(
      game.size.x - margin - butttonSize,
      game.size.y - margin - butttonSize,
    );
    // Le da prioridad alta para que esté siempre por encima de otros elementos
    priority = 10;
    return super.onLoad();
  }

  // Se ejecuta cuando se presiona el botón
  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true; // Indica al jugador que debe saltar
    super.onTapDown(event);
  }

  // Se ejecuta cuando se suelta el botón
  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false; // El salto termina cuando se suelta
    super.onTapUp(event);
  }
}
