// Importa librerías y componentes necesarios para el manejo de niveles, mapas y objetos del juego
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

// Clase que representa un nivel completo del juego
class Level extends World with HasGameRef<PixelAdventure> {
  // Nombre del nivel (usado para cargar el archivo correspondiente)
  final String levelName;
  // Instancia del jugador que se usará en este nivel
  final Player player;

  // Constructor, requiere el nombre del nivel y el jugador
  Level({required this.levelName, required this.player});

  // Variable donde se guarda el mapa cargado desde un archivo .tmx
  late TiledComponent level;
  // Lista de bloques de colisión presentes en el nivel
  List<CollisionBlock> collisionBlocks = [];

  // Se ejecuta cuando se carga el nivel
  @override
  FutureOr<void> onLoad() async {
    // Carga el archivo TMX con el mapa del nivel, usando tiles de 16x16
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    // Agrega el mapa del nivel a la escena
    add(level);

    // Agrega fondo, objetos y colisiones al nivel
    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }
  
  // Método para agregar un fondo de color o imagen al nivel
  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      // Lee el color del fondo desde las propiedades del mapa
      final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');
      // Crea un BackgroundTile y lo agrega al mundo
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }
  
  // Método que agrega todos los objetos del mapa al mundo del juego
  void _spawningObjects() {
    // Obtiene la capa de objetos "Spawnpoints" del mapa
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      // Itera sobre cada objeto de spawn (aparición)
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          // Si el objeto es un jugador, lo coloca en esa posición
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = -1; // Escala inicial (por si el sprite mira a la izquierda)
            add(player);         // Agrega el jugador al mundo
            break;
          // Si es una fruta, la agrega en la posición indicada
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          // Si es una sierra, la agrega y configura sus propiedades
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);
            break;
          // Si es un checkpoint, lo agrega
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          // Si es un pollo enemigo, lo agrega y configura su rango de movimiento
          case 'Chicken':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(chicken);
            break;
          default:
            // Si el objeto no coincide con los anteriores, no hace nada
        }
      }
    }
  }
  
  // Método que agrega los bloques de colisión al mundo y al jugador
  void _addCollisions() {
    // Obtiene la capa de colisiones del mapa
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          // Si el bloque es una plataforma (solo se puede pisar por arriba)
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform); // Lo agrega a la lista de bloques
            add(platform);                 // Lo agrega al mundo
            break;
          // Si es un bloque normal (colisión total)
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
    // Le pasa al jugador la lista de bloques de colisión para que pueda detectar choques
    player.collisionBlocks = collisionBlocks;
  }
}
