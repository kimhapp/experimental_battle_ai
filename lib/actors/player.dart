import 'dart:math';
import 'dart:ui';

import 'package:experimental_battle_ai/actors/actor.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

enum PlayerState { idle, roll, slowWalk, run, die }

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

  double rollSpeed = 350;
  Vector2 direction = Vector2(1, 0); // Default direction

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

  @override
  void onLoad() {
    super.onLoad();
    cursor = SpriteComponent(
      sprite: Sprite(game.images.fromCache("hud/cursor.png")),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2) + Vector2(size.x / 2, 0)
    );
    add(cursor);
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
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.die: deathAnimation,
      PlayerState.slowWalk: slowWalkAnimation,
      PlayerState.roll: rollAnimation
    };
    
    setState(PlayerState.idle);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateState(dt);
    updateCursorPosition();
  }

  @override
  void render(Canvas canvas) {
    // It's only for flipping pure sprite
    // So the cursor won't be flippling with child's local origin
    // Important that it's before super.render
    canvas.save();

    if (cursorDirection.x < 0) {
      canvas.translate(size.x / 2, size.y / 2);
      canvas.scale(-1, 1);
      canvas.translate(-size.x / 2, -size.y / 2);
    } 
    
    super.render(canvas);
    canvas.restore();
  }
  
  @override
  void die({Actor? killer}) {
    setState(PlayerState.die);
    animationTickers![PlayerState.die]!.onStart = () {
      isDying = true;
    };
    animationTickers![PlayerState.die]!.onComplete = () {
      isDying = false;
    };
  }

  @override
  void attack({Actor? killer}) {
    if (!canAttack) return;

    
  }
  
  @override
  void hurt({Actor? source}) {
    isHurt = true;
  }
  
  @override
  void idle() {
    setState(PlayerState.idle);
    isMoving = false;
  }
  
  @override
  void move(double dt) {
    if (isSlow) {
      setState(PlayerState.slowWalk);
    } else {
      setState(PlayerState.run);
    }

    direction = moveJoystick.relativeDelta;
    position.add(direction * speed * dt);
  }

  void roll(double dt) {
    if (current != PlayerState.roll) {
      setState(PlayerState.roll);
      animationTickers![PlayerState.roll]!.onStart = () {
        isRolling = true;
        isInvicinble = true;
      };

      animationTickers![PlayerState.roll]!.onComplete = () {
        isRolling = false;
        isInvicinble = false;
      };
    }

    position.add(direction * rollSpeed * dt);
  }

  @override
  void updateState(double dt) {
    if (isDying) return die();
    if (isHurt && !isDying) return hurt();
    if (game.gameHud.isRollPressed || isRolling) return roll(dt);
    if (moveJoystick.direction != JoystickDirection.idle && canMove) return move(dt);
    return idle();
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
    }
  }
}