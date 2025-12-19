import 'package:experimental_battle_ai/actors/enemies/bosses/golem/golem.dart';
import 'package:experimental_battle_ai/actors/enemies/elites/necromancer/necromancer.dart';
import 'package:experimental_battle_ai/actors/enemies/minions/flying_eye/flying_eye.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class GameHud extends PositionComponent with HasGameReference<ExperimentalBattle>, DragCallbacks {
  GameHud();

  late final JoystickComponent moveJoystick;
  late final JoystickComponent aimJoystick;
  late final HudButtonComponent rollButton;

  late final HudButtonComponent pauseButton;
  late final List<HudButtonComponent> spawnButtons;
  late final List<TextComponent> spawnTexts;
  
  bool isRollPressed = false;

  bool isMinionAlive = false;
  bool isEliteAlive = false;
  bool isBossAlive = false;

  late Golem golem;
  late Necromancer necromancer;
  late FlyingEye flyingEye;

  @override
  void onLoad() {
    moveJoystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/joystick/knob.png")))..size = Vector2.all(32),
      background: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/joystick/joystick.png")))..size = Vector2.all(64),
      margin: const EdgeInsets.only(left: 32, bottom: 32)
    );

    aimJoystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/joystick/knob.png")))..size = Vector2.all(32),
      background: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/joystick/joystick.png")))..size = Vector2.all(64),
      margin: const EdgeInsets.only(right: 32, bottom: 32)
    );

    rollButton = HudButtonComponent(
      button: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/button/button.png")))..size = Vector2.all(48),
      buttonDown: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/button/button_down.png")))..size = Vector2.all(48),
      margin: const EdgeInsets.only(right: 96, bottom: 32),
      onPressed: () { isRollPressed = true; },
      onReleased: () { isRollPressed = false; },
    );

    pauseButton = HudButtonComponent(
      button: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/button/button.png")))..size = Vector2(16, 16).scaled(2),
      buttonDown: SpriteComponent(sprite: Sprite(game.images.fromCache("hud/button/button_down.png")))..size = Vector2(16, 16).scaled(2),
      margin: const EdgeInsets.only(left: 16, top: 16),
      onPressed: () {
        if (!game.paused) {
          game.pauseEngine();
        } else {
          game.resumeEngine();
        }
      },
    );

    final buttonLabels = ['Minion', 'Elite', 'Boss'];
    final buttonWidth = 64.0;
    final buttonHeight = 32.0;
    final buttonSpacing = 8.0;
    final topMargin = 16.0;
    final rightMargin = 16.0;
    
    spawnButtons = [];
    spawnTexts = [];

    for (int i = 0; i < 3; i++) {
      final button = HudButtonComponent(
        button: SpriteComponent(sprite: Sprite(game.images.fromCache("ui/button/button.png")))..size = Vector2(buttonWidth, buttonHeight),
        buttonDown: SpriteComponent(sprite: Sprite(game.images.fromCache("ui/button/button_down.png")))..size = Vector2(buttonWidth, buttonHeight),
        margin: EdgeInsets.only(
          right: rightMargin + (i * (buttonWidth + buttonSpacing)),
          top: topMargin,
        ),
        onPressed: () {
          _spawnEnemy(i);
        },
      );
      spawnButtons.add(button);

      final textComponent = TextComponent(
        text: buttonLabels[i],
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
        anchor: Anchor.center,
      );
      spawnTexts.add(textComponent);
    }
  }

  void _spawnEnemy(int buttonIndex) {
    switch (buttonIndex) {
      case 0: // Minion
        if (!isMinionAlive) {
          isMinionAlive = !isMinionAlive;
          flyingEye = FlyingEye(player: game.player);
          flyingEye.position = game.player.position + Vector2.all(100);
          game.camera.world!.add(flyingEye);
          print("minion spawned: ${flyingEye.absolutePosition}");
          print("player spawned: ${game.player.absolutePosition}");
        } else {
          isMinionAlive = !isMinionAlive;
          flyingEye.setState(flyingEye.death);
        }
        break;
      case 1: // Elite
        if (!isEliteAlive) {
          isEliteAlive = !isEliteAlive;
          necromancer = Necromancer(player: game.player);
          necromancer.position = necromancer.player.position + Vector2.all(150);
          game.camera.world!.add(necromancer);
          print("elite spawned!");
        } else {
          isEliteAlive = !isEliteAlive;
          necromancer.setState(necromancer.death);
        }
        break;
      case 2: // Boss
        if (!isBossAlive) {
          isBossAlive = !isBossAlive;
          golem = Golem(player: game.player);
          golem.position = golem.player.position + Vector2.all(150);
          game.camera.world!.add(golem);
          print("boss spawned!");
        } else {
          isBossAlive = !isBossAlive;
          golem.setState(golem.death);
        }
        break;
    }
  }


  void addHud() {
    game.camera.viewport.add(moveJoystick);
    game.camera.viewport.add(aimJoystick);
    game.camera.viewport.add(rollButton);
    game.camera.viewport.add(pauseButton);

    for (int i = 0; i < spawnButtons.length; i++) {
      final button = spawnButtons[i];
      final text = spawnTexts[i];

      game.camera.viewport.add(button);
      game.camera.viewport.add(text);

      // Position text at button's position (centered)
      final buttonPosition = button.absolutePosition;
      final buttonSize = button.button!.size;

      text.position = Vector2(
        buttonPosition.x + buttonSize.x / 2, 
        buttonPosition.y + buttonSize.y / 2,
      );
    }
  }
}