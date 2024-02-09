import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:defend_the_donut/space_game_3d.dart';
import 'package:defend_the_donut/styles.dart';

class MainMenu extends Component with HasGameReference<SpaceGame3D>, TapCallbacks {
  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void render(Canvas canvas) {
    Styles.title.render(
      canvas,
      'DEFEND THE',
      Vector2(game.size.x / 2, 320.0),
      anchor: Anchor.topCenter,
    );
    Styles.title.copyWith((it) => it.copyWith(fontSize: 240)).render(
      canvas,
      'DONUT',
      Vector2(game.size.x / 2, 360.0),
      anchor: Anchor.topCenter,
    );

    Styles.textBig.render(
      canvas,
      '- click to start -',
      Vector2(game.size.x / 2, 592.0),
      anchor: Anchor.topCenter,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.initGame();
  }
}
