import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:space_nico/space_game_3d.dart';

class Hud extends Component with HasGameReference<SpaceGame3D> {
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

    _text.render(
      canvas,
      'Donut Life',
      Vector2(game.size.x / 2, y + 4.0),
      anchor: Anchor.topCenter,
    );

    _textBig.render(
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

  static const _width = 1.2;
  static const _color = Color(0xFFFFFFFF);
  static final _style = TextStyle(
    color: const Color(0xFF000000),
    fontFamily: 'SingleDay',
    shadows: [
      for (var x = 1; x < _width + 5; x++)
        for (var y = 1; y < _width + 5; y++) ...[
          Shadow(offset: Offset(-_width / x, -_width / y), color: _color),
          Shadow(offset: Offset(-_width / x, _width / y), color: _color),
          Shadow(offset: Offset(_width / x, -_width / y), color: _color),
          Shadow(offset: Offset(_width / x, _width / y), color: _color),
        ],
    ],
  );
  final _text = TextPaint(style: _style);
  final _textBig = TextPaint(style: _style.copyWith(fontSize: 24));
}
