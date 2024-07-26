import 'package:defend_the_donut/parser/glb_parser.dart';
import 'package:flame_3d/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame_test/flame_test.dart';

const double _epsilon = 0.0001;

void main() {
  group('gltf parser test', () {
    test('simple test', () async {
      WidgetsFlutterBinding.ensureInitialized();

      final result = await GlbParser.parseGlb('objects/cube.glb');
      final root = result.parse();

      expect(root.scenes.length, 1);
      final scene = root.scenes[0];

      final meshes = scene.toFlameMeshes();
      expect(meshes.length, 1);

      final mesh = meshes[0];

      final surface = mesh.surfaces.toList()[0];
      final aabb = surface.aabb;
      expect(aabb.min, closeToVector3(Vector3.all(-1), _epsilon));
      expect(aabb.max, closeToVector3(Vector3.all(1), _epsilon));
    });
  });
}
