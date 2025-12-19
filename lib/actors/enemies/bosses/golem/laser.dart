import 'dart:math';

import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class Laser extends SpriteAnimationComponent with HasGameReference<ExperimentalBattle> {
  Laser({
    required super.position, 
    required this.player,
    required this.onComplete,
  }): super(anchor: Anchor(23 / textureSizeX, 22 / textureSizeY)); // anchor is the middle point of the laser orb

  static const double textureSizeX = 271;
  static const double textureSizeY = 44;

  final Player player;
  final VoidCallback onComplete;
  final Timer rotateDuration = Timer(1, autoStart: false);
  static const double rotateSpeed = 3;

  double rotationDirection = 0; 

  @override
  void onLoad() {
    super.onLoad();
    priority = 10;

    animation = game.createSpriteAnimation(
      'vfx/bosses/golem/laser.png', 
      AnimationConfig(
        amount: 13, 
        stepTime: 0.1, 
        textureSize: Vector2(textureSizeX, textureSizeY),
        loop: false,
        amountPerRow: 1
      )
    );

    print("starting laser!");

    animationTicker!.onComplete = () { 
      double targetAngle = angleTo(player.position);
      double currentAngle = angle;
      double angleDiff = targetAngle - currentAngle;
      
      if (angleDiff > pi) angleDiff -= 2 * pi;
      if (angleDiff < -pi) angleDiff += 2 * pi;
      
      rotationDirection = angleDiff.sign;

      rotateDuration.start();
    };

    scale = Vector2.all(.5);
  }

  @override
  void onMount() {
    super.onMount();
    Vector2 direction = (player.position - absolutePosition).normalized();
    angle = atan2(direction.y, direction.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (rotateDuration.isRunning()) {
      angle += rotationDirection * rotateSpeed * dt;
    }

    rotateDuration.update(dt);

    if (rotateDuration.finished) {
      onComplete.call();
      print("removing laser!");
      removeFromParent();
    }
  }
}