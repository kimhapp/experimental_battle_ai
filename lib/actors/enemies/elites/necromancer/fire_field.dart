import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

class FireField extends SpriteAnimationComponent with HasGameReference<ExperimentalBattle> {
  FireField({
    required super.position,
    required this.player
  }): super(anchor: Anchor.center);

  final Timer duration = Timer(5, autoStart: false);
  final Player player;

  @override
  void onLoad() {
    super.onLoad();
    priority = 10;

    animation = game.createSpriteAnimation(
      'vfx/elites/necromancer/fire_field.png', 
      AnimationConfig(
        amount: 4, 
        stepTime: 0.1, 
        textureSize: Vector2.all(32),
      )
    );

    scale = Vector2.all(2);
    position.add(player.position - absolutePosition);
  }

  @override
  void onMount() {
    super.onMount();
    duration.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    duration.update(dt);

    if (duration.finished) removeFromParent();
  }
}