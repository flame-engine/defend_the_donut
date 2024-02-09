import 'package:defend_the_donut/styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:defend_the_donut/mouse.dart';
import 'package:defend_the_donut/space_game_3d.dart';

class PauseMenu extends Component
    with TapCallbacks, HasGameReference<SpaceGame3D> {
  @override
  void onTapUp(TapUpEvent event) {
    if (game.isPaused) {
      game.resume();
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => game.isPaused;

  @override
  void render(Canvas canvas) {
    if (game.isPaused) {
      canvas.drawRect(
          game.canvasSize.toRect(), Paint()..color = const Color(0xAF000000));

      Styles.textBig.render(
        canvas,
        '- click to continue -',
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
