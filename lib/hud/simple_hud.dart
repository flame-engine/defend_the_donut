import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';
import 'package:space_nico/space_game_3d.dart';
import 'package:space_nico/styles.dart';

class SimpleHud extends Component with HasGameReference<SpaceGame3D> {
  SimpleHud() : super(children: [FpsComponent()]);

  String get fps => firstChild<FpsComponent>()?.fps.toStringAsFixed(2) ?? '0';

  final _textLeft = Styles.text;
  final _textRight = TextPaint(style: Styles.text.style, textDirection: TextDirection.rtl);

  @override
  void render(Canvas canvas) {
    final CameraComponent3D(:position, :target, :up) = game.camera;

    _textLeft.render(
      canvas,
      '''
Camera controls:
- Move using W, A, S, D
- Look around with the mouse
''',
      Vector2.all(8),
    );
    _textRight.render(
      canvas,
      '''
FPS: $fps
Mode: ${game.camera.mode.name}
Projection: ${game.camera.projection.name}

Position: ${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}, ${position.z.toStringAsFixed(2)}
Target: ${target.x.toStringAsFixed(2)}, ${target.y.toStringAsFixed(2)}, ${target.z.toStringAsFixed(2)}
Up: ${up.x.toStringAsFixed(2)}, ${up.y.toStringAsFixed(2)}, ${up.z.toStringAsFixed(2)}
''',
      Vector2(game.size.x - 8, 8),
      anchor: Anchor.topRight,
    );
  }
}
