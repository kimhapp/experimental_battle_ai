import 'package:experimental_battle_ai/actors/enemies/enemy.dart';
import 'package:experimental_battle_ai/actors/enemies/minions/flying_eye/heal.dart';
import 'package:experimental_battle_ai/actors/projectile.dart';
import 'package:experimental_battle_ai/actors/state.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum FlyingEyeAnimationState { flight, bite, dash, heal, hurt, death }

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

  bool _biteLeap = false;
  bool _dash = false;
  bool _hasTakeHit = false;

  double biteDistance = 20;
  double biteDistanceMultiplier = 2;
  
  double dashDistance = 200;
  double dashDistanceMultiplier = 2;

  Timer dashCooldown = Timer(6, autoStart: false);
  Timer healCooldown = Timer(10, autoStart: false);
  Timer attackCooldown = Timer(4, autoStart: false);

  @override
  void onLoad() {
    super.onLoad();
    hitbox = RectangleHitbox(
      size: Vector2(45, 45),
      anchor: anchor,
      position: size / 2
    )..onCollisionStartCallback = onCollideWithHitbox;

    add(hitbox);
  }

  @override
  void onMount() {
    super.onMount();
    setState(follow);
    speed = 200;
  }

  @override
  void update(double dt) {
    super.update(dt);

    attackCooldown.update(dt);
    dashCooldown.update(dt);
    healCooldown.update(dt);
  }

  @override
  void loadAnimations() {
    flightAnimation = game.createSpriteAnimation(
      'actors/enemies/minions/flying_eye(150x150)/flight.png', 
      AnimationConfig(
        amount: 8, 
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

    animations = {
      FlyingEyeAnimationState.flight: flightAnimation,
      FlyingEyeAnimationState.bite: biteAnimation,
      FlyingEyeAnimationState.dash: dashAnimation,
      FlyingEyeAnimationState.heal: healAnimation,
      FlyingEyeAnimationState.hurt: hurtAnimation,
      FlyingEyeAnimationState.death: deathAnimation,
    };
  }

  @override
  void loadStates() {
    idle
    ..onEnter = () {
      if (current != FlyingEyeAnimationState.flight) setAnimationState(FlyingEyeAnimationState.flight);
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
      if (current != FlyingEyeAnimationState.flight) setAnimationState(FlyingEyeAnimationState.flight);
    }
    ..onUpdate = (dt) {
      followMovementUpdate(dt);
      
      if (distance(player) < biteDistance) return setState(bite);

      if (!attackCooldown.isRunning()) {
        if (_hasTakeHit && !healCooldown.isRunning()) return setState(heal);
        return setState(dash);
      }
    };

    bite = State('bite',
      onEnter: () {
        setAnimationState(FlyingEyeAnimationState.bite,
          onFrames: {
            6: () => _biteLeap = true
          },
          onComplete: () {
            _biteLeap = false;
            setState(idle);
          }
        );
      },
      onUpdate: (dt) {
        if (_biteLeap) {
          velocity = direction * biteDistance * biteDistanceMultiplier;
          position.add(velocity * dt);
        }
      },
      onExit: () { 
        stateCountdown = Timer(1);
      }
    );

    dash = State('dash',
      onEnter: () {
        setAnimationState(FlyingEyeAnimationState.dash,
          onFrames: {
            5: () => _dash = true
          },
          onComplete: () {
            _dash = false;
            setState(idle);
          }
        );
      },
      onUpdate: (dt) {
        if (_dash) {
          final dashSpeed = dashDistance * dashDistanceMultiplier;
          final dashVelocity = direction * dashSpeed;
          position.add(dashVelocity * dt);
        } else {
          direction = (player.position - position).normalized();
        }
      },
      onExit: () {
        attackCooldown.start();
        dashCooldown.start();
        stateCountdown = Timer(1);
      }
    );

    heal = State('heal',
      onEnter: () {
        setAnimationState(FlyingEyeAnimationState.heal,
          onComplete: () {
            add(HealVisual(position: size / 2));
            setState(idle);
          },
        );
      },
      onExit: () {
        attackCooldown.start();
        healCooldown.start();
        stateCountdown = Timer(1);
      }
    );

    hurt.onEnter = () {
      setAnimationState(FlyingEyeAnimationState.hurt,
        onComplete: () => setState(follow)
      );
    };

    death.onEnter = () {
      setAnimationState(FlyingEyeAnimationState.death,
        onComplete: () => removeFromParent()
      );
    };
  }

  @override
  void onCollideWithHitbox(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other.parent is Projectile) {
      setState(hurt);
      _hasTakeHit = true;
    }
  }
}