import 'package:experimental_battle_ai/actors/enemies/enemy.dart';
import 'package:experimental_battle_ai/actors/state.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

enum FlyingEyeAnimation { flight, bite, dash, heal, hurt, death }

class FlyingEye extends Enemy {
  FlyingEye({required super.player}) : super(
    template: EnemyTemplate.flyingEye,
    maxEnemyCount: 5
  );

  late final SpriteAnimation flightAnimation;
  late final SpriteAnimation biteAnimation;
  late final SpriteAnimation dashAnimation;
  late final SpriteAnimation healAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation deathAnimation;

  late final State bite;
  late final State dash;
  late final State heal;

  @override
  void onMount() {
    super.onMount();
    speed = 200;
  }

  @override
  void loadAnimations() {
    flightAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/flight.png', 
      AnimationConfig(
        amount: 9, 
        stepTime: 0.2, 
        textureSize: Vector2.all(150)
      )
    );

    biteAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/attack.png', 
      AnimationConfig(
        amount: 8, 
        stepTime: 0.2, 
        textureSize: Vector2.all(150),
        loop: false
      )
    );

    dashAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/attack2.png', 
      AnimationConfig(
        amount: 8, 
        stepTime: 0.2, 
        textureSize: Vector2.all(150),
        loop: false
      )
    );

    healAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/attack3.png', 
      AnimationConfig(
        amount: 6, 
        stepTime: 0.2, 
        textureSize: Vector2.all(150),
        loop: false
      )
    );

    hurtAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/hurt.png', 
      AnimationConfig(
        amount: 4, 
        stepTime: 0.1,
        textureSize: Vector2.all(150),
        loop: false
      )
    );

    deathAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/death.png', 
      AnimationConfig(
        amount: 4, 
        stepTime: 0.1, 
        textureSize: Vector2.all(150),
        loop: false
      )
    );
  }

  @override
  void loadStates() {
    idle.onEnter = () {
      if (current != FlyingEyeAnimation.flight) setAnimation(FlyingEyeAnimation.flight);
    };

    follow
    ..onEnter = () {
      if (current != FlyingEyeAnimation.flight) setAnimation(FlyingEyeAnimation.flight);
    }
    ..onUpdate = (dt) {
       direction = (player.position - position).normalized();
       if (direction.x > 0) {
        if (isFlippedHorizontally) flipHorizontally();
       } else if (direction.x < 0) {
        if (!isFlippedHorizontally) flipHorizontally();
       }

       velocity = direction * speed;
       position.add(velocity * dt);
    };
  }
}