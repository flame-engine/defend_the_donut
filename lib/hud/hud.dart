import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
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
  late RRect _rect;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _rect = _makeTopRect();
  }

  RRect _makeTopRect({
    double percent = 1.0,
    double d = 0.0,
  }) {
    final height = game.size.y / 3;

    return RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _m + d,
        _m + d,
        _h - 2 * d,
        (height - 2 * d) * percent,
      ),
      _r,
    ).scaleRadii();
  }

  RRect _makeBottomRect({
    required double topHeight,
    double percent = 1.0,
    double d = 0.0,
  }) {
    final fullHeight = game.size.y / 3 - topHeight;
    final height = fullHeight - 2 * d;

    return RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _m + d,
        topHeight + _m + d + height * (1 - percent),
        _h - 2 * d,
        height * percent,
      ),
      _r,
    ).scaleRadii();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_rect, _bgPaint);

    final energy = game.world.player.energy;
    final energyRect =
        energy > 0 ? _makeTopRect(percent: energy / 100.0, d: 4.0) : null;
    if (energyRect != null) {
      canvas.drawRRect(energyRect, _energyPaint);
    }

    final heat = game.world.player.heat;
    if (heat > 0) {
      canvas.drawRRect(
        _makeBottomRect(
          topHeight: energyRect?.height ?? 0.0,
          percent: heat / (100 - energy),
          d: 4.0,
        ),
        _heatPaint,
      );
    }
  }
}

class _DonutLifeBar extends Component with HasGameReference<SpaceGame3D> {
  late RRect _rect;

  RRect _makeRect({
    double fill = 1.0,
    double d = 0.0,
  }) {
    final width = game.size.x - 2 * _m;
    final y = game.size.y - _m - _h;

    return RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _m + d,
        y + d,
        (width - 2 * d) * fill,
        _h - 2 * d,
      ),
      _r,
    ).scaleRadii();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _rect = _makeRect();
  }

  @override
  void render(Canvas canvas) {
    final life = game.donutLife;

    canvas.drawRRect(_rect, _bgPaint);

    if (life == 0) {
      return;
    }

    canvas.drawRRect(
      _makeRect(fill: life / 100.0, d: 4.0),
      _lifePaint,
    );

    Styles.text.render(
      canvas,
      'Donut Life',
      Vector2(game.size.x / 2, _rect.top + 4.0),
      anchor: Anchor.topCenter,
    );

    Styles.textBig.render(
      canvas,
      '${game.donutLife.toStringAsFixed(0)} %',
      Vector2(game.size.x / 2, _rect.top + 16.0),
      anchor: Anchor.topCenter,
    );
  }
}

final _heatPaint = Paint()
  ..color = const Color(0xFFC11717)
  ..style = PaintingStyle.fill
  ..strokeWidth = 2;

final _energyPaint = Paint()
  ..color = const Color(0xFF0F57DC)
  ..style = PaintingStyle.fill
  ..strokeWidth = 2;

final _lifePaint = Paint()
  ..color = const Color(0xFF0FAE82)
  ..style = PaintingStyle.fill
  ..strokeWidth = 2;

final _bgPaint = Paint()
  ..color = const Color(0xFF3C3C3C)
  ..style = PaintingStyle.fill;

const _m = 64.0;
const _h = 48.0;
const _r = Radius.circular(16.0);
