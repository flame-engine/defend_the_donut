import 'package:defend_the_donut/styles.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/rendering.dart';

class MenuItem extends TextComponent<TextPaint>
    with HoverCallbacks, TapCallbacks {
  static final _hovered = Styles.textStyleWithShadows(
    color: const Color(0xFF444444),
    shadow: const Color(0xFFFFFFFF),
  );
  static final _default = Styles.textStyleWithShadows();

  final Vector2 Function(Vector2 gameSize) positionProvider;
  final void Function() onTap;

  MenuItem({
    required super.textRenderer,
    required super.text,
    required super.anchor,
    required this.positionProvider,
    required this.onTap,
  });

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    position = positionProvider(size);
  }

  @override
  void onHoverEnter() {
    _updateStyleColor(_hovered);
  }

  @override
  void onHoverExit() {
    _updateStyleColor(_default);
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap();
  }

  void _updateStyleColor(TextStyle style) {
    textRenderer = textRenderer.copyWith((e) {
      return e.copyWith(
        color: style.color,
        shadows: style.shadows,
      );
    });
  }
}
