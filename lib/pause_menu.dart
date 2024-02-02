import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';
import 'package:pointer_lock/pointer_lock.dart';
import 'package:space_nico/main.dart';

final _text = TextPaint(
  style: const TextStyle(
    color: Color(0xFFFFFFFF),
  ),
);

class PauseMenu extends Component with TapCallbacks, HasGameReference<ExampleGame3D> {
  @override
  void onTapUp(TapUpEvent event) {
    game.resume();
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void render(Canvas canvas) {
    if (game.isGamePaused) {
      canvas.drawRect(
          game.canvasSize.toRect(), Paint()..color = const Color(0x7FFFFFFF));
      _text.render(
        canvas,
        'Continue',
        game.canvasSize / 2,
        anchor: Anchor.center,
      );
    }
  }
}

mixin CanPause {
  final _pointerLockPlugin = PointerLock();
  bool _gamePaused = true;

  bool get isGamePaused => _gamePaused;

  void pointerSetup() {
    _pointerLockPlugin.subscribeToRawInputData();
  }

  void pause() {
    _gamePaused = true;
    _pointerLockPlugin.showPointer();
    _pointerLockPlugin.unlockPointer();
  }

  void resume() {
    _gamePaused = false;
    _pointerLockPlugin.hidePointer();
    _pointerLockPlugin.lockPointer();
  }
}