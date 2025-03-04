import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player.dart';

// Clase que representa un nivel en el juego
class Level extends World {
  // Nombre del nivel (se usará para cargar el archivo correspondiente)
  final String levelName;
  final Player player;
  // Constructor que recibe el nombre del nivel
  Level({required this.levelName, required this.player});

  // Variable para almacenar el mapa del nivel cargado desde un archivo .tmx
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    // Carga el archivo TMX del nivel, escalando cada tile a 16x16 píxeles
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    // Agrega el mapa del nivel a la escena
    add(level);

    // Obtiene la capa de objetos llamada 'Spawnpoints' del archivo TMX
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if(spawnPointsLayer !=null){

          // Itera sobre los objetos de la capa de puntos de aparición
    for (final spawnPoint in spawnPointsLayer.objects) {
      switch (spawnPoint.class_) {
        // Si el objeto tiene la clase 'Player', se crea un jugador en esa posición
        case 'Player':
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player); // Se agrega el jugador al nivel
          break;
        default:
          // Si el objeto no es un 'Player', no se hace nada
      }
    }
    }

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer !=null){
      for (final collision in collisionsLayer.objects){
        switch (collision.class_){
          case 'Platform':
          final platform = CollisionBlock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
            isPlatform: true,
          );
          collisionBlocks.add(platform);
          add(platform);
          break;
        default:
        final block = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
        );
        collisionBlocks.add(block);
        add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }
}
