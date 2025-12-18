import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

class Skull extends SpriteAnimationComponent with HasGameReference<ExperimentalBattle> {
  Skull({
    required super.position, 
    required this.player
  }): super(anchor: Anchor.center);

  final Player player;
  late final Vector2 direction;
  Vector2 velocity = Vector2.zero();
  static const double speed = 400;

  @override
  void onLoad() {
    super.onLoad();
    priority = 10;

    animation = game.createSpriteAnimation(
      'vfx/elites/necromancer/skull.png', 
      AnimationConfig(
        amount: 7, 
        stepTime: 0.1, 
        textureSize: Vector2.all(48),
      )
    );

    scale = Vector2.all(.5);
  }

  @override
  void onMount() {
    super.onMount();
    direction = (player.position - absolutePosition).normalized();
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity = direction * speed;
    position.add(velocity * dt);

    if (isOutOfCamera(this)) {
      removeFromParent();
    }
  }

  bool isOutOfCamera(PositionComponent component) {
    final cameraRect = game.camera.visibleWorldRect;
    final componentRect = component.toRect();

    return cameraRect.overlaps(componentRect);
  }
}