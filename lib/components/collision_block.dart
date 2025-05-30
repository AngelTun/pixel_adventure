import 'package:flame/components.dart';

// Clase que representa un bloque de colisión (pared, piso, plataforma, etc.)
class CollisionBlock extends PositionComponent {
  // Indica si el bloque es una plataforma (solo se puede pisar por arriba)
  bool isPlatform;

  // Constructor del bloque, recibe posición, tamaño y si es plataforma (por defecto no lo es)
  CollisionBlock({
    position,
    size,
    this.isPlatform = false,
  }) : super(
        position: position,
        size: size,
      ) {
    // debugMode = true; // Para ver el bloque dibujado en pantalla (útil para pruebas)
  }
}
