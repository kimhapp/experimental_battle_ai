import 'dart:math';

import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent with HasGameReference<ExperimentalBattle> {
  Bullet({
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

    sprite = Sprite(game.images.fromCache('vfx/bosses/golem/bullet.png'));

    scale = Vector2.all(1);
  }

  @override
  void onMount() {
    super.onMount();
    direction = (player.position - absolutePosition).normalized();
    angle = atan2(direction.y, direction.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity = direction * speed;
    position.add(velocity * dt);

    if (isOutOfCamera(this)) removeFromParent();
  }

  bool isOutOfCamera(PositionComponent component) {
    final cameraRect = game.camera.visibleWorldRect;
    final componentRect = component.toRect();

    return cameraRect.overlaps(componentRect);
  }
}