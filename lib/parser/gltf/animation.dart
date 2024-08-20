import 'package:defend_the_donut/parser/gltf/animation_channel.dart';
import 'package:defend_the_donut/parser/gltf/animation_sampler.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';

class Animation extends GltfNode {
  /// An array of animation channels.
  /// An animation channel combines an animation sampler with a target property being animated.
  /// Different channels of the same animation **MUST NOT** have the same targets.
  final List<AnimationChannel> channels;

  /// An array of animation samplers.
  /// An animation sampler combines timestamps with a sequence of output values and defines an interpolation algorithm.
  final List<AnimationSampler> samplers;

  Animation({
    required super.root,
    required this.channels,
    required this.samplers,
  });

  Animation.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          channels: Parser.objectList(
            root,
            map,
            'channels',
            AnimationChannel.parse,
          )!,
          samplers: Parser.objectList(
            root,
            map,
            'samplers',
            AnimationSampler.parse,
          )!,
        );
}
