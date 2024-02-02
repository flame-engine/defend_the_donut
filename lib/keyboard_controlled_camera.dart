import 'package:flame/components.dart' show HasGameReference, KeyboardHandler;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, RawKeyEvent;
import 'package:space_nico/main.dart';
import 'package:space_nico/mouse.dart';

class KeyboardControlledCamera extends CameraComponent3D
    with KeyboardHandler, HasGameReference<ExampleGame3D> {
  KeyboardControlledCamera({
    super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  }) : super(
          projection: CameraProjection.perspective,
          mode: CameraMode.firstPerson,
          position: Vector3(0, 2, 4),
          target: Vector3(0, 2, 0),
          up: Vector3(0, 1, 0),
          fovY: 60,
        );

  final double moveSpeed = 0.9;
  final double rotationSpeed = 0.3;
  final double panSpeed = 2;
  final double orbitalSpeed = 0.5;

  Set<Key> _keysDown = {};

  @override
  bool onKeyEvent(RawKeyEvent event, Set<Key> keysPressed) {
    _keysDown = keysPressed;

    // Switch camera mode
    if (isKeyDown(Key.digit1)) {
      mode = CameraMode.free;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit2)) {
      mode = CameraMode.firstPerson;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit3)) {
      mode = CameraMode.thirdPerson;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit4)) {
      mode = CameraMode.orbital;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit5)) {
      mode = CameraMode.custom;
      up = Vector3(0, 1, 0); // Reset roll
    }

    return false;
  }

  @override
  void update(double dt) {
    if (game.isPaused) {
      return;
    }
    final rotateAroundTarget = switch (mode) {
      CameraMode.thirdPerson || CameraMode.orbital => true,
      _ => false,
    };
    final lockView = switch (mode) {
      CameraMode.free || CameraMode.firstPerson || CameraMode.orbital => true,
      _ => false,
    };

    if (Mouse.delta.distance != 0) {
      const mouseMoveSensitivity = 0.003;

      yaw(
        (Mouse.delta.dx) * mouseMoveSensitivity,
        rotateAroundTarget: rotateAroundTarget,
      );
      pitch(
        (Mouse.delta.dy) * mouseMoveSensitivity,
        lockView: lockView,
        rotateAroundTarget: rotateAroundTarget,
      );
    }

    // Keyboard movement
    if (isKeyDown(Key.keyW)) {
      moveForward(moveSpeed * dt);
    } else if (isKeyDown(Key.keyS)) {
      moveForward(-moveSpeed * dt);
    }
    if (isKeyDown(Key.keyA)) {
      moveRight(-moveSpeed * dt);
    } else if (isKeyDown(Key.keyD)) {
      moveRight(moveSpeed * dt);
    }
  }

  bool isKeyDown(Key key) => _keysDown.contains(key);
}

typedef Key = LogicalKeyboardKey;
