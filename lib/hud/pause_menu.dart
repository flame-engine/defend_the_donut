import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:space_nico/main.dart';
import 'package:space_nico/mouse.dart';

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
    if (game.isPaused) {
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
  bool _isPaused = true;

  bool get isPaused => _isPaused;

  @override
  @mustCallSuper
  void onMount() {
    Mouse.init();
    return super.onMount();
  }

  void pause() {
    _isPaused = true;
    mouseCursor = MouseCursor.defer;
    Mouse.unlock();
  }

  void resume() {
    _isPaused = false;
    mouseCursor = SystemMouseCursors.none;
    Mouse.lock();
  }
}