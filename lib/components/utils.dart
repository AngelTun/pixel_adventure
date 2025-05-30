// Función que verifica si el jugador (player) colisiona con un bloque (block)
bool checkCollision(player, block) {
  // Obtiene la caja de colisiones (hitbox) del jugador
  final hitbox = player.hitbox;
  // Calcula la posición X real del jugador considerando el offset de la hitbox
  final playerX = player.position.x + hitbox.offsetX;
  // Calcula la posición Y real del jugador considerando el offset de la hitbox
  final playerY = player.position.y + hitbox.offsetY;
  // Obtiene el ancho de la hitbox del jugador
  final playerWidth = hitbox.width;
  // Obtiene la altura de la hitbox del jugador
  final playerHeight = hitbox.height;

  // Obtiene la posición y dimensiones del bloque
  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Ajusta la posición X del jugador según la dirección en la que mira (escala negativa)
  final fixedX = player.scale.x < 0 
      ? playerX - (hitbox.offsetX * 2) - playerWidth // Si mira a la izquierda, ajusta más la posición
      : playerX; // Si mira a la derecha, usa la posición normal

  // Ajusta la posición Y si el bloque es una plataforma
  final fixedY = block.isPlatform 
      ? playerY + playerHeight // Si es plataforma, toma la parte de abajo del jugador
      : playerY; // Si no, toma la parte de arriba

  // Retorna true si hay colisión (intersección de rectángulos)
  return (
    fixedY < blockY + blockHeight &&           // El jugador está por encima del fondo del bloque
    playerY + playerHeight > blockY &&         // El fondo del jugador está por debajo del tope del bloque
    fixedX < blockX + blockWidth &&            // El jugador está a la izquierda del lado derecho del bloque
    fixedX + playerWidth > blockX              // El lado derecho del jugador está a la derecha del lado izquierdo del bloque
  );
}
