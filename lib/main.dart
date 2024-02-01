import 'dart:async';
import 'dart:ui';

import 'package:space_nico/keyboard_controlled_camera.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/simple_hud.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame, GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show runApp, Listener;

// TODO(wolfen): we need surfaces!! I AM WORKING ON IT

class ExampleGame3D extends FlameGame<World3D>
    with HasKeyboardHandlerComponents {
  ExampleGame3D()
      : super(
          world: World3D(),
          camera: KeyboardControlledCamera(
            hudComponents: [SimpleHud()],
          ),
        );

  @override
  KeyboardControlledCamera get camera =>
      super.camera as KeyboardControlledCamera;

  @override
  FutureOr<void> onLoad() async {
    final speeder = await ObjParser.parse('objects/craft_speederA.obj');
    print(speeder.material);

    world.addAll([
      MeshComponent(mesh: speeder),

      // Floor
      MeshComponent(
        mesh: PlaneMesh(
          size: Vector2(32, 32),
          material: StandardMaterial(
            albedoTexture: ColorTexture(const Color(0xFF9E9E9E)),
          ),
        ),
      ),
    ]);
  }
}

void main() {
  final example = ExampleGame3D();

  runApp(
    Listener(
      onPointerMove: (event) {
        if (!event.down) {
          return;
        }
        example.camera.pointerEvent = event;
      },
      onPointerSignal: (event) {
        if (event is! PointerScrollEvent || !event.down) {
          return;
        }
        example.camera.scrollMove = event.delta.dy / 3000;
      },
      onPointerUp: (event) => example.camera.pointerEvent = null,
      onPointerCancel: (event) => example.camera.pointerEvent = null,
      child: GameWidget(game: example),
    ),
  );
}
