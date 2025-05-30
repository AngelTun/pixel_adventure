// Clase que representa una "hitbox" personalizada para colisiones
class CustomHitbox {
  // Distancia en pixeles desde la esquina superior izquierda del sprite hacia la derecha
  final double offsetX;
  // Distancia en pixeles desde la esquina superior izquierda del sprite hacia abajo
  final double offsetY;
  // Ancho de la hitbox (área de colisión)
  final double width;
  // Alto de la hitbox (área de colisión)
  final double height;

  // Constructor que recibe y asigna los valores de la hitbox
  CustomHitbox({
    required this.offsetX,   // Obligatorio: desplazamiento en X
    required this.offsetY,   // Obligatorio: desplazamiento en Y
    required this.width,     // Obligatorio: ancho de la hitbox
    required this.height,    // Obligatorio: alto de la hitbox
  });
}
