import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../experimental_battle.dart';

abstract class Actor<T> extends SpriteAnimationGroupComponent with HasGameReference<ExperimentalBattle> {
  // Stats
  // Any stats, that are not specified with percentage, are considered as flat values
  double maxHealth = 0.0;
  late double health = maxHealth;
  double healthRegenSecond = 0.0;
  double percHealingBoost = 0.0;
  double percHealReduction = 0.0;
  double baseAttack = 0.0;
  double attackBoost = 0.0;
  double percAttackBoost = 0.0;
  double baseDefense = 0.0;
  double percDefenseBoost = 0.0;
  double defenseReduction = 0.0;
  double percDefenseReduction = 0.0;
  double percDamageReceived = 0.0;
  double mana = 0.0;
  double manaRegen = 0.0;
  double critMultiplier = 2.0;
  double critChance = 0.0;
  double cooldownReduction = 0.0;
  double speed = 0.0;
  double attackSpeed = 0.0;
  double projectileSpeed = 0.0;
  double finalMultiplier = 1.0;

  @override
  void onLoad() {
    anchor = Anchor.center;
    loadAnimations();
  }

  // Multipliers are modified by the activator and can use any stats to scale freely
  // Damage Formula
  double calculateDamageAmount(Actor target, double attackMultiplier) {
    final finalAttack =
        attackMultiplier * ((baseAttack * (1 + percAttackBoost)) + attackBoost);
    final finalDefense = // percDefenseReduction should not be above 90%
        (1 + target.percDefenseBoost) *
            (((target.baseDefense - (target.baseDefense * clampDouble(percDefenseReduction, 0.0, 0.9)))  - defenseReduction)).clamp(0, double.infinity);
    final rawDamage = (finalAttack - finalDefense).clamp(1, double.infinity); // Only deal 1 if defense is above attack
    final isCrit = Random().nextDouble() + critChance >= 1;
    final multiplier = isCrit ? critMultiplier : 1.0;
    return (1 + target.percDamageReceived) * finalMultiplier * multiplier * rawDamage;
  }

  // Heal Formula
  double calculateHealAmount(double healMultiplier) {
    // healReduction should not be above 99%
    final healEffectiveness = (1 + percHealingBoost - clampDouble(percHealReduction, 0.0, 0.99));
    return healEffectiveness * healMultiplier;
  }

  // DoT Formula
  double calculateDotAmount(Actor target, double dotMultiplier) {
    return (1 + target.percDamageReceived) * dotMultiplier;
  }

  void setState(T state) {
    if (animations == null) {
      throw StateError('Animations not loaded yet.');
    }

    if (animations!.containsKey(state)) {
      current = state;
    } else if (kDebugMode) {
      throw ArgumentError('State "$state" not found in animations. '
          'Available: ${animations!.keys.join(", ")}');
    } else {
      debugPrint('Actor: State $state not available, using ${animations!.keys.first}');
      current = animations!.keys.first;
    }
  }

  void idle();
  void move(double dt);
  void attack();
  void die({Actor? killer});
  void hurt({Actor? source});

  void changeHealth(double amount, {Actor? source}) {
    health = (health + amount).clamp(0, maxHealth);
    if (amount < 0 && health > 0) hurt(source: source);
    
    if (health <= 0) die(killer: source);
  }
  
  void loadAnimations();
  void updateState(double dt);
}