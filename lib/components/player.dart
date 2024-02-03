import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart' show HasGameReference;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:space_nico/key_event_handler.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/space_game_3d.dart';

class Player extends MeshComponent
    with HasGameReference<SpaceGame3D>, KeyEventHandler {
  Player() : super(mesh: Mesh());

  @override
  bool get propegateKeyEvent =>
      isAnyDown([Key.keyW, Key.keyS, Key.keyA, Key.keyD]);

  double angle = 0;

  @override
  FutureOr<void> onLoad() async {
    await ObjParser.parse('objects/craft_speederA.obj', applyTo: mesh);
  }

  @override
  void update(double dt) {
    // final mouseDelta = Mouse.getDelta();
    // if (mouseDelta.distance != 0) {
    //   const mouseMoveSensitivity = 0.003;

    //   yaw(
    //     -mouseDelta.dx * mouseMoveSensitivity,
    //     rotateAroundTarget: rotateAroundTarget,
    //   );
    //   pitch(
    //     -mouseDelta.dy * mouseMoveSensitivity,
    //     lockView: lockView,
    //     rotateAroundTarget: rotateAroundTarget,
    //   );
    // }

    // Keyboard movement
    if (isKeyDown(Key.keyW)) {
      moveForward(moveSpeed * dt);
    } else if (isKeyDown(Key.keyS)) {
      moveForward(-moveSpeed * dt);
    }
    if (isKeyDown(Key.keyA)) {
      moveRight(rotationSpeed * dt);
    } else if (isKeyDown(Key.keyD)) {
      moveRight(-rotationSpeed * dt);
    }
  }

  void moveForward(double distance) {
    final forward = Vector3(0, 0, 1)
      ..applyQuaternion(rotation)
      ..scale(distance);
    position += forward;
    game.camera.position += forward;
    game.camera.target.setFrom(position + Vector3(0, 1, 0));
  }

  void moveRight(double distance) {
    angle += distance;
    rotation.x = sin(angle / 2) * 0;
    rotation.y = sin(angle / 2) * 1;
    rotation.z = sin(angle / 2) * 0;
    rotation.w = cos(angle / 2);
  }

  static const moveSpeed = 5;
  static const rotationSpeed = 2;
}
