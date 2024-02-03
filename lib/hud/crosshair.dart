import 'dart:ui';

import 'package:flame/components.dart';
import 'package:space_nico/main.dart';

class Crosshair extends Component with HasGameReference<ExampleGame3D> {
  List<(Offset, Offset)> _lines = [];

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final halfSize = size / 2;
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

    for (final line in _lines) {
      canvas.drawLine(line.$1, line.$2, _paint);
    }
  }

  static const _radius = 10.0;
  static final _paint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..strokeWidth = 2;
}
