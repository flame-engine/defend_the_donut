import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:space_nico/key_event_handler.dart';
import 'package:space_nico/mouse.dart';

class Player extends Component3D with KeyEventHandler {

  bool isBoosting = false;
  double energy = 100.0;

  Player({
    required super.position,
  });

  @override
  bool get propagateKeyEvent =>
      isAnyDown([Key.keyW, Key.keyS, Key.keyA, Key.keyD, Key.shiftLeft]);

  Vector3 get forward => Vector3(0, 0, 1)..applyQuaternion(rotation);

  @override
  void update(double dt) {
    isBoosting = isKeyDown(Key.shiftLeft);
    energy += 5 * dt;
    if (energy > 100) {
      energy = 100;
    }
    if (isBoosting) {
      energy -= dt * 25;
    }
    if (energy <= 0) {
      energy = 0;
      isBoosting = false;
    }

    final multiplier = isBoosting ? 10 : 1;
    if (isKeyDown(Key.keyW)) {
      accelerate(moveSpeed * multiplier * dt);
    } else if (isKeyDown(Key.keyS)) {
      accelerate(-moveSpeed * dt);
    }
    if (isKeyDown(Key.keyA)) {
      strafe(strafingSpeed * dt);
    } else if (isKeyDown(Key.keyD)) {
      strafe(-strafingSpeed * dt);
    }

    final mouseDelta = Mouse.getDelta();
    if (mouseDelta.distance != 0) {
      const mouseMoveSensitivity = 0.003;
      applyDeltaYawPitch(
        deltaYaw: -mouseDelta.dx * mouseMoveSensitivity,
        deltaPitch: mouseDelta.dy * mouseMoveSensitivity,
      );
    }
  }

  void applyDeltaYawPitch({
    required double deltaYaw,
    required double deltaPitch,
  }) {
    Quaternion yawRotation = Quaternion.axisAngle(Vector3(0, 1, 0), deltaYaw);
    Quaternion pitchRotation =
        Quaternion.axisAngle(Vector3(1, 0, 0), deltaPitch);

    rotation.setFrom((rotation * yawRotation) * pitchRotation);
    rotation.normalize();
  }

  void accelerate(double distance) {
    position += forward..scale(distance);
  }

  void strafe(double distance) {
    final direction = forward.cross(_up)
      ..normalize()
      ..scale(distance);
    position += direction;
  }

  static const moveSpeed = 12;
  static const strafingSpeed = 2;

  static final _up = Vector3(0, 1, 0);
}
