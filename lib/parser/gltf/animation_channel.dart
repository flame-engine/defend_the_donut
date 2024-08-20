import 'package:defend_the_donut/parser/gltf/animation_target.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/sampler.dart';

class AnimationChannel extends GltfNode {
  /// The reference to a sampler in this animation used to compute the value for the target, e.g., a node's translation, rotation, or scale (TRS).
  final GltfRef<Sampler> sampler;

  /// The descriptor of the animated property.
  final AnimationTarget target;

  AnimationChannel({
    required super.root,
    required this.sampler,
    required this.target,
  });

  AnimationChannel.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          sampler: Parser.ref(root, map, 'sampler')!,
          target: Parser.object(root, map, 'target', AnimationTarget.parse)!,
        );
}
