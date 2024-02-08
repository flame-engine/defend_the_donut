import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:space_nico/space_game_3d.dart';
import 'package:space_nico/styles.dart';

class Hud extends Component with HasGameReference<SpaceGame3D> {
  @override
  FutureOr<void> onLoad() {
    addAll([_DonutLifeBar(), _PlayerEnergyBar()]);
  }
}

class _PlayerEnergyBar extends Component with HasGameReference<SpaceGame3D> {
  @override
  void render(Canvas canvas) {
    // TODO: render player energy bar
    Styles.textBig.render(
      canvas,
      '${game.world.player.energy.toStringAsFixed(0)} %',
      Vector2.all(32.0),
    );
  }
}

class _DonutLifeBar extends Component with HasGameReference<SpaceGame3D> {
  @override
  void render(Canvas canvas) {
    final fullWidth = game.size.x - 2 * _m;
    final currentWidth = fullWidth * game.donutLife / 100;
    final y = game.size.y - _m - _h;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_m, y, fullWidth, _h),
        const Radius.circular(_r),
      ),
      _bgPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_m, y, currentWidth, _h),
        const Radius.circular(_r),
      ).deflate(4.0),
      _fgPaint,
    );

    Styles.text.render(
      canvas,
      'Donut Life',
      Vector2(game.size.x / 2, y + 4.0),
      anchor: Anchor.topCenter,
    );

    Styles.textBig.render(
      canvas,
      '${game.donutLife.toStringAsFixed(0)} %',
      Vector2(game.size.x / 2, y + 16.0),
      anchor: Anchor.topCenter,
    );
  }

  static final _bgPaint = Paint()
    ..color = const Color(0xFF3C3C3C)
    ..style = PaintingStyle.fill;

  static final _fgPaint = Paint()
    ..color = const Color(0xFF0FAE82)
    ..style = PaintingStyle.fill
    ..strokeWidth = 2;

  static const _m = 64.0;
  static const _h = 48.0;
  static const _r = 16.0;
}
