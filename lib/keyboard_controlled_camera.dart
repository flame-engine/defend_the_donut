import 'dart:async';

import 'package:flame/components.dart' show HasGameReference;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/services.dart' show RawKeyEvent;
import 'package:space_nico/key_event_handler.dart';
import 'package:space_nico/mouse.dart';
import 'package:space_nico/space_game_3d.dart';

class KeyboardControlledCamera extends CameraComponent3D
    with KeyEventHandler, HasGameReference<SpaceGame3D> {
  KeyboardControlledCamera({
    super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  }) : super(
          projection: CameraProjection.perspective,
          mode: CameraMode.thirdPerson,
          position: Vector3(0, 0, 0),
          target: Vector3(0, 0, 0),
          up: Vector3(0, 1, 0),
          fovY: 60,
        );

  final double moveSpeed = 0.9;
  final double rotationSpeed = 0.3;
  final double panSpeed = 2;
  final double orbitalSpeed = 0.5;

  @override
  FutureOr<void> onLoad() {
    position = game.world.player.position + Vector3(0, 1, 2);
    target.setFrom(game.world.player.position + Vector3(0, 1, 0));
    return super.onLoad();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<Key> keysPressed) {
    super.onKeyEvent(event, keysPressed);
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

    return true;
  }

  @override
  void update(double dt) {
    if (game.isPaused) {
      return;
    }

    final mouseDelta = Mouse.getDelta();
    if (mouseDelta.distance != 0) {
      const mouseMoveSensitivity = 0.003;

      yaw(-mouseDelta.dx * mouseMoveSensitivity, rotateAroundTarget: true);
      pitch(-mouseDelta.dy * mouseMoveSensitivity, rotateAroundTarget: true);
    }
  }
}
