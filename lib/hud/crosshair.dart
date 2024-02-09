import 'dart:ui';

import 'package:flame/components.dart';
import 'package:defend_the_donut/space_game_3d.dart';

class Crosshair extends Component with HasGameReference<SpaceGame3D> {
  List<(Offset, Offset)> _lines = [];
  Offset _center = Offset.zero;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final halfSize = size / 2;
    _center = halfSize.toOffset();
    _lines = [
      (
        (halfSize - Vector2(0, _radius)).toOffset(),
        (halfSize + Vector2(0, _radius)).toOffset()
      ),
      (
        (halfSize - Vector2(_radius, 0)).toOffset(),
        (halfSize + Vector2(_radius, 0)).toOffset()
      ),
    ];
  }

  @override
  void render(Canvas canvas) {
    if (game.isPaused) {
      return;
    }

    canvas.drawCircle(_center, _radius + 2, _paint1);
    for (final line in _lines) {
      canvas.drawLine(line.$1, line.$2, _paint2);
    }
  }

  static const _radius = 10.0;
  static final _paint1 = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  static final _paint2 = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..strokeWidth = 2;
}
