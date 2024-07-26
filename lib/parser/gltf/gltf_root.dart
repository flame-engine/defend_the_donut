import 'package:defend_the_donut/parser/gltf/accessor.dart';
import 'package:defend_the_donut/parser/gltf/buffer.dart';
import 'package:defend_the_donut/parser/gltf/buffer_view.dart';
import 'package:defend_the_donut/parser/gltf/camera.dart';
import 'package:defend_the_donut/parser/gltf/glb_chunk.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/material.dart';
import 'package:defend_the_donut/parser/gltf/mesh.dart';
import 'package:defend_the_donut/parser/gltf/node.dart';
import 'package:defend_the_donut/parser/gltf/scene.dart';
import 'package:defend_the_donut/parser/gltf/skin.dart';

class GltfRoot {
  late final List<RawAccessor> accessors;
  late final List<BufferView> bufferViews;
  late final List<Buffer> buffers;

  late final List<Camera> cameras;
  late final List<Material> materials;
  late final List<Mesh> meshes;
  late final List<Node> nodes;
  late final List<Skin> skins;

  late final int scene;
  late final List<Scene> scenes;

  late final List<GlbChunk> chunks;

  // TODO: add textures, samplers, images, animations, extensionsUsed, extensionsRequired

  T resolve<T extends GltfNode>(int index) {
    return switch (T) {
      const (Scene) => scenes[index],
      const (Node) => nodes[index],
      const (Mesh) => meshes[index],
      const (Material) => materials[index],
      const (Camera) => cameras[index],
      const (Skin) => skins[index],
      const (BufferView) => bufferViews[index],
      const (Buffer) => buffers[index],
      const (IntAccessor) => IntAccessor(
          root: this,
          accessor: accessors[index],
        ),
      const (Vector3Accessor) => Vector3Accessor(
          root: this,
          accessor: accessors[index],
        ),
      const (Vector2Accessor) => Vector2Accessor(
          root: this,
          accessor: accessors[index],
        ),
      const (RawAccessor) => accessors[index],
      _ => throw UnimplementedError('Cannot resolve type $T')
    } as T;
  }
}
