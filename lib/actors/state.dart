import 'package:flutter/foundation.dart';

class State {
  final String name;
  VoidCallback? onEnter;
  void Function(double dt)? onUpdate;
  VoidCallback? onExit;
  
  State(this.name, {this.onEnter, this.onExit, this.onUpdate});
}