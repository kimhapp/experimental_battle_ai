import 'dart:math';
import 'dart:ui';

import 'package:experimental_battle_ai/actors/actor.dart';
import 'package:experimental_battle_ai/actors/projectile.dart';
import 'package:experimental_battle_ai/actors/state.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum PlayerAnimationState { idle, roll, slowWalk, run, die }

class Player extends Actor {
  Player({required this.moveJoystick, required this.aimJoystick});

  final JoystickComponent moveJoystick;
  final JoystickComponent aimJoystick;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation deathAnimation;
  late final SpriteAnimation rollAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation slowWalkAnimation;

  late SpriteComponent cursor;
  Vector2 cursorOffset = Vector2.zero();
  Vector2 cursorFlippedOffset= Vector2.zero();
  double cursorAngle = 0.0;
  Vector2 cursorDirection = Vector2.zero();
  bool isFlipped = false;

  double rollSpeed = 350;

  bool get isSlow => speed < 200;
  bool isStunned = false;
  bool isRooted = false;
  bool isHurt = false;
  bool isDying = false;
  bool isSwitchingWeapon = false;
  bool isAttacking = false;
  bool isRolling = false;
  bool isInvicinble = false;
  bool isMoving = false;
  bool get canMove => !isStunned && !isRooted && !isRolling && !isDying;
  bool get canAttack => !isStunned && !isAttacking && !isSwitchingWeapon && !isDying;

  late final State move;
  late final State roll;

  final Timer attackInterval = Timer(1, autoStart: false);

  @override
  void onLoad() {
    super.onLoad();
    cursor = SpriteComponent(
      sprite: Sprite(game.images.fromCache("hud/cursor.png")),
      anchor: anchor,
      position: Vector2(size.x / 2, size.y / 2) + Vector2(size.x / 2, 0)
    );
    hitbox = RectangleHitbox(
      size: Vector2(16, 29),
      anchor: anchor,
      position: size / 2
    )..onCollisionStartCallback = onCollideWithHitbox;

    addAll([cursor, hitbox]);
  }

  @override
  void onMount() {
    super.onMount();
    maxHealth = 10;
    speed = 190;
    scale = Vector2.all(1.5);
  }
  
  @override
  void loadAnimations() {
    idleAnimation = game.createSpriteAnimation(
      'actors/player(48x32)/idle.png',
      AnimationConfig(
        amount: 4, 
        stepTime: 0.2,
        textureSize: Vector2(48, 32),
      ),
    );

    runAnimation = game.createSpriteAnimation(
      'actors/player(48x32)/run.png',
      AnimationConfig(
        amount: 5, 
        stepTime: 0.1,
        textureSize: Vector2(48, 32),
      ),
    );

    deathAnimation = game.createSpriteAnimation(
      'actors/player(48x32)/death.png',
      AnimationConfig(
        amount: 7, 
        stepTime: 0.2,
        textureSize: Vector2(48, 32),
      ),
    );

    rollAnimation = game.createSpriteAnimation(
      'actors/player(48x32)/roll.png',
      AnimationConfig(
        amount: 4, 
        stepTime: 0.1,
        textureSize: Vector2(48, 32),
        loop: false
      ),
    );

    slowWalkAnimation = game.createSpriteAnimation(
      'actors/player(48x32)/slow_walk.png',
      AnimationConfig(
        amount: 6, 
        stepTime: 0.1,
        textureSize: Vector2(48, 32),
      ),
    );

    animations = {
      PlayerAnimationState.idle: idleAnimation,
      PlayerAnimationState.run: runAnimation,
      PlayerAnimationState.die: deathAnimation,
      PlayerAnimationState.slowWalk: slowWalkAnimation,
      PlayerAnimationState.roll: rollAnimation
    };
  }

  @override
  void loadStates() {
    idle
    ..onEnter = () {
      setAnimationState(PlayerAnimationState.idle);
      isMoving = false;
    }
    ..onUpdate = (dt) => direction = isFlipped ? Vector2(-1,0) : Vector2(1, 0);

    move = State('move', 
      onEnter: () {
        if (isSlow) {
          setAnimationState(PlayerAnimationState.slowWalk);
        } else {
          setAnimationState(PlayerAnimationState.run);
        }
      },
      onUpdate: (dt) {
        direction = moveJoystick.relativeDelta.normalized();
        velocity = direction * speed;
        position.add(velocity * dt);
      },
    );

    roll = State('roll',
      onEnter: () {
        setAnimationState(PlayerAnimationState.roll, 
          onStart: () {
            isRolling = true;
            isInvicinble = true;
          },

          onComplete: () {
            isRolling = false;
          },
        );
      },
      onUpdate: (dt) => position.add(direction * rollSpeed * dt),
      onExit: () => isInvicinble = false
    );

    hurt.onEnter = () => isHurt = true;

    death.onEnter = () {
      setAnimationState(PlayerAnimationState.die,
        onStart: () => isDying = true,
        onComplete: () => isDying = false
      );
    };
  }

  @override
  void update(double dt) {
    super.update(dt);
    updatePlayerControl();
    updateCursorPosition();
    attackInterval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // It's only for flipping pure sprite
    // So the cursor won't be flippling with child's local origin
    // Important that it's before super.render
    canvas.save();

    if (cursorDirection.x < 0) {
      if (!isFlipped) isFlipped = true;
      canvas.translate(size.x / 2, size.y / 2);
      canvas.scale(-1, 1);
      canvas.translate(-size.x / 2, -size.y / 2);
    } else {
      if (isFlipped) isFlipped = false;
    }
    
    super.render(canvas);
    canvas.restore();
  }
  
  void updatePlayerControl() {
    if (isDying) return setState(death);
    if (isHurt && !isDying) return setState(hurt);
    if (game.gameHud.isRollPressed || !canMove) return setState(roll);
    if (moveJoystick.direction != JoystickDirection.idle && canMove) return setState(move);
    setState(idle);
  }

  void updateCursorPosition() {
    if (aimJoystick.direction != JoystickDirection.idle) {
      cursorDirection = aimJoystick.relativeDelta;

      if (cursorDirection.length2 > 0) {
        cursorAngle = atan2(cursorDirection.y, cursorDirection.x);

        cursorOffset = Vector2(
          size.x / 2 * cos(cursorAngle),
          size.x / 2 * sin(cursorAngle)
        );

        cursor.angle = cursorAngle;
        cursor.position = Vector2(size.x / 2, size.y / 2) + cursorOffset;
      }

      if (!attackInterval.isRunning()) {
        add(Projectile(position: cursor.position, direction: cursorDirection));
        attackInterval.start();
      }
    }
  }
  
  @override
  void onCollideWithHitbox(Set<Vector2> intersectionPoints, PositionComponent other) {

  }
}