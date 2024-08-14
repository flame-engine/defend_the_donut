import 'package:defend_the_donut/parser/gltf/accessor.dart';
import 'package:defend_the_donut/parser/gltf/buffer.dart';
import 'package:defend_the_donut/parser/gltf/buffer_view.dart';
import 'package:defend_the_donut/parser/gltf/camera.dart';
import 'package:defend_the_donut/parser/gltf/glb_chunk.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/image.dart';
import 'package:defend_the_donut/parser/gltf/material.dart';
import 'package:defend_the_donut/parser/gltf/mesh.dart';
import 'package:defend_the_donut/parser/gltf/node.dart';
import 'package:defend_the_donut/parser/gltf/sampler.dart';
import 'package:defend_the_donut/parser/gltf/scene.dart';
import 'package:defend_the_donut/parser/gltf/skin.dart';
import 'package:defend_the_donut/parser/gltf/texture.dart';
import 'package:flame_3d/resources.dart' as flame_3d;

class GltfRoot {
  late final List<RawAccessor> accessors;
  late final List<BufferView> bufferViews;
  late final List<Buffer> buffers;

  late final int scene;
  late final List<Scene> scenes;

  late final List<Node> nodes;
  late final List<Camera> cameras;
  late final List<Skin> skins;
  late final List<Mesh> meshes;
  late final List<Material> materials;
  late final List<Texture> textures;
  late final List<Sampler> samplers;

  late final List<Image> images;

  late final List<GlbChunk> chunks;

  // TODO: add animations, extensionsUsed, extensionsRequired

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
      const (Texture) => textures[index],
      const (Sampler) => samplers[index],
      const (Image) => images[index],
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

  Future<void> init(Map<String, dynamic> json) async {
    List<T> parse<T>(
      String key,
      T Function(GltfRoot, Map<String, Object?>) parser,
    ) {
      return Parser.objectList(this, json, key, parser) ?? [];
    }

    accessors = parse('accessors', RawAccessor.parse);
    bufferViews = parse('bufferViews', BufferView.parse);
    buffers = parse('buffers', Buffer.parse);

    scenes = parse('scenes', Scene.parse);
    scene = Parser.integer(json, 'scene')!;

    nodes = parse('nodes', Node.parse);
    cameras = parse('cameras', Camera.parse);
    skins = parse('skins', Skin.parse);
    meshes = parse('meshes', Mesh.parse);
    materials = parse('materials', Material.parse);
    textures = parse('textures', Texture.parse);
    samplers = parse('samplers', Sampler.parse);

    images = parse('images', Image.parse);
    for (final image in images) {
      await image.init();
    }
  }

  List<flame_3d.Mesh> toFlameMeshes([int? scene]) {
    return scenes[scene ?? this.scene].toFlameMeshes();
  }
}
