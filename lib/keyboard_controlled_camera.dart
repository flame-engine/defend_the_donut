import 'package:flame/components.dart' show HasGameReference;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:space_nico/components/player.dart';
import 'package:space_nico/space_game_3d.dart';

class KeyboardControlledCamera extends CameraComponent3D
    with HasGameReference<SpaceGame3D> {
  KeyboardControlledCamera({
    super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  }) : super(
          projection: CameraProjection.perspective,
          mode: CameraMode.free,
          up: Vector3(0, 1, 0),
          fovY: 60,
        );

  final double moveSpeed = 0.9;
  final double rotationSpeed = 0.3;
  final double panSpeed = 2;
  final double orbitalSpeed = 0.5;

  Player get player => game.world.player;

  @override
  void update(double dt) {
    if (game.isPaused) {
      return;
    }

    final origin = player.position;
    position.setFrom(origin);
    target.setFrom(origin + player.forward);
  }
}
