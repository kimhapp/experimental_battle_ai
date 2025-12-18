import 'package:experimental_battle_ai/actors/enemies/elites/necromancer/skull.dart';
import 'package:experimental_battle_ai/actors/enemies/enemy.dart';
import 'package:experimental_battle_ai/actors/state.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum NecromancerAnimationState { idle, move, shoot, castFromGround, castFromSky, hurt, death }

class Necromancer extends Enemy {
  Necromancer({required super.player}) : super(
    template: EnemyTemplate.necromancer,
    maxEnemyCount: 1
  );

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation moveAnimation;
  late final SpriteAnimation shootAnimation;
  late final SpriteAnimation castFromGroundAnimation;
  late final SpriteAnimation castFromSkyAnimation;
  late final SpriteAnimation hurtAnimation;
  late final SpriteAnimation deathAnimation;

  late final State shoot;
  late final State castFromSky;
  late final State castFromGround;

  final Vector2 _skullPoint = Vector2(55, 47); // Based on sprite

  @override
  void onLoad() {
    super.onLoad();
    hitbox = RectangleHitbox(
      size: Vector2(33, 48),
      anchor: anchor,
      position: size / 2
    )..onCollisionStartCallback = onCollideWithHitbox;

    add(hitbox);
  }

  @override
  void onMount() {
    super.onMount();
    speed = 200;
    setState(shoot);
  }

  @override
  void loadAnimations() {
    idleAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/idle.png', 
      AnimationConfig(
        amount: 8, 
        stepTime: 0.2, 
        textureSize: Vector2.all(128)
      )
    );
    
    moveAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/move.png', 
      AnimationConfig(
        amount: 8, 
        stepTime: 0.2, 
        textureSize: Vector2.all(128)
      )
    );

    shootAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/shoot.png', 
      AnimationConfig(
        amount: 17, 
        stepTime: 0.1, 
        textureSize: Vector2.all(128),
        loop: false
      )
    );

    castFromGroundAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/cast_from_ground.png', 
      AnimationConfig(
        amount: 9, 
        stepTime: 0.2, 
        textureSize: Vector2.all(128)
      )
    );

    castFromSkyAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/cast_from_sky.png', 
      AnimationConfig(
        amount: 9, 
        stepTime: 0.2, 
        textureSize: Vector2.all(128)
      )
    );

    hurtAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/hurt.png', 
      AnimationConfig(
        amount: 9, 
        stepTime: 0.2, 
        textureSize: Vector2.all(128)
      )
    );

    deathAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/death.png', 
      AnimationConfig(
        amount: 9, 
        stepTime: 0.2, 
        textureSize: Vector2.all(128)
      )
    );

    animations = {
      NecromancerAnimationState.idle: idleAnimation,
      NecromancerAnimationState.move: moveAnimation,
      NecromancerAnimationState.shoot: shootAnimation,
      NecromancerAnimationState.castFromGround: castFromGroundAnimation,
      NecromancerAnimationState.castFromSky: castFromSkyAnimation,
      NecromancerAnimationState.hurt: hurtAnimation,
      NecromancerAnimationState.death: deathAnimation,
    };
  }

  @override
  void loadStates() {
    idle
    ..onEnter = () { 
      setAnimationState(NecromancerAnimationState.idle);
    }
    ..onUpdate = (dt) {
      if (stateCountdown != null) {
        stateCountdown!.update(dt);
        if (stateCountdown!.finished) setState(follow);
      }
    }
    ..onExit = () => stateCountdown = null;

    follow
    ..onEnter = () {
      setAnimationState(NecromancerAnimationState.move);
    }
    ..onUpdate = (dt) {
      followMovementUpdate(dt);
    };

    shoot = State('shoot',
      onEnter: () {
        setAnimationState(NecromancerAnimationState.shoot,
          onFrames: {
            12: () {
              print("necro's pos: $position");
              add(Skull(
                position: absolutePosition,
                player: player
              ));
            }
          }
        );
      }
    );

    castFromSky = State('cast from sky',
    );

    castFromGround = State('cast from ground',
    );

    hurt.onEnter = () {

    };

    death.onEnter = () {
      setAnimationState(NecromancerAnimationState.death);
    };
  }
  
  @override
  void onCollideWithHitbox(Set<Vector2> intersectionPoints, PositionComponent other) {

  }
}