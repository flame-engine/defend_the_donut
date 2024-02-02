import 'dart:async';

import 'package:flame_3d/resources.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:space_nico/keyboard_controlled_camera.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/pause_menu.dart';
import 'package:space_nico/simple_hud.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' show FlameGame, GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';

class ExampleGame3D extends FlameGame<World3D>
    with CanPause, HasKeyboardHandlerComponents {
  ExampleGame3D()
      : super(
          world: World3D(),
          camera: KeyboardControlledCamera(
            hudComponents: [SimpleHud(), PauseMenu()],
          ),
        );

  @override
  KeyboardControlledCamera get camera =>
      super.camera as KeyboardControlledCamera;

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      pause();
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  FutureOr<void> onLoad() async {
    final speederA = await ObjParser.parse('objects/craft_speederA.obj');
    final speederB = await ObjParser.parse('objects/craft_speederB.obj');
    final speederC = await ObjParser.parse('objects/craft_speederC.obj');
    final speederD = await ObjParser.parse('objects/craft_speederD.obj');

    world.addAll([
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
}

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  final game = ExampleGame3D();

  bool discardDelta = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      return;
    }

    if (!game.isGamePaused) {
      game.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) async {
        if (game.isGamePaused || !event.down) {
          return;
        }

        // Discard the first delta as it might be way out there.
        final delta = await game.lock.lastPointerDelta();
        if (discardDelta) {
          discardDelta = false;
          return;
        }
        game.camera.pointerDelta = delta;
      },
      onPointerUp: (_) => discardDelta = true,
      onPointerCancel: (_) => discardDelta = true,
      child: GameWidget(game: game),
    );
  }
}
