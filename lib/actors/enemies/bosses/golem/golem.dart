import 'package:experimental_battle_ai/actors/enemies/bosses/golem/bullet.dart';
import 'package:experimental_battle_ai/actors/enemies/bosses/golem/laser.dart';
import 'package:experimental_battle_ai/actors/enemies/enemy.dart';
import 'package:experimental_battle_ai/actors/projectile.dart';
import 'package:experimental_battle_ai/actors/state.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

enum GolemAnimationState { idle, glow, shoot, shootLaser, melee, ironBody, stasis, death }

class Golem extends Enemy {
  Golem({required super.player}): super(
    template: EnemyTemplate.golem, 
    maxEnemyCount: 1
  );

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation glowAnimation;
  late final SpriteAnimation shootAnimation;
  late final SpriteAnimation shootLaserAnimation;
  late final SpriteAnimation meleeAnimation;
  late final SpriteAnimation ironBodyAnimation;
  late final SpriteAnimation stasisAnimation;
  late final SpriteAnimation deathAnimation;

  late final State shoot;
  late final State shootLaser;
  late final State melee;
  late final State ironBody;  
  late final State stasis;

  final Vector2 _bulletPoint = Vector2(73, 37);
  final Vector2 _laserPoint = Vector2(52, 33);

  @override
  void onLoad() {
    super.onLoad();
    hitbox = RectangleHitbox(
      size: Vector2(50, 48),
      anchor: anchor,
      position: size / 2
    )..onCollisionStartCallback = onCollideWithHitbox;

    add(hitbox);
  }

  @override
  void onMount() {
    super.onMount();
    scale = Vector2.all(2);
    speed = 200;
    setState(idle);
  }

  @override
  void loadAnimations() {
    idleAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/idle.png', 
      AnimationConfig(
        amount: 4, 
        stepTime: 0.3, 
        textureSize: Vector2.all(100)
      )
    );
    
    glowAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/glow.png', 
      AnimationConfig(
        amount: 8, 
        stepTime: 0.2, 
        textureSize: Vector2.all(100)
      )
    );

    shootAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/shoot.png', 
      AnimationConfig(
        amount: 9, 
        stepTime: 0.2, 
        textureSize: Vector2.all(100)
      )
    );

    shootLaserAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/shoot_laser.png', 
      AnimationConfig(
        amount: 7, 
        stepTime: 0.2, 
        textureSize: Vector2.all(100),
        loop: false
      )
    );

    meleeAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/melee_attack.png', 
      AnimationConfig(
        amount: 7, 
        stepTime: 0.2, 
        textureSize: Vector2.all(100)
      )
    );

    ironBodyAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/iron_body.png', 
      AnimationConfig(
        amount: 10,   
        stepTime: 0.2, 
        textureSize: Vector2.all(100)
      )
    );

    stasisAnimation = game.createSpriteAnimation(
      'actors/enemies/bosses/golem(100x100)/stasis.png',  
      AnimationConfig(
        amount: 8, 
        stepTime: 0.2, 
        textureSize: Vector2.all(100)
      )
    );

    deathAnimation = game.createSpriteAnimation(
      'actors/enemies/elites/necromancer(128x128)/death.png', 
      AnimationConfig(
        amount: 14, 
        stepTime: 0.2, 
        textureSize: Vector2.all(100)
      )
    );

    animations = {
      GolemAnimationState.idle: idleAnimation,
      GolemAnimationState.glow: glowAnimation,
      GolemAnimationState.shoot: shootAnimation,
      GolemAnimationState.shootLaser: shootLaserAnimation,
      GolemAnimationState.melee: meleeAnimation,
      GolemAnimationState.stasis: stasisAnimation,
      GolemAnimationState.death: deathAnimation,
    };
  }

  @override
  void loadStates() {
    idle    
    ..onEnter = () {
      if (current != GolemAnimationState.idle) setAnimationState(GolemAnimationState.idle);
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
      if (current != GolemAnimationState.idle) setAnimationState(GolemAnimationState.idle);
    }
    ..onUpdate = (dt) {
      followMovementUpdate(dt);
    };

    shoot = State('shoot',
      onEnter: () {
        setAnimationState(GolemAnimationState.shoot,
          onFrames: {
            8: () {
              add(Bullet(
                position: _bulletPoint, player: player
              ));
            }
          }
        );
      },
    );

    shootLaser = State('shoot laser',
      onEnter: () {
        setAnimationState(GolemAnimationState.shootLaser,
          onStart: () {
            add(Laser(
              position: _laserPoint, 
              player: player,
              onComplete: () => setState(idle)
            ));
          },
        );
      },
      onExit: () => stateCountdown = Timer(1)
    );

    melee  = State('melee',
      onEnter: () {
        setAnimationState(GolemAnimationState.melee);
      },
    );

    ironBody = State('iron body',
      onEnter: () {
        setAnimationState(GolemAnimationState.ironBody);
      },
    );

    stasis = State('stasis',
      onEnter: () {
        setAnimationState(GolemAnimationState.stasis);
      },
    );

    hurt.onEnter = () {

    };

    death.onEnter = () {
      setAnimationState(GolemAnimationState.death);
    };
  }

  @override
  void onCollideWithHitbox(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other.parent is Projectile) {
          print('collided!');
      add(OpacityEffect.fadeOut(
        EffectController(duration: 0.25, reverseDuration: 0.25),
      ));
    }
  }
}