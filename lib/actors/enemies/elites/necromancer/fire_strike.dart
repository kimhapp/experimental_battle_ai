import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

class FireStrike extends SpriteAnimationComponent with HasGameReference<ExperimentalBattle> {
  FireStrike({
    required super.position,
    required this.player
  }): super(anchor: Anchor.bottomCenter);

  final Timer duration = Timer(0.25, autoStart: false);
  final Player player;

  @override
  void onLoad() {
    super.onLoad();
    priority = 10;

    animation = game.createSpriteAnimation(
      'vfx/elites/necromancer/fire_strike.png', 
      AnimationConfig(
        amount: 3, 
        stepTime: 0.1, 
        textureSize: Vector2(32, 48),
        loop: false
      )
    );

    animationTicker!.onComplete = () {
      duration.start();
    };

    scale = Vector2(2, 4);

    position.add(player.position - absolutePosition);
  }

  @override
  void update(double dt) {
    super.update(dt);
    duration.update(dt);

    if (duration.finished) removeFromParent();
  }
}