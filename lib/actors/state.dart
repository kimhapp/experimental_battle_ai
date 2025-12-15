import 'package:flutter/foundation.dart';

class State {
  final String name;
  late final VoidCallback? onEnter;
  late final void Function(double dt)? onUpdate;
  late final VoidCallback? onExit;
  
  State(this.name, {this.onEnter, this.onExit, this.onUpdate});
}