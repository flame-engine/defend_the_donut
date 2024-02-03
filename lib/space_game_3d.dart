import 'dart:async';

import 'package:flame_3d/resources.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:space_nico/hud/crosshair.dart';
import 'package:space_nico/keyboard_controlled_camera.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/hud/pause_menu.dart';
import 'package:space_nico/hud/simple_hud.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:space_nico/components/pew.dart';

class SpaceGame3D extends FlameGame<SpaceWorld3D>
    with CanPause, HasKeyboardHandlerComponents {
  SpaceGame3D()
      : super(
          world: SpaceWorld3D(),
          camera: KeyboardControlledCamera(
            hudComponents: [SimpleHud(), Crosshair(), PauseMenu()],
          ),
        );

  @override
  KeyboardControlledCamera get camera =>
      super.camera as KeyboardControlledCamera;

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      pause();
    }
    return super.onKeyEvent(event, keysPressed);
  }
}

class SpaceWorld3D extends World3D with TapCallbacks {
  KeyboardControlledCamera get camera => findParent<SpaceGame3D>()!.camera;

  @override
  FutureOr<void> onLoad() async {
    final speederA = await ObjParser.parse('objects/craft_speederA.obj');
    final speederB = await ObjParser.parse('objects/craft_speederB.obj');
    final speederC = await ObjParser.parse('objects/craft_speederC.obj');
    final speederD = await ObjParser.parse('objects/craft_speederD.obj');

    await addAll([
      MeshComponent(mesh: speederA, position: Vector3(-4.5, 0, 0)),
      MeshComponent(mesh: speederB, position: Vector3(-1.5, 0, 0)),
      MeshComponent(mesh: speederC, position: Vector3(1.5, 0, 0)),
      MeshComponent(mesh: speederD, position: Vector3(4.5, 0, 0)),

      // Floor
      MeshComponent(
        position: Vector3(0, -1, 0),
        mesh: PlaneMesh(
          size: Vector2(32, 32),
          material: StandardMaterial(
            albedoTexture: ColorTexture(const Color(0xFF9E9E9E)),
          ),
        ),
      ),
    ]);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print('pew pew!');
    add(
      Pew(
        speed: camera.forward.normalized() * 10,
        position: camera.position.clone(),
      ),
    );
  }
}