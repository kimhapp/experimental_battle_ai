import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

class HealVisual extends SpriteAnimationComponent with HasGameReference<ExperimentalBattle> {
  HealVisual({required super.position}): super(anchor: Anchor.center);

  @override
  void onLoad() {
    super.onLoad();
    priority = 10;

    animation = game.createSpriteAnimation(
      'vfx/minions/flying_eye/heal.png', 
      AnimationConfig(
        amount: 13, 
        stepTime: 0.05, 
        textureSize: Vector2(128, 192),
        loop: false
      )
    );
    scale = Vector2.all(.5);

    animationTicker!.onComplete = () => removeFromParent();
  }
}