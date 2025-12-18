import 'package:experimental_battle_ai/actors/actor.dart';
import 'package:experimental_battle_ai/actors/player.dart';
import 'package:experimental_battle_ai/actors/state.dart';
import 'package:flame/components.dart';

enum EnemyType { minion, elite, boss }

// !!! INITIALIZE THE ENEMY ID AND TYPE THROUGH ENEMYTEMPLATE TO AVOID REPEATED ID ASSIGNMENT! !!!
enum EnemyTemplate {
  flyingEye(1, EnemyType.minion),
  necromancer(2, EnemyType.elite),
  golem(3, EnemyType.boss);

  const EnemyTemplate(this.id, this.type);
  final int id;
  final EnemyType type;
}

abstract class Enemy extends Actor {
  Enemy({
    required this.template,
    required this.player,
    required this.maxEnemyCount
  }) {
    totalCount++;
    _typeCounts[template.type] = (_typeCounts[template.type] ?? 0) + 1;
    _enemyCounts[template.id] = (_enemyCounts[template.id] ?? 0) + 1;
  }

  static int totalCount = 0;
  static final Map<EnemyType, int> _typeCounts = {};
  static final Map<int, int> _enemyCounts = {};

  final EnemyTemplate template;
  final Player player;
  final int maxEnemyCount;

  static int getCountForType(EnemyType type) => _typeCounts[type] ?? 0;
  bool get canSpawn => _enemyCounts[template.id]! < maxEnemyCount;

  final State follow = State('follow');
  Timer? stateCountdown;
  
  @override
  void onRemove() {
    super.onRemove();
    totalCount--;
    _typeCounts[template.type] = _typeCounts[template.type]! > 0 ? _typeCounts[template.type]! - 1 : 0;
    _enemyCounts[template.id] = _enemyCounts[template.id]! > 0 ? _enemyCounts[template.id]! - 1 : 0;
  }

  void followMovementUpdate(double dt) {
    direction = (player.position - position).normalized();
    
    if (direction.x > 0) {
      if (isFlippedHorizontally) flipHorizontally();
    } else if (direction.x < 0) {
      if (!isFlippedHorizontally) flipHorizontally();
    }

    velocity = direction * speed;
    position.add(velocity * dt);
  }
}