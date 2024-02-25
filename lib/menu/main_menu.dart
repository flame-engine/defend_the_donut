import 'dart:async';
import 'dart:ui';

import 'package:defend_the_donut/menu/menu.dart';
import 'package:defend_the_donut/menu/menu_item.dart';
import 'package:defend_the_donut/styles.dart';
import 'package:flame/components.dart';

class MainMenu extends Menu {
  static final mainTitle = Styles.title.copyWith((it) => it.copyWith(fontSize: 240));

  @override
  FutureOr<void> onLoad() async {
    await add(
      MenuItem(
        textRenderer: Styles.textBig,
        text: '- start -',
        positionProvider: (gameSize) => Vector2(gameSize.x / 2, 592.0),
        anchor: Anchor.topCenter,
        onTap: game.initGame,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    Styles.title.render(
      canvas,
      'DEFEND THE',
      Vector2(game.size.x / 2, 320.0),
      anchor: Anchor.topCenter,
    );
    mainTitle.render(
      canvas,
      'DONUT',
      Vector2(game.size.x / 2, 360.0),
      anchor: Anchor.topCenter,
    );
  }
}
