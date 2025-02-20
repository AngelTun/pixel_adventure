import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';

// Clase que representa un nivel en el juego
class Level extends World {
  // Nombre del nivel (se usará para cargar el archivo correspondiente)
  final String levelName;

  // Constructor que recibe el nombre del nivel
  Level({required this.levelName});

  // Variable para almacenar el mapa del nivel cargado desde un archivo .tmx
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    // Carga el archivo TMX del nivel, escalando cada tile a 16x16 píxeles
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    // Agrega el mapa del nivel a la escena
    add(level);

    // Obtiene la capa de objetos llamada 'Spawnpoints' del archivo TMX
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    // Itera sobre los objetos de la capa de puntos de aparición
    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        // Si el objeto tiene la clase 'Player', se crea un jugador en esa posición
        case 'Player':
          final player = Player(
            character: 'Ninja Frog', // Se establece el personaje del jugador
            position: Vector2(spawnPoint.x, spawnPoint.y), // Se usa la posición definida en el mapa
          );
          add(player); // Se agrega el jugador al nivel
          break;
        default:
          // Si el objeto no es un 'Player', no se hace nada
      }
    }

    return super.onLoad();
  }
}
