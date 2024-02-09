import 'package:flame/components.dart' show HasGameReference;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:defend_the_donut/audio.dart';
import 'package:defend_the_donut/components/pew.dart';
import 'package:defend_the_donut/key_event_handler.dart';
import 'package:defend_the_donut/mouse.dart';
import 'package:defend_the_donut/space_game_3d.dart';

class Player extends Component3D with KeyEventHandler, HasGameReference<SpaceGame3D> {

  double energy = 100.0;
  double heat = 0.0;

  double boostingSfxTimer = 0.0;

  Player({
    required super.position,
  });

  @override
  bool get propagateKeyEvent =>
      isAnyDown([Key.keyW, Key.keyS, Key.keyA, Key.keyD, Key.shiftLeft]);

  Vector3 get forward => Vector3(0, 0, 1)..applyQuaternion(rotation);

  @override
  void update(double dt) {
    if (game.isPaused) {
      return;
    }

    _addHeat(-20 * dt);
    _addEnergy(5 * dt);

    final isBoosting = isKeyDown(Key.shiftLeft) && isKeyDown(Key.keyW) && consumeEnergy(25 * dt);
    if (isBoosting && boostingSfxTimer == 0.0) {
      Audio.boost();
      boostingSfxTimer = 2.0;
    } else if (boostingSfxTimer > 0.0) {
      boostingSfxTimer -= dt;
      if (boostingSfxTimer <= 0.0) {
        boostingSfxTimer = 0.0;
      }
    }

    final multiplier = isBoosting ? 10 : 1;
    if (isKeyDown(Key.keyW)) {
      accelerate(moveSpeed * multiplier * dt);
    } else if (isKeyDown(Key.keyS)) {
      accelerate(-moveSpeed * dt);
    }
    if (isKeyDown(Key.keyA)) {
      strafe(-strafingSpeed * dt);
    } else if (isKeyDown(Key.keyD)) {
      strafe(strafingSpeed * dt);
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

  bool consumeEnergy(double value) {
    if (energy < value) {
      return false;
    }
    _addEnergy(-value);
    return true;
  }

  void _addEnergy(double value) {
    energy = (energy + value).clamp(0, 100);
    _addHeat(0.0);
  }

  void _addHeat(double value) {
    heat = (heat + value).clamp(0, 100 - energy);
  }

  void pew() {
    if (heat > 0) {
      Audio.failedPew();
      return;
    }

    if (energy >= 95) {
      energy = 95;
      _addEnergy(0.0);
    }
    heat = 100 - energy;
    _spawnPew();
  }

  void _spawnPew() {
    Audio.pew();
    game.world.add(
      Pew(
        position: position.clone(),
        direction: forward.clone(),
      ),
    );
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
  static const strafingSpeed = 16;

  static final _up = Vector3(0, 1, 0);
}
