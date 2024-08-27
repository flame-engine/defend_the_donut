import 'package:defend_the_donut/parser/model_parser.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const double _epsilon = 0.0001;

void main() {
  group('gltf parser test', () {
    test('simple test', () async {
      WidgetsFlutterBinding.ensureInitialized();

      final root = await ModelParser.glb.parseRoot('objects/cube.glb');

      expect(root.scenes.length, 1);
      final scene = root.scenes[0];

      final nodes = scene.toFlameNodes();
      expect(nodes.length, 2);

      final node = nodes.values.last;
      final mesh = node.mesh!;
      final aabb = mesh.aabb;
      expect(aabb.min, closeToVector3(Vector3.all(-1), _epsilon));
      expect(aabb.max, closeToVector3(Vector3.all(1), _epsilon));
    });
  });
}
