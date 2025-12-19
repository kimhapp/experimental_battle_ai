import 'dart:math';

import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Projectile extends SpriteAnimationComponent with HasGameReference<ExperimentalBattle> {
  Projectile({
    required super.position,
    required this.direction
  }): super(anchor: Anchor.center); // anchor is the middle point of the laser orb

  final Vector2 direction;
  Vector2 velocity = Vector2.zero();
  static const double speed = 400;

  @override
  void onLoad() {
    super.onLoad();
    priority = 10;

    animation = game.createSpriteAnimation(
      'vfx/player/projectile.png', 
      AnimationConfig(
        amount: 8, 
        stepTime: 0.1, 
        textureSize: Vector2.all(128),
      )
    );

    add(RectangleHitbox());

    scale = Vector2.all(.25);
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