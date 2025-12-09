import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class GameHud extends PositionComponent with HasGameReference<ExperimentalBattle> {
  GameHud();

  late final JoystickComponent moveJoystick;
  late final JoystickComponent aimJoystick;
  late final HudButtonComponent rollButton;
  // late final HudButtonComponent switchButton;
  // late final HudButtonComponent skillButton;

  bool isRollPressed = false;

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
  }

  void addHud() {
    game.camera.viewport.add(moveJoystick);
    game.camera.viewport.add(aimJoystick);
    game.camera.viewport.add(rollButton);
  }
}