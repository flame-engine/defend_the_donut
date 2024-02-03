import 'package:flame/components.dart';
import 'package:flutter/services.dart';

mixin KeyEventHandler implements KeyboardHandler {
  Set<Key> _keysDown = {};

  bool isKeyDown(Key key) => _keysDown.contains(key);

  bool isAnyDown(List<Key> keys) => _keysDown.containsAll(keys);

  @override
  bool onKeyEvent(RawKeyEvent event, Set<Key> keysPressed) {
    _keysDown = keysPressed;
    return propegateKeyEvent;
  }

  bool get propegateKeyEvent => true;
}

typedef Key = LogicalKeyboardKey;
