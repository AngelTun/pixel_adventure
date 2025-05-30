import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Clase que representa un fondo (background) parallax para el nivel
class BackgroundTile extends ParallaxComponent {
  // Nombre o color del fondo (ejemplo: 'Gray')
  final String color;

  // Constructor, recibe color y posición inicial (opcional)
  BackgroundTile({
    this.color = 'Gray',
    position,
  }) : super(
      position: position,
    );

  // Velocidad de desplazamiento del fondo para el efecto parallax
  final double scrollSpeed = 0.4;

  // Se ejecuta al cargar el componente en el juego
  @override
  FutureOr<void> onLoad() async {
    priority = -10;              // Se dibuja en el fondo, detrás de otros objetos
    size = Vector2.all(64);      // Tamaño del tile de fondo

    // Carga el parallax, que es una imagen de fondo que se repite y se mueve
    parallax = await (findGame() as PixelAdventure).loadParallax([
        ParallaxImageData('Background/$color.png'),
      ],
      baseVelocity: Vector2(0, -scrollSpeed), // Velocidad de movimiento vertical (hacia arriba)
      repeat: ImageRepeat.repeat,             // La imagen se repite para llenar todo el fondo
      fill: LayerFill.none,                   // No estira la imagen, solo la repite
    );
    return super.onLoad();
  }
}
