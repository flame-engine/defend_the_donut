import 'package:defend_the_donut/menu/menu.dart';
import 'package:defend_the_donut/menu/menu_item.dart';
import 'package:defend_the_donut/styles.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class EndGameMenu extends Menu {
  @override
  Future<void> onLoad() async {
    await add(
      MenuItem(
        textRenderer: Styles.textBig,
        text: '- restart -',
        positionProvider: (gameSize) => gameSize / 2 + Vector2(0, 80.0),
        anchor: Anchor.center,
        onTap: game.restartGame,
      ),
    );
  }

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
      game.canvasSize / 2 + Vector2(0, 52.0),
      anchor: Anchor.center,
    );
  }
}
