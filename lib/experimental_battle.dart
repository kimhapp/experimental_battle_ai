import 'package:experimental_battle_ai/actors/enemies/bosses/golem/golem.dart';
import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/game_hud.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class ExperimentalBattle extends FlameGame with HasCollisionDetection {
  final double width = 640;
  final double height = 360;
  final GameHud gameHud = GameHud();
  late Player player;

  static const List<String> levelNames = ['arena'];

  @override
  void onLoad() async {
    await images.loadAllImages();
    add(gameHud);
  }

  @override
  void onMount() {
    super.onMount();
    _loadLevel();
  }

  void _loadLevel() {
    player = Player(
      moveJoystick: gameHud.moveJoystick,
      aimJoystick: gameHud.aimJoystick
    );
    final world = GameWorld(levelName: levelNames[0], player: player);
    
    camera = CameraComponent.withFixedResolution(
      width: width, 
      height: height, 
      world: world
    );
    camera.viewfinder.anchor = Anchor.center;
    camera.follow(player);

    addAll([world, camera]);
    gameHud.addHud();
  }

  SpriteAnimation createSpriteAnimation(String path, AnimationConfig config) {
    return SpriteAnimation.fromFrameData(
        images.fromCache(path),
        SpriteAnimationData.sequenced(
            amount: config.amount,
            stepTime: config.stepTime,
            textureSize: Vector2(config.textureSize.x, config.textureSize.y),
            loop: config.loop,
            amountPerRow: config.amountPerRow
        )
    );
  }
}

class GameWorld extends World with HasGameReference<ExperimentalBattle> {
  GameWorld({required this.levelName, required this.player});
  String levelName;
  Player player;

  late TiledComponent map;
  static const double tileLevelSize = 16;

  @override
  void onLoad() async {
    try {
      map = await TiledComponent.load('$levelName.tmx', Vector2.all(tileLevelSize));
      add(map);

      _spawningObjects();
    } catch (e) {
      throw Exception(
        'Failed to load map: $levelName.tmx\n'
        'Error: $e\n'
        'Possible reasons:\n'
        '- File not found in assets\n'
        '- Map might be set to "Infinite" in Tiled (check Map → Map Properties)\n'
        '- TMX file might be corrupted\n'
        '- Tileset images not found or paths incorrect in TMX file'
      );
    }
    debugMode = true;
  }

  void _spawningObjects() {
    final spawnPointsLayer = map.tileMap.getLayer<ObjectGroup>('spawn_points');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case "player":
            player.position = spawnPoint.position;
            Golem golem = Golem(player: player)..position = player.position - Vector2.all(100);
            add(golem);
            add(player);
            break;
        }
      }
    }
  }
}

class AnimationConfig {
  final int amount;
  final double stepTime;
  final Vector2 textureSize;
  final bool loop;
  final int? amountPerRow;

  const AnimationConfig({
    required this.amount,
    required this.stepTime,
    required this.textureSize,
    this.loop = true,
    this.amountPerRow
  });
}