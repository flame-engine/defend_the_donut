import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pointer_lock/pointer_lock.dart';
import 'package:space_nico/main.dart';

final _text = TextPaint(
  style: const TextStyle(
    color: Color(0xFFFFFFFF),
  ),
);

class PauseMenu extends Component
    with TapCallbacks, HasGameReference<ExampleGame3D> {
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

mixin CanPause<T extends World> on FlameGame<T> {
  final lock = PointerLock();
  bool _gamePaused = true;

  bool get isGamePaused => _gamePaused;

  @override
  @mustCallSuper
  void onMount() {
    lock.subscribeToRawInputData();
    return super.onMount();
  }

  void pause() {
    _gamePaused = true;
    mouseCursor = MouseCursor.defer;
    lock.unlockPointer();
  }

  void resume() {
    _gamePaused = false;
    mouseCursor = SystemMouseCursors.none;
    lock.lockPointer();
  }
}
