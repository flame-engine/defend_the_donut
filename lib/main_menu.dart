import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:space_nico/space_game_3d.dart';
import 'package:space_nico/styles.dart';

class MainMenu extends Component with HasGameReference<SpaceGame3D>, TapCallbacks {
  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void render(Canvas canvas) {
    Styles.title.render(
      canvas,
      'Donut Defender',
      Vector2(game.size.x / 2, 320.0),
      anchor: Anchor.topCenter,
    );

    Styles.textBig.render(
      canvas,
      'Press any key to start',
      Vector2(game.size.x / 2, 580.0),
      anchor: Anchor.topCenter,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.initGame();
  }
}
