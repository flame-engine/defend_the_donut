import 'package:defend_the_donut/space_game_3d.dart';
import 'package:defend_the_donut/styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart';

class EndGameMenu extends Component
    with TapCallbacks, HasGameReference<SpaceGame3D> {
  @override
  void onTapUp(TapUpEvent event) {
    game.restartGame();
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      game.canvasSize.toRect(),
      Paint()..color = const Color(0xAF000000),
    );

    Styles.title.render(
      canvas,
      'Game Over',
      game.canvasSize / 2,
      anchor: Anchor.center,
    );
    Styles.textBig.render(
      canvas,
      'Your Score: ${game.clock}',
      game.canvasSize / 2 + Vector2(0, 48.0),
      anchor: Anchor.center,
    );
    Styles.textBig.render(
      canvas,
      '- click to restart -',
      game.canvasSize / 2 + Vector2(0, 64.0),
      anchor: Anchor.center,
    );
  }
}
