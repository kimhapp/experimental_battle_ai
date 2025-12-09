import 'package:experimental_battle_ai/experimental_battle.dart';
import 'package:flame/components.dart';

class EnemySpawner extends Component with HasWorldReference<GameWorld> {
  EnemySpawner({
    required this.minionSpawnSpeed,
    required this.eliteSpawnSpeed, 
  });

  double minionSpawnSpeed;
  late final SpawnComponent minionSpawnComponent;
  double eliteSpawnSpeed;
  late final SpawnComponent eliteSpawnComponent;

  @override
  void onLoad() {
    super.onLoad();
    minionSpawnComponent = SpawnComponent(
      period: minionSpawnSpeed,
      
    );

    eliteSpawnComponent = SpawnComponent(
      period: eliteSpawnSpeed,
    );
  }

}