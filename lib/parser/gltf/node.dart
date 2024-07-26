import 'package:defend_the_donut/parser/gltf/camera.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/mesh.dart';
import 'package:defend_the_donut/parser/gltf/skin.dart';
import 'package:defend_the_donut/parser/gltf/utils.dart';
import 'package:flame_3d/extensions.dart';
import 'package:flame_3d/resources.dart' as flame_3d;

/// A node in the node hierarchy.
///
/// When the node contains `skin`, all `mesh.primitives` **MUST** contain `JOINTS_0` and `WEIGHTS_0` attributes.
///
/// A node **MAY** have either a `matrix` or any combination of `translation`/`rotation`/`scale` (TRS) properties.
/// TRS properties are converted to matrices and postmultiplied in the `T * R * S` order to compose the transformation matrix;
/// first the scale is applied to the vertices, then the rotation, and then the translation.
/// If none are provided, the transform is the identity.
///
/// When a node is targeted for animation (referenced by an animation.channel.target), `matrix` **MUST NOT** be present.
class Node extends GltfNode {
  /// The reference to the camera referenced by this node.
  final GltfRef<Camera>? camera;

  /// The references to this node's children.
  final List<GltfRef<Node>> children;

  /// The reference to the skin referenced by this node.
  /// When a skin is referenced by a node within a scene, all joints used by the skin **MUST** belong to the same scene.
  /// When defined, `mesh` **MUST** also be defined.
  final GltfRef<Skin>? skin;

  /// A floating-point 4x4 transformation matrix stored in column-major order.
  final Matrix4? matrix;

  /// The reference to the mesh in this node.
  final GltfRef<Mesh>? mesh;

  /// The node's unit quaternion rotation in the order (x, y, z, w), where w is the scalar.
  final Vector4 rotation;

  /// The node's non-uniform scale, given as the scaling factors along the x, y, and z axes.
  final Vector3 scale;

  /// The node's translation along the x, y, and z axes.".
  final Vector3 translation;

  /// The weights of the instantiated morph target.
  /// The number of array elements **MUST** match the number of morph targets of the referenced mesh.
  /// When defined, `mesh` **MUST** also be defined.
  final List<double>? weights;

  Node({
    required super.root,
    required this.camera,
    required this.children,
    required this.skin,
    required this.matrix,
    required this.mesh,
    required this.rotation,
    required this.scale,
    required this.translation,
    required this.weights,
  }); 

  Node.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          camera: Parser.ref(root, map, 'camera'),
          children: Parser.refList(root, map, 'children') ?? [],
          skin: Parser.ref(root, map, 'skin'),
          matrix: Parser.matrix4(root, map, 'matrix'),
          mesh: Parser.ref(root, map, 'mesh'),
          rotation: Parser.vector4(root, map, 'rotation') ?? Vector4(0, 0, 0, 1),
          scale: Parser.vector3(root, map, 'scale') ?? Vector3(1, 1, 1),
          translation: Parser.vector3(root, map, 'translation') ?? Vector3.zero(),
          weights: Parser.floatList(root, map, 'weights'),
        );

  List<flame_3d.Mesh> toFlameMeshes() {
    final meshes = [
      mesh?.get().toFlameMesh(),
      ...children.expand((e) => e.get().toFlameMeshes()),
    ];
    return meshes.filterNotNull();
  }
}