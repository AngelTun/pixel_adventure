bool checkCollision(player, block){
  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = player.width;
  final playerHeight = player.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fireX = player.scale.x < 0 ? playerX - playerWidth : playerX;

  return (
    playerY < blockY + blockHeight &&
    playerY + playerHeight > blockY &&
    fireX < blockX + blockWidth &&
    fireX + playerWidth > blockX
    
  );
}