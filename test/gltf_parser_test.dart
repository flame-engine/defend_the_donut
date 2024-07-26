import 'package:defend_the_donut/parser/glb_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gltf parser test', () {
    test('simple test', () async {
      WidgetsFlutterBinding.ensureInitialized();

      final result = await GlbParser.parseGlb('objects/cube.glb');
      final root = result.parse();

      expect(root.scenes.length, 1);
      final scene = root.scenes[0];

      final meshes = scene.toFlameMeshes();
      print(meshes.length);
      // expect(meshes.length, 80);

      final node = scene.nodes[0].get().children[0].get();
      final prim = node.mesh!.get().primitives[0];
      print(prim.toFlameVertices());

      final mesh = meshes[0];
      final surface = mesh.copySurfaces()[0];
      final aabb = surface.aabb;
      print(aabb);
    });
  });
}
