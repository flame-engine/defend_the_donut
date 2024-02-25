import 'package:flame/text.dart';
import 'package:flutter/rendering.dart';

class Styles {
  static const _width = 1.2;
  static const _white = Color(0xFFFFFFFF);
  static const _black = Color(0xFF000000);

  static TextStyle textStyleWithShadows({
    Color color = _black,
    Color shadow = _white,
  }) {
    return TextStyle(
      color: color,
      fontFamily: 'SingleDay',
      shadows: [
        for (var x = 1; x < _width + 5; x++)
          for (var y = 1; y < _width + 5; y++) ...[
            Shadow(offset: Offset(-_width / x, -_width / y), color: shadow),
            Shadow(offset: Offset(-_width / x, _width / y), color: shadow),
            Shadow(offset: Offset(_width / x, -_width / y), color: shadow),
            Shadow(offset: Offset(_width / x, _width / y), color: shadow),
          ],
      ],
    );
  }

  static final _style = textStyleWithShadows();

  static final text = TextPaint(style: _style);
  static final textBig = TextPaint(style: _style.copyWith(fontSize: 24));
  static final title = TextPaint(style: _style.copyWith(fontSize: 128));
}
